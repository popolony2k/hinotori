(*<msxbios.pas>
 * MSX-BIOS management function library.
 * CopyLeft (c) 1995-2024 by PopolonY2k.
 * CopyLeft (c) since 2024 by Hinotori Team.
 *)

(*
 * This module depends on folowing include files (respect the order):
 * - /system/types.pas;
 *)

(**
  * MSXBIOS struct and data definitions
  *)
const     ctMaxSlots        = 4;    { Max. MSX slots           }
          ctMaxSecSlots     = 4;    { Max. MSX secondary slots }



(**
  * Return the Slot number for use in BIOS calls like
  * CALSLT, WRTSLT, RDSLT. Check MSX technical information
  * for details;
  * Slot calculation described below:
  *
  * FxxxSSPP
  * |   ||||
  * |   ||++--- Primary slot number (0-3)
  * |   ++----- Secondary slot number (0-3)
  * +---------- If secondary slot number specified
  * @param nPrimarySlot The primary slot number to compose the
  * @see TSlotNumber;
  * @param nSecondarySlot The secondary slot number to compose the
  * @see TSlotNumber;
  *)
function MakeSlotNumber( nPrimarySlot, nSecondarySlot : byte ) : TSlotNumber;
begin
  MakeSlotNumber := ( nPrimarySlot + 128 ) or ( nSecondarySlot shl 2 );
end;

(**
  * Retrieve the slot number splited in Primary and secondary slot
  * for a given composite slot number;
  * @param nSlotNumber The composite slot number;
  * @param nPrimarySlot The primary slot number retrieved;
  * @param nSecondarySlot The secondary slot number retrieved;
  *)
procedure SplitSlotNumber( nSlotNumber : TSlotNumber;
                           var nPrimarySlot, nSecondarySlot : byte );
begin
  nPrimarySlot   := nSlotNumber and 3;
  nSecondarySlot := ( nSlotNumber and 12 ) shr 2;
end;

(* MSXBIOS Routines to support slots management *)

(**
  * Write a byte to specified memory/slot position.
  * @param nSlotNumber The @see TSlotNumber containing the slot information;
  * @param nAddr Memory address;
  * @param nData Data to write;
  *)
procedure WRSLT( nSlotNumber : TSlotNumber; nAddr : integer; nData : byte );
begin
  inline( $ED/$5B/nData/          { LD DE, (nData)      }
          $3A/nSlotNumber/        { LD A, (nSlotNumber) }
          $2A/nAddr/              { LD HL, (nAddr)      }
          $CD/$14/$00/            { CALL WRSLT          }
          $FB                     { EI                  }
        );
end;

(**
  * Retrieve a data from specified Slot/Address;
  * @param nSlotNumber The @see TSlotNumber containing the slot information;
  * @param nAddr Address to retrieve data;
  *)
function RDSLT( nSlotNumber : TSlotNumber; nAddr : integer ) : byte;
begin
  inline( $3A/nSlotNumber/        { LD A, (nSlotNumber) }
          $2A/nAddr/              { LD HL,(nAddr)       }
          $CD/$0C/$00/            { CALL RDSLT          }
          $32/nSlotNumber/        { LD (nSlotNumber), A }
          $FB                     { EI                  }
        );

  RDSLT := nSlotNumber;
end;

(**
  * Switches to indicated slot at indicated page.
  * @param nSlotNumber The @see TSlotNumber containing the slot information;
  * @param nPage The Page to enable;
  *)
procedure ENASLT( nSlotNumber : TSlotNumber; nPage : byte );
begin
  nPage := nPage shl 6;
  inline( $3A/nPage/              { LD A, (nPage)       }
          $67/                    { LD H, A             }
          $3A/nSlotNumber/        { LD A, (nSlotNumber) }
          $CD/$24/$00/            { CALL ENASLT         }
          $FB                     { EI                  } );
end;

(**
  * Perform an inter-slot call through CALSLT MSX-BIOS
  * call.
  * @param regs The register struct to pass and receive
  * data to/from call;
  *)
procedure CALSLT( var regs : TRegs );
var
        nA, nF         : byte;
        nHL, nDE, nBC  : integer;
        nIX, nIY       : integer;
begin
  nA  := regs.A;
  nHL := regs.HL;
  nDE := regs.DE;
  nBC := regs.BC;
  nIX := regs.IX;
  nIY := Swap( regs.IY );

  inline( $F5/                  { PUSH AF      ; Push all registers  }
          $C5/                  { PUSH BC                            }
          $D5/                  { PUSH DE                            }
          $E5/                  { PUSH HL                            }
          $DD/$E5/              { PUSH IX                            }
          $FD/$E5/              { PUSH IY                            }
          $3A/nA/               { LD A , (nA )                       }
          $ED/$4B/nBC/          { LD BC, (nBC)                       }
          $ED/$5B/nDE/          { LD DE, (nDE)                       }
          $2A/nHL/              { LD HL, (nHL)                       }
          $DD/$2A/nIX/          { LD IX, (nIX)                       }
          $FD/$2A/nIY/          { LD IY, (nIY)                       }
          $CD/$1C/$00/          { CALL &H001C; CALL CALSLT           }
          $32/nA/               { LD (nA ), A                        }
          $ED/$43/nBC/          { LD (nBC), BC                       }
          $ED/$53/nDE/          { LD (nDE), DE                       }
          $22/nHL/              { LD (nHL), HL                       }
          $DD/$22/nIX/          { LD (nIX), IX                       }
          $FD/$22/nIY/          { LD (nIY), IY                       }
          $F5/                  { PUSH AF                            }
          $E1/                  { POP HL                             }
          $22/nF/               { LD (nF), HL                        }
          $FD/$E1/              { POP YI       ; Pop all registers   }
          $DD/$E1/              { POP IX                             }
          $E1/                  { POP HL                             }
          $D1/                  { POP DE                             }
          $C1/                  { POP BC                             }
          $F1/                  { POP AF                             }
          $FB                   { EI                                 }
        );

  (* Update the caller register struct *)
  regs.A  := nA;
  regs.F  := nF;
  regs.BC := nBC;
  regs.DE := nDE;
  regs.HL := nHL;
  regs.IY := nIY;
  regs.IX := nIX;
end;
