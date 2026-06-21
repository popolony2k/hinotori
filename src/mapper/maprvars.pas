(*<maprvars.pas>
 * Direct memory mapper management base implementation.
 * CopyLeft (c) 1995-2024 by PopolonY2k.
 * CopyLeft (c) since 2024 by Hinotori Team.
 *)

(*
 * This module depends on folowing include files (respect the order):
 * -
 *)

(**
  * MSXDOS System variables used on Memory Mapper management.
  *)
var
               CURSEGPAGE0       : byte absolute $F2C7; { Current page 0     }
               CURSEGPAGE1       : byte absolute $F2C8; { Current page 1     }
               CURSEGPAGE2       : byte absolute $F2C9; { Current page 2     }
               CURSEGPAGE3       : byte absolute $F2CA; { Current page 3     }
               LASTSEGPAGE2      : byte absolute $F2CF; { Segment page 2     }
               LASTSEGPAGE0      : byte absolute $F2D0; { Segment page 0     }

