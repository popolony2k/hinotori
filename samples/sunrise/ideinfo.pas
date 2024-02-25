(*<ideinfo.pas>
 * Sample code using the PopolonY2k's IDE function library.
 * CopyLeft (c) 1995-2024 by PopolonY2k.
 * CopyLeft (c) since 2024 by Hinotori Team.
 *)
Program IDEInfo;

(* Please respect include dependency order *)

{$v- c- u- a+ r-}

(*
 * This module depends on folowing include files (respect the order):
 *
 * - /memory/memory.pas;
 * - /system/types.pas;
 * - /bios/msxbios.pas;
 * - /bit/bitwise.pas;
 * - /slot/sltsrch.pas;
 * - /sunrise/suntypes.pas;
 * - /sunrise/sunwrksp.pas;
 * - /math/math.pas;
 * - /math/math16.pas;
 * - /math/bigint.pas;
 *)

{$i ..\..\src\memory\memory.pas}
{$i ..\..\src\system\types.pas}
{$i ..\..\src\bios\msxbios.pas}
{$i ..\..\src\bit\bitwise.pas}
{$i ..\..\src\slot\sltsrch.pas}
{$i ..\..\src\sunrise\suntypes.pas}
{$i ..\..\src\sunrise\sunwrksp.pas}
{$i ..\..\src\math\math.pas}
{$i ..\..\src\math\math16.pas}
{$i ..\..\src\math\bigint.pas}


(**
  * String type to represent a 24 bit number.
  *)
Type TNumberString = String[11];


(* Support routines *)

(**
  * Print device type information.
  * @param devType The device type struct to
  * print information;
  * @param nNumHeads Number of heads for device;
  * @param nNumCylinders Number of cylinders/sector for device;
  *)
Procedure PrintDeviceTypeInfo( devType : TDeviceType;
                               nNumHeads, nNumCylinders : Byte );
Begin
  With devType Do
  Begin
    If( Not devType.bIsATA And Not devType.bIsATAPI )  Then
      WriteLn( '(** Not connected device **)' );

    WriteLn( 'Is ATA                      ', bIsATA );
    WriteLn( 'Is ATAPI                    ', bIsATAPI );
    WriteLn( 'Is CDROM                    ', bIsCDROM );
    WriteLn( 'Uses Only CHS addressing    ', bUsesOnlyCHSAddressing );
    WriteLn( 'Support also LBA addressing ', bSupportAlsoLBAAddressing );
    WriteLn( 'Support direct access       ', bDirectAccess );

    If( bIsATA )  Then
    Begin
      WriteLn( 'Number of heads             ', nNumHeads );
      WriteLn( 'Number of Sectors/Cylinders ', nNumCylinders );
    End;

    WriteLn;
  End;
End;

(* Main block *)

Var      info            : TIDEInfo;
         wrkspc          : TIDEWorkspace;
         devInfo         : TDeviceInfo;
         devTypeMaster   : TDeviceType;
         devTypeSlave    : TDeviceType;
         partInfo        : TAdditionalPartitionInfo;
         nPrimarySlot    : Byte;
         nSecondarySlot  : Byte;
         nCount          : Byte;
         nMax            : Byte;
         n24Tmp          : TBigInt;
         n24TmpSwap      : TBigInt;
         n24SwapValue    : TInt24;
         str24PartStart  : TNumberString;
         str24PartCount  : TNumberString;
         strDeviceName   : TTinyString;
         opCode          : TOperationCode;

Begin
  WriteLn( 'MSX IDE Information sample' );
  WriteLn( 'CopyLeft (c) Since 1995 by PopolonY2k' );
  WriteLn( 'Project home at http://www.planetamessenger.org' );
  WriteLn;

  { 24Bit temp swap value big int setup }
  n24TmpSwap.nSize  := SizeOf( n24SwapValue );
  n24TmpSwap.pValue := Ptr( Addr( n24SwapValue ) );

  GetIDEInfo( info );

  If( info.nSlotNumber <> ctUnitializedSlot )  Then
  Begin
    (* Data initialization *)
    FillChar( wrkspc, SizeOf( TIDEWorkspace ), 0 );

    SplitSlotNumber( info.nSlotNumber, nPrimarySlot, nSecondarySlot );

    WriteLn( 'IDE found at Slot -> ',
             nPrimarySlot, '-', nSecondarySlot );

    WriteLn( 'BIOS version      -> ',
             info.nMajor, '.',
             info.nMinor, '.',
             info.nRevision );
    WriteLn;

    If( GetIDEWorkSpace( info, wrkspc ) )  Then
    Begin
      WriteLn( 'IDE workspace information :' );
      WriteLn;
      nMax := ctDriveFieldSize;

      (* Get device type information *)
      GetDeviceType( wrkspc.ptrDeviceInfoBytes^.nDeviceTypeMaster,
                     devTypeMaster );
      GetDeviceType( wrkspc.ptrDeviceInfoBytes^.nDeviceTypeSlave,
                     devTypeSlave );

      WriteLn( '=========================' );
      WriteLn( 'Device Type (Master)' );
      WriteLn( '=========================' );
      PrintDeviceTypeInfo( devTypeMaster,
                           wrkspc.ptrDeviceInfoBytes^.nNumOfHeadsMaster,
                           wrkspc.ptrDeviceInfoBytes^.nNumSectorsCylMaster );

      While( Not KeyPressed ) Do;

      WriteLn( '=========================' );
      WriteLn( 'Device Type (Slave)' );
      WriteLn( '=========================' );
      PrintDeviceTypeInfo( devTypeSlave,
                           wrkspc.ptrDeviceInfoBytes^.nNumOfHeadsSlave,
                           wrkspc.ptrDeviceInfoBytes^.nNumSectorsCylSlave );

      While( Not KeyPressed ) Do;

      For nCount := 0 to nMax Do
      Begin
        (*
         * The IDE 24Bit values has different byte ordering as needed by
         * the BigInt functions library, then a byte order swap must be
         * done.
         *)
        n24Tmp.nSize  := SizeOf( wrkspc.ptrDriveField[nCount]^.n24PartitionStart );
        n24Tmp.pValue := Ptr( Addr( wrkspc.ptrDriveField[nCount]^.n24PartitionStart ) );
        opCode := AssignBigInt( n24TmpSwap, n24Tmp );
        opCode := SwapBigInt( n24TmpSwap );
        opCode := BigIntToStr( str24PartStart, n24TmpSwap );

        n24Tmp.nSize  := SizeOf( wrkspc.ptrDriveField[nCount]^.n24PartitionLenght );
        n24Tmp.pValue := Ptr( Addr( wrkspc.ptrDriveField[nCount]^.n24PartitionLenght ) );
        opCode := AssignBigInt( n24TmpSwap, n24Tmp );
        opCode := SwapBigInt( n24TmpSwap );
        opCode := BigIntToStr( str24PartCount, n24TmpSwap );

        GetDeviceInfo( wrkspc.ptrDriveField[nCount]^.nDeviceCodeByte, devInfo );
        GetAdditionalPartitionInfo( wrkspc.ptrDriveField[nCount]^.nAdditionalPartInfo, partInfo );

        Case( devInfo.nPartitionLocation ) Of
          ctPartitionATADevice   : strDeviceName := 'ATA device';
          ctPartitionATAPIDevice : strDeviceName := 'ATAPI device';
          ctPartitionATAPICDROM  : strDeviceName := 'ATAPI CDROM device';
        End;

        WriteLn( '---------------------------------------------------' );
        WriteLn( 'Device ID                 ', nCount );
        WriteLn( 'Master                    ', devInfo.bPartitionIsMaster );
        WriteLn( 'Partition located on      ', strDeviceName );
        WriteLn( 'Partition sector start    ', str24PartStart );
        WriteLn( 'Partition sector count    ', str24PartCount );
        WriteLn( 'Medium changed            ', devInfo.bMediumChanged );
        WriteLn( 'Partition in use          ', devInfo.bPartitionInUse );
        WriteLn( 'Drive locked              ', devInfo.bDriveLocked );
        WriteLn( '=========================' );
        WriteLn( 'Additional Partition Info' );
        WriteLn( '=========================' );
        WriteLn( 'Enabled during boot       ', partInfo.bEnabledDuringBoot );
        WriteLn( 'Bootable                  ', partInfo.bIsBootable );
        WriteLn( 'Logically write protected ', partInfo.bLogicallyWriteProtected );
        WriteLn( '---------------------------------------------------' );
        WriteLn;

        While( Not KeyPressed ) Do;
      End;
    End
    Else
        WriteLn( 'Error to get the IDE workspace information' );
  End
  Else
    WriteLn( 'IDE interface not found' );
End.
