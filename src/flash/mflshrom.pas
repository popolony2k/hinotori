(*<mflshrom.pas>
 * MegaFlashROM routines for using with MegaFlashROM cards.
 *
 * Boards compatibility:
 *
 * - Konami4 (AM29F040B chipset);
 *
 * CopyLeft (c) 1995-2024 by PopolonY2k.
 * CopyLeft (c) since 2024 by Hinotori Team.
 *)

(*
 * This module depends on folowing include files (respect the order):
 * - /system/types.pas;
 * - /bios/msxbios.pas;
 *)

(*
 * Module constants.
 *)
const
       ctAM29F040BDeviceId      = $A4;        { Device ID for AM29F040B       }
       ctAM29F040BWriteAddr1    = $4555;      { AM29F040B cmd address 1       }
       ctAM29F040BWriteAddr2    = $42AA;      { AM29F040B cmd address 2       }

       ctAM29F040BManIdAddr     = $4000;      { AM29F040B manufacturer Id     }
       ctAM29F040BDevIdAddr     = $4001;      { AM29F040B device Id           }
       ctAM29F040BSecProtect    = $4001;      { AM29F040B sector protection   }

       ctKonami4Bank1           = $4000;      { Konami4 Bank 1 No selectable  }
       ctKonami4Bank2           = $6000;      { Konami4 Bank 2 sel. register  }
       ctKonami4Bank3           = $8000;      { Konami4 Bank 3 sel. register  }
       ctKonami4Bank4           = $A000;      { Konami4 Bank 4 sel. register  }

       ctMegaFlashROMBankSize   = $2000;      { MFlashROM bank size           }
       ctMaxMegaFlashROMBankSel = $03;        { Max. MFlashROM bank selection }

(**
  * ROM types.
  *)
type TROMType = ( Konami4,
                  KonamiSCC,
                  ASCII8,
                  ASCII16,
                  UnknownROM );

(**
  * Flash operation status.
  *)
type TFlashStatus = ( FlashReset,        { Internal status use }
                      FlashSuccess,
                      FlashWriteError,
                      FlashEraseError,
                      FlashPollingError,
                      FlashSelectionError,
                      FlashInvalidMapperType,
                      FlashInvalidBankSelection );

(**
  * Flash ROM operation handle.
  *)
type TFlashHandle = record
  nSlot       : TSlotNumber;       { MFR Slot number }
  romType     : TROMType;          { ROM type        }
end;

(*
 * MSX slot related memory addresses used by local internal functions.
 * Do not use it in your software (for internal use only).
 *)
var
     __aSLTTBL  : array[0..ctMaxSecSlots] of byte absolute $FCC5;
     __aRAMAD   : array[0..ctMaxSecSlots] of byte absolute $F341;


(* Routines for internal module use only *)

(**
  * Performs a flash polling, looking for the status of the last
  * memory write I/O or erase operation.
  * @param nFlshAddr The address whose the last operation was executed
  * in the flash rom;
  * @param nSrcAddr The source address to compare data to Flash address;
  * @param nBankSelAddr The flash 8Kb bank selection number (0..3);
  * @param nBankId The Id for the selected bank;
  * @param bDataPolling Flag informing if data polling will be performed;
  * There are some cases where data polling is not available.
  *  1) Erase process;
  *  2) Data writing on the first Konami4 megarom bank;
  *)
function __FlashPolling( nFlshAddr,
                         nSrcAddr,
                         nBankSelAddr : integer;
                         nBankId      : byte;
                         bDataPolling : boolean ) : TFlashStatus;
var
       status : TFlashStatus;
       nData  : byte;

begin
  status := FlashReset;

  repeat
    (*
     * Check the AM29F040B Datasheet, for these statuses below at
     * Page 16 (Figure 3).
     *)
    nData := Mem[nFlshAddr];

    if( ( nData and $80 ) = ( Mem[nSrcAddr] and $80 ) ) then
      status := FlashSuccess
    else
    begin
      if( ( nData and $20 ) = $20 )  then
      begin
        (*
         * Select bank before new a data reading.
         *)
        if( bDataPolling )  then
          Mem[nBankSelAddr] := nBankId;

        if( ( Mem[nFlshAddr] and $80 ) = ( Mem[nSrcAddr] and $80 ) ) then
          status := FlashSuccess
        else
          status := FlashPollingError;
      end
      else
        (*
         * Select bank before new a data reading.
         *)
        if( bDataPolling )  then
          Mem[nBankSelAddr] := nBankId;
    end;
  until( status in [FlashSuccess, FlashPollingError] );

  __FlashPolling := status;
end;

(* User routines *)

(**
  * Search for the MegaFlashROM device for reading/writing operations.
  * @param handle Reference to the MegaFlashROM structure handle with
  * information to be returned, about the connected device;
  *)
function FindMFR( var handle : TFlashHandle ) : boolean;
var
        nSlotNumber      : TSlotNumber;
        nPrimarySlot     : TSlotNumber;
        nSecondarySlot   : TSlotNumber;
        nPriRAMSlotPage1 : TSlotNumber;
        nSecRAMSlotPage1 : TSlotNumber;
        bResult          : boolean;

begin
  (* Save current RAM slot *)
  nPriRAMSlotPage1 := __aRAMAD[1];
  nSecRAMSlotPage1 := ( __aSLTTBL[1] and $0C );
  nPrimarySlot := 0;
  bResult := false;

  (* Search for the MFR slot *)
  repeat
    nSecondarySlot := 0;

    repeat
      nSlotNumber := MakeSlotNumber( nPrimarySlot, nSecondarySlot );

      (* Enable page 1 at specified slot *)
      ENASLT( nSlotNumber, 1 );

      inline( $F3 );       { DI }
      Mem[$4000] := $F0;                  { Write reset }

      (*
       * Activate the autoselect mode for the AM29F040B chip.
       * Please check the command below at AM29F040B Datasheet
       * (Table 4. AM29F040 command definitions - Page 9).
       *)
      Mem[ctAM29F040BWriteAddr1] := $AA;  { Autoselect mode on }
      Mem[ctAM29F040BWriteAddr2] := $55;
      Mem[ctAM29F040BWriteAddr1] := $90;

      (*
       * Data information about the selected device.
       * $4000 - Manufacturer Id.
       * $4001 - Device Id.
       *)
      bResult := ( ( Mem[ctAM29F040BManIdAddr] = 01 ) and
                   ( Mem[ctAM29F040BDevIdAddr] = ctAM29F040BDeviceId ) );

      if( not bResult )  then
        nSecondarySlot := nSecondarySlot + 1;
      inline( $FB );       { EI }
    until( bResult or ( nSecondarySlot = ctMaxSecSlots ) );

    if( not bResult )  then
      nPrimarySlot := nPrimarySlot + 1;
  until( bResult or ( nPrimarySlot = ctMaxSlots ) );

  if( not bResult )  then
  begin
    handle.nSlot   := ctUnitializedSlot;
    handle.romType := UnknownROM;
  end
  else
  begin
    handle.nSlot   := nSlotNumber;
    handle.romType := Konami4;
  end;

  FindMFR := bResult;
end;

(**
  * Erase whole flash memory.
  * @param handle Reference to the MegaFlashROM structure handle with
  * information about the connected device;
  *)
function EraseMFR( var handle : TFlashHandle ) : TFlashStatus;
var
        nPriRAMSlotPage1,
        nSecRAMSlotPage1 : TSlotNumber;
        nEraseStatus     : byte;
        status           : TFlashStatus;

begin
  if( handle.nSlot <> ctUnitializedSlot )  then
  begin
    (* Save current RAM slot *)
    nPriRAMSlotPage1 := __aRAMAD[1];
    nSecRAMSlotPage1 := ( __aSLTTBL[1] and $0C );
    nEraseStatus     := $FF;

    inline( $F3 );       { DI }
    Mem[$4000] := $F0;                   { Write reset }

    (*
     * Erase whole Flash.
     * Please check the command below at AM29F040B Datasheet
     * (Table 4. AM29F040 command definitions - Page 9).
     *)
    Mem[ctAM29F040BWriteAddr1] := $AA;   { Chip erase }
    Mem[ctAM29F040BWriteAddr2] := $55;
    Mem[ctAM29F040BWriteAddr1] := $80;
    Mem[ctAM29F040BWriteAddr1] := $AA;
    Mem[ctAM29F040BWriteAddr2] := $55;
    Mem[ctAM29F040BWriteAddr1] := $10;

    (* Check data written status *)
    status := __FlashPolling( $4000, Addr( nEraseStatus ), 0, 0, false );
    inline( $FB );       { EI }

    (* Restore the original RAM slot for page 1 *)
    ENASLT( MakeSlotNumber( nPriRAMSlotPage1, nSecRAMSlotPage1 ), 1 );
  end
  else
    status := FlashEraseError;

  EraseMFR := status;
end;

 (**
  * Write a buffer to flash.
  * @param handle Reference to the MegaFlashROM structure handle with
  * information about the connected device;
  * @param buffer The source buffer containing the data to be transferred.
  * @param nFlashPos Reference to the relative address in the flash memory
  * where the data will be saved;
  * @param nSize The buffer size;
  * @param nBankSel The flash 8Kb bank selection number (0..3);
  * @param nBankId The Id for the selected bank;
  *)
function WriteToMFR( var handle : TFlashHandle;
                     var buffer;
                     var nFlashPos : integer;
                     nSize : integer;
                     nBankSel,
                     nBankId : byte ) : TFlashStatus;
var
       bDataPolling  : boolean;
       nCount        : integer;
       nBufferAddr   : integer;
       nFlshAddr     : integer;
       nBankSelAddr  : integer;
       status        : TFlashStatus;
       nPriSlotPage1 : TSlotNumber;
       nPriSlotPage2 : TSlotNumber;
       nSecSlotPage1 : TSlotNumber;
       nSecSlotPage2 : TSlotNumber;

begin
  if( handle.nSlot <> ctUnitializedSlot )  then
  begin
    status := FlashSuccess;
    bDataPolling := true;

    if( nBankSel > ctMaxMegaFlashROMBankSel )  then
      status := FlashInvalidBankSelection
    else
      case handle.romType of
        Konami4 :  begin
                     case nBankSel of
                       0 : begin
                             nBankSelAddr := ctKonami4Bank1;
                             bDataPolling := false;
                           end;
                       1 : nBankSelAddr := ctKonami4Bank2;
                       2 : nBankSelAddr := ctKonami4Bank3;
                       3 : nBankSelAddr := ctKonami4Bank4;
                     end;
                   end;
        else
          status := FlashInvalidMapperType;
      end;

    if( status = FlashSuccess ) then
    begin
      nFlshAddr   := ( nBankSelAddr + nFlashPos );
      nBufferAddr := Addr( buffer );
      nCount      := 0;

      (* Save current RAM slot *)
      nPriSlotPage1 := __aRAMAD[1];
      nPriSlotPage2 := __aRAMAD[2];
      nSecSlotPage1 := ( __aSLTTBL[1] and $0C );
      nSecSlotPage2 := ( __aSLTTBL[2] and $30 );

      (* Enable MFR pages 1 & 2 to RAM *)
      ENASLT( handle.nSlot, 1 );

      if( nBankSel > 1 )  then
        ENASLT( handle.nSlot, 2 );

      inline( $F3 );       { DI }

      while( ( nCount <> nSize ) and ( status = FlashSuccess ) ) do
      begin
        (*
         * Byte programming.
         * Please check the command below at AM29F040B Datasheet
         * (Table 4. AM29F040 command definitions - Page 9 and 14 (Figure 1)).
         *)
        Mem[nBankSelAddr]          := nBankId; { Select bank id for this data }
        Mem[ctAM29F040BWriteAddr1] := $AA;     { Write byte to flash rom      }
        Mem[ctAM29F040BWriteAddr2] := $55;
        Mem[ctAM29F040BWriteAddr1] := $A0;
        Mem[nFlshAddr] := Mem[nBufferAddr];

        (* Check data written status *)
        status := __FlashPolling( nFlshAddr,
                                  nBufferAddr,
                                  nBankSelAddr,
                                  nBankId,
                                  bDataPolling );

        if( status = FlashSuccess )  then
        begin
          nCount      := Succ( nCount );
          nFlshAddr   := Succ( nFlshAddr );
          nBufferAddr := Succ( nBufferAddr );
        end;
      end;

      nFlashPos := ( nFlashPos + nCount );

      inline( $FB );       { EI }

      (* Restore RAM to pages 1 & 2 *)
      ENASLT( MakeSlotNumber( nPriSlotPage1, nSecSlotPage1 ) , 1 );

       if( nBankSel > 1 )  then
        ENASLT( MakeSlotNumber( nPriSlotPage2, nSecSlotPage2 ) , 2 );
    end;
  end
  else
    status := FlashWriteError;

  WriteToMFR := status;
end;

(**
  * Select the MegaFlashROM ROM starting pages.
  * @param handle Reference to the MegaFlashROM structure handle with
  * information about the connected device;
  * @param bReset Flag to inform if the machine will be restarted after
  * the pages selecting;
  *)
function SelectInitialMFRPages( var handle : TFlashHandle;
                                bReset : boolean ) : TFlashStatus;
var
       nCount        : byte;
       aBankSelAddr  : array[0..ctMaxMegaFlashROMBankSel] of integer;
       status        : TFlashStatus;
       nPriSlotPage1 : TSlotNumber;
       nPriSlotPage2 : TSlotNumber;
       nSecSlotPage1 : TSlotNumber;
       nSecSlotPage2 : TSlotNumber;
       regs          : TRegs;

begin
  if( handle.nSlot <> ctUnitializedSlot )  then
  begin
    status := FlashSuccess;

    case handle.romType of
      Konami4 :  begin
                   aBankSelAddr[0] := 0;
                   aBankSelAddr[1] := ctKonami4Bank2;
                   aBankSelAddr[2] := ctKonami4Bank3;
                   aBankSelAddr[3] := ctKonami4Bank4;
                 end;
      else
        status := FlashInvalidMapperType;
    end;

    if( status = FlashSuccess ) then
    begin
      (* Save current RAM slot *)
      nPriSlotPage1 := __aRAMAD[1];
      nPriSlotPage2 := __aRAMAD[2];
      nSecSlotPage1 := ( __aSLTTBL[1] and $0C );
      nSecSlotPage2 := ( __aSLTTBL[2] and $30 );

      (* Enable MFR pages 1 & 2 to RAM *)
      ENASLT( handle.nSlot, 1 );
      ENASLT( handle.nSlot, 2 );

      inline( $F3 );       { DI }

      for nCount := 0 to ctMaxMegaFlashROMBankSel do
      begin
        if( aBankSelAddr[nCount] <> 0 )  then
          Mem[aBankSelAddr[nCount]] := nCount;
      end;

      inline( $FB );       { EI }

      (* Restore RAM to pages 1 & 2 *)
      ENASLT( MakeSlotNumber( nPriSlotPage1, nSecSlotPage1 ) , 1 );
      ENASLT( MakeSlotNumber( nPriSlotPage2, nSecSlotPage2 ) , 2 );

      (* Reset the machine - See CHKRAM BIOS call *)
      if( bReset )  then
      begin
        FillChar( regs, sizeof( regs ), 0 );
        CALSLT( regs );
      end;
    end;
  end
  else
    status := FlashSelectionError;

  SelectInitialMFRPages := status;
end;
