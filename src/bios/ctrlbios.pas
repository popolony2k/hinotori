(*<ctrlbios.pas>
 * MSX-BIOS addresses related to controllers management.
 * CopyLeft (c) 1995-2024 by PopolonY2k.
 * CopyLeft (c) since 2024 by Hinotori Team.
 *)

(*
 * This module depends on folowing include files (respect the order):
 * -
 *)

(* MSX BIOS address functions *)

Const     ctGTSTCK  = $00D5;      { Return the joystick status               }
          ctGTTRIG  = $00D8;      { Return current trigger status            }
          ctGTPAD   = $00DB;      { Return current touch pad status          }
          ctGTPDL   = $00DE;      { Return current value of paddle           }
