(*<suntypes.pas>
 * MSXIDE (sunrise-like) types definition to all shared modules.
 * CopyLeft (c) 1995-2024 by PopolonY2k.
 * CopyLeft (c) since 2024 by Hinotori Team.
 *)

(*
 * This source file depends on following include files (respect the order):
 * - /system/types.pas;
 *)

(* Constants, Types and strucutres of MSX IDE library *)

Const    ctDriveFieldSize = 5;      { IDE Max drive letters - 1 }


(* IDE types and definitions *)

(**
  * IDE information (Connected Slot, BIOS Version, ...)
  *)
Type TIDEInfo = Record
  nMajor,
  nMinor,
  nRevision   : Byte;
  nSlotNumber : TSlotNumber;
End;

(*
 * Drive field definition. The size of drive fields is variable
 * and can change according BIOS version. The current rule is written
 * like below:
 * 8 for BIOS 1.9x and 2.xx;
 * > 8 for BIOS 3.xx and higher;
 * See idesys.txt for details
 *)
Type TDriveField = Record
  nDeviceCodeByte     : Byte;
  n24PartitionStart,                        { 24Bit absolute sector number }
  n24PartitionLenght  : TInt24;             { 24Bit sector (count - 1) }
  nAdditionalPartInfo,                      { Addition partition info }
  (* The two bytes below is reserved to BIOS 3.xx or higher *)
  nPartitionStart,                          { Partition start bit 24 to 31 }
  nPartitionLength    : Byte;               { Partition (lenght - 1) 24 to 31 }
End;

Type PDriveField = ^TDriveField;            { TDriveField pointer type }

(*
 * Device info bytes definition.
 * 6 bytes for BIOS 1.9x and 2.xx.
 *)
Type TDeviceInfoBytes = Record
  nNumOfHeadsMaster,             { For ATA Devices }
  nNumOfHeadsSlave,              { For ATA Devices }
  nNumSectorsCylMaster,          { For ATA Devices }
  nNumSectorsCylSlave,           { For ATA Devices }
  nDeviceTypeMaster,
  nDeviceTypeSlave,
  nUndefined           : Byte;   { Undefined yet - don`t use them }
End;

Type PDeviceInfoBytes = ^TDeviceInfoBytes;  { TDeviceInfoBytes pointer type }

(**
  * Free space worspace area.
  *)
Type TFreeSpace = Array[0..17] Of Byte;
Type PFreeSpace = ^TFreeSpace;              { TFreeSpace pointer type }

(*
 * IDE interface Workspace allocate at boot process.
 * More details check idesys.txt file at this library
 * directory.
 *)
Type TIDEWorkspace = Record
  ptrDriveField      : Array[0..ctDriveFieldSize] Of PDriveField;
  ptrDeviceInfoBytes : PDeviceInfoBytes;
  ptrFreeSpace       : PFreeSpace;
End;

(* High level struct definitions *)

(**
  * This struct is a high level representation
  * of Device byte code information.
  * Use @see GetDeviceInfo() function to
  * retrieve the struct from given device byte
  * code;
  *)
Type TDeviceInfo = Record
  nPartitionLocation : Byte;
  bPartitionIsMaster,
  bMediumChanged,
  bPartitionInUse,
  bDriveLocked       : Boolean;
End;

(**
  * This struct is a high level representation
  * of additional partition info byte code
  * information.
  * Use @see GetAdditionalPartitionInfo()
  * function to retrieve the struct from given
  * additional partition info byte code;
  *)
Type TAdditionalPartitionInfo = Record
  bEnabledDuringBoot,
  bIsBootable,
  bLogicallyWriteProtected : Boolean;
End;

(**
  + This struct is a high level representation
  * of device type byte code information of
  * @see TDeviceInfoBytes structure.
  * Use @see GetDeviceType() function to
  * retrieve the struct from given device type
  * byte code;
  *)
Type TDeviceType = Record
  bIsATA,
  bIsATAPI,
  bUsesOnlyCHSAddressing,
  bSupportAlsoLBAAddressing,
  bDirectAccess,
  bIsCDROM                  : Boolean;
End;
