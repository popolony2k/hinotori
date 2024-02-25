(*<tpcodes.pas>
 * Turbo Pascal I/O return codes.
 * CopyLeft (c) 1995-2024 by PopolonY2k.
 * CopyLeft (c) since 2024 by Hinotori Team.
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
