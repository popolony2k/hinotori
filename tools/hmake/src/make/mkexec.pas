(*<mkexec.pas>
 * Hinotori makefile execution routines.
 *
 * CopyLeft (c) 1995-2024 by PopolonY2k.
 * CopyLeft (c) since 2024 by Hinotori Team.
 *)

(*
 * This module depends on folowing include files (respect the order):
 *
 * - /system/types.pas;
 * - /collectn/lnkdlist.pas;
 * - /memory/pointer.pas;
 * - ./make/mktypes.pas;
 * - ./make/mkhelper.pas;
 *)

 (**
  * Execute a previously compiled makefile.
  * @param handle The makefile handle struct containing
  * all previously processed makefile data.
  * @param strTarget The target name that will be processed.
  * If empty, the default will be processed;
  *)
function MkExecute( var handle : TMakeHandle; strTarget : TString ) : boolean;

  (**
    * Find the identifier based on its name;
    * @param strName The identifier name to find;
    * The function return the pointer to the requested identifier or
    * nil if not found;
    *)
  function __FindIdentifier( var strName : TIdentifierName ) : PIdentifierPair;
  var
        pItem  : PLinkedListItem;
        pPair  : PIdentifierPair;
        bFound : boolean;
         
  begin
    bFound := false;
    pItem  := GetFirstLinkedListItem( handle.variableList );

    while( not bFound and ( pItem <> nil ) ) do
    begin
      Move( pItem^.pValue, pPair, sizeof( pPair ) );
      bFound := ( pPair^.strName = strName );
      pItem  := GetNextLinkedListItem( handle.variableList );
    end;

    if( not bFound )  then
      pPair := nil;

    __FindIdentifier := pPair;
  end;

  (**
    * Find a target based on its name;
    * @param strName The target name to find;
    * The function return the pointer to the requested target or
    * nil if not found;
    *)
  function __FindTarget( var strName : TIdentifierName ) : PTarget;
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

    __FindTarget := pItemTarget;
  end;

  (**
    * Execute a commandlist passed as parameter.
    * @param commandList The command list to execute;
    *)
  function __ExecCommands( var commandList : TLinkedList ) : boolean;
  var
         bRet : boolean;

  begin
    bRet := true;

    { TODO: FINISH HIM !!!! }

    __ExecCommands := bRet;
  end;

var
      bRet        : boolean;
      pTargetItem : PTarget;

(*
 * MkExecute main routine
 *)
begin
  if( strTarget = '' )  then
    pTargetItem := handle.pDefaultTarget
  else
    pTargetItem := __FindTarget( strTarget );

  bRet := ( pTargetItem <> nil );

  if( bRet )  then
    bRet := __ExecCommands( pTargetItem^.commandList )
  else
    handle.strLastError := 'Invalid target [' + strTarget + ']';

  MkExecute := bRet;
end;
