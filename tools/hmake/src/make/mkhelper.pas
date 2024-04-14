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
 * - ./make/mktypes.pas;
 *)

(**
  * Return the identifier type for a given token.
  * @param strToken The token to be checked;
  *)
function MkGetIdentifier( var strToken : TIdentifierValue ) : TIdentifierType;
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

  MkGetIdentifier := identType;
end;

(**
  * Check if an indentifier is valid.
  * param handle The @see TMakeHandle of a makefile that 
  * has been checked;
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
