(*<maprbase.pas>
 * Memory mapper management implementation using MSXDOS2 EXTBIO calls.
 * CopyLeft (c) since 1995 by PopolonY2k.
 *)

(**
  *
  * $Id: maprbase.pas 145 2021-05-05 02:54:06Z popolony2k $
  * $Author: popolony2k $
  * $Date: 2021-05-04 23:54:06 -0300 (Tue, 04 May 2021) $
  * $Revision: 145 $
  * $HeadURL: https://svn.code.sf.net/p/oldskooltech/code/msx/trunk/msxdos/pascal/maprbase.pas $
  *)

(*
 * This module depends on folowing include files (respect the order):
 * - types.pas;
 * - maprdefs.pas;
 * - msxbios.pas;
 * - extbio.pas;
 *)

(**
  * Modules types and definitions.
  *)

(**
  * The addresses below are related to the mapper routines jump table.
  *)
Const
           ctALL_SEG       : Byte = $00; { Allocate a 16Kb segment           }
           ctFRE_SEG       : Byte = $03; { Free a 16Kb segment               }
           ctRD_SEG        : Byte = $06; { Read byte from address a:AL to A  }
           ctWR_SEG        : Byte = $09; { Write byte from E to address A:HL }
           ctCAL_SEG       : Byte = $0C; { Inter-segment call                }
           ctCALLS         : Byte = $0F; { Inter-segment call                }
           ctPUT_PH        : Byte = $12; { Put segment into page (HL)        }
           ctGET_PH        : Byte = $15; { Get current segment for page (HL) }
           ctPUT_P0        : Byte = $18; { Put segment into page 0           }
           ctGET_P0        : Byte = $1B; { Get current segment for page 0    }
           ctPUT_P1        : Byte = $1E; { Put segment into page 1           }
           ctGET_P1        : Byte = $21; { Get current segment for page 1    }
           ctPUT_P2        : Byte = $24; { Put segment into page 2           }
           ctGET_P2        : Byte = $27; { Get current segment for page 2    }
           ctPUT_P3        : Byte = $2A; { Put segment into page 3           }
           ctGET_P3        : Byte = $2D; { Get current segment for page 3    }


(**
  * Internal module data.
  *)
Var
          aGetPageEntry : Array[0..3] Of Byte;  { GET_Pn function entries    }
          aPutPageEntry : Array[0..3] Of Byte;  { PUT_Pn function entries    }



(**
  * Init modeule internal handlers.
  *)
Function InitMapperInternals : Boolean;
Var
        bRet   : Boolean;

Begin
  bRet := HasInstalledHook;

  If( bRet )  Then
  Begin
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
  End;

  InitMapperInternals := bRet;
End;

(**
  * Initialize the mapper engine.
  * @param handle Reference to mapper handle containing information about
  * connected mapper;
  *)
Function InitMapper( Var handle : TMapperHandle ) : Boolean;
Var
        bRet   : Boolean;
        regs   : TRegs;

Begin
  bRet := InitMapperInternals;

  If( bRet )  Then
  Begin
    (* Get the mapper variable table *)
    FillChar( regs, SizeOf( regs ), 0 );

    With regs Do
    Begin
      D := ctDOS2Memory;
      E := 1;
      ExtBIO( regs );
      handle.nMapperVarTblAddr := HL;
      handle.nPriMapperSlotId  := A;
    End;

    (* Get the mapper support routines *)
    FillChar( regs, SizeOf( regs ), 0 );

    With regs Do
    Begin
      D := ctDOS2Memory;
      E := 2;
      ExtBIO( regs );
      handle.nTotalMapperSegs   := A;
      handle.nFreePriMapperSegs := C;
      handle.nStartAddrJumpTbl  := HL;
      bRet := ( A <> 0 );
    End;
  End;

  InitMapper := bRet;
End;

(**
  * Get the pointer to the mapper array containing all mappers connected
  * to computer.
  * @param handle Reference to previsously allocated mapper handle;
  *)
Function GetMapperVarTable( Var handle : TMapperHandle ) : PMapperVarTable;
Begin
  GetMapperVarTable := Ptr( handle.nMapperVarTblAddr );
End;
