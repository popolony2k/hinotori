(*<vdpbios.pas>
 * MSX-BIOS addresses related to VDP management.
 * CopyLeft (c) 1995-2024 by PopolonY2k.
 * CopyLeft (c) since 2024 by Hinotori Team.
 *)

(*
 * This module depends on folowing include files (respect the order):
 * -
 *)

(* MSX BIOS address functions *)

Const     ctDISSCR  = $0041;      { Disable screen display                   }
          ctENASCR  = $0044;      { Enable screen display                    }
          ctWRTVDP  = $0047;      { Write to the VDP register                }
          ctRDVRM   = $004A;      { Read the VRAM adddress                   }
          ctWRTVRM  = $004D;      { Write to VRAM                            }
          ctSETRD   = $0050;      { Setup the VDP for read                   }
          ctSETWRT  = $0053;      { Setup the VDP for write                  }
          ctFILVRM  = $0056;      { Fill the VRAM with specified data        }
          ctLDIRMV  = $0059;      { Moves VRAM memory content to memory      }
          ctLDIRVM  = $005C;      { Moves memory content to VRAM             }
          ctCHGMOD  = $005F;      { Set the VDP mode according SCRMOD        }
          ctCHGCLR  = $0062;      { Changes the color of the screen          }
          ctNMI     = $0066;      { Performs non-maskable interrupts         }
          ctCLRSPR  = $0069;      { Initialize all sprites                   }
          ctINITXT  = $006C;      { Initialize screen for text mode (40x24)  }
          ctINIT32  = $006F;      { Initialize screen mode for text (32x24)  }
          ctINIGRP  = $0072;      { Initialize screen for hi-resolution mode }
          ctINIMLT  = $0075;      { Initialize screen for multi color mode   }
          ctSETTXT  = $0078;      { Set the VDP for text mode (40x24)        }
          ctSETT32  = $007B;      { Set the VDP for text mode (32x24)        }
          ctSETGRP  = $007E;      { Set the VDP for high resolution mode     }
          ctSETMLT  = $0081;      { Set the VDP for multicolor mode          }
          ctCALPAT  = $0084;      { Return address of sprite pattern table   }
          ctCALATR  = $0087;      { Return address of sprite attribute table }
          ctGSPSIZ  = $008A;      { Return the current sprite size           }
          ctGRPPRT  = $008D;      { Print a character on the graphic screen  }
