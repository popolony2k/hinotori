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
Var
               CURSEGPAGE0       : Byte Absolute $F2C7; { Current page 0     }
               CURSEGPAGE1       : Byte Absolute $F2C8; { Current page 1     }
               CURSEGPAGE2       : Byte Absolute $F2C9; { Current page 2     }
               CURSEGPAGE3       : Byte Absolute $F2CA; { Current page 3     }
               LASTSEGPAGE2      : Byte Absolute $F2CF; { Segment page 2     }
               LASTSEGPAGE0      : Byte Absolute $F2D0; { Segment page 0     }

