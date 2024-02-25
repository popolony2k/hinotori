(*<quebios.pas>
 * MSX-BIOS addresses related to queue management.
 * CopyLeft (c) 1995-2024 by PopolonY2k.
 * CopyLeft (c) since 2024 by Hinotori Team.
 *)

(*
 * This module depends on folowing include files (respect the order):
 * -
 *)

(* MSX BIOS address functions *)

Const     ctLFTQ    = $00F6;      { Return the number of bytes in queue      }
          ctPUTQ    = $00F9;      { Put byte in queue                        }
