(**<ctrlbios.pas>
  * MSX-BIOS addresses related to controllers management.
  * Copyright (c) since 1995 by PopolonY2k.
  *)

(**
  *
  * $Id: ctrlbios.pas 128 2020-07-08 17:51:23Z popolony2k $
  * $Author: popolony2k $
  * $Date: 2020-07-08 14:51:23 -0300 (Wed, 08 Jul 2020) $
  * $Revision: 128 $
  * $HeadURL: https://svn.code.sf.net/p/oldskooltech/code/msx/trunk/msxdos/pascal/ctrlbios.pas $
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
