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

const    ctDriveFieldSize = 5;      { IDE Max drive letters - 1 }


(* IDE types and definitions *)

(**
  * IDE information (Connected Slot, BIOS Version, ...)
  *)
type TIDEInfo = record
  nMajor,
  nMinor,
  nRevision   : byte;
  nSlotNumber : TSlotNumber;
end;

(*
 * Drive field definition. The size of drive fields is variable
 * and can change according BIOS version. The current rule is written
 * like below:
 * 8 for BIOS 1.9x and 2.xx;
 * > 8 for BIOS 3.xx and higher;
 * See idesys.txt for details
 *)
type TDriveField = record
  nDeviceCodeByte     : byte;
  n24PartitionStart,                        { 24Bit absolute sector number }
  n24PartitionLenght  : TInt24;             { 24Bit sector (count - 1) }
  nAdditionalPartInfo,                      { Addition partition info }
  (* The two bytes below is reserved to BIOS 3.xx or higher *)
  nPartitionStart,                          { Partition start bit 24 to 31 }
  nPartitionLength    : byte;               { Partition (lenght - 1) 24 to 31 }
end;

type PDriveField = ^TDriveField;            { TDriveField pointer type }

(*
 * Device info bytes definition.
 * 6 bytes for BIOS 1.9x and 2.xx.
 *)
type TDeviceInfoBytes = record
  nNumOfHeadsMaster,             { For ATA Devices }
  nNumOfHeadsSlave,              { For ATA Devices }
  nNumSectorsCylMaster,          { For ATA Devices }
  nNumSectorsCylSlave,           { For ATA Devices }
  nDeviceTypeMaster,
  nDeviceTypeSlave,
  nUndefined           : byte;   { Undefined yet - don`t use them }
end;

type PDeviceInfoBytes = ^TDeviceInfoBytes;  { TDeviceInfoBytes pointer type }

(**
  * Free space worspace area.
  *)
type TFreeSpace = array[0..17] of byte;
type PFreeSpace = ^TFreeSpace;              { TFreeSpace pointer type }

(*
 * IDE interface Workspace allocate at boot process.
 * More details check idesys.txt file at this library
 * directory.
 *)
type TIDEWorkspace = record
  ptrDriveField      : array[0..ctDriveFieldSize] of PDriveField;
  ptrDeviceInfoBytes : PDeviceInfoBytes;
  ptrFreeSpace       : PFreeSpace;
end;

(* High level struct definitions *)

(**
  * This struct is a high level representation
  * of Device byte code information.
  * Use @see GetDeviceInfo() function to
  * retrieve the struct from given device byte
  * code;
  *)
type TDeviceInfo = record
  nPartitionLocation : byte;
  bPartitionIsMaster,
  bMediumChanged,
  bPartitionInUse,
  bDriveLocked       : boolean;
end;

(**
  * This struct is a high level representation
  * of additional partition info byte code
  * information.
  * Use @see GetAdditionalPartitionInfo()
  * function to retrieve the struct from given
  * additional partition info byte code;
  *)
type TAdditionalPartitionInfo = record
  bEnabledDuringBoot,
  bIsBootable,
  bLogicallyWriteProtected : boolean;
end;

(**
  + This struct is a high level representation
  * of device type byte code information of
  * @see TDeviceInfoBytes structure.
  * Use @see GetDeviceType() function to
  * retrieve the struct from given device type
  * byte code;
  *)
type TDeviceType = record
  bIsATA,
  bIsATAPI,
  bUsesOnlyCHSAddressing,
  bSupportAlsoLBAAddressing,
  bDirectAccess,
  bIsCDROM                  : boolean;
end;
