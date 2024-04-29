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
 * - /memory/fpc/pointer.pas;  (depemds on archtecture)
 * - /memory/msx/pointer.pas;  (depemds on archtecture)
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
    * Replace reference on command passed as parameter.
    * @param strCommand Reference to the command that will be replaced;
    *)
  function __ReplaceReferences( var strCommand : TIdentifierValue ) : boolean;
  var
        bRet          : boolean;
        bContains     : boolean;
        nStart        : integer;
        nEnd          : integer;
        strIdentifier : TIdentifierValue;
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
    until( not bContains or not bRet );

    __ReplaceReferences := bRet;
  end;

  (**
    * Execute a commandlist passed as parameter.
    * @param commandList The command list to execute;
    *)
  function __ExecCommands( var commandList : TLinkedList ) : boolean;
  var
         bRet         : boolean;
         bMultiLine   : boolean;
         bHasCommands : boolean;
         nPos         : integer;
         strCommand   : TIdentifierValue;
         strMultiLine : TIdentifierValue;
         pItem        : PLinkedListItem;

  begin
    bRet  := true;
    pItem := GetFirstLinkedListItem( commandList );
    bHasCommands := ( pItem <> nil );
    bMultiLine   := false;

    while( bRet and ( pItem <> nil ) ) do
    begin
      Move( pItem^.pValue^, strCommand, sizeof( strCommand ) );

      if( bMultiLine )  then
        strCommand := strMultiLine + strCommand;

      bRet := __ReplaceReferences( strCommand );
  
      if( bRet )  then
      begin
        nPos := Pos( '\', strCommand );
        bMultiLine := ( nPos <> 0 );

        if( bMultiLine )  then
        begin
          Delete( strCommand, nPos, 1 );
          strMultiLine := strCommand; 
        end;
        
        if( not bMultiLine )  then
        begin
          if( handle.bDebugMode )  then
            WriteLn( '(cmd) => ', strCommand );

          bRet := MkExecCommand( handle, strCommand );
        end;
      end;

      pItem := GetNextLinkedListItem( commandList );       
    end;

    if( bRet )  then
    begin
      if( bMultiLine and ( pItem = nil ) )  then
      begin
        bRet := false;
        handle.strLastError := 'Error. Multi-line unexpectedly ended';
      end
      else
      begin
        if( handle.bDebugMode and not bHasCommands )  then
          WriteLn( 'hmake: Nothing to do' );
      end;
    end;

    __ExecCommands := bRet;
  end;

var
      bRet        : boolean;
      pTargetItem : PTarget;
      targetPair  : TIdentifierPair;

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

  targetPair := pTargetItem^.targetPair;
  bRet := __ReplaceReferences( targetPair.strValue );
  
  if( bRet )  then
  begin
    if( MkCheckTarget( targetPair ) )  then
    begin
      if( bRet )  then
        bRet := __ExecCommands( pTargetItem^.commandList )
      else
        handle.strLastError := 'Invalid target [' + strTarget + ']';
    end
    else
      WriteLn( 'hmake: ''', 
               pTargetItem^.targetPair.strName, 
               ''' is up to date.' );
  end;

  if( handle.bDebugMode )  then
  begin
    WriteLn( '-----------------------' );
  end;

  MkExecute := bRet;
end;
