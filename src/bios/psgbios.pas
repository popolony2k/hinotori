(*<psgbios.pas>
 * MSX-BIOS addresses related to PSG management.
 * CopyLeft (c) 1995-2024 by PopolonY2k.
 * CopyLeft (c) since 2024 by Hinotori Team.
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
