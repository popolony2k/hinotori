(*<sndstart.pas>
 * Types and functions to manage all kind of soundchips supported by the
 * MSX standard.
 * CopyLeft (c) since 1995 by PopolonY2k.
 *)

(**
  *
  * $Id: sndstart.pas 128 2020-07-08 17:51:23Z popolony2k $
  * $Author: popolony2k $
  * $Date: 2020-07-08 14:51:23 -0300 (Wed, 08 Jul 2020) $
  * $Revision: 128 $
  * $HeadURL: https://svn.code.sf.net/p/oldskooltech/code/msx/trunk/msxdos/pascal/sndstart.pas $
  *)

(*
 * This module depends on folowing include files (respect the order):
 * - hooks.pas;
 * - systypes.pas;
 * - system.pas;
 * - types.pas;
 * - sysvars.pas;
 * - sndtypes.pas;
 * - msxbios.pas;
 * - sndchips.pas;
 * - scc-i.pas;
 * - ym2151-i.pas;
 * - ym2413-i.pas;
 * - opl4-i.pas;
 * - y8950-i.pas;
 *)

(**
  * Host frequency divisor.
  *)
Const
              ctSamples50Hz = 882;    { 50Hz host frequency divisor }
              ctSamples60Hz = 735;    { 60Hz host frequency divisor }


(**
  * Initialize all chips used by the loaded VGM.
  * CAUTION: Do not call this function before any other that manipulates
  * memory on any slots because the @see FindSCC function can corrupt data
  * on any slots when it is searching by the SCC interface, so call this
  * function before any other, like @see OpenVGM, in your program;
  * @param chips Reference to a structure that will receive all chips
  * information;
  *)
Procedure InitChips( Var chips : TSoundChips );
Begin
  With chips Do
  Begin
    (* Looking for SCC *)
    FindSCC( nSCCPrimarySlot, nSCCSecondarySlot );

    (* Looking for YM2151 *)
    FindYM2151( nYM2151PrimarySlot, nYM2151SecondarySlot );

    (* Looking for YM2413 *)
    nYM2413SlotNumber := FindYM2413;

    (* Looking for YMF278B *)
    hasYMF278B := FindOPL4;

    (* Looking for Y8950 *)
    hasY8950 := FindY8950;

    (* Host frequency divisor *)
    If( GetHostFrequency = Timing50Hz )  Then
      nHostFreqDivisor := ctSamples50Hz
    Else
      nHostFreqDivisor := ctSamples60Hz;

    { TODO: Check optimization by size in future.
    If( ( RDSLT( EXPTBL[0], ROMVR1 ) ShR 7 ) = 0 )  Then
      nHostFreqDivisor := ctSamples60Hz
    Else
      nHostFreqDivisor := ctSamples50Hz;
    }

    (* Save and reset the current H.TIMI and H.KEYI hooks *)
    ResetHook( H_TIMI, hookHTIMI );
    ResetHook( H_KEYI, hookHKEYI );
  End;
End;
