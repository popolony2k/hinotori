(*<sysvars.pas>
 * Official MSX system variables description.
 * Thanks to MSX Assembly pages - http://map.graw.nl
 * CopyLeft (c) 1995-2024 by PopolonY2k.
 * CopyLeft (c) since 2024 by Hinotori Team.
 *)

(*
 * This module depends on folowing include files (respect the order):
 * -
 *)

(*
 * MSX System Variables.
 * This is an overview of the system variables which you can use. They are
 * official, unless mentioned otherwise.
 *)

(* MSX System Variables located in Main ROM *)

Const

CGTABL : Integer =        $0004; { Base addr of the MSX charset in ROM      }
VDP_DR : Byte    =        $0006; { Base port address for VDP data read      }
VDP_DW : Byte    =        $0007; { Base port address for VDP data write     }
ROMVR1 : Byte    =        $002B; { Basic ROM version Official address       }
                        { 7 6 5 4 3 2 1 0                                   }
                        { | | | | +-+-+-+-- Character set                   }
                        { | | | |           0 = Japanese,                   }
                        { | | | |           1 = International,              }
                        { | | | |           2=Korean                        }
                        { | +-+-+---------- Date format                     }
                        { |                 0 = Y-M-D, 1 = M-D-Y, 2 = D-M-Y }
                        { +---------------- Default interrupt frequency     }
                        {                   0 = 60Hz, 1 = 50Hz              }
ROMVR2 : Byte    =        $002C; { Basic ROM version - Official address     }
                        { 7 6 5 4 3 2 1 0                                   }
                        { | | | | +-+-+-+-- Keyboard type                   }
                        { | | | |           0 = Japanese, 1 = International }
                        { | | | |           2 = French (AZERTY),            }
                        { | | | |           3 = UK,                         }
                        { | | | |           4 = German (DIN)                }
                        { +-+-+-+---------- Basic version                   }
                        {                   0 = Japanese, 1 = International }
MSXVRS : Byte    =        $002D; { MSX version number - Official address    }
                        { 0 = MSX 1                                         }
                        { 1 = MSX 2                                         }
                        { 2 = MSX 2+                                        }
                        { 3 = MSX turbo R                                   }
MSXMID : Byte    =        $002E; { Bit 0: if 1 MSX-MIDI is present TR Only  }
RSRVED : Byte    =        $002F; { Reserved                                 }

(* MSX System Variables located in Sub ROM *)

SROMID : Integer =        $0000; { String "CD", ident. of MSX Sub ROM       }
STSCRN : Integer =        $0002; { Exec address for startup screen on MSX 2 }
                                 { MSX 2+ or MSX turbo R.                   }
                                 { This is unofficial and undocumented addr }

(* MSX-DOS (DiskROM) System Variables located in RAM *)

(* These addresses are only initialized when a DiskROM is present *)
(* (e.g. when the machine has a diskdrive or a harddisk interface *)
(* connected).                                                    *)

Var

RAMAD0 : Byte Absolute    $F341; { Slot addr. of RAM in page 0 (DOS)       }
RAMAD1 : Byte Absolute    $F342; { Slot addr. of RAM in page 1 (DOS)       }
RAMAD2 : Byte Absolute    $F343; { Slot addr. of RAM in page 2 (DOS/BASIC) }
RAMAD3 : Byte Absolute    $F344; { Slot addr. of RAM in page 3 (DOS/BASIC) }
RAMADM : Byte Absolute    $F348; { Slot addr. of the main DiskROM          }

(* MSX System Variables located in RAM *)

(* This is the start of the MSX BIOS system area. *)

RDPRIM : Array[0..4] Of Byte Absolute  $F380; { Routine that reads from a  }
                                              { primary slot               }
WRPRIM : Array[0..6] Of Byte Absolute  $F385; { Routine that writes to a   }
                                              { primary slot               }
CLPRIM : Array[0..13] Of Byte Absolute $F38C; { Routine that calls a       }
                                              { routine in a primary slot  }
USRTB0 : Integer Absolute $F39A; { Address to call with Basic USR0         }
USRTB1 : Integer Absolute $F39C; { Address to call with Basic USR1         }
USRTB2 : Integer Absolute $F39E; { Address to call with Basic USR2         }
USRTB3 : Integer Absolute $F3A0; { Address to call with Basic USR3         }
USRTB4 : Integer Absolute $F3A2; { Address to call with Basic USR4         }
USRTB5 : Integer Absolute $F3A4; { Address to call with Basic USR5         }
USRTB6 : Integer Absolute $F3A6; { Address to call with Basic USR6         }
USRTB7 : Integer Absolute $F3A8; { Address to call with Basic USR7         }
USRTB8 : Integer Absolute $F3AA; { Address to call with Basic USR8         }
USRTB9 : Integer Absolute $F3AC; { Address to call with Basic USR9         }
LINL40 : Byte Absolute    $F3AE; { Width for SCREEN 0 (default 37)         }
LINL32 : Byte Absolute    $F3AF; { Width for SCREEN 1 (default 29)         }
LINLEN : Byte Absolute    $F3B0; { Width for the current text mode         }
CRTCNT : Byte Absolute    $F3B1; { Number of lines on screen               }
CLMLST : Byte Absolute    $F3B2; { Column space. It's uncertain what this  }
                                 { address actually stores                 }
TXTNAM : Integer Absolute $F3B3; { BASE(0) - SCREEN 0 name table           }
TXTCOL : Integer Absolute $F3B5; { BASE(1) - SCREEN 0 color table          }
TXTCGP : Integer Absolute $F3B7; { BASE(2) - SCREEN 0 char pattern table   }
TXTATR : Integer Absolute $F3B9; { BASE(3) - SCREEN 0 Sprite Attr. Table   }
TXTPAT : Integer Absolute $F3BB; { BASE(4) - SCREEN 0 Sprite Pattern Table }
T32NAM : Integer Absolute $F3B3; { BASE(5) - SCREEN 1 name table           }
T32COL : Integer Absolute $F3B5; { BASE(6) - SCREEN 1 color table          }
T32CGP : Integer Absolute $F3B7; { BASE(7) - SCREEN 1 char pattern table   }
T32ATR : Integer Absolute $F3B9; { BASE(8) - SCREEN 1 sprite attr.table    }
T32PAT : Integer Absolute $F3BB; { BASE(9) - SCREEN 1 sprite pattern table }
GRPNAM : Integer Absolute $F3B3; { BASE(10) - SCREEN 2 name table          }
GRPCOL : Integer Absolute $F3B5; { BASE(11) - SCREEN 2 color table         }
GRPCGP : Integer Absolute $F3B7; { BASE(12) - SCREEN 2 char pattern table  }
GRPATR : Integer Absolute $F3B9; { BASE(13) - SCREEN 2 sprite attr. table  }
GRPPAT : Integer Absolute $F3BB; { BASE(14) - SCREEN 2 sprite pattrn table }
MLTNAM : Integer Absolute $F3B3; { BASE(15) - SCREEN 3 name table          }
MLTCOL : Integer Absolute $F3B5; { BASE(16) - SCREEN 3 color table         }
MLTCGP : Integer Absolute $F3B7; { BASE(17) - SCREEN 3 char pattern table  }
MLTATR : Integer Absolute $F3B9; { BASE(18) - SCREEN 3 sprite attr. table  }
MLTPAT : Integer Absolute $F3BB; { BASE(19) - SCREEN 3 sprite pattrn table }
CLIKSW : Byte Absolute    $F3DB; { =0 when key press click disabled        }
                                 { =1 when key press click enabled         }
                                 { SCREEN ,,n will write to this address   }
CSRY   : Byte Absolute    $F3DC; { Current row-position of the cursor      }
CSRX   : Byte Absolute    $F3DD; { Current column-position of the cursor   }
CNSDFG : Byte Absolute    $F3DE; { =0 when function keys are not displayed }
                                 { =1 when function keys are displayed     }
RG0SAV : Byte Absolute    $F3DF; { Content of VDP(0) register (R#0)        }
RG1SAV : Byte Absolute    $F3E0; { Content of VDP(1) register (R#1)        }
RG2SAV : Byte Absolute    $F3E1; { Content of VDP(2) register (R#2)        }
RG3SAV : Byte Absolute    $F3E2; { Content of VDP(3) register (R#3)        }
RG4SAV : Byte Absolute    $F3E3; { Content of VDP(4) register (R#4)        }
RG5SAV : Byte Absolute    $F3E4; { Content of VDP(5) register (R#5)        }
RG6SAV : Byte Absolute    $F3E5; { Content of VDP(6) register (R#6)        }
RG7SAV : Byte Absolute    $F3E6; { Content of VDP(7) register (R#7)        }
STATFL : Byte Absolute    $F3E7; { Content of VDP(8) status register (S#0) }
TRGFLG : Byte Absolute    $F3E8; { Trigger buttons and spacebar state info }
                                 { 7 6 5 4 3 2 1 0         (0=pressed)     }
                                 { | | | |       +-- SpcBar, Trigger 0     }
                                 { | | | +---------- Stick 1, Trigger 1    }
                                 { | | +------------ Stick 1, Trigger 2    }
                                 { | +-------------- Stick 2, Trigger 1    }
                                 { +---------------- Stick 2, Trigger 2    }
FORCLR : Byte Absolute    $F3E9; { Foreground color                        }
BAKCLR : Byte Absolute    $F3EA; { Background color                        }
BDRCLR : Byte Absolute    $F3EB; { Border color                            }
MAXUPD : Array[0..2] Of Byte Absolute $F3EC; { Jump instruction used by    }
                                             { Basic LINE command. The     }
                                             { used are: RIGHTC, LEFTC,    }
                                             { UPC and DOWNC               }
MINUPD : Array[0..2] Of Byte Absolute $F3EF; { Jump instruction used by    }
                                             { Basic LINE command. The     }
                                             { routines used are: RIGHTC,  }
                                             { LEFTC, UPC and DOWNC        }
ATRBYT : Byte Absolute    $F3F2; { Attribute byte (for graphical routines  }
                                 { it's used to read the color)            }
QUEUES : Integer Absolute $F3F3; { Address of the queue table              }
FRCNEW : Byte Absolute    $F3F5; { CLOAD flag. = 0 when CLOAD. = 255 when  }
                                 { CLOAD?                                  }
SCNCNT : Byte Absolute    $F3F6; { Key scan timing. When it's zero,the key }
                                 { scan routine will scan for pressed keys }
                                 { so characters can be written to the     }
                                 { the keyboard                            }
REPCNT : Byte Absolute    $F3F7; { This is the key repeat delay counter    }
                                 { When reaches zero the key will repeat.  }
PUTPNT : Integer Absolute $F3F8; { Address in the keyboard buffer where a  }
                                 { character will be written               }
GETPNT : Integer Absolute $F3FA; { Address in the keyboard buffer where    }
                                 { the next character is read              }
CS120  : Array[0..4] Of Byte Absolute $F3FC; { Cassette I/O parameters to  }
                                             { use for 1200 baud           }
CS240  : Array[0..4] Of Byte Absolute $F401; { Cassette I/O parameters to  }
                                             {  use for 2400 baud          }
LOW    : Integer Absolute $F406; { Signal delay when writing a 0 to tape   }
HIGH   : Integer Absolute $F408; { Signal delay when writing a 1 to tape   }
HEADER : Byte Absolute    $F40A; { Delay of tape header (sync.) block      }
ASPCT1 : Integer Absolute $F40B; { Horizontal / Vertical aspect for CIRCLE }
                                 { command                                 }
ASPCT2 : Integer Absolute $F40D; { Horizontal / Vertical aspect for CIRCLE }
                                 { command                                 }
ENDPRG : Array[0..4] Of Byte Absolute $F40F; { Pointer for the RESUME NEXT }
                                             { command                     }
ERRFLG : Byte Absolute    $F414; { Basic Error code                        }
LPTPOS : Byte Absolute    $F415; { Position of the printer head.Is read by }
                                 { Basic function LPOS and used by LPRINT  }
                                 { Basic command                           }
PRTFLG : Byte Absolute    $F416; { Printer output flag is read by OUTDO    }
                                 { =0 to print to screen                   }
                                 { =1 to print to printer                  }
NTMSXP : Byte Absolute    $F417; { Printer type is read by OUTDO           }
                                 { SCREEN ,,,n writes to this address      }
                                 { =0 for MSX printer                      }
                                 { =1 for non-MSX printer                  }
RAWPRT : Byte Absolute    $F418; { Raw printer output is read by OUTDO     }
                                 { =0 to convert tabs and unknown chars to }
                                 { spaces and remove graphical headers.    }
                                 { =1 to send data just like it gets it.   }
VLZADR : Integer Absolute $F419; { Address of data that is temporarilly    }
                                 { replaced by 'O' when Basic function     }
                                 { VAL("") is running.                     }
VLZDAT : Byte Absolute    $F41B; { Original value that was in the address  }
                                 { pointed to with VLZADR.                 }
CURLIN : Integer Absolute $F41C; { Line number the Basic interpreter is    }
                                 { working on, in direct mode it will be   }
                                 { filled with #FFFF                       }
CHSLOT : Byte Absolute    $F91F; { Character set SlotID. Unnofficial name  }
CHADDR : Integer Absolute $F920; { Character set address. Unnofficial name }
EXBRSA : Byte Absolute    $FAF8; { Slot address of the SUBROM              }
                                 { (Extended BIOS-ROM Slot Address)        }
DRVIN1 : Byte Absolute    $FB21; { Nr. of drives connected to disk intrf 1 }
DRVAD1 : Byte Absolute    $FB22; { Slot address of disk interface 1        }
DRVIN2 : Byte Absolute    $FB23; { Nr. of drives connected to disk intrf 2 }
DRVAD2 : Byte Absolute    $FB24; { Slot address of disk interface 2        }
DRVIN3 : Byte Absolute    $FB25; { Nr. of drives connected to disk intrf 3 }
DRVAD3 : Byte Absolute    $FB26; { Slot address of disk interface 3        }
DRVIN4 : Byte Absolute    $FB27; { Nr. of drives connected to disk intrf 4 }
DRVAD4 : Byte Absolute    $FB28; { Slot address of disk interface 4        }
INSFLG : Byte Absolute    $FCA8; { Insert Key On/Off                       }
CSRSW  : Byte Absolute    $FCA9; { Show/Hide the cursor                    }
CAPST  : Byte Absolute    $FCAB; { Caps lock On/Off                        }
SCRMOD : Byte Absolute    $FCAF; { Current screen number                   }
EXPTBL : Array[0..3] Of Byte Absolute $FCC1; { Slot 0 to 3.                }
                                             { #80 = expanded              }
                                             { #00 = not expanded          }
                                             { Also slot address of the    }
                                             { main BIOS-ROM.              }
SLTTBL : Array[0..3] Of Byte Absolute $FCC5; { Mirror of slot 0 to 3       }
                                             { secondary slot selection    }
                                             { register                    }
SLTTBA : Byte Absolute    $FFFF; { (all slots) Secondary slot select       }
                                 { register. Reading returns the inverted  }
                                 { previously written value.               }

(* Thanks to 2012 MSX Assembly Page for constants above *)
