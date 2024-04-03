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
type TIdentifierType = ( IDENT_NONE,
                         IDENT_VARIABLE, 
                         IDENT_TARGETS, 
                         IDENT_COMMAND,
                         IDENT_REMARK );

(**
  * Variable data struct.
  *)
type PIdentifierName  = ^TIdentifierName;
     TIdentifierName  = string[20];
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
  * Target data structure.
  *)
type PTarget = ^TTarget;
     TTarget = record
  target        : TIdentifierPair; { Target name/prereq.   }
  commandList   : TLinkedList;     { Command list          }
end;

(**
  * Makefile build handle used by parsing and build routines.
  *)
 type TMakeHandle = record
   bIsOpen       : boolean;        { Make file is open     }
   hFile         : text;           { Make file handle      }
   variableList  : TLinkedList;    { Make variable list    }
   targetList    : TLinkedList;    { Make target list      }
   strLastError  : TString;        { Last processing error }        
 end;


(**
  * Helper function used by debug only operations,
  * @param handle reference to a valid TMakeHandle with data;
  *)
procedure __PrintDebug( var handle : TMakeHandle );
var
    pItem     : PLinkedListItem;
    pCmdItem  : PLinkedListItem;
    pair      : TIdentifierPair;
    target    : TTarget;
    command   : TIdentifierValue;

begin
  pItem := GetFirstLinkedListItem( handle.variableList );

  WriteLn;
  
  if( pItem <> nil )  then
    WriteLn( 'VARIABLES ======');

  WriteLn;
  
  while( pItem <> nil )  do
  begin
    Move( pItem^.pValue^, pair, sizeof( pair ) );
    WriteLn( 'Item Name  -> ', pair.strName );
    WriteLn( 'Item Value -> ', pair.strValue );
    WriteLn( '-----------------------' );

    pItem := GetNextLinkedListItem( handle.variableList );
  end;

  pItem := GetFirstLinkedListItem( handle.targetList );

  Writeln;

  if( pItem <> nil )  then
    WriteLn( 'TARGETS ======');

  WriteLn;

  while( pItem <> nil )  do
  begin
    Move( pItem^.pValue^, target, sizeof( target ) );
    WriteLn( 'Item Name  -> ', target.target.strName );
    WriteLn( 'Item Value -> ', target.target.strValue );

    pCmdItem := GetFirstLinkedListItem( target.commandList );

    if( pCmdItem <> nil )  then
      WriteLn( 'COMMANDS ======');

    while( pCmdItem <> nil )  do
    begin
      Move( pCmdItem^.pValue^, command, sizeof( command ) );
      WriteLn( 'CMD -> ', command );
      pCmdItem := GetNextLinkedListItem( target.commandList );
    end;

    WriteLn( '-----------------------' );

    pItem := GetNextLinkedListItem( handle.targetList );
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
    CreateLinkedList( handle.variableList, sizeof( TIdentifierPair ) );
    CreateLinkedList( handle.targetList, sizeof( TTarget ) );
  end;

  MkOpen := ( handle.bIsOpen );
end;

(**
 * Close a previously open make file.
 * @param handle The handle of a makefile previously opened by @see MkOpen;
 * The function will return true if the operation was successfull otherwise false;
 *)
function MkClose( var handle : TMakeHandle ) : boolean;
var
      pItem     : PLinkedListItem;
      target    : TTarget;

begin
  if( handle.bIsOpen )  then
  begin
    DestroyLinkedList( handle.variableList );

    (* Destroy target list and its command list *)
    pItem := GetFirstLinkedListItem( handle.targetList );

    while( pItem <> nil )  do
    begin
      Move( pItem^.pValue^, target, sizeof( target ) );
      DestroyLinkedList( target.commandList );
      pItem := GetNextLinkedListItem( handle.targetList );
    end;

    DestroyLinkedList( handle.targetList );

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
       strLine      : TString;
       bMustRead    : boolean;
       bRet         : boolean;
       nCursor      : byte;
       aCursor      : array[0..3] of char;
       pTargets     : PTarget;

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
    * Process a command in @see strLine;
    *)
  function __ProcessCommand : boolean;
  begin
    Writeln( 'COMMAND -> ', strLine );
    { TODO: FINISH command processing. Add variable macro substitution here }
    { Add multi-line command processing like variable content processing }
    __ProcessCommand := true;
  end;

  (**
    * Return the identifier type for a given token.
    * @param strToken The token to be checked;
    *)
  function __GetIdentifier( var strToken : TString ) : TIdentifierType;
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
      begin
        if( Length( Trim( strToken ) ) = 0 )  then
          identType := TIdentifierType.IDENT_NONE
        else
          identType := TIdentifierType.IDENT_COMMAND;
      end
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

    __GetIdentifier := identType;
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
    pItem  := GetFirstLinkedListItem( handle.variableList );

    while( not bFound and ( pItem <> nil ) ) do
    begin
      pItem  := GetNextLinkedListItem( handle.variableList );
      pPair  := {Ptr}( Addr( pItem^.pValue ) );
      bFound := ( pPair^.strName = strName );
    end;

    if( not bFound )  then
      pPair := nil;

    __FindIdentifier := pPair;
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
        nCount     : integer;
        bRet       : boolean;
        chToken    : char;
        pItem      : PLinkedListItem;
        pTemp      : PLinkedListItem;
        tokenList  : TLinkedList;
        target     : TTarget;
        pair       : TIdentifierPair;
        pPair      : PIdentifierPair;
        identType  : TIdentifierType;

  begin
    bRet      := true;
    bMustRead := true;
    identType := __GetIdentifier( strLine );

    case identType of
      TIdentifierType.IDENT_VARIABLE :  chToken := '=';
      TIdentifierType.IDENT_TARGETS  :  chToken := ':'; 
    end;

    if( identType in [ TIdentifierType.IDENT_VARIABLE, 
                       TIdentifierType.IDENT_TARGETS ] )  then
    begin
      CreateLinkedList( tokenList, sizeof( TIdentifierValue ) );
      nCount := SplitString( strLine, chToken, tokenList );
      
      (* Process identifier *)
      if( nCount > 0 )  then
      begin
        nCount := 0;
        pItem  := GetFirstLinkedListItem( tokenList );

        case identType of
          TIdentifierType.IDENT_VARIABLE : 
            pPair := {Ptr}( Addr( pair ) );

          TIdentifierType.IDENT_TARGETS  :
          begin
            CreateLinkedList( target.commandList, sizeof( TIdentifierValue ) );
            pPair := {Ptr}( Addr( target.target ) );
          end;
        end;

        pPair^.identType := identType;

        while( bRet and ( pItem <> nil ) )  do
        begin
          if( ( nCount mod 2 ) = 0 )  then
            Move( pItem^.pValue^, pPair^.strName, sizeof( pPair^.strName ) )
          else
          begin
            Move( pItem^.pValue^, pPair^.strValue, sizeof( pPair^.strValue ) );

            if( __ParseValue( pPair^.strValue ) )  then
            begin
              case identType of
                TIdentifierType.IDENT_VARIABLE :
                begin 
                  pTemp := AddLinkedListItem( handle.variableList, 
                                              {Ptr}( Addr( pPair^ ) ) );
                  bRet := ( pTemp <> nil );
                end;
                TIdentifierType.IDENT_TARGETS  :
                begin
                  pTemp := AddLinkedListItem( handle.targetList, 
                                              {Ptr}( Addr( target ) ) );
                  bRet := ( pTemp <> nil );

                  if( bRet )  then
                    Move( pTemp^.pValue, pTargets, sizeof( pTargets ) );
                end;
              end;

              if( not bRet )  then
                handle.strLastError := 'Not enough memory -> ' + strLine;
            end
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
      end
      else
      begin
        handle.strLastError := 'Invalid identifier ' + strLine;
        bRet := false; 
      end;

      DestroyLinkedList( tokenList );
    end
    else
    begin  (* Commands processing *)
      if( ( pTargets <> nil ) and ( Trim( strLine ) <> '' ) )  then
      begin
        bRet := ( AddLinkedListItem( pTargets^.commandList, 
                                     {Ptr}( Addr( strLine ) ) ) <> nil );
        
        if( bRet )  then
        begin
          handle.strLastError := 'Not enough memory -> '  + strLine;
        end;
      end;

      __DoProgress;
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
    nCursor    := 0;
    aCursor[0] := '|';
    aCursor[1] := '/';
    aCursor[2] := '-';
    aCursor[3] := '\';
    bMustRead  := true;
    pTargets   := nil;

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
