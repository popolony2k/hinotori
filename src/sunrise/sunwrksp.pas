(*<sunwrksp.pas>
 * MSX-IDE functions library implementation (Sunrise-like) to
 * manage IDE memory workspace.
 * CopyLeft (c) 1995-2024 by PopolonY2k.
 * CopyLeft (c) since 2024 by Hinotori Team.
 *)

(*
 * This source file depends on following include files (respect the order):
 * - /system/memory.pas;
 * - /system/types.pas;
 * - /bios/msxbios.pas;
 * - /bit/bitwise.pas;
 * - /sunrise/suntypes.pas;
 * - /slot/sltsrch.pas;
 *)

(* Constants, Types and strucutres of MSX IDE library *)

const    ctDefaultWrkspcPage        = 3;      { Default workspace slot page }
         ctBIOSMajorVerAddr         = $7FB6;  { BIOS major version address }
         ctBIOSMinorVerAddr         = $7FB7;  { BIOS minor version address }
         ctBIOSRevisionAddr         = $7FB8;  { BIOS revision version address }
         ctIDESignatureAddr         = $7F80;  { IDE signature address }

         (* Workspace BIOS Call Routines *)

         ctBIOSGetDriveFieldAddr    = $7FBF;  { Get drive field address }

         (* Device code byte values *)

         (* Bit 0 *)
         ctPartitionSlaveDevice     = $1;  { Partition on slave device }
         (* Bit 21 *)
         ctPartitionATADevice       = $0;  { Partition on ATA device HD }
         ctPartitionATAPIDevice     = $4;  { Partition on ATAPI device }
         ctPartitionATAPICDROM      = $6;  { Partition on ATAPI CDROM }
         (* Bit 3 *)
         ctPartitionMediaNotChanged = $8;  { Partition medium not changed }
         (* Bit 4 *)
         ctPartitionNotInUse        = $10; { Partition in use or disabled }
         (* Bit 5 *)
         ctDriveLockedByProgram     = $20; { Drive locked by external program }

         (* Additional partition info *)

         (* Bit 0 *)
         ctPartEnabledDuringBoot    = $1;  { Partition enabled during boot }
         (* Bit 6 *)
         ctNotBootablePartition     = $40; { Partition not bootable }
         (* Bit 7 *)
         ctLogicallyNotWrProtected  = $80; { Part. not logically wr protected }

         (* Device type code byte  *)

         (* Bit 0 *)
         ctATADevice                = $1;  { Device is ATA (HD) }
         (* Bit 1 *)
         ctATAPIDevice              = $2;  { Device is ATAPI }
         (* Bit 2 *)
         ctSupportLBAAddressing     = $4;  { Device supports also LBA }
         (* Bit 43 *)
         ctGetDeviceBits            = $18; { Bit to retrieve the 43 bits }

         (* The device type 43 bits *)

         ctDirectAccessDevice       = 0;   { Device is a direct access device }
         ctDeviceIsCDROM            = 1;   { Device is a CDROM }
         ctReserved1                = 2;   { Reserved }
         ctReserved2                = 3;   { Reserved }

(* IDE Helper functions *)

(**
  * Get the IDE information like vesion and connected slot.
  * @param info Reference to info struct to receive the IDE
  * information.
  *)
procedure GetIDEInfo( var info : TIDEInfo );
var
        strSignature : string[3];
begin
  with info do
  begin
    strSignature := 'ID#';
    nSlotNumber  := FindSignature( strSignature, ctIDESignatureAddr );

    (* Get the BIOS Version *)
    if( nSlotNumber <> ctUnitializedSlot )  then
    begin
       nMajor    := RDSLT( nSlotNumber, ctBIOSMajorVerAddr );
       nMinor    := RDSLT( nSlotNumber, ctBIOSMinorVerAddr );
       nRevision := RDSLT( nSlotNumber, ctBIOSRevisionAddr );
    end;
  end;
end;

(**
  * Retrieve the device code struct for a given
  * device byte code.
  * @param nDeviceCodeByte The device byte code
  * to retrieve the struct;
  * @param dev The reference to device struct
  * that will receive the information;
  *)
procedure GetDeviceInfo( nDeviceCodeByte : byte; var dev : TDeviceInfo );
begin
  with dev do
  begin
    bPartitionIsMaster := not BitCmp( ctPartitionSlaveDevice,
                                      nDeviceCodeByte );
    bMediumChanged     := not BitCmp( ctPartitionMediaNotChanged,
                                      nDeviceCodeByte );
    bPartitionInUse    := not BitCmp( ctPartitionNotInUse,
                                      nDeviceCodeByte );
    bDriveLocked       := BitCmp( ctDriveLockedByProgram,
                                  nDeviceCodeByte );
    nPartitionLocation := ( nDeviceCodeByte and ctPartitionATAPICDROM );
  end;
end;

(**
  * Retrieve the additional partition information for a
  * given partition info byte code.
  * @param nDeviceCodeByte The partition info byte code to
  * retrieve the struct;
  * @param part The reference to additional partition
  * info struct that will receive the information;
  *)
procedure GetAdditionalPartitionInfo( nDeviceCodeByte : byte;
                                      var part : TAdditionalPartitionInfo );
begin
  with part do
  begin
    bEnabledDuringBoot       := BitCmp( ctPartEnabledDuringBoot,
                                        nDeviceCodeByte );
    bIsBootable              := not BitCmp( ctNotBootablePartition,
                                            nDeviceCodeByte );
    bLogicallyWriteProtected := not BitCmp( ctLogicallyNotWrProtected,
                                            nDeviceCodeByte );
  end;
end;

(**
  * Retrieve the device type information for a given
  * device type byte code.
  * @param nDeviceCodeByte The device type byte code;
  * @param devType The reference to Device type struct
  * that will receive the information;
  *)
procedure GetDeviceType( nDeviceCodeByte : byte; var devType : TDeviceType );
begin
  with devType do
  begin
    bIsATA   := BitCmp( ctATADevice, nDeviceCodeByte );
    bIsATAPI := BitCmp( ctATAPIDevice, nDeviceCodeByte );

    if( BitCmp( ctSupportLBAAddressing, nDeviceCodeByte ) )  then
    begin
      bSupportAlsoLBAAddressing := true;
      bUsesOnlyCHSAddressing    := false;
    end
    else
    begin
      bSupportAlsoLBAAddressing := false;
      bUsesOnlyCHSAddressing    := true;
    end;

    (* Get the bits 43 *)
    case( nDeviceCodeByte and ctGetDeviceBits ) of
      ctDirectAccessDevice : begin
                               bDirectAccess := true;
                               bIsCDROM      := false;
                             end;
      ctDeviceIsCDROM      : begin
                               bDirectAccess := false;
                               bIsCDROM      := true;
                             end;
    end;
  end;
end;

(* BIOS calls implementation *)

(**
  * Get the drive field data of specified drive field
  * id;
  * @param nDrvFldId The drive field id;
  * This parameter can be a number between :
  * 0..5 - For a valid drive field;
  * The nDriveFieldId > 5 is described below:
  * 6    - The device info bytes;
  * 7    - The freespace data;
  * The data between (0..7) represent the ide workspace area
  * @see GetIDEWorkspace();
  * @param info The IDE information required to retrieve the Drive field;
  * @result A pointer with the required drive field structure
  * previosly "automagically" allocated by the Sunrise IDE or
  * Nil if the drive field was not retrieved;
  *)
function GetDriveField( nDrvFldId : byte;
                        info  : TIDEInfo ) : PDriveField;
var
      regs          : TRegs;
      ptrDriveField : PDriveField;

begin
  ptrDriveField := nil;

  if( ( info.nSlotNumber <> ctUnitializedSlot ) and
      ( nDrvFldId <= ctDriveFieldSize ) )  then
  begin
    regs.A  := nDrvFldId;
    regs.IX := ctBIOSGetDriveFieldAddr;
    regs.IY := info.nSlotNumber;
    CALSLT( regs );

    (*
     * Point the address of Sunrise drive field to the drive field
     * pointer struct;
     *)
    ptrDriveField := Ptr( regs.HL );
  end;

  GetDriveField := ptrDriveField;
end;

(* IDE Workspace functions *)

(**
  * Get the workspace data stored at page 3 of slot that IDE
  * lives in.
  * @param info The IDE information required to retrieve the workspace;
  * @param wrkspc Reference to structure to receive the
  * workspace data;
  *)
function GetIDEWorkspace( info : TIDEInfo;
                          var wrkspc : TIDEWorkspace ) : boolean;
var
         nCount         : byte;
         bResult        : boolean;
         regs           : TRegs;

begin
  bResult := false;

  if( info.nSlotNumber <> ctUnitializedSlot )  then
  begin
    bResult := true;

    (* Return all drive fields *)
    for nCount := 0 to ctDriveFieldSize do
    begin
      wrkspc.ptrDriveField[nCount] := GetDriveField( nCount, info );
      bResult := bResult and ( wrkspc.ptrDriveField[nCount] <> nil );
    end;

    if( bResult )  then
    begin
      (* Get the device info bytes *)
      regs.A  := 6;
      regs.IX := ctBIOSGetDriveFieldAddr;
      regs.IY := info.nSlotNumber;
      CALSLT( regs );
      wrkspc.ptrDeviceInfoBytes := Ptr( regs.HL );

      (* Get the Free space content *)
      regs.A  := 7;
      regs.IX := ctBIOSGetDriveFieldAddr;
      regs.IY := info.nSlotNumber;
      CALSLT( regs );
      wrkspc.ptrFreeSpace := Ptr( regs.HL );
    end;
  end;

  GetIDEWorkspace := bResult;
end;
