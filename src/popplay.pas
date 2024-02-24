(*<popplay.pas>
 * The Pop!Art VGM player engine for MSX computers.
 *
 * CopyLeft (c) since 1995 by PopolonY2k.
 *)

Program PopArtVGMPlayer;

(**
  *
  * $Id: popplay.pas 128 2020-07-08 17:51:23Z popolony2k $
  * $Author: popolony2k $
  * $Date: 2020-07-08 14:51:23 -0300 (Wed, 08 Jul 2020) $
  * $Revision: 128 $
  * $HeadURL: https://svn.code.sf.net/p/oldskooltech/code/msx/trunk/msxdos/pascal/popplay.pas $
  *)

(*
 * This module depends on folowing include files (respect the order):
 * - hooks.pas;
 * - systypes.pas;
 * - types.pas;
 * - sndchips.pas;
 * - ay8910.pas;
 * - scc.pas;
 * - opl4.pas;
 * - y8950.pas;
 * - ym2413.pas;
 * - ym2151.pas;
 * - wait.pas;
 * - sndtypes.pas;
 * - sndreset.pas;
 * - msxbios.pas;
 * - extbio.pas;
 * - vgmtypes.pas;
 * - maprdefs.pas;
 * - math.pas;
 * - math32.pas;
 * - longjmp.pas;
 * - vgmplay.pas;
 * - vgmmem.pas;
 *)

(**
  * Variables to be shared with other external executable modules
  * like the POPVGM.COM;
  *)
Var
        nVgmDataAddr      : Integer;
        nChipsAddr        : Integer;


{$c-,u-,a+,x+}

{$i hooks.pas}
{$i systypes.pas}
{$i types.pas}
{$i sndchips.pas}
{$i ay8910.pas}
{$i scc.pas}
{$i opl4.pas}
{$i y8950.pas}
{$i ym2413.pas}
{$i ym2151.pas}
{$i wait.pas}
{$i sndtypes.pas}
{$i sndreset.pas}
{$i msxbios.pas}
{$i extbio.pas}
{$i vgmtypes.pas}
{$i maprdefs.pas}
{$i math.pas}
{$i math32.pas}
{$i longjmp.pas}
{$i vgmplay.pas}
{$i vgmmem.pas}


(* Main block variables *)

Var
        ptrVgmData  : PVGMData;
        ptrChips    : PSoundChips;

Begin
  WriteLn( 'Press ESC key to exit.' );
  WriteLn( 'Playing' );

  ptrVgmData := Ptr( nVGMDataAddr );
  ptrChips   := Ptr( nChipsAddr );

  PlayVGM( ptrVgmData^, ptrChips^ );

  ReleaseVGM( ptrVgmData^ );
  ResetChips( ptrChips^ );

  {Dispose( ptrVgmData );
  Dispose( ptrChips );}
End.
