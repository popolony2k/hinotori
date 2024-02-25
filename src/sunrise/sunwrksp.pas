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

Const    ctDefaultWrkspcPage        = 3;      { Default workspace slot page }
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
Procedure GetIDEInfo( Var info : TIDEInfo );
Var
        strSignature : String[3];
Begin
  With info Do
  Begin
    strSignature := 'ID#';
    nSlotNumber  := FindSignature( strSignature, ctIDESignatureAddr );

    (* Get the BIOS Version *)
    If( nSlotNumber <> ctUnitializedSlot )  Then
    Begin
       nMajor    := RDSLT( nSlotNumber, ctBIOSMajorVerAddr );
       nMinor    := RDSLT( nSlotNumber, ctBIOSMinorVerAddr );
       nRevision := RDSLT( nSlotNumber, ctBIOSRevisionAddr );
    End;
  End;
End;

(**
  * Retrieve the device code struct for a given
  * device byte code.
  * @param nDeviceCodeByte The device byte code
  * to retrieve the struct;
  * @param dev The reference to device struct
  * that will receive the information;
  *)
Procedure GetDeviceInfo( nDeviceCodeByte : Byte; Var dev : TDeviceInfo );
Begin
  With dev Do
  Begin
    bPartitionIsMaster := Not BitCmp( ctPartitionSlaveDevice,
                                      nDeviceCodeByte );
    bMediumChanged     := Not BitCmp( ctPartitionMediaNotChanged,
                                      nDeviceCodeByte );
    bPartitionInUse    := Not BitCmp( ctPartitionNotInUse,
                                      nDeviceCodeByte );
    bDriveLocked       := BitCmp( ctDriveLockedByProgram,
                                  nDeviceCodeByte );
    nPartitionLocation := ( nDeviceCodeByte And ctPartitionATAPICDROM );
  End;
End;

(**
  * Retrieve the additional partition information for a
  * given partition info byte code.
  * @param nDeviceCodeByte The partition info byte code to
  * retrieve the struct;
  * @param part The reference to additional partition
  * info struct that will receive the information;
  *)
Procedure GetAdditionalPartitionInfo( nDeviceCodeByte : Byte;
                                      Var part : TAdditionalPartitionInfo );
Begin
  With part Do
  Begin
    bEnabledDuringBoot       := BitCmp( ctPartEnabledDuringBoot,
                                        nDeviceCodeByte );
    bIsBootable              := Not BitCmp( ctNotBootablePartition,
                                            nDeviceCodeByte );
    bLogicallyWriteProtected := Not BitCmp( ctLogicallyNotWrProtected,
                                            nDeviceCodeByte );
  End;
End;

(**
  * Retrieve the device type information for a given
  * device type byte code.
  * @param nDeviceCodeByte The device type byte code;
  * @param devType The reference to Device type struct
  * that will receive the information;
  *)
Procedure GetDeviceType( nDeviceCodeByte : Byte; Var devType : TDeviceType );
Begin
  With devType Do
  Begin
    bIsATA   := BitCmp( ctATADevice, nDeviceCodeByte );
    bIsATAPI := BitCmp( ctATAPIDevice, nDeviceCodeByte );

    If( BitCmp( ctSupportLBAAddressing, nDeviceCodeByte ) )  Then
    Begin
      bSupportAlsoLBAAddressing := True;
      bUsesOnlyCHSAddressing    := False;
    End
    Else
    Begin
      bSupportAlsoLBAAddressing := False;
      bUsesOnlyCHSAddressing    := True;
    End;

    (* Get the bits 43 *)
    Case( nDeviceCodeByte And ctGetDeviceBits ) Of
      ctDirectAccessDevice : Begin
                               bDirectAccess := True;
                               bIsCDROM      := False;
                             End;
      ctDeviceIsCDROM      : Begin
                               bDirectAccess := False;
                               bIsCDROM      := True;
                             End;
    End;
  End;
End;

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
Function GetDriveField( nDrvFldId : Byte;
                        info  : TIDEInfo ) : PDriveField;
Var
      regs          : TRegs;
      ptrDriveField : PDriveField;

Begin
  ptrDriveField := Nil;

  If( ( info.nSlotNumber <> ctUnitializedSlot ) And
      ( nDrvFldId <= ctDriveFieldSize ) )  Then
  Begin
    regs.A  := nDrvFldId;
    regs.IX := ctBIOSGetDriveFieldAddr;
    regs.IY := info.nSlotNumber;
    CALSLT( regs );

    (*
     * Point the address of Sunrise drive field to the drive field
     * pointer struct;
     *)
    ptrDriveField := Ptr( regs.HL );
  End;

  GetDriveField := ptrDriveField;
End;

(* IDE Workspace functions *)

(**
  * Get the workspace data stored at page 3 of slot that IDE
  * lives in.
  * @param info The IDE information required to retrieve the workspace;
  * @param wrkspc Reference to structure to receive the
  * workspace data;
  *)
Function GetIDEWorkspace( info : TIDEInfo;
                          Var wrkspc : TIDEWorkspace ) : Boolean;
Var
         nCount         : Byte;
         bResult        : Boolean;
         regs           : TRegs;

Begin
  bResult := False;

  If( info.nSlotNumber <> ctUnitializedSlot )  Then
  Begin
    bResult := True;

    (* Return all drive fields *)
    For nCount := 0 To ctDriveFieldSize Do
    Begin
      wrkspc.ptrDriveField[nCount] := GetDriveField( nCount, info );
      bResult := bResult And ( wrkspc.ptrDriveField[nCount] <> Nil );
    End;

    If( bResult )  Then
    Begin
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
    End;
  End;

  GetIDEWorkspace := bResult;
End;
