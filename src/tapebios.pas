(**<tapebios.pas>
  * MSX-BIOS addresses related to tape management.
  * Copyright (c) since 1995 by PopolonY2k.
  *)

(**
  *
  * $Id: tapebios.pas 128 2020-07-08 17:51:23Z popolony2k $
  * $Author: popolony2k $
  * $Date: 2020-07-08 14:51:23 -0300 (Wed, 08 Jul 2020) $
  * $Revision: 128 $
  * $HeadURL: https://svn.code.sf.net/p/oldskooltech/code/msx/trunk/msxdos/pascal/tapebios.pas $
  *)

(*
 * This module depends on folowing include files (respect the order):
 * -
 *)

(* MSX BIOS address functions *)

Const     ctTAPION  = $00E1;      { Read the header block after turn tape on }
          ctTAPIN   = $00E4;      { Read data from the tape                  }
          ctTAPIOF  = $00E7;      { Stop reading from the tape               }
          ctTAPOON  = $00EA;      { Turn on the cassete motor & write header }
          ctTAPOUT  = $00ED;      { Write data to the tape                   }
          ctTAPOOF  = $00F0;      { Stop writing to tape                     }
          ctSTMOTR  = $00F3;      { Set the cassete motor action             }
