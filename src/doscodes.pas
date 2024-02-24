(*<doscodes.pas>
 * MSXDOS and CP/M return codes.
 * CopyLeft (c) since 1995 by PopolonY2k.
 *)

(**
  *
  * $Id: doscodes.pas 128 2020-07-08 17:51:23Z popolony2k $
  * $Author: popolony2k $
  * $Date: 2020-07-08 14:51:23 -0300 (Wed, 08 Jul 2020) $
  * $Revision: 128 $
  * $HeadURL: https://svn.code.sf.net/p/oldskooltech/code/msx/trunk/msxdos/pascal/doscodes.pas $
  *)

(* MSXDOS and CP/M80 DISKIO return codes *)

Const
    ctDISKIOWriteProtected   : Byte = $0;   { Device is write protected }
    ctDISKIONotReady         : Byte = $2;   { Device is not ready }
    ctDISKIODataCRCError     : Byte = $4;   { Device data CRC error }
    ctDISKIOSeekError        : Byte = $6;   { Device seek positioning }
                                            { error }
    ctDISKIORecordNotFound   : Byte = $8;   { Device record/sector not }
                                            { found }
    ctDISKIOWriteFault       : Byte = $10;  { Device write operation }
                                            { fault }
    ctDISKIOOtherErrors      : Byte = $12;  { Other unspecified error }
    ctDISKIOSuccess          : Byte = $FF;  { Success operation  }
                                            { not official }

(* MSXDOS (1 & 2) file return codes *)

    ctDOSSuccess             : Byte = $00; { DOS Success }
    ctDOSIncompatibleDisk    : Byte = $FF; { DOS2 Incompatible disk }
    ctDOSInternalError       : Byte = $DF; { Internal error }
    ctDOSNotEnoughMemory     : Byte = $DE; { Not enough memory }
    ctDOSInvalidMSXDOSCall   : Byte = $DC; { Invalid CPM/MSXDOS function call }
    ctDOSInvalidDrive        : Byte = $DB; { Inavlid drive number/letter }
    ctDOSInvalidFileName     : Byte = $DA; { Invalid file name }
    ctDOSInvalidPathName     : Byte = $D9; { Invalid path }
    ctDOSPathNameTooLong     : Byte = $D8; { Path name too long }
    ctDOSFileNotFound        : Byte = $D7; { File not found }
    ctDOSDirectoryNotFound   : Byte = $D6; { Directory not found }
    ctDOSDirectoryFull       : Byte = $D5; { Directory full }
    ctDOSDiskFull            : Byte = $D4; { Disk full }
    ctDOSDuplicateFileName   : Byte = $D3; { Duplicated file name }
    ctDOSInvalidDirMove      : Byte = $D2; { Invalid attempt to move the dir. }
    ctDOSReadOnlyFile        : Byte = $D1; { Read only file }
    ctDOSDirectoryNotEmpty   : Byte = $D0; { Directory not empty to remove }
    ctDOSInvalidAttributes   : Byte = $CF; { Invalid attributes }
    ctDOSInvalidDotOperation : Byte = $CE; { Invalid operation on }
                                           { (.) or (..) entries }
    ctDOSSystemFileExists    : Byte = $CD; { Attempt to create an }
                                           { existing system file }
    ctDOSDirectoryExists     : Byte = $CC; { Attempt to create an }
                                           { existing directory }
    ctDOSFileExists          : Byte = $CB; { Attempt to create an }
                                           { existing file }
    ctDOSFileAlreadyInUse    : Byte = $CA; { Attempt to change a file }
                                           { in use }
    ctDOSCannotTransfer64K   : Byte = $C9; { Disk transfer area would }
                                           { have extended 64Kb }
    ctDOSFileAllocationError : Byte = $C8; { Cluster chain for file is }
                                           { corrupt }
    ctDOSEndOfFile           : Byte = $C7; { Attempt to read beyond EOF }
    ctDOSFileAccessViolation : Byte = $C6; { File access violation }
    ctDOSInvalidPID          : Byte = $C5; { Invalid process Id }
    ctDOSNoSpareFileHandles  : Byte = $C4; { No more file handles }
    ctDOSInvalidFileHandle   : Byte = $C3; { Invalid file handle }
    ctDOSFileHandleNotOpen   : Byte = $C2; { The file handle is not open }
    ctDOSInvalidDeviceOper   : Byte = $C1; { Invalid device operation }
    ctDOSInvalidEnvString    : Byte = $C0; { Invalid environment string }
    ctDOSEnvStringTooLong    : Byte = $BF; { Environment string too long }
    ctDOSInvalidDate         : Byte = $BE; { Invalid date }
    ctDOSInvalidTime         : Byte = $BD; { Invalid time }
    ctDOSRAMDISKAlreadExist  : Byte = $BC; { RAMDISK already exist }
    ctDOSRAMDISKDoesNotExist : Byte = $BB; { RAMDISK does not exist }
    ctDOSFileHandleDeleted   : Byte = $BA; { The file assigned to the  }
                                           { handle was deleted }
    ctDOSEndOfLine           : Byte = $B9; { End of line }
    ctInvalidSubFnNumber     : Byte = $B8; { Invalid sub-function number }
                                           { passed to the IOCTL (4B) }
                                           { function }
