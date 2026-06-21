(*<doscodes.pas>
 * MSXDOS and CP/M return codes.
 * CopyLeft (c) 1995-2024 by PopolonY2k.
 * CopyLeft (c) since 2024 by Hinotori Team.
 *)

 (*
  * This module depends on folowing include files (respect the order):
  * -
  *)

(* MSXDOS and CP/M80 DISKIO return codes *)

const
    ctDISKIOWriteProtected   : byte = $0;   { Device is write protected }
    ctDISKIONotReady         : byte = $2;   { Device is not ready }
    ctDISKIODataCRCError     : byte = $4;   { Device data CRC error }
    ctDISKIOSeekError        : byte = $6;   { Device seek positioning }
                                            { error }
    ctDISKIORecordNotFound   : byte = $8;   { Device record/sector not }
                                            { found }
    ctDISKIOWriteFault       : byte = $10;  { Device write operation }
                                            { fault }
    ctDISKIOOtherErrors      : byte = $12;  { Other unspecified error }
    ctDISKIOSuccess          : byte = $FF;  { Success operation  }
                                            { not official }

(* MSXDOS (1 & 2) file return codes *)

    ctDOSSuccess             : byte = $00; { DOS Success }
    ctDOSIncompatibleDisk    : byte = $FF; { DOS2 Incompatible disk }
    ctDOSInternalError       : byte = $DF; { Internal error }
    ctDOSNotEnoughMemory     : byte = $DE; { Not enough memory }
    ctDOSInvalidMSXDOSCall   : byte = $DC; { Invalid CPM/MSXDOS function call }
    ctDOSInvalidDrive        : byte = $DB; { Inavlid drive number/letter }
    ctDOSInvalidFileName     : byte = $DA; { Invalid file name }
    ctDOSInvalidPathName     : byte = $D9; { Invalid path }
    ctDOSPathNameTooLong     : byte = $D8; { Path name too long }
    ctDOSFileNotFound        : byte = $D7; { File not found }
    ctDOSDirectoryNotFound   : byte = $D6; { Directory not found }
    ctDOSDirectoryFull       : byte = $D5; { Directory full }
    ctDOSDiskFull            : byte = $D4; { Disk full }
    ctDOSDuplicateFileName   : byte = $D3; { Duplicated file name }
    ctDOSInvalidDirMove      : byte = $D2; { Invalid attempt to move the dir. }
    ctDOSReadOnlyFile        : byte = $D1; { Read only file }
    ctDOSDirectoryNotEmpty   : byte = $D0; { Directory not empty to remove }
    ctDOSInvalidAttributes   : byte = $CF; { Invalid attributes }
    ctDOSInvalidDotOperation : byte = $CE; { Invalid operation on }
                                           { (.) or (..) entries }
    ctDOSSystemFileExists    : byte = $CD; { Attempt to create an }
                                           { existing system file }
    ctDOSDirectoryExists     : byte = $CC; { Attempt to create an }
                                           { existing directory }
    ctDOSFileExists          : byte = $CB; { Attempt to create an }
                                           { existing file }
    ctDOSFileAlreadyInUse    : byte = $CA; { Attempt to change a file }
                                           { in use }
    ctDOSCannotTransfer64K   : byte = $C9; { Disk transfer area would }
                                           { have extended 64Kb }
    ctDOSFileAllocationError : byte = $C8; { Cluster chain for file is }
                                           { corrupt }
    ctDOSEndOfFile           : byte = $C7; { Attempt to read beyond EOF }
    ctDOSFileAccessViolation : byte = $C6; { File access violation }
    ctDOSInvalidPID          : byte = $C5; { Invalid process Id }
    ctDOSNoSpareFileHandles  : byte = $C4; { No more file handles }
    ctDOSInvalidFileHandle   : byte = $C3; { Invalid file handle }
    ctDOSFileHandleNotOpen   : byte = $C2; { The file handle is not open }
    ctDOSInvalidDeviceOper   : byte = $C1; { Invalid device operation }
    ctDOSInvalidEnvString    : byte = $C0; { Invalid environment string }
    ctDOSEnvStringTooLong    : byte = $BF; { Environment string too long }
    ctDOSInvalidDate         : byte = $BE; { Invalid date }
    ctDOSInvalidTime         : byte = $BD; { Invalid time }
    ctDOSRAMDISKAlreadExist  : byte = $BC; { RAMDISK already exist }
    ctDOSRAMDISKDoesNotExist : byte = $BB; { RAMDISK does not exist }
    ctDOSFileHandleDeleted   : byte = $BA; { The file assigned to the  }
                                           { handle was deleted }
    ctDOSEndOfLine           : byte = $B9; { End of line }
    ctInvalidSubFnNumber     : byte = $B8; { Invalid sub-function number }
                                           { passed to the IOCTL (4B) }
                                           { function }
