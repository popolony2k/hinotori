(*<tapebios.pas>
 * MSX-BIOS addresses related to tape management.
 * CopyLeft (c) 1995-2024 by PopolonY2k.
 * CopyLeft (c) since 2024 by Hinotori Team.
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
