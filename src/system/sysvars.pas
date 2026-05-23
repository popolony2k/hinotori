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

const

CGTABL : integer =        $0004; { Base addr of the MSX charset in ROM      }
VDP_DR : byte    =        $0006; { Base port address for VDP data read      }
VDP_DW : byte    =        $0007; { Base port address for VDP data write     }
ROMVR1 : byte    =        $002B; { Basic ROM version Official address       }
                        { 7 6 5 4 3 2 1 0                                   }
                        { | | | | +-+-+-+-- Character set                   }
                        { | | | |           0 = Japanese,                   }
                        { | | | |           1 = International,              }
                        { | | | |           2=Korean                        }
                        { | +-+-+---------- Date format                     }
                        { |                 0 = Y-M-D, 1 = M-D-Y, 2 = D-M-Y }
                        { +---------------- Default interrupt frequency     }
                        {                   0 = 60Hz, 1 = 50Hz              }
ROMVR2 : byte    =        $002C; { Basic ROM version - Official address     }
                        { 7 6 5 4 3 2 1 0                                   }
                        { | | | | +-+-+-+-- Keyboard type                   }
                        { | | | |           0 = Japanese, 1 = International }
                        { | | | |           2 = French (AZERTY),            }
                        { | | | |           3 = UK,                         }
                        { | | | |           4 = German (DIN)                }
                        { +-+-+-+---------- Basic version                   }
                        {                   0 = Japanese, 1 = International }
MSXVRS : byte    =        $002D; { MSX version number - Official address    }
                        { 0 = MSX 1                                         }
                        { 1 = MSX 2                                         }
                        { 2 = MSX 2+                                        }
                        { 3 = MSX turbo R                                   }
MSXMID : byte    =        $002E; { Bit 0: if 1 MSX-MIDI is present TR Only  }
RSRVED : byte    =        $002F; { Reserved                                 }

(* MSX System Variables located in Sub ROM *)

SROMID : integer =        $0000; { String "CD", ident. of MSX Sub ROM       }
STSCRN : integer =        $0002; { Exec address for startup screen on MSX 2 }
                                 { MSX 2+ or MSX turbo R.                   }
                                 { This is unofficial and undocumented addr }

(* MSX-DOS (DiskROM) System Variables located in RAM *)

(* These addresses are only initialized when a DiskROM is present *)
(* (e.g. when the machine has a diskdrive or a harddisk interface *)
(* connected).                                                    *)

Var

RAMAD0 : byte absolute    $F341; { Slot addr. of RAM in page 0 (DOS)       }
RAMAD1 : byte absolute    $F342; { Slot addr. of RAM in page 1 (DOS)       }
RAMAD2 : byte absolute    $F343; { Slot addr. of RAM in page 2 (DOS/BASIC) }
RAMAD3 : byte absolute    $F344; { Slot addr. of RAM in page 3 (DOS/BASIC) }
RAMADM : byte absolute    $F348; { Slot addr. of the main DiskROM          }

(* MSX System Variables located in RAM *)

(* This is the start of the MSX BIOS system area. *)

RDPRIM : array[0..4] of byte absolute  $F380; { Routine that reads from a  }
                                              { primary slot               }
WRPRIM : array[0..6] of byte absolute  $F385; { Routine that writes to a   }
                                              { primary slot               }
CLPRIM : array[0..13] of byte absolute $F38C; { Routine that calls a       }
                                              { routine in a primary slot  }
USRTB0 : integer absolute $F39A; { Address to call with Basic USR0         }
USRTB1 : integer absolute $F39C; { Address to call with Basic USR1         }
USRTB2 : integer absolute $F39E; { Address to call with Basic USR2         }
USRTB3 : integer absolute $F3A0; { Address to call with Basic USR3         }
USRTB4 : integer absolute $F3A2; { Address to call with Basic USR4         }
USRTB5 : integer absolute $F3A4; { Address to call with Basic USR5         }
USRTB6 : integer absolute $F3A6; { Address to call with Basic USR6         }
USRTB7 : integer absolute $F3A8; { Address to call with Basic USR7         }
USRTB8 : integer absolute $F3AA; { Address to call with Basic USR8         }
USRTB9 : integer absolute $F3AC; { Address to call with Basic USR9         }
LINL40 : byte absolute    $F3AE; { Width for SCREEN 0 (default 37)         }
LINL32 : byte absolute    $F3AF; { Width for SCREEN 1 (default 29)         }
LINLEN : byte absolute    $F3B0; { Width for the current text mode         }
CRTCNT : byte absolute    $F3B1; { Number of lines on screen               }
CLMLST : byte absolute    $F3B2; { Column space. It's uncertain what this  }
                                 { address actually stores                 }
TXTNAM : integer absolute $F3B3; { BASE(0) - SCREEN 0 name table           }
TXTCOL : integer absolute $F3B5; { BASE(1) - SCREEN 0 color table          }
TXTCGP : integer absolute $F3B7; { BASE(2) - SCREEN 0 char pattern table   }
TXTATR : integer absolute $F3B9; { BASE(3) - SCREEN 0 Sprite Attr. Table   }
TXTPAT : integer absolute $F3BB; { BASE(4) - SCREEN 0 Sprite Pattern Table }
T32NAM : integer absolute $F3B3; { BASE(5) - SCREEN 1 name table           }
T32COL : integer absolute $F3B5; { BASE(6) - SCREEN 1 color table          }
T32CGP : integer absolute $F3B7; { BASE(7) - SCREEN 1 char pattern table   }
T32ATR : integer absolute $F3B9; { BASE(8) - SCREEN 1 sprite attr.table    }
T32PAT : integer absolute $F3BB; { BASE(9) - SCREEN 1 sprite pattern table }
GRPNAM : integer absolute $F3B3; { BASE(10) - SCREEN 2 name table          }
GRPCOL : integer absolute $F3B5; { BASE(11) - SCREEN 2 color table         }
GRPCGP : integer absolute $F3B7; { BASE(12) - SCREEN 2 char pattern table  }
GRPATR : integer absolute $F3B9; { BASE(13) - SCREEN 2 sprite attr. table  }
GRPPAT : integer absolute $F3BB; { BASE(14) - SCREEN 2 sprite pattrn table }
MLTNAM : integer absolute $F3B3; { BASE(15) - SCREEN 3 name table          }
MLTCOL : integer absolute $F3B5; { BASE(16) - SCREEN 3 color table         }
MLTCGP : integer absolute $F3B7; { BASE(17) - SCREEN 3 char pattern table  }
MLTATR : integer absolute $F3B9; { BASE(18) - SCREEN 3 sprite attr. table  }
MLTPAT : integer absolute $F3BB; { BASE(19) - SCREEN 3 sprite pattrn table }
CLIKSW : byte absolute    $F3DB; { =0 when key press click disabled        }
                                 { =1 when key press click enabled         }
                                 { SCREEN ,,n will write to this address   }
CSRY   : byte absolute    $F3DC; { Current row-position of the cursor      }
CSRX   : byte absolute    $F3DD; { Current column-position of the cursor   }
CNSDFG : byte absolute    $F3DE; { =0 when function keys are not displayed }
                                 { =1 when function keys are displayed     }
RG0SAV : byte absolute    $F3DF; { Content of VDP(0) register (R#0)        }
RG1SAV : byte absolute    $F3E0; { Content of VDP(1) register (R#1)        }
RG2SAV : byte absolute    $F3E1; { Content of VDP(2) register (R#2)        }
RG3SAV : byte absolute    $F3E2; { Content of VDP(3) register (R#3)        }
RG4SAV : byte absolute    $F3E3; { Content of VDP(4) register (R#4)        }
RG5SAV : byte absolute    $F3E4; { Content of VDP(5) register (R#5)        }
RG6SAV : byte absolute    $F3E5; { Content of VDP(6) register (R#6)        }
RG7SAV : byte absolute    $F3E6; { Content of VDP(7) register (R#7)        }
STATFL : byte absolute    $F3E7; { Content of VDP(8) status register (S#0) }
TRGFLG : byte absolute    $F3E8; { Trigger buttons and spacebar state info }
                                 { 7 6 5 4 3 2 1 0         (0=pressed)     }
                                 { | | | |       +-- SpcBar, Trigger 0     }
                                 { | | | +---------- Stick 1, Trigger 1    }
                                 { | | +------------ Stick 1, Trigger 2    }
                                 { | +-------------- Stick 2, Trigger 1    }
                                 { +---------------- Stick 2, Trigger 2    }
FORCLR : byte absolute    $F3E9; { Foreground color                        }
BAKCLR : byte absolute    $F3EA; { Background color                        }
BDRCLR : byte absolute    $F3EB; { Border color                            }
MAXUPD : array[0..2] of byte absolute $F3EC; { Jump instruction used by    }
                                             { Basic LINE command. The     }
                                             { used are: RIGHTC, LEFTC,    }
                                             { UPC and DOWNC               }
MINUPD : array[0..2] of byte absolute $F3EF; { Jump instruction used by    }
                                             { Basic LINE command. The     }
                                             { routines used are: RIGHTC,  }
                                             { LEFTC, UPC and DOWNC        }
ATRBYT : byte absolute    $F3F2; { Attribute byte (for graphical routines  }
                                 { it's used to read the color)            }
QUEUES : integer absolute $F3F3; { Address of the queue table              }
FRCNEW : byte absolute    $F3F5; { CLOAD flag. = 0 when CLOAD. = 255 when  }
                                 { CLOAD?                                  }
SCNCNT : byte absolute    $F3F6; { Key scan timing. When it's zero,the key }
                                 { scan routine will scan for pressed keys }
                                 { so characters can be written to the     }
                                 { the keyboard                            }
REPCNT : byte absolute    $F3F7; { This is the key repeat delay counter    }
                                 { When reaches zero the key will repeat.  }
PUTPNT : integer absolute $F3F8; { Address in the keyboard buffer where a  }
                                 { character will be written               }
GETPNT : integer absolute $F3FA; { Address in the keyboard buffer where    }
                                 { the next character is read              }
CS120  : array[0..4] of byte absolute $F3FC; { Cassette I/O parameters to  }
                                             { use for 1200 baud           }
CS240  : array[0..4] of byte absolute $F401; { Cassette I/O parameters to  }
                                             {  use for 2400 baud          }
LOW    : integer absolute $F406; { Signal delay when writing a 0 to tape   }
HIGH   : integer absolute $F408; { Signal delay when writing a 1 to tape   }
HEADER : byte absolute    $F40A; { Delay of tape header (sync.) block      }
ASPCT1 : integer absolute $F40B; { Horizontal / Vertical aspect for CIRCLE }
                                 { command                                 }
ASPCT2 : integer absolute $F40D; { Horizontal / Vertical aspect for CIRCLE }
                                 { command                                 }
ENDPRG : array[0..4] of byte absolute $F40F; { Pointer for the RESUME NEXT }
                                             { command                     }
ERRFLG : byte absolute    $F414; { Basic Error code                        }
LPTPOS : byte absolute    $F415; { Position of the printer head.Is read by }
                                 { Basic function LPOS and used by LPRINT  }
                                 { Basic command                           }
PRTFLG : byte absolute    $F416; { Printer output flag is read by OUTDO    }
                                 { =0 to print to screen                   }
                                 { =1 to print to printer                  }
NTMSXP : byte absolute    $F417; { Printer type is read by OUTDO           }
                                 { SCREEN ,,,n writes to this address      }
                                 { =0 for MSX printer                      }
                                 { =1 for non-MSX printer                  }
RAWPRT : byte absolute    $F418; { Raw printer output is read by OUTDO     }
                                 { =0 to convert tabs and unknown chars to }
                                 { spaces and remove graphical headers.    }
                                 { =1 to send data just like it gets it.   }
VLZADR : integer absolute $F419; { Address of data that is temporarilly    }
                                 { replaced by 'O' when Basic function     }
                                 { VAL("") is running.                     }
VLZDAT : byte absolute    $F41B; { Original value that was in the address  }
                                 { pointed to with VLZADR.                 }
CURLIN : integer absolute $F41C; { Line number the Basic interpreter is    }
                                 { working on, in direct mode it will be   }
                                 { filled with #FFFF                       }
CHSLOT : byte absolute    $F91F; { Character set SlotID. Unnofficial name  }
CHADDR : integer absolute $F920; { Character set address. Unnofficial name }
EXBRSA : byte absolute    $FAF8; { Slot address of the SUBROM              }
                                 { (Extended BIOS-ROM Slot Address)        }
DRVIN1 : byte absolute    $FB21; { Nr. of drives connected to disk intrf 1 }
DRVAD1 : byte absolute    $FB22; { Slot address of disk interface 1        }
DRVIN2 : byte absolute    $FB23; { Nr. of drives connected to disk intrf 2 }
DRVAD2 : byte absolute    $FB24; { Slot address of disk interface 2        }
DRVIN3 : byte absolute    $FB25; { Nr. of drives connected to disk intrf 3 }
DRVAD3 : byte absolute    $FB26; { Slot address of disk interface 3        }
DRVIN4 : byte absolute    $FB27; { Nr. of drives connected to disk intrf 4 }
DRVAD4 : byte absolute    $FB28; { Slot address of disk interface 4        }
INSFLG : byte absolute    $FCA8; { Insert Key On/Off                       }
CSRSW  : byte absolute    $FCA9; { Show/Hide the cursor                    }
CAPST  : byte absolute    $FCAB; { Caps lock On/Off                        }
SCRMOD : byte absolute    $FCAF; { Current screen number                   }
EXPTBL : array[0..3] of byte absolute $FCC1; { Slot 0 to 3.                }
                                             { #80 = expanded              }
                                             { #00 = not expanded          }
                                             { Also slot address of the    }
                                             { main BIOS-ROM.              }
SLTTBL : array[0..3] of byte absolute $FCC5; { Mirror of slot 0 to 3       }
                                             { secondary slot selection    }
                                             { register                    }
SLTTBA : byte absolute    $FFFF; { (all slots) Secondary slot select       }
                                 { register. Reading returns the inverted  }
                                 { previously written value.               }

(* Thanks to 2012 MSX Assembly Page for constants above *)
