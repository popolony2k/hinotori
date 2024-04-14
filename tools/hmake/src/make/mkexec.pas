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
 * - ./make/fpc/mkoscall.pas   (depemds on archtecture)
 * - ./make/msx/mkoscall.pas   (depends on archtecture)
 
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
    * Execute a commandlist passed as parameter.
    * @param commandList The command list to execute;
    *)
  function __ExecCommands( var commandList : TLinkedList ) : boolean;
  var
         bRet         : boolean;
         bHasCommands : boolean;
         strCommand   : TIdentifierValue;
         pItem        : PLinkedListItem;

  begin
    bRet  := true;
    pItem := GetFirstLinkedListItem( commandList );
    bHasCommands := ( pItem <> nil );

    while( bRet and ( pItem <> nil ) ) do
    begin
      Move( pItem^.pValue^, strCommand, sizeof( strCommand ) );
      pItem  := GetNextLinkedListItem( commandList );

      if( handle.bDebugMode )  then
        WriteLn( '(cmd) => ', strCommand );
      
      bRet := MkExecCommand( handle, strCommand );
    end;

    if( handle.bDebugMode and not bHasCommands )  then
      WriteLn( 'No commands to execute on this target' );

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
    pTargetItem := MkFindTarget( handle, strTarget );

  bRet := ( pTargetItem <> nil );

  if( handle.bDebugMode )  then
  begin
    WriteLn;
    WriteLn( 'Executing target [', strTarget, ']' );
    WriteLn( '-----------------------' );
  end;

  if( bRet )  then
    bRet := __ExecCommands( pTargetItem^.commandList )
  else
    handle.strLastError := 'Invalid target [' + strTarget + ']';

  if( handle.bDebugMode )  then
  begin
    WriteLn( '-----------------------' );
  end;

  MkExecute := bRet;
end;
