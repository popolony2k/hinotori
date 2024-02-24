(**<conbios.pas>
  * MSX-BIOS addresses related to the console.
  * Copyright (c) since 1995 by PopolonY2k.
  *)

(**
  *
  * $Id: conbios.pas 128 2020-07-08 17:51:23Z popolony2k $
  * $Author: popolony2k $
  * $Date: 2020-07-08 14:51:23 -0300 (Wed, 08 Jul 2020) $
  * $Revision: 128 $
  * $HeadURL: https://svn.code.sf.net/p/oldskooltech/code/msx/trunk/msxdos/pascal/conbios.pas $
  *)

(*
 * This module depends on folowing include files (respect the order):
 * -
 *)

(* MSX BIOS address functions *)

Const     ctCHSNS   = $009C;      { Check status of keyboard buffer          }
          ctCHGET   = $009F;      { Wait for input character and return      }
          ctCHPUT   = $00A2;      { Output a character to the console        }
          ctLPTOUT  = $00A5;      { Output a character to the line printer   }
          ctLPTSTT  = $00A8;      { Check the line printer status            }
          ctCNVCHR  = $00AB;      { Check graphic header byte & convert code }
          ctPINLIN  = $00AE;      { Accept a line from console until CR/STOP }
          ctINLIN   = $00B1;      { Same as PINLIN, except is AUTOFLO is set }
          ctQUINLIN = $00B4;      { Output a '?' and space and falls INLIN   }
          ctBREAKX  = $00B7;      { Verify <Ctrl>+<Stop>                     }
          ctISCNTC  = $00BA;      { Verify <Stop> or <Ctrl>+<Stop>           }
          ctCKCNTC  = $00BD;      { Same as ISCNTC                           }
          ctBEEP    = $00C0;      { Emit a Beep                              }
          ctCLS     = $00C3;      { Clear screen, including graphic modes    }
          ctPOSIT   = $00C6;      { Change text cursor position              }
          ctFNKSB   = $00C9;      { Check if function key display is active  }
          ctERAFNK  = $00CC;      { Erase the function key display           }
          ctDSPFNK  = $00CF;      { Display the function key display         }
          ctTOTEXT  = $00D2;      { Force screen to the text mode            }
