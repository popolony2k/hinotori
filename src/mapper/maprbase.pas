(*<maprbase.pas>
 * Memory mapper management implementation using MSXDOS2 EXTBIO calls.
 * CopyLeft (c) 1995-2024 by PopolonY2k.
 * CopyLeft (c) since 2024 by Hinotori Team.
 *)

(*
 * This module depends on folowing include files (respect the order):
 * - /system/types.pas;
 * - /mapper/maprdefs.pas;
 * - /bios/msxbios.pas;
 * - /bios/extbio.pas;
 *)

(**
  * Modules types and definitions.
  *)

(**
  * The addresses below are related to the mapper routines jump table.
  *)
const
           ctALL_SEG       : byte = $00; { Allocate a 16Kb segment           }
           ctFRE_SEG       : byte = $03; { Free a 16Kb segment               }
           ctRD_SEG        : byte = $06; { Read byte from address a:AL to A  }
           ctWR_SEG        : byte = $09; { Write byte from E to address A:HL }
           ctCAL_SEG       : byte = $0C; { Inter-segment call                }
           ctCALLS         : byte = $0F; { Inter-segment call                }
           ctPUT_PH        : byte = $12; { Put segment into page (HL)        }
           ctGET_PH        : byte = $15; { Get current segment for page (HL) }
           ctPUT_P0        : byte = $18; { Put segment into page 0           }
           ctGET_P0        : byte = $1B; { Get current segment for page 0    }
           ctPUT_P1        : byte = $1E; { Put segment into page 1           }
           ctGET_P1        : byte = $21; { Get current segment for page 1    }
           ctPUT_P2        : byte = $24; { Put segment into page 2           }
           ctGET_P2        : byte = $27; { Get current segment for page 2    }
           ctPUT_P3        : byte = $2A; { Put segment into page 3           }
           ctGET_P3        : byte = $2D; { Get current segment for page 3    }


(**
  * Internal module data.
  *)
var
          aGetPageEntry : array[0..3] of byte;  { GET_Pn function entries    }
          aPutPageEntry : array[0..3] of byte;  { PUT_Pn function entries    }



(**
  * Init modeule internal handlers.
  *)
function InitMapperInternals : boolean;
var
        bRet   : boolean;

begin
  bRet := HasInstalledHook;

  if( bRet )  then
  begin
    (* Initialize all GET pages entries *)
    aGetPageEntry[0] := ctGET_P0;
    aGetPageEntry[1] := ctGET_P1;
    aGetPageEntry[2] := ctGET_P2;
    aGetPageEntry[3] := ctGET_P3;

    (* Initialize all PUT pages entries *)
    aPutPageEntry[0] := ctPUT_P0;
    aPutPageEntry[1] := ctPUT_P1;
    aPutPageEntry[2] := ctPUT_P2;
    aPutPageEntry[3] := ctPUT_P3;
  end;

  InitMapperInternals := bRet;
end;

(**
  * Initialize the mapper engine.
  * @param handle Reference to mapper handle containing information about
  * connected mapper;
  *)
function InitMapper( var handle : TMapperHandle ) : boolean;
var
        bRet   : boolean;
        regs   : TRegs;

begin
  bRet := InitMapperInternals;

  if( bRet )  then
  begin
    (* Get the mapper variable table *)
    FillChar( regs, sizeof( regs ), 0 );

    with regs do
    begin
      D := ctDOS2Memory;
      E := 1;
      ExtBIO( regs );
      handle.nMapperVarTblAddr := HL;
      handle.nPriMapperSlotId  := A;
    end;

    (* Get the mapper support routines *)
    FillChar( regs, sizeof( regs ), 0 );

    with regs do
    begin
      D := ctDOS2Memory;
      E := 2;
      ExtBIO( regs );
      handle.nTotalMapperSegs   := A;
      handle.nFreePriMapperSegs := C;
      handle.nStartAddrJumpTbl  := HL;
      bRet := ( A <> 0 );
    end;
  end;

  InitMapper := bRet;
end;

(**
  * Get the pointer to the mapper array containing all mappers connected
  * to computer.
  * @param handle Reference to previsously allocated mapper handle;
  *)
function GetMapperVarTable( var handle : TMapperHandle ) : PMapperVarTable;
begin
  GetMapperVarTable := Ptr( handle.nMapperVarTblAddr );
end;
