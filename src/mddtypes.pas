(*<mddtypes.pas>
 * MSXDD data types definition.
 * CopyLeft (c) since 1995 by PopolonY2k.
 *)

(**
  *
  * $Id: mddtypes.pas 134 2020-09-11 02:44:57Z popolony2k $
  * $Author: popolony2k $
  * $Date: 2020-09-10 23:44:57 -0300 (Thu, 10 Sep 2020) $
  * $Revision: 134 $
  * $HeadURL: https://svn.code.sf.net/p/oldskooltech/code/msx/trunk/msxdos/pascal/mddtypes.pas $
  *)

(*
 * This source file depends on following include files (respect the order):
 * - types.pas;
 *)

Const     ctScreenPageSize = 128;      { Default screen page size }
          ctMaxSectorDec   = 11;       { Maximum sector decimal - 24Bit }
          ctMSXDDEnvVar    = 'MSXDD';  { MSXDD environment variable }
          ctAPPENDEnvVar   = 'APPEND'; { APPEND MSXDOS environment variable }

(**
  * The command-line startup parameters.
  *)
Type TCmdLineParms = Record
  bDrive               : Boolean;
  bFile                : Boolean;
  bHelp                : Boolean;
  bSector              : Boolean;
  bAbsoluteStartSector : Boolean;
  nDriveNumber         : Byte;
  strFileName          : TFileName;
  strDriveLetter       : String[2];
  strSectorNumber      : String[ctMaxSectorDec];
End;
