(*<initbios.pas>
 * MSX-BIOS addresses related to Initialization and RST BIOS calls.
 * CopyLeft (c) 1995-2024 by PopolonY2k.
 * CopyLeft (c) since 2024 by Hinotori Team.
 *)

(*
 * This module depends on folowing include files (respect the order):
 * -
 *)

(* MSX BIOS address functions *)

Const     ctCHKRAM  = $0000;      { Check RAM and set slot for command area  }
          ctSYNCHR  = $0008;      { Check if current token                   }
          ctRDSLT   = $000C;      { Load memory position of any slot         }
          ctCHRGTB  = $0010;      { Check next BASIC token                   }
          ctWRSLT   = $0014;      { Write to memory position of any slot     }
          ctOUTDO   = $0018;      { Output to the current device             }
          ctCALSLT  = $001C;      { Inter slot call                          }
          ctDCOMPR  = $0020;      { Compare HL with DE                       }
          ctENASLT  = $0024;      { Select page between slots                }
          ctGETYPR  = $0028;      { Return the type FAC                      }
          ctCALLF   = $0030;      { Performs far calls(i.e inter-slots calls)}
          ctKEYINT  = $0038;      { Performs hardware interrupt procedures   }
          ctINITIO  = $003B;      { Performs device inititalization          }
          ctINIFNK  = $003E;      { Initialize function key strings          }
