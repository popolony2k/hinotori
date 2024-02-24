(*<Y8950.pas>
 * Library for the Y8950 (Philips Music Module) soundchip handling.
 * CopyLeft (c) 1995-2024 by PopolonY2k.
 * CopyLeft (c) since 2024 by Hinotori Team.
 *)

(*
 * This module depends on folowing include files (respect the order):
 * - /system/types.pas;
 * - /sndchips/sndchips.pas;
 *)

Const
       { Y8950 related constants }
       (*ctPortY8950RegisterWrite   : Byte = $C0;   { Y8950 reg. write port }*)
       ctPortY8950DataWrite       : Byte = $C1;   { Y8950 val. write port }
       ctY8950FMInitialSlotReg    : Byte = $20;   { Initial slot register }
       ctY8950FMFinalSlotReg      : Byte = $35;   { Final slot register }
       ctY8950FMInitialChannelReg : Byte = $C0;   { Initial channel register }
       ctY8950FMFinalChannelReg   : Byte = $C8;   { Final channel register }


(**
  * Write data to Y8950 sound chip using internal variable parameter;
  * @param __pSndChipArrayParms The Y8950 array address containing the
  * parameters like described below:
  * item[0] := Y8950 Port Register;
  * item[1] := Y8950 Port Data;
  *)
Procedure WriteY8950Direct{( __pSndChipArrayParms : Pointer )};
Begin
  (*
   * The ASM routine below is located in the .\ASM\ project folder
   * and was generated by INLASS.
   *)
  Inline(
          $2A/__pSndChipArrayParms  { LD HL,(__pSndChipArrayParms) }
          /$0E/$C0                  { LD C,Y8950REGWRITE           }
          /$ED/$A3                  { OUTI                         }
          /$DB/$C4                  { IN A,(Y8950STATUSREG)        }
          /$0C                      { INC C                        }
          /$ED/$A3                  { OUTI                         } );
End;

(**
  * Write data to Y8950 sound chip. This is a wrapper to the @see
  * WriteY8950Direct procedure.
  * @param nRegister The register index to write data;
  * @param nData The data to be written;
  *)
Procedure WriteY8950( nRegister, nData : Byte );
Var
         aY8950ArrayParms : Array[0..1] Of Byte;

Begin
  aY8950ArrayParms[0]  := nRegister;
  aY8950ArrayParms[1]  := nData;
  __pSndChipArrayParms := Ptr( Addr( aY8950ArrayParms ) );

  WriteY8950Direct{( __pSndChipArrayParms )};
End;

(**
  * Reset the Y8950 sound chip.
  * Check the chapter 2-5 (Channels and slots) of Yamaha Y8950 Application
  * Manual (MSX-AUDIO)
  *)
Procedure ResetY8950;
Var
         aY8950ArrayParms : Array[0..1] Of Byte;
         nRegister        : Integer;

Begin
  aY8950ArrayParms[1]  := 0;
  __pSndChipArrayParms := Ptr( Addr( aY8950ArrayParms ) );

  (* Reset FM slots *)
  For nRegister := ctY8950FMInitialSlotReg To ctY8950FMFinalSlotReg Do
  Begin
    aY8950ArrayParms[0] := nRegister;
    WriteY8950Direct{( __pSndChipArrayParms )};
    Delay( ctSndChipResetDelay );
  End;

  (* Reset FM Channels *)
  For nRegister := ctY8950FMInitialChannelReg To ctY8950FMFinalChannelReg Do
  Begin
    aY8950ArrayParms[0] := nRegister;
    WriteY8950Direct{( __pSndChipArrayParms )};
    Delay( ctSndChipResetDelay );
  End;
End;
