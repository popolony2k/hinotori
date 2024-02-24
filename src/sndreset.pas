(*<sndreset.pas>
 * Types and functions to manage all kind of soundchips supported by the
 * MSX standard.
 * CopyLeft (c) since 1995 by PopolonY2k.
 *)

(**
  *
  * $Id: sndreset.pas 128 2020-07-08 17:51:23Z popolony2k $
  * $Author: popolony2k $
  * $Date: 2020-07-08 14:51:23 -0300 (Wed, 08 Jul 2020) $
  * $Revision: 128 $
  * $HeadURL: https://svn.code.sf.net/p/oldskooltech/code/msx/trunk/msxdos/pascal/sndreset.pas $
  *)

(*
 * This module depends on folowing include files (respect the order):
 * - hooks.pas;
 * - systypes.pas;
 * - types.pas;
 * - sndchips.pas;
 * - ay8910.pas;
 * - scc.pas;
 * - ym2151.pas;
 * - ym2413.pas;
 * - opl4.pas;
 * - y8950.pas;
 *)


(**
  * Reset all sound chips specified by the @see TSoundChips structure.
  * @param chips The @see TSoundChips structure containing all sound chips
  * used by the library.
  *)
Procedure ResetChips( Var chips : TSoundChips );
Var
       hookOld : THookCode;

Begin
  With chips Do
  Begin
    (* Reset the AY8910 *)
    ResetAY8910;

    (* Reset YM2413 *)
    If( nYM2413SlotNumber <> ctUnitializedSlot )  Then
      ResetYM2413;

    (* Reset SCC *)
    If( ( nSCCPrimarySlot <> ctUnitializedSlot ) And
        ( nSCCSecondarySlot <> ctUnitializedSlot ) ) Then
      ResetSCC( nSCCPrimarySlot, nSCCSecondarySlot );

    (* Reset YM2151 *)
    If( ( nYM2151PrimarySlot <> ctUnitializedSlot ) And
        ( nYM2151SecondarySlot <> ctUnitializedSlot ) )  Then
      ResetYM2151( nYM2151PrimarySlot, nYM2151SecondarySlot );

    (* Reset OPL4 *)
    If( hasYMF278B )  Then
      ResetOPL4;

    (* Reset Y8950 *)
    If( hasY8950 )  Then
      ResetY8950;

    (* Restore the saved H.TIMI and H.KEYI hooks *)
    SetHook( H_TIMI, hookHTIMI, hookOld );
    SetHook( H_KEYI, hookHKEYI, hookOld );
  End;
End;
