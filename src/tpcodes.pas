(*<tpcodes.pas>
 * Turbo Pascal I/O return codes.
 * CopyLeft (c) since 1995 by PopolonY2k.
 *)

(**
  *
  * $Id: tpcodes.pas 128 2020-07-08 17:51:23Z popolony2k $
  * $Author: popolony2k $
  * $Date: 2020-07-08 14:51:23 -0300 (Wed, 08 Jul 2020) $
  * $Revision: 128 $
  * $HeadURL: https://svn.code.sf.net/p/oldskooltech/code/msx/trunk/msxdos/pascal/tpcodes.pas $
  *)

(*
 * This module depends on folowing include files (respect the order):
 * -
 *)

Const    ctTPSuccess          = $0;      { Success }
         ctTPFileNotFound     = $1;      { File not found }
         ctTPFileNotOpen      = $4;      { File not open }
         ctTPFileDesappeared  = $FF;     { Invalid drive }
         ctTPSeekBeyondEOF    = $91;     { Seek beyond End of file }
         ctTPUnexpectedEOF    = $99;     { Unexpected end of file   }
