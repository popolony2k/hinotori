(**<testload.pas>
  * Loadable module library sample test.
  * CopyLeft (c) since 1995 by PopolonY2k.
  *)
Program TestLoadable;

(**
  *
  * $Id: testload.pas 128 2020-07-08 17:51:23Z popolony2k $
  * $Author: popolony2k $
  * $Date: 2020-07-08 14:51:23 -0300 (Wed, 08 Jul 2020) $
  * $Revision: 128 $
  * $HeadURL: https://svn.code.sf.net/p/oldskooltech/code/msx/trunk/msxdos/pascal/testload.pas $
  *)

{$i types.pas}
{$i loadable.pas}


(**
  * Routine that will be stored inside the loadable module.
  *)
Procedure TestEntryNoParms;
Begin
  WriteLn( 'FIRST ROUTINE CALLED' );
End;

(**
  * Routine that will be stored inside the loadable module.
  * @param nParm The passed parameter;
  *)
Procedure TestEntry1Parm( nParm : Integer );
Begin
  WriteLn( 'SECOND ROUTINE CALLED WITH PARAMETER ->  ', nParm );
End;

(**
  * This routine is a dummy routine to be used as an end of loadable module
  * delimiter.
  *)
Procedure EndOfLibrary;
Begin
End;

(**
  * These external routines prototype points to the address where the stored
  * routines will be placed at loading time.
  *)
Procedure MyRoutine; External $C000;
Procedure MyRoutine2( nParm : Integer ); External $C100;


(*
 * Internal functions.
 *)

(**
  * Initialize a buffer with zeroes.
  * @param buffer The buffer that will be initialized;
  * @param nBufferSize The buffer size;
  *)
Procedure InitBuffer( Var buffer; nBufferSize : Integer );
Begin
  FillChar( buffer, nBufferSize, 0 );
End;


(**
  * Main program.
  *)
Var

     handle : TLibraryHandle;
     ret    : TLibraryResult;
     entry  : TLibraryEntry;

Begin
  (* Open a loadable module to store the desired functions *)
  ret := OpenLibrary( 'mytest.dll', LibraryModeCreate, handle );

  If( ret = LibSuccess )  Then
    WriteLn( 'OpenLibrary - Success' )
  Else
    WriteLn( 'OpenLibrary - Error' );

  (* Write the first entry to the loadable module file *)
  InitBuffer( entry, SizeOf( entry ) );

  With entry Do
  Begin
    strEntryName  := 'TestEntryNoParms';
    nEntryAddress := Addr( TestEntryNoParms );
    nEntrySize    := ( Addr( TestEntry1Parm ) - Addr( TestEntryNoParms ) );
  End;

  ret := WriteLibraryEntry( handle, entry );

  If( ret = LibSuccess )  Then
    WriteLn( 'WriteLibraryEntry( TestEntryNoParms ) - Success' )
  Else
    WriteLn( 'WriteLibraryEntry( TestEntryNoParms ) - Error' );

  (* Write the second entry to the loadable module file *)
  InitBuffer( entry, SizeOf( entry ) );

  With entry Do
  Begin
    strEntryName  := 'TestEntry1Parm';
    nEntryAddress := Addr( TestEntry1Parm );
    nEntrySize    := ( Addr( EndOfLibrary ) - Addr( TestEntry1Parm ) );
  End;

  ret := WriteLibraryEntry( handle, entry );

  If( ret = LibSuccess )  Then
    WriteLn( 'WriteLibraryEntry( TestEntry1Parm ) - Success' )
  Else
    WriteLn( 'WriteLibraryEntry( TestEntry1Parm ) - Error' );

  (* Loading and executing all stored entries *)
  entry.strEntryName  := 'TestEntryNoParms';
  entry.nEntryAddress := $C000;
  ret := LoadLibraryEntry( handle, entry, False );

  If( ret = LibSuccess )  Then
  Begin
    WriteLn( 'CALLING MODULE ROUTINE -> TestEntryNoParms' );
    MyRoutine;
  End
  Else
    WriteLn( 'LoadLibraryEntry( TestEntryNoParms ) - Error' );

  entry.strEntryName  := 'TestEntry1Parm';
  entry.nEntryAddress := $C100;
  ret := LoadLibraryEntry( handle, entry, False );

  If( ret = LibSuccess )  Then
  Begin
    WriteLn( 'CALLING MODULE ROUTINE -> TestEntry1Parm' );
    MyRoutine2( 1000 );
  End
  Else
    WriteLn( 'LoadLibraryEntry( TestEntry1Parm ) - Error' );

  ret := CloseLibrary( handle );

  If( ret = LibSuccess )  Then
    WriteLn( 'CloseLibrary - Success' )
  Else
    WriteLn( 'CloseLibrary - Error' );
End.
