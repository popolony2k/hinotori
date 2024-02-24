(*<uihelp.pas>
 * MSXDD help messages implementation.
 * CopyLeft (c) since 1995 by PopolonY2k.
 *)

(**
  *
  * $Id: uihelp.pas 128 2020-07-08 17:51:23Z popolony2k $
  * $Author: popolony2k $
  * $Date: 2020-07-08 14:51:23 -0300 (Wed, 08 Jul 2020) $
  * $Revision: 128 $
  * $HeadURL: https://svn.code.sf.net/p/oldskooltech/code/msx/trunk/msxdos/pascal/uihelp.pas $
  *)

(*
 * This source file depends on following include files (respect the order):
 * - msxddver.pas;
 *)


(**
  * Print the help options for MSX Disk Doctor dump
  * application.
  *)
Procedure ShowHelp;
Begin
  WriteLn( 'MSX Disk Doctor application suite version ', ctSuiteVer, '.' );
  WriteLn( 'MSXDD Dump Editor version ', ctDumpEditorVer, '.' );
  WriteLn( 'CopyLeft (c) since 1995 by PopolonY2k.' );
  Write( 'Check newer versions of this software at ' );
  WriteLn( 'http://www.popolony2k.com.br' );
  WriteLn;
  Write( 'Usage: ' );
  WriteLn( 'msxdump [-h][-f <file_name>][-d <drive>][-s <sector_number>][-a]' );
  WriteLn;
  WriteLn( '-h Show this help screen;' );
  WriteLn( '-f <file_name> Specify the file name whose the dump/edition' );
  WriteLn( '   operation will be performed. The <file_name> parameter must' );
  WriteLn( '   to be an existing file name in the MSXDOS filesystem;' );
  WriteLn( '-d <drive> Open the drive specified by <drive> parameter' );
  WriteLn( '   to perform the next disk operations. The <drive> parameter' );
  WriteLn( '   must to be one of valid drives (A:,B:, ..., H:);' );
  WriteLn( '-s <sector_number> Specify the initial sector to perform the' );
  WriteLn( '   next disk operations. The <sector_number> parameter must to' );
  WriteLn( '   be a valid sector number;' );
  WriteLn( '-a When -a is specified, the <sector_number> specified at the' );
  WriteLn( '   -s parameter is a absolute sector position of the drive' );
  WriteLn( '   specified by the -d <drive> parameter.' );
End;

