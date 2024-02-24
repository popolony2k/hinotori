(*<popvgm.pas>
 * The Pop!Art VGM player engine for MSX computers.
 *
 * CopyLeft (c) since 1995 by PopolonY2k.
 *)

Program PopArtVGMLoader;

(**
  *
  * $Id: popvgm.pas 128 2020-07-08 17:51:23Z popolony2k $
  * $Author: popolony2k $
  * $Date: 2020-07-08 14:51:23 -0300 (Wed, 08 Jul 2020) $
  * $Revision: 128 $
  * $HeadURL: https://svn.code.sf.net/p/oldskooltech/code/msx/trunk/msxdos/pascal/popvgm.pas $
  *)

(*
 * This module depends on folowing include files (respect the order):
 * - hooks.pas;
 * - systypes.pas;
 * - system.pas;
 * - types.pas;
 * - sysvars.pas;
 * - databufr.pas;
 * - msxdos.pas;
 * - msxdos2.pas;
 * - msxbios.pas;
 * - dos2file.pas;
 * - sltsrch.pas;
 * - sndchips.pas;
 * - ay8910.pas;
 * - scc-i.pas;
 * - opl4-i.pas;
 * - y8950-i.pas;
 * - ym2413-i.pas;
 * - ym2151-i.pas;
 * - sndtypes.pas;
 * - sndstart.pas;
 * - vgmtypes.pas;
 * - extbio.pas;
 * - maprdefs.pas;
 * - maprbase.pas;
 * - maprallc.pas;
 * - maprpage.pas;
 * - vgmfile.pas;
 * - vgmmem.pas;
 *)

(**
  * Variables to be shared with other external executable modules
  * like the POPPLAYER.CHN;
  *)
Var
        nVgmDataAddr      : Integer;
        nChipsAddr        : Integer;

{$c-,u-,a+,x+}

{$i hooks.pas}
{$i systypes.pas}
{$i system.pas}
{$i types.pas}
{$i sysvars.pas}
{$i databufr.pas}
{$i msxdos.pas}
{$i msxdos2.pas}
{$i msxbios.pas}
{$i dos2file.pas}
{$i sltsrch.pas}
{$i sndchips.pas}
{$i scc-i.pas}
{$i opl4-i.pas}
{$i y8950-i.pas}
{$i ym2413-i.pas}
{$i ym2151-i.pas}
{$i sndtypes.pas}
{$i sndstart.pas}
{$i vgmtypes.pas}
{$i extbio.pas}
{$i maprdefs.pas}
{$i maprbase.pas}
{$i maprallc.pas}
{$i maprpage.pas}
{$i vgmfile.pas}
{$i vgmmem.pas}


(**
  * Engine's player constants.
  *)
Const
              ctEngineMinorVersion = 0;   { Engine's major version }
              ctEngineMajorVersion = 0;   { Engine's minor version }


(**
  * Show the engine's help.
  *)
Procedure ShowHelp;
Begin
  Write( 'Usage: ' );
  WriteLn( 'popvgm <file_name>' );
End;


(* Main block variables *)

Var
        ptrVgmData   : PVGMData;
        ptrChips     : PSoundChips;
        strFileName  : TFileName;
        fpPlayerFile : File;

Begin
  WriteLn( 'Pop!Art vrs ', ctEngineMajorVersion, '.', ctEngineMinorVersion );
  WriteLn( 'CopyLeft (c) since 1995 by PopolonY2k.' );
  Write( 'Check newer versions of this software at ' );
  WriteLn( 'http://www.popolony2k.com.br' );
  WriteLn;

  If( ParamCount = 1 )  Then
  Begin
    New( ptrVgmData );
    New( ptrChips );

    nVgmDataAddr := Ord( ptrVgmData );
    nChipsAddr   := Ord( ptrChips );
    strFileName  := ParamStr( ParamCount );

    InitChips( ptrChips^ );

    WriteLn( 'Opening VGM file [' + strFileName + ']' );
    OpenVGM( strFileName, ptrVgmData^ );

    (*
     * Check the opening status *)
    Case ptrVgmData^.status Of
      StateSuccessfullyLoaded :
        Begin
          Assign( fpPlayerFile, 'POPPLAY.CHN' );
          Chain( fpPlayerFile );
        End;

      StateNotEnoughMemory :
        WriteLn( 'Not enough memory for this song' );

      StateNoMemoryMapper :
        WriteLn( 'Memory mapper required. No mapper found' );

      StateUninitialized,
      StateInvalidFileFormat,
      StateInvalidHeaderData :
        WriteLn( 'Invalid file' );
    End;

    ReleaseVGM( ptrVgmData^ );
    Dispose( ptrVgmData );
    Dispose( ptrChips );
  End
  Else
    ShowHelp;
End.
