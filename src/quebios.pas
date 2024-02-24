(**<quebios.pas>
  * MSX-BIOS addresses related to queue management.
  * Copyright (c) since 1995 by PopolonY2k.
  *)

(**
  *
  * $Id: quebios.pas 128 2020-07-08 17:51:23Z popolony2k $
  * $Author: popolony2k $
  * $Date: 2020-07-08 14:51:23 -0300 (Wed, 08 Jul 2020) $
  * $Revision: 128 $
  * $HeadURL: https://svn.code.sf.net/p/oldskooltech/code/msx/trunk/msxdos/pascal/quebios.pas $
  *)

(*
 * This module depends on folowing include files (respect the order):
 * -
 *)

(* MSX BIOS address functions *)

Const     ctLFTQ    = $00F6;      { Return the number of bytes in queue      }
          ctPUTQ    = $00F9;      { Put byte in queue                        }
