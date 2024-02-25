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
Const
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
Type TROMType = ( Konami4,
                  KonamiSCC,
                  ASCII8,
                  ASCII16,
                  UnknownROM );

(**
  * Flash operation status.
  *)
Type TFlashStatus = ( FlashReset,        { Internal status use }
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
Type TFlashHandle = Record
  nSlot       : TSlotNumber;       { MFR Slot number }
  romType     : TROMType;          { ROM type        }
End;

(*
 * MSX slot related memory addresses used by local internal functions.
 * Do not use it in your software (for internal use only).
 *)
Var
     __aSLTTBL  : Array[0..ctMaxSecSlots] Of Byte Absolute $FCC5;
     __aRAMAD   : Array[0..ctMaxSecSlots] Of Byte Absolute $F341;


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
Function __FlashPolling( nFlshAddr,
                         nSrcAddr,
                         nBankSelAddr : Integer;
                         nBankId      : Byte;
                         bDataPolling : Boolean ) : TFlashStatus;
Var
       status : TFlashStatus;
       nData  : Byte;

Begin
  status := FlashReset;

  Repeat
    (*
     * Check the AM29F040B Datasheet, for these statuses below at
     * Page 16 (Figure 3).
     *)
    nData := Mem[nFlshAddr];

    If( ( nData And $80 ) = ( Mem[nSrcAddr] And $80 ) ) Then
      status := FlashSuccess
    Else
    Begin
      If( ( nData And $20 ) = $20 )  Then
      Begin
        (*
         * Select bank before new a data reading.
         *)
        If( bDataPolling )  Then
          Mem[nBankSelAddr] := nBankId;

        If( ( Mem[nFlshAddr] And $80 ) = ( Mem[nSrcAddr] And $80 ) ) Then
          status := FlashSuccess
        Else
          status := FlashPollingError;
      End
      Else
        (*
         * Select bank before new a data reading.
         *)
        If( bDataPolling )  Then
          Mem[nBankSelAddr] := nBankId;
    End;
  Until( status In [FlashSuccess, FlashPollingError] );

  __FlashPolling := status;
End;

(* User routines *)

(**
  * Search for the MegaFlashROM device for reading/writing operations.
  * @param handle Reference to the MegaFlashROM structure handle with
  * information to be returned, about the connected device;
  *)
Function FindMFR( Var handle : TFlashHandle ) : Boolean;
Var
        nSlotNumber      : TSlotNumber;
        nPrimarySlot     : TSlotNumber;
        nSecondarySlot   : TSlotNumber;
        nPriRAMSlotPage1 : TSlotNumber;
        nSecRAMSlotPage1 : TSlotNumber;
        bResult          : Boolean;

Begin
  (* Save current RAM slot *)
  nPriRAMSlotPage1 := __aRAMAD[1];
  nSecRAMSlotPage1 := ( __aSLTTBL[1] And $0C );
  nPrimarySlot := 0;
  bResult := False;

  (* Search for the MFR slot *)
  Repeat
    nSecondarySlot := 0;

    Repeat
      nSlotNumber := MakeSlotNumber( nPrimarySlot, nSecondarySlot );

      (* Enable page 1 at specified slot *)
      ENASLT( nSlotNumber, 1 );

      Inline( $F3 );       { DI }
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
      bResult := ( ( Mem[ctAM29F040BManIdAddr] = 01 ) And
                   ( Mem[ctAM29F040BDevIdAddr] = ctAM29F040BDeviceId ) );

      If( Not bResult )  Then
        nSecondarySlot := nSecondarySlot + 1;
      Inline( $FB );       { EI }
    Until( bResult Or ( nSecondarySlot = ctMaxSecSlots ) );

    If( Not bResult )  Then
      nPrimarySlot := nPrimarySlot + 1;
  Until( bResult Or ( nPrimarySlot = ctMaxSlots ) );

  If( Not bResult )  Then
  Begin
    handle.nSlot   := ctUnitializedSlot;
    handle.romType := UnknownROM;
  End
  Else
  Begin
    handle.nSlot   := nSlotNumber;
    handle.romType := Konami4;
  End;

  FindMFR := bResult;
End;

(**
  * Erase whole flash memory.
  * @param handle Reference to the MegaFlashROM structure handle with
  * information about the connected device;
  *)
Function EraseMFR( Var handle : TFlashHandle ) : TFlashStatus;
Var
        nPriRAMSlotPage1,
        nSecRAMSlotPage1 : TSlotNumber;
        nEraseStatus     : Byte;
        status           : TFlashStatus;

Begin
  If( handle.nSlot <> ctUnitializedSlot )  Then
  Begin
    (* Save current RAM slot *)
    nPriRAMSlotPage1 := __aRAMAD[1];
    nSecRAMSlotPage1 := ( __aSLTTBL[1] And $0C );
    nEraseStatus     := $FF;

    Inline( $F3 );       { DI }
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
    status := __FlashPolling( $4000, Addr( nEraseStatus ), 0, 0, False );
    Inline( $FB );       { EI }

    (* Restore the original RAM slot for page 1 *)
    ENASLT( MakeSlotNumber( nPriRAMSlotPage1, nSecRAMSlotPage1 ), 1 );
  End
  Else
    status := FlashEraseError;

  EraseMFR := status;
End;

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
Function WriteToMFR( Var handle : TFlashHandle;
                     Var buffer;
                     Var nFlashPos : Integer;
                     nSize : Integer;
                     nBankSel,
                     nBankId : Byte ) : TFlashStatus;
Var
       bDataPolling  : Boolean;
       nCount        : Integer;
       nBufferAddr   : Integer;
       nFlshAddr     : Integer;
       nBankSelAddr  : Integer;
       status        : TFlashStatus;
       nPriSlotPage1 : TSlotNumber;
       nPriSlotPage2 : TSlotNumber;
       nSecSlotPage1 : TSlotNumber;
       nSecSlotPage2 : TSlotNumber;

Begin
  If( handle.nSlot <> ctUnitializedSlot )  Then
  Begin
    status := FlashSuccess;
    bDataPolling := True;

    If( nBankSel > ctMaxMegaFlashROMBankSel )  Then
      status := FlashInvalidBankSelection
    Else
      Case handle.romType Of
        Konami4 :  Begin
                     Case nBankSel Of
                       0 : Begin
                             nBankSelAddr := ctKonami4Bank1;
                             bDataPolling := False;
                           End;
                       1 : nBankSelAddr := ctKonami4Bank2;
                       2 : nBankSelAddr := ctKonami4Bank3;
                       3 : nBankSelAddr := ctKonami4Bank4;
                     End;
                   End;
        Else
          status := FlashInvalidMapperType;
      End;

    If( status = FlashSuccess ) Then
    Begin
      nFlshAddr   := ( nBankSelAddr + nFlashPos );
      nBufferAddr := Addr( buffer );
      nCount      := 0;

      (* Save current RAM slot *)
      nPriSlotPage1 := __aRAMAD[1];
      nPriSlotPage2 := __aRAMAD[2];
      nSecSlotPage1 := ( __aSLTTBL[1] And $0C );
      nSecSlotPage2 := ( __aSLTTBL[2] And $30 );

      (* Enable MFR pages 1 & 2 to RAM *)
      ENASLT( handle.nSlot, 1 );

      If( nBankSel > 1 )  Then
        ENASLT( handle.nSlot, 2 );

      Inline( $F3 );       { DI }

      While( ( nCount <> nSize ) And ( status = FlashSuccess ) ) Do
      Begin
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

        If( status = FlashSuccess )  Then
        Begin
          nCount      := Succ( nCount );
          nFlshAddr   := Succ( nFlshAddr );
          nBufferAddr := Succ( nBufferAddr );
        End;
      End;

      nFlashPos := ( nFlashPos + nCount );

      Inline( $FB );       { EI }

      (* Restore RAM to pages 1 & 2 *)
      ENASLT( MakeSlotNumber( nPriSlotPage1, nSecSlotPage1 ) , 1 );

       If( nBankSel > 1 )  Then
        ENASLT( MakeSlotNumber( nPriSlotPage2, nSecSlotPage2 ) , 2 );
    End;
  End
  Else
    status := FlashWriteError;

  WriteToMFR := status;
End;

(**
  * Select the MegaFlashROM ROM starting pages.
  * @param handle Reference to the MegaFlashROM structure handle with
  * information about the connected device;
  * @param bReset Flag to inform if the machine will be restarted after
  * the pages selecting;
  *)
Function SelectInitialMFRPages( Var handle : TFlashHandle;
                                bReset : Boolean ) : TFlashStatus;
Var
       nCount        : Byte;
       aBankSelAddr  : Array[0..ctMaxMegaFlashROMBankSel] Of Integer;
       status        : TFlashStatus;
       nPriSlotPage1 : TSlotNumber;
       nPriSlotPage2 : TSlotNumber;
       nSecSlotPage1 : TSlotNumber;
       nSecSlotPage2 : TSlotNumber;
       regs          : TRegs;

Begin
  If( handle.nSlot <> ctUnitializedSlot )  Then
  Begin
    status := FlashSuccess;

    Case handle.romType Of
      Konami4 :  Begin
                   aBankSelAddr[0] := 0;
                   aBankSelAddr[1] := ctKonami4Bank2;
                   aBankSelAddr[2] := ctKonami4Bank3;
                   aBankSelAddr[3] := ctKonami4Bank4;
                 End;
      Else
        status := FlashInvalidMapperType;
    End;

    If( status = FlashSuccess ) Then
    Begin
      (* Save current RAM slot *)
      nPriSlotPage1 := __aRAMAD[1];
      nPriSlotPage2 := __aRAMAD[2];
      nSecSlotPage1 := ( __aSLTTBL[1] And $0C );
      nSecSlotPage2 := ( __aSLTTBL[2] And $30 );

      (* Enable MFR pages 1 & 2 to RAM *)
      ENASLT( handle.nSlot, 1 );
      ENASLT( handle.nSlot, 2 );

      Inline( $F3 );       { DI }

      For nCount := 0 To ctMaxMegaFlashROMBankSel Do
      Begin
        If( aBankSelAddr[nCount] <> 0 )  Then
          Mem[aBankSelAddr[nCount]] := nCount;
      End;

      Inline( $FB );       { EI }

      (* Restore RAM to pages 1 & 2 *)
      ENASLT( MakeSlotNumber( nPriSlotPage1, nSecSlotPage1 ) , 1 );
      ENASLT( MakeSlotNumber( nPriSlotPage2, nSecSlotPage2 ) , 2 );

      (* Reset the machine - See CHKRAM BIOS call *)
      If( bReset )  Then
      Begin
        FillChar( regs, SizeOf( regs ), 0 );
        CALSLT( regs );
      End;
    End;
  End
  Else
    status := FlashSelectionError;

  SelectInitialMFRPages := status;
End;
