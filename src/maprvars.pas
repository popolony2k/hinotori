(*<maprvars.pas>
 * Direct memory mapper management base implementation.
 * CopyLeft (c) since 1995 by PopolonY2k.
 *)

(**
  *
  * $Id: maprvars.pas 128 2020-07-08 17:51:23Z popolony2k $
  * $Author: popolony2k $
  * $Date: 2020-07-08 14:51:23 -0300 (Wed, 08 Jul 2020) $
  * $Revision: 128 $
  * $HeadURL: https://svn.code.sf.net/p/oldskooltech/code/msx/trunk/msxdos/pascal/maprvars.pas $
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

