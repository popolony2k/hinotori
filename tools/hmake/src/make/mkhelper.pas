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
 * - /memory/{platform}/pointer.pas;  (depemds on architecture)
 * - /dos/dosutil.pas;
 * - ./make/mktypes.pas;
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
        bHasTarget : boolean;

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
      begin
        bHasTarget := ( handle.targetList.nListSize > 0 );

        if( bHasTarget and ( vType <> __TVariableType.VARIABLE ) )  then
          identType := TIdentifierType.IDENT_COMMAND
        else
          identType := TIdentifierType.IDENT_NOP;
      end;
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
  identType := __GetIdentifierType( __TVariableType.VARIABLE );

  if( identType in [TIdentifierType.IDENT_NONE,
                    TIdentifierType.IDENT_NOP] )  then
    identType := __GetIdentifierType( __TVariableType.TARGET );

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
  * @param strName The identifier name to find;
  * The function return the pointer to the requested identifier or
  * nil if not found;
  *)
function MkFindIdentifier( var handle : TMakeHandle; var strName : TIdentifierName ) : PIdentifierPair;
var
      pItem     : PLinkedListItem;
      pItemPair : PIdentifierPair;
      bFound    : boolean;
        
begin
  bFound := false;
  pItem  := GetFirstLinkedListItem( handle.variableList );

  while( not bFound and ( pItem <> nil ) ) do
  begin
    Move( pItem^.pValue, pItemPair, sizeof( pItemPair ) );
    bFound := ( pItemPair^.strName = strName );
    pItem  := GetNextLinkedListItem( handle.variableList );
  end;

  if( not bFound )  then
    pItemPair := nil;

  MkFindIdentifier := pItemPair;
end;

(**
  * Find a target based on its name;
  * @param strName The target name to find;
  * The function return the pointer to the requested target or
  * nil if not found;
  *)
function MkFindTarget( var handle : TMakeHandle; var strName : TIdentifierName ) : PTarget;
var
      pItem       : PLinkedListItem;
      pItemTarget : PTarget;
      bFound      : boolean;
        
begin
  bFound := false;
  pItem  := GetFirstLinkedListItem( handle.targetList );

  while( not bFound and ( pItem <> nil ) ) do
  begin
    Move( pItem^.pValue, pItemTarget, sizeof( pItemTarget ) );
    bFound := ( pItemTarget^.targetPair.strName = strName );
    pItem  := GetNextLinkedListItem( handle.targetList );
  end;

  if( not bFound )  then
    pItemTarget := nil;

  MkFindTarget := pItemTarget;
end;

(**
  * Find a target based on its pair;
  * @param pair The target pair to find;
  * The function return the pointer to the requested target or
  * nil if not found;
  *)
function MkFindTargetByPair( var handle : TMakeHandle; var pair : TIdentifierPair ) : PTarget;
var
      pItem       : PLinkedListItem;
      pItemTarget : PTarget;
      bFound      : boolean;
        
begin
  bFound := false;
  pItem  := GetFirstLinkedListItem( handle.targetList );

  while( not bFound and ( pItem <> nil ) ) do
  begin
    Move( pItem^.pValue, pItemTarget, sizeof( pItemTarget ) );
    bFound := ( pItemTarget^.targetPair.strName  = pair.strName  ) and 
              ( pItemTarget^.targetPair.strValue = pair.strValue );
    pItem  := GetNextLinkedListItem( handle.targetList );
  end;

  if( not bFound )  then
    pItemTarget := nil;

  MkFindTargetByPair := pItemTarget;
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
