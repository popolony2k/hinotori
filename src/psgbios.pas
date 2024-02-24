(**<psgbios.pas>
  * MSX-BIOS addresses related to PSG management.
  * Copyright (c) since 1995 by PopolonY2k.
  *)

(**
  *
  * $Id: psgbios.pas 128 2020-07-08 17:51:23Z popolony2k $
  * $Author: popolony2k $
  * $Date: 2020-07-08 14:51:23 -0300 (Wed, 08 Jul 2020) $
  * $Revision: 128 $
  * $HeadURL: https://svn.code.sf.net/p/oldskooltech/code/msx/trunk/msxdos/pascal/psgbios.pas $
  *)

(*
 * This module depends on folowing include files (respect the order):
 * -
 *)

(* MSX BIOS address functions *)

Const     ctGICINI  = $0090;      { Initialize PSG and static data for PLAY  }
          ctWRTPSG  = $0093;      { Write data to the PSG register           }
          ctRDPSG   = $0096;      { Read data from PSG register              }
          ctSTRTMS  = $0099;      { Check/start background tasks for PLAY    }
