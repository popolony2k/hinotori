(*<mkhelper.pas>
 * Hinotori make helper routines for handling makefiles.
 *
 * CopyLeft (c) 1995-2024 by PopolonY2k.
 * CopyLeft (c) since 2024 by Hinotori Team.
 *)

(*
 * This module depends on folowing include files (respect the order):
 *
 * - /system/types.pas;
 * - /collectn/lnkdlist.pas;
 * - /memory/{platform}/pointer.pas;  (depends on architecture)
 * - /dos/dosutil.pas;
 * - ./make/mktypes.pas;
 * - ./make/{platform}}/mkoscall.pas   (depends on architecture)
 *)

(**
  * Return the identifier type for a given token.
  * param handle The @see TMakeHandle of a makefile that 
  * identifier will be retrieved;
  * @param strToken The token to be checked;
  *)
function MkIdentifierType( var handle : TMakeHandle; 
                           var strToken : TIdentifierValue ) : TIdentifierType;
  
  type __TVariableType = ( VARIABLE, TARGET );

  (**
    * Get a identifier type based on type passed as paraneter;
    * @param vType The variable type to check;
    *)
  function __GetIdentifierType( vType : __TVariableType ) : TIdentifierType;
  var
        identType  : TIdentifierType;
        nPosToken  : integer;

  begin
    (* Check variables *)
    if( vType = __TVariableType.VARIABLE )  then
      nPosToken := Pos( '=', strToken )
    else 
      nPosToken := Pos( ':', strToken );

    (* Check targets and command *)
    if( nPosToken = 0 )  then
    begin
      if( Length( Trim( strToken ) ) = 0 )  then
        identType := TIdentifierType.IDENT_NONE
      else
        identType := TIdentifierType.IDENT_NOP;
    end
    else
    begin
      if( vType = __TVariableType.VARIABLE )  then
        identType := TIdentifierType.IDENT_VARIABLE
      else
        identType := TIdentifierType.IDENT_TARGETS;
    end;

    __GetIdentifierType := identType;
  end;

var
       identType   : TIdentifierType;

begin
  (* TAB-indented lines with existing targets are always commands,
     regardless of '=' or ':' in their content (e.g. echo "x=y"). *)
  if( ( Length( strToken ) > 0 ) and
      ( strToken[1] = #9 ) and
      ( handle.targetList.nListSize > 0 ) )  then
    identType := TIdentifierType.IDENT_COMMAND
  else
  begin
    identType := __GetIdentifierType( __TVariableType.VARIABLE );

    if( identType in [TIdentifierType.IDENT_NONE,
                      TIdentifierType.IDENT_NOP] )  then
      identType := __GetIdentifierType( __TVariableType.TARGET );
  end;

  MkIdentifierType := identType;
end;

(**
  * Check if an indentifier is valid.
  * param handle The @see TMakeHandle of a makefile that 
  * will be checked;
  * @param pair The identifier that will be checked;
  *)
function MkCheckValidIdentifier( var handle : TMakeHandle; 
                                 var pair : TIdentifierPair ) : boolean;
var
    bRet     : boolean;
    nPos     : integer;
begin
  bRet := true;

  case pair.identType of
    TIdentifierType.IDENT_VARIABLE : 
    begin
      nPos := Pos( ':', pair.strValue ) + Pos( '=', pair.strValue );
      bRet := ( nPos = 0 );

      if( not bRet )  then
        handle.strLastError := 'Not supported variable referencing mode';
    end;
  end;

  MkCheckValidIdentifier := bRet;
end;

(**
  * Find the identifier based on its name;
  * param handle The @see TMakeHandle of open makefile;
  * @param strName The identifier name to find;
  * The function return the pointer to the requested identifier or
  * nil if not found;
  *)
function MkFindIdentifier( var handle : TMakeHandle; var strName : TIdentifierName ) : PIdentifierPair;
var
      pItem      : PLinkedListItem;
      pItemPair  : PIdentifierPair;
      pLastMatch : PIdentifierPair;

begin
  (* Walk the full list via raw pointers (no cursor mutation) and return the
     LAST matching entry so that later assignments override earlier ones,
     matching GNU make recursive-variable semantics. *)
  pLastMatch := nil;
  pItem      := handle.variableList.pFirstItem;

  while( pItem <> nil ) do
  begin
    Move( pItem^.pValue, pItemPair, sizeof( pItemPair ) );

    if( pItemPair^.strName = strName )  then
      pLastMatch := pItemPair;

    pItem := pItem^.pNextItem;
  end;

  MkFindIdentifier := pLastMatch;
end;

(**
  * Find a target based on its name;
  * param handle The @see TMakeHandle of open makefile;
  * @param strName The target name to find;
  * The function return the pointer to the requested target or
  * nil if not found;
  *)
function MkFindTarget( var handle : TMakeHandle; var strName : TIdentifierName ) : PTarget;
var
      pItem       : PLinkedListItem;
      pIdentItem  : PLinkedListItem;
      pItemTarget : PTarget;
      identName   : TIdentifierName;
      bFound      : boolean;
        
begin
  bFound := false;
  pItem  := GetFirstLinkedListItem( handle.targetList );

  while( not bFound and ( pItem <> nil ) ) do
  begin
    Move( pItem^.pValue, pItemTarget, sizeof( pItemTarget ) );
    pIdentItem := GetFirstLinkedListItem( pItemTarget^.targetNameList );
      
    while( not bFound and ( pIdentItem <> nil ) )  do
    begin
      Move( pIdentItem^.pValue^, identName, sizeof( identName ) );
      bFound := ( identName = strName );
      pIdentItem := GetNextLinkedListItem( pItemTarget^.targetNameList );
    end;

    pItem  := GetNextLinkedListItem( handle.targetList );
  end;

  if( not bFound )  then
    pItemTarget := nil;

  MkFindTarget := pItemTarget;
end;

(**
  * Check if a string has a special char.
  * @param string Reference to a string that will be checked;
  * @param charType The type of char to check;
  * The function return true if is wildcard otherwise false;
  *)
function MkStringHasChar( var strValue : TString; 
                          charType : TSpecialCharType ) : boolean;
var
      bRet  : boolean;
      aChar : array[CHAR_PERCENT..CHAR_ASTERISK_DOT] of TString;

begin
  aChar[CHAR_PERCENT]  := '%';
  aChar[CHAR_ASTERISK] := '*';
  aChar[CHAR_DOT]      := '.';
  aChar[CHAR_PERCENT_DOT]  := '%.';
  aChar[CHAR_ASTERISK_DOT] := '*.';

  bRet := ( Pos( aChar[charType], strValue ) > 0 );

  MkStringHasChar := bRet;
end;

(**
  * Check if target has a special char.
  * @param pair Reference to a pair that will be checked;
  * @param charType The type of char to check;
  * @param bCheckTarget Flag to check the Target value if set or
  * prerequisite if is reset;
  * The function return true if is wildcard otherwise false;
  *)
function MkPairHasChar( var pair : TIdentifierPair; 
                        charType : TSpecialCharType; 
                        bCheckTarget : boolean ) : boolean;
var
      bRet : boolean;

begin
  if( bCheckTarget )  then
    bRet := MkStringHasChar( pair.strName, charType )
  else
    bRet := MkStringHasChar( pair.strValue, charType );

  MkPairHasChar := bRet;
end;

(**
  * Test whether strName matches a pattern containing exactly one '%'.
  * On match, strStem receives the text that '%' matched and the function
  * returns true.  On no-match, strStem is unchanged and false is returned.
  * @param strPattern The pattern string (must contain '%');
  * @param strName The concrete name to test;
  * @param strStem On success, receives the matched stem;
  *)
function MkMatchPattern( var strPattern : TIdentifierName;
                         var strName    : TIdentifierName;
                         var strStem    : TIdentifierName ) : boolean;
var
      nPct    : integer;
      nPre    : integer;
      nSuf    : integer;
      strPre  : TIdentifierName;
      strSuf  : TIdentifierName;
      bRet    : boolean;

begin
  nPct := Pos( '%', strPattern );
  bRet := false;

  if( nPct > 0 )  then
  begin
    nPre   := nPct - 1;
    nSuf   := Length( strPattern ) - nPct;
    strPre := Copy( strPattern, 1, nPre );
    strSuf := Copy( strPattern, nPct + 1, nSuf );

    if( Length( strName ) >= ( nPre + nSuf ) )  then
    begin
      bRet := ( Copy( strName, 1, nPre ) = strPre );

      if( bRet and ( nSuf > 0 ) )  then
        bRet := ( Copy( strName, Length( strName ) - nSuf + 1, nSuf ) = strSuf );

      if( bRet )  then
        strStem := Copy( strName, nPre + 1, Length( strName ) - nPre - nSuf );
    end;
  end;

  MkMatchPattern := bRet;
end;

(**
  * Find a pattern target (e.g. %.o: %.c) that matches strName.
  * On match, strStem receives the stem and the function returns the target.
  * Returns nil when no pattern target matches.
  * @param handle The @see TMakeHandle of open makefile;
  * @param strName The concrete target name to match;
  * @param strStem On success, receives the matched stem;
  *)
function MkFindPatternTarget( var handle  : TMakeHandle;
                              var strName : TIdentifierName;
                              var strStem : TIdentifierName ) : PTarget;
var
      pItem       : PLinkedListItem;
      pIdentItem  : PLinkedListItem;
      pItemTarget : PTarget;
      identName   : TIdentifierName;
      stemTmp     : TIdentifierName;
      bFound      : boolean;

begin
  bFound      := false;
  pItemTarget := nil;
  pItem       := GetFirstLinkedListItem( handle.targetList );

  while( not bFound and ( pItem <> nil ) )  do
  begin
    Move( pItem^.pValue, pItemTarget, sizeof( pItemTarget ) );
    pIdentItem := GetFirstLinkedListItem( pItemTarget^.targetNameList );

    while( not bFound and ( pIdentItem <> nil ) )  do
    begin
      Move( pIdentItem^.pValue^, identName, sizeof( identName ) );

      if( MkStringHasChar( identName, CHAR_PERCENT ) )  then
      begin
        stemTmp := '';
        bFound  := MkMatchPattern( identName, strName, stemTmp );

        if( bFound )  then
          strStem := stemTmp;
      end;

      pIdentItem := GetNextLinkedListItem( pItemTarget^.targetNameList );
    end;

    if( not bFound )  then
      pItem := GetNextLinkedListItem( handle.targetList );
  end;

  if( not bFound )  then
    pItemTarget := nil;

  MkFindPatternTarget := pItemTarget;
end;

(**
  * Replace reference on command passed as parameter.
  * param handle The @see TMakeHandle of open makefile;
  * @param strCommand Reference to the command that will be replaced;
  *)
function MkReplaceReferences( var handle : TMakeHandle;
                              var strCommand : TIdentifierValue ) : boolean;
const
      __ctWildcard = 'wildcard ';

var
      bRet          : boolean;
      bContains     : boolean;
      nStart        : integer;
      nEnd          : integer;
      strIdentifier : TIdentifierValue;
      strWildResult : TIdentifierValue;
      pIdentPair    : PIdentifierPair;

begin
  bRet := true;

  repeat
    nStart    := Pos( '$(', strCommand );
    nEnd      := Pos( ')', strCommand );
    bContains := ( ( nStart <> 0 ) and ( nEnd <> 0 ) );

    if( bContains )  then
    begin
      strIdentifier := Copy( strCommand,
                              ( nStart + 2 ),
                              ( nEnd - nStart - 2 ) );

      if( Pos( __ctWildcard, strIdentifier ) = 1 )  then
      begin
        strIdentifier := Copy( strIdentifier,
                               Length( __ctWildcard ) + 1,
                               Length( strIdentifier ) );
        strWildResult := '';
        MkWildcard( strIdentifier, strWildResult );
        strCommand := Copy( strCommand, 0, ( nStart - 1 ) ) +
                            strWildResult +
                            Copy( strCommand,
                                  ( nEnd + 1 ),
                                  Length( strCommand ) );
      end
      else
      begin
        pIdentPair := MkFindIdentifier( handle, strIdentifier );
        bRet := ( pIdentPair <> nil );

        if( bRet )  then
        begin
          strCommand := Copy( strCommand, 0, ( nStart - 1 ) ) +
                              pIdentPair^.strValue +
                              Copy( strCommand,
                                    ( nEnd + 1 ),
                                    Length( strCommand ) );
        end
        else
        begin  (* Check identifier on OS environment variables *)
          bRet := MkGetEnv( strIdentifier, strIdentifier );

          if( bRet )  then
          begin
            strCommand := Copy( strCommand, 0, ( nStart - 1 ) ) +
                                strIdentifier +
                                Copy( strCommand,
                                      ( nEnd + 1 ),
                                      Length( strCommand ) );
          end
          else
          begin
            handle.strLastError := 'Identifier not found';
          end;
        end;
      end;
    end;
  until( not bContains or not bRet );

  MkReplaceReferences := bRet;
end;

