(*<intr.pas>
 * Interrupt handling manager implementation for Turbo Pascal.
 * CopyLeft (c) 1995-2024 by PopolonY2k.
 * CopyLeft (c) since 2024 by Hinotori Team.
 *)

(*
 * This module depends on following include files (respect the order):
 * -
 *)


(**
  * Modules types and constants.
  *)
Type TInterruptAddress     = Array[0..2] Of Byte;   { Interrupt address }

(**
  * Supported interrupt handler modes.
  *)
Type TInterruptMode = ( SaferInterruptMode,
                        FasterInterruptMode );



(**
  * Interrupt handler manager used internally to call the registered interrupt
  * user function.
  * This interrupt handler is a safe implementation of interrupts for use
  * with Turbo Pascal procedures because it saves all registers between
  * the procedure call.
  * This function is slower than the high frequency interrupt handler
  * implementation.
  * WARNING: Do not call this function directly.
  *)
Procedure __SaferInterruptHandler;
Begin
  InLine( $F3/          { DI          }
          $F5/          { PUSH AF     }
          $C5/          { PUSH BC     }
          $D5/          { PUSH DE     }
          $E5/          { PUSH HL     }
          $D9/          { EXX         }
          $F5/          { PUSH AF'    }
          $C5/          { PUSH BC'    }
          $D5/          { PUSH DE'    }
          $E5/          { PUSH HL'    }
          $DD/$E5/      { PUSH IX     }
          $FD/$E5/      { PUSH IY     }
          $21/$00/$00/  { LD HL, word }
          $E5/          { PUSH HL     }
          $CD/$00/$00/  { CALL nnnn   }
          $FD/$E1/      { POP IY      }
          $DD/$E1/      { POP IX      }
          $E1/          { POP HL      }
          $D1/          { POP DE      }
          $C1/          { POP BC      }
          $F1/          { POP AF      }
          $D9/          { EXX         }
          $E1/          { POP HL'     }
          $D1/          { POP DE'     }
          $C1/          { POP BC'     }
          $F1/          { POP AF'     }
          $C3/$00/$00   { JP nnnn     } );
End;

(**
  * Interrupt handler manager used internally to call the registered interrupt
  * user function.
  * This interrupt handler is a faster implementation of interrupts for use
  * with Turbo Pascal procedures.
  * WARNING: Do not call this function directly.
  *)
Procedure __FasterInterruptHandler;
Begin
  InLine( $F3/          { DI          }
          $E5/          { PUSH HL     }
          $21/$00/$00/  { LD HL, word }
          $E5/          { PUSH HL     }
          $CD/$00/$00/  { CALL nnnn   }
          $E1/          { POP HL      }
          $C3/$00/$00   { JP nnnn     } );
End;

(**
  * Set a interrupt function to the interrupt vector.
  * @param nUserIntrFnAddr The user interrupt procedure address;
  * @param nUserParm The parameter passed by the user caller;
  * @param interruptMode The interrupt handler type. Below are described
  * the two supported types:
  *    - SaferInterruptMode - This mode saves all registers and recover its
  *      state after interrupt was called. This mode is very useful for almost
  *      all application's kind because the interrupt can use other functions
  *      including the Turbo Pascal runtime functions without take care about
  *      register status;
  *    - FasterInterruptMode - This is a faster but unsafe mode. When
  *      the application is using this mode, it need to take care about the
  *      status of all registers. Useful when the application is doing
  *      something very well controlled;
  * @param aOldIntr Reference to the address of the previous interrupt
  * procedure. The returned value will be useful to restore the old interrupt
  * function by calling the @see RestoreInterrupt function;
  *)
Procedure SetInterrupt( nUserIntrFnAddr,
                        nUserParm     : Integer;
                        interruptMode :TInterruptMode;
                        Var aOldIntr  : TInterruptAddress );
Var
        nLoUserParm,
        nHiUserParm,
        nLoUserIntrFnAddr,
        nHiUserIntrFnAddr,
        nIMIntr1,
        nIMIntr2,
        nIMIntr3           : Byte;
        nIntrFnAddr        : Integer;
        aIM1Intr           : TInterruptAddress Absolute $0038;

Const   ctSafeLoUserParm       = 15;   { Safer interrupt parameters }
        ctSafeHiUserParm       = 16;
        ctSafeLoUserIntrFnAddr = 19;
        ctSafeHiUserIntrFnAddr = 20;
        ctSafeIMIntr1          = 34;
        ctSafeIMIntr2          = 35;
        ctSafeIMIntr3          = 36;

        ctFastLoUserParm       = 3;    { Faster interrupt parameters }
        ctFastHiUserParm       = 4;
        ctFastLoUserIntrFnAddr = 7;
        ctFastHiUserIntrFnAddr = 8;
        ctFastIMIntr1          = 10;
        ctFastIMIntr2          = 11;
        ctFastIMIntr3          = 12;

Begin
  Move( aIM1Intr, aOldIntr, SizeOf( aOldIntr ) );

  If( interruptMode = SaferInterruptMode )  Then
  Begin
    nIntrFnAddr       := Addr( __SaferInterruptHandler );
    nLoUserParm       := ctSafeLoUserParm;
    nHiUserParm       := ctSafeHiUserParm;
    nLoUserIntrFnAddr := ctSafeLoUserIntrFnAddr;
    nHiUserIntrFnAddr := ctSafeHiUserIntrFnAddr;
    nIMIntr1          := ctSafeIMIntr1;
    nIMIntr2          := ctSafeIMIntr2;
    nIMIntr3          := ctSafeIMIntr3;
  End
  Else
  Begin
    nIntrFnAddr       := Addr( __FasterInterruptHandler );
    nLoUserParm       := ctFastLoUserParm;
    nHiUserParm       := ctFastHiUserParm;
    nLoUserIntrFnAddr := ctFastLoUserIntrFnAddr;
    nHiUserIntrFnAddr := ctFastHiUserIntrFnAddr;
    nIMIntr1          := ctFastIMIntr1;
    nIMIntr2          := ctFastIMIntr2;
    nIMIntr3          := ctFastIMIntr3;
  End;

  { Pass user parameter to the user interrupt handler }
  Mem[nIntrFnAddr+nLoUserParm] := Lo( nUserParm );
  Mem[nIntrFnAddr+nHiUserParm] := Hi( nUserParm );

  { Pass the user interrupt handler to the new interrupt handler manager }
  Mem[nIntrFnAddr+nLoUserIntrFnAddr] := Lo( nUserIntrFnAddr );
  Mem[nIntrFnAddr+nHiUserIntrFnAddr] := Hi( nUserIntrFnAddr );

  { Pass the old interrupt procedure to the new interrupt handler manager }
  Mem[nIntrFnAddr+nIMIntr1] := aIM1Intr[0];
  Mem[nIntrFnAddr+nIMIntr2] := aIM1Intr[1];
  Mem[nIntrFnAddr+nIMIntr3] := aIM1Intr[2];

  { Change the old interrupt handler by the new interrupt handler manager }
  InLine( $F3 );  { DI }
  aIM1Intr[1] := Lo( nIntrFnAddr );
  aIM1Intr[2] := Hi( nIntrFnAddr );
  InLine( $FB );  { EI }
End;

(**
  * Restore the interrupt address passed by parameter.
  * @param aIntr The interrupt address to be restored;
  *)
Procedure RestoreInterrupt( Var aIntr : TInterruptAddress );
Var
      aIM1Intr : TInterruptAddress Absolute $0038;

Begin
  InLine( $F3 );  { DI }
  Move( aIntr, aIM1Intr, SizeOf( aIntr ) );
  InLine( $FB );  { EI }
End;
