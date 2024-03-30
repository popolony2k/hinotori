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
  * Variable data struct.
  *)
type PIdentifierName  = ^TIdentifierName;
     TIdentifierName  = string[10];
     PIdentifierValue = ^TIdentifierValue;
     TIdentifierValue = TString;

(**
  * Identifier data structure.
  *)
type PIdentifierPair = ^TIdentifierPair;
     TIdentifierPair = record
  strName     : TIdentifierName;
  strValue    : TIdentifierValue;
end;

(**
  * Makefile build handle used by parsing and build routines.
  *)
 type TMakeHandle = record
   bIsOpen     : boolean;        { Make file is open  }
   hFile       : text;           { Make file handle   }
   mkVars      : TLinkedList;    { Make variable list }
   mkTargets   : TLinkedList;    { Make targets list  }
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
  begin
    CreateLinkedList( handle.mkVars, sizeof( TIdentifierPair ) );
    CreateLinkedList( handle.mkTargets, sizeof( TIdentifierPair ) );
  end;

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
      strLine   : TString;
      bMustRead : boolean;
      bRet      : boolean;
      chCSI     : char;
      nCursor   : byte;
      aCursor   : array[0..3] of char;


  (**
   * Show progress indicator.
   *)
  procedure __DoProgress;
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
  end;

  (**
    * Read comtent from file.
    * The function return true when operation is success
    * otherwise false;
    *)
  function __ReadFile : boolean;
  begin
      {$i-}
      ReadLn( handle.hFile, strLine );
      {$i+}
      __ReadFile := ( IOResult = 0 );
  end;
  
  (**
    * Parse identifier value.
    * @param strValue The value that will be parsed and the content
    * will return into the same variable;  
    *)
  function __ParseValue( var strValue : TString ) : boolean;
  var
         nPos   : integer;
         bRet   : boolean;

  begin
    bRet := true;

    repeat
      nPos := Pos( '\', strValue );

      if( nPos > 0 )  then
      begin
        { TODO : TRIM !!! }
        strValue := Copy( strValue, 1, ( nPos - 1 ) );
        bRet := __ReadFile;

        if( bRet )  then
        begin
          nPos := Pos( '\', strLine );

          (*
           * Already read data from file, process in the next loop.
           *)
          if( nPos <= 0 )  then
            bMustRead := ( ( Pos( ':', strLine ) = 0 ) and 
                           ( Pos( '=', strLine ) = 0 ) );

          if( bMustRead )  then
          begin
            { TODO: implement variable reference (or copy) }
            strValue := strValue + strLine;
          end;
        end;
      end;
    until( not bRet or ( nPos <= 0 ) );

    __ParseValue := bRet;  
  end;

  (**
    * Parse all make file valid tokens;
    * If the parsing is successful bRet is set to true
    * otherwise false;
    *)
  function __Parse : boolean;
  var
        nCount    : integer;
        bRet      : boolean;
        pItem     : PLinkedListItem;
        tokenList : TLinkedList;
        pair      : TIdentifierPair;

  begin
    CreateLinkedList( tokenList, sizeof( TIdentifierValue ) );
    nCount    := SplitString( strLine, '=', tokenList );
    bRet      := true;
    bMustRead := true;
    
    WriteLn( 'NumItems -> ', nCount );

    if( nCount > 0 )  then
    begin
      nCount := 0;
      pItem  := GetFirstLinkedListItem( tokenList );

      while( bRet and ( pItem <> nil ) )  do
      begin
        if( ( nCount mod 2 ) = 0 )  then
          Move( pItem^.pValue^, pair.strName, sizeof( pair.strName ) )
        else
        begin
          Move( pItem^.pValue^, pair.strValue, sizeof( pair.strValue ) );

          if( __ParseValue( pair.strValue ) )  then
            AddLinkedListItem( handle.mkVars, {Ptr}( Addr( pair ) ) )
          else
            bRet := false;
        end;

        if( bRet )  then
        begin
          nCount := Succ( nCount );
          pItem  := GetNextLinkedListItem( tokenList );
          __DoProgress;
        end;
      end;
      
      if( bRet )  then
      begin
        pItem := GetFirstLinkedListItem( handle.mkVars );

        while( pItem <> nil )  do
        begin
          Move( pItem^.pValue^, pair, sizeof( pair ) );
          WriteLn( 'Item Name  -> ', pair.strName );
          WriteLn( 'Item Value -> ', pair.strValue );
          pItem := GetNextLinkedListItem( handle.mkVars );
        end;
      end;
    end;

    __Parse := bRet;
  end;

(*
 * MkBuid main routine
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
    bMustRead   := true;

    Write( 'Processing ( )' );
    Write( #27, chCSI, 'D' );
  
    while( bRet and not eof( handle.hFile ) ) do
    begin
      if( bMustRead )  then
        bRet := __ReadFile;

      if( bRet )  then
        bRet := __Parse;
    end;

    Write( #27, chCSI, 'D' );
    Write( '*' );
    Write( #27, chCSI, 'C' );
    WriteLn;
  end;

  MkBuild := bRet;
end;
