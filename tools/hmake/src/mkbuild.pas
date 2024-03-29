(*<mkbuild.pas>
 * Hinotori make file parse and build routines.
 *
 * CopyLeft (c) 1995-2024 by PopolonY2k.
 * CopyLeft (c) since 2024 by Hinotori Team.
 *)

(*
 * This module depends on folowing include files (respect the order):
 *
 * - /system/types.pas;
 * - /collectn/lnkdlist.pas;
 * - /util/helpstr.pas;
 *)


(**
  * Variable data types.
  *)
type PVariableName  = ^TVariableName;
     TVariableName  = string[10];
     PVariableValue = ^TVariableValue;
     TVariableValue = TString;

(**
  * Variable data structure.
  *)
type PMakeVariablePair = ^TMakeVariablePair;
     TMakeVariablePair = record
  strKey       : TVariableName;
  strValue     : TVariableValue;
end;

(**
  * Makefile build handle used by parsing and build routines.
  *)
 type TMakeHandle = record
   bIsOpen     : boolean;        { Make file is open }
   hFile       : text;           { Make file handle  }
   mkVars      : TLinkedList;    { Make variables    }
 end;


(**
 * Open a make file for processing.
 * @param strFileName The make file name to open;
 * @param handle A @see TMakeHandle of the opened makefile
 * that will be used to perform all make operations;
 * The function will return true for success operation 
 * otherwise false;
 *)
function MkOpen( strFileName : TFileName; var handle : TMakeHandle ) : boolean;
begin
  {$i-}
  Assign( handle.hFile, strFileName );
  Reset( handle.hFile );
  {$i+}

  handle.bIsOpen := ( IOResult = 0 );

  if( handle.bIsOpen )  then
    CreateLinkedList( handle.mkVars, sizeof( TMakeVariablePair ) );

  MkOpen := ( handle.bIsOpen );
end;

(**
 * Close a previously open make file.
 * @param handle The handle of a makefile previously opened by @see MkOpen;
 * The function will return true if the operation was successfull otherwise false;
 *)
function MkClose( var handle : TMakeHandle ) : boolean;
begin
  if( handle.bIsOpen )  then
  begin
    DestroyLinkedList( handle.mkVars );
    {$i-}
    Close( handle.hFile );
    {$i+}
    handle.bIsOpen := false;
  end;

  MkClose := ( IOResult = 0 );
end;

(**
 * Parse and build an open make file. This function will parse the makefile, creating
 * all needed infrastructure needed by making a Pascal project;
 * @param handle The handle of a makefile previously opened by @see MkOpen;
 * The function will return true if the operation was successfull otherwise false;
 *)
function MkBuild( var handle : TMakeHandle ) : boolean;
var
      bRet      : boolean;
      strLine   : TString;
      chCSI     : char;
      nCursor   : byte;
      aCursor   : array[0..3] of char;

  
  (**
    * Parse all make file valid tokens;
    * If the parsing is successful bRet is set to true
    * otherwise false;
    *)
  procedure __Parse;
  var
        nCount    : integer;
        pItem     : PLinkedListItem;
        tokenList : TLinkedList;
        pair      : TMakeVariablePair;

  begin
    CreateLinkedList( tokenList, sizeof( TVariableValue ) );
    nCount := SplitString( strLine, '=', tokenList );
    WriteLn( 'NumItems -> ', nCount );

    if( nCount > 0 )  then
    begin
      nCount := 0;
      pItem  := GetFirstLinkedListItem( tokenList );

      while( pItem <> nil )  do
      begin
        if( ( nCount mod 2 ) = 0 )  then
          Move( pItem^.pValue^, pair.strKey, sizeof( pair.strKey ) )
        else
        begin
          Move( pItem^.pValue^, pair.strValue, sizeof( pair.strValue ) );
          AddLinkedListItem( handle.mkVars, {Ptr}( Addr( pair ) ) );
        end;

        nCount := Succ( nCount );
        pItem  := GetNextLinkedListItem( tokenList );
      end;
      
      pItem := GetFirstLinkedListItem( handle.mkVars );

      while( pItem <> nil )  do
      begin
        Move( pItem^.pValue^, pair, sizeof( pair ) );
        WriteLn( 'Item Key   -> ', pair.strKey );
        WriteLn( 'Item Value -> ', pair.strValue );
        pItem := GetNextLinkedListItem( handle.mkVars );
      end;
    end;
  end;

(*
 * MkNuid main routine
 *)
begin
  bRet := handle.bIsOpen;

  if( bRet )  then
  begin
    (* Control Sequence Introducer - On Unix is '[', on MSXDOS is empty char *)
    chCSI       := '[';
    nCursor     := 0;
    aCursor[0]  := '|';
    aCursor[1]  := '/';
    aCursor[2]  := '-';
    aCursor[3]  := '\';

    Write( 'Processing ( )' );
    Write( #27, chCSI, 'D' );
  
    while( bRet and not eof( handle.hFile ) ) do
    begin
      (*
       * Progress indicator.
       *)
      Write( #27, chCSI, 'D' );
      Write( aCursor[nCursor] );

      if( nCursor = 3 )  then
        nCursor := 0
      else
        nCursor := nCursor + 1;

      ReadLn( handle.hFile, strLine );
      __Parse;
    end;

    Write( #27, chCSI, 'D' );
    Write( '*' );
    Write( #27, chCSI, 'C' );
    WriteLn;
  end;

  MkBuild := bRet;
end;
