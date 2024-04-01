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
  * Identifier type
  *)
type TIdentifierType = ( IDENT_VARIABLE, 
                         IDENT_TARGETS, 
                         IDENT_COMMAND,
                         IDENT_REMARK );

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
  identType   : TIdentifierType;
end;

(**
  * Makefile build handle used by parsing and build routines.
  *)
 type TMakeHandle = record
   bIsOpen       : boolean;        { Make file is open     }
   hFile         : text;           { Make file handle      }
   lstIdentifier : TLinkedList;    { Make variable list    }
   strLastError  : TString;        { Last processing error }        
 end;


(**
  * Helper function used by debug only operations,
  * @param handle reference to a valid TMakeHandle with data;
  *)
procedure __PrintDebug( var handle : TMakeHandle );
var
    pItem     : PLinkedListItem;
    pair      : TIdentifierPair;

begin
  pItem := GetFirstLinkedListItem( handle.lstIdentifier );

  while( pItem <> nil )  do
  begin
    Move( pItem^.pValue^, pair, sizeof( pair ) );
    WriteLn( 'Item Name  -> ', pair.strName );
    WriteLn( 'Item Value -> ', pair.strValue );
    Write( 'Item type    -> ' );

    case pair.identType of
      TIdentifierType.IDENT_COMMAND  : WriteLn( 'COMMAND' );
      TIdentifierType.IDENT_REMARK   : WriteLn( 'REMARK' );
      TIdentifierType.IDENT_TARGETS  : WriteLn( 'TARGETS' );
      TIdentifierType.IDENT_VARIABLE : WriteLn( 'VARIABLE' );
    end;
    pItem := GetNextLinkedListItem( handle.lstIdentifier );
  end;
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
    CreateLinkedList( handle.lstIdentifier, sizeof( TIdentifierPair ) );
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
    DestroyLinkedList( handle.lstIdentifier );
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
const 
       __ctCSI   = '['; { Control Sequence Introducer.
                          On Unix is '[', on MSXDOS is empty char }
var
       strLine   : TString;
       bMustRead : boolean;
       bRet      : boolean;
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
    Write( #27, __ctCSI, 'D' );
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
    * Check identifier type.
    * @param strToken The token to be checked;
    *)
  function __CheckIdentifier( var strToken : TString ) : TIdentifierType;
  var
        identType : TIdentifierType;
        nPosToken : integer;
        nPosRem   : integer;
        nDiff     : integer;

  begin
    (* Check variables *)
    nPosToken := Pos( '=', strToken );
    nPosRem   := Pos( '#', strToken );
    nDiff     := ( nPosRem - nPosToken );

    (* Check targets and command *)
    if( nDiff = 0 )  then
    begin
      nPosToken := Pos( ':', strToken );
      nPosRem   := Pos( '#', strToken );
      nDiff     := ( nPosRem - nPosToken );

      if( nDiff = 0 )  then
        identType := TIdentifierType.IDENT_COMMAND
      else
      begin
        if( ( ( nPosRem > 0 ) and ( nPosToken = 0 ) ) or 
            ( ( nPosRem > 0 ) and ( nDiff < 0 ) ) ) then
          identType := TIdentifierType.IDENT_REMARK
        else
        begin
          identType := TIdentifierType.IDENT_TARGETS;

          if( ( nDiff > 0 ) and ( nPosRem < nPosToken) )  then
            identType := TIdentifierType.IDENT_REMARK;
        end;
      end;
    end
    else
    begin
      if( ( ( nPosRem > 0 ) and ( nPosToken = 0 ) ) or 
          ( ( nPosRem > 0 ) and ( nDiff < 0 ) ) ) then
        identType := TIdentifierType.IDENT_REMARK
      else
      begin
        identType := TIdentifierType.IDENT_VARIABLE;

        if( ( nDiff > 0 ) and ( nPosRem < nPosToken ) )  then
          identType := TIdentifierType.IDENT_REMARK;
      end;
    end;

    __CheckIdentifier := identType;
  end;

  (**
    * Find the identifier based on its name;
    * @param strName The identifier name to find;
    * The function return the pointer to the requested identifier or
    * nil if not found;
    *)
  function __FindIdentifier( var strName : TString ) : PIdentifierPair;
  var
        pItem  : PLinkedListItem;
        pPair  : PIdentifierPair;
        bFound : boolean;
         
  begin
    bFound := false;
    pItem  := GetFirstLinkedListItem( handle.lstIdentifier );

    while( not bFound and ( pItem <> nil ) ) do
    begin
      pItem  := GetNextLinkedListItem( handle.lstIdentifier );
      pPair  := {Ptr}( Addr( pItem^.pValue ) );
      bFound := ( pPair^.strName = strName );
    end;

    if( not bFound )  then
      pPair := nil;
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
        strValue := Copy( strValue, 1, ( nPos - 1 ) );
        strValue := Trim( strValue );
        { TODO: implement variable reference (or copy) }
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
            strValue := strValue + ' ' + Trim( strLine );
          end;
        end
        else
          handle.strLastError := 'Error reading makefile';
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
        chToken   : char;
        pItem     : PLinkedListItem;
        tokenList : TLinkedList;
        pair      : TIdentifierPair;
        identType : TIdentifierType;

  begin
    bRet      := true;
    bMustRead := true;
    identType := __CheckIdentifier( strLine );

    case identType of
      TIdentifierType.IDENT_VARIABLE :  chToken := '=';
      TIdentifierType.IDENT_TARGETS  :  chToken := ':'; 
    end;

    if( identType in [ TIdentifierType.IDENT_VARIABLE, 
                       TIdentifierType.IDENT_TARGETS ] )  then
      begin
        CreateLinkedList( tokenList, sizeof( TIdentifierValue ) );
        nCount := SplitString( strLine, chToken, tokenList );
        
        if( nCount > 0 )  then
        begin
          nCount := 0;
          pItem  := GetFirstLinkedListItem( tokenList );

          while( bRet and ( pItem <> nil ) )  do
          begin
            pair.identType := identType;

            if( ( nCount mod 2 ) = 0 )  then
              Move( pItem^.pValue^, pair.strName, sizeof( pair.strName ) )
            else
            begin
              Move( pItem^.pValue^, pair.strValue, sizeof( pair.strValue ) );

              if( __ParseValue( pair.strValue ) )  then
                AddLinkedListItem( handle.lstIdentifier, {Ptr}( Addr( pair ) ) )
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
        end;

        DestroyLinkedList( tokenList );
      end
      else
      begin
        { TODO: command processing }
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
    nCursor     := 0;
    aCursor[0]  := '|';
    aCursor[1]  := '/';
    aCursor[2]  := '-';
    aCursor[3]  := '\';
    bMustRead   := true;

    Write( 'Processing ( )' );
    Write( #27, __ctCSI, 'D' );
  
    while( bRet and not eof( handle.hFile ) ) do
    begin
      if( bMustRead )  then
        bRet := __ReadFile;

      if( bRet )  then
        bRet := __Parse;
    end;

    Write( #27, __ctCSI, 'D' );
    Write( '*' );
    Write( #27, __ctCSI, 'C' );
    WriteLn;
  end;

  MkBuild := bRet;
end;
