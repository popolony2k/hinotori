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
 * - /memory/{platform}/pointer.pas;  (depemds on architecture)
  * - /dos/dosutil.pas;
 * - ./make/mktypes.pas;
 * - ./make/mkhelper.pas;
 * - ./make/{platform}}/mkoscall.pas   (depemds on architecture)
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
    strMultiLine := '';

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

  (**
    * Execute the target processing based on target passed as parameter;
    * @param strTarget The target name that will be processed.
    * If empty, the default will be processed;
    *)
  function __ExecTarget( strTarget : TString; bFirstLevel : boolean ) : boolean;
  var
      bRet        : boolean;
      bCheck      : boolean;
      pTargetItem : PTarget;
      targetPair  : TIdentifierPair;
      preReqList  : TLinkedList;
      pItem       : PLinkedListItem;
      strFileName : TFileName;
      strFileExt  : TFileExt;

  begin
    if( strTarget = '' )  then
      pTargetItem := handle.pDefaultTarget
    else
    begin
      if( bFirstLevel and 
          MkStringHasWildcard( strTarget, WILDCARD_PERCENT ) )  then
        pTargetItem := nil
      else
        pTargetItem := MkFindTarget( handle, strTarget );
    end;

    bRet := ( pTargetItem <> nil );

    if( bRet )  then
    begin
      targetPair := pTargetItem^.targetPair;
      bRet := __ReplaceReferences( targetPair.strValue );

      if( bRet )  then
      begin
        CreateLinkedList( preReqList, sizeof( TIdentifierValue ) );
        bCheck := ( SplitString( targetPair.strValue, ' ', preReqList ) >= 0 );
        pItem  := GetFirstLinkedListItem( preReqList );

        while( pItem <> nil ) do
        begin
          Move( pItem^.pValue^, 
                targetPair.strValue, 
                sizeof( targetPair.strValue ) );
          bCheck := ( bCheck and MkCheckTarget( targetPair ) );
          (* TODO: PATTERN MATCHING *)
          pItem  := GetNextLinkedListItem( preReqList );
        end;

        (* TODO: PATTERN MATCHING *)
        if( SplitFileName( targetPair.strValue, 
                            strFileName, 
                            strFileExt ) )  then
        begin
          WriteLn( '==> ', strFileName, ' ext ==> ', strFileExt );
        end;

        DestroyLinkedList( preReqList );

        if( bCheck )  then
          bRet := __ExecCommands( pTargetItem^.commandList )
        else
        begin
          handle.nLastLine := -1;
          handle.strLastError := 'hmake: ''' + 
                                 pTargetItem^.targetPair.strName + 
                                 ''' is up to date.';
        end;
      end;
    end
    else
    begin
      handle.nLastLine := -1;
      handle.strLastError := 'hmake: *** No rule to make target ''' + 
                             strTarget + 
                             '''.  Stop.';
    end;

    __ExecTarget := bRet;
  end;

(* MkExecute main routine *)
var
      bRet : boolean;

(*
 * MkExecute main routine
 *)
begin
  if( handle.bDebugMode )  then
  begin
    WriteLn;
    WriteLn( 'Executing target [', strTarget, ']' );
    WriteLn( '-----------------------' );
  end;

  bRet := __ExecTarget( strTarget, true );

  if( handle.bDebugMode )  then
  begin
    WriteLn( '-----------------------' );
  end;

  MkExecute := bRet;
end;
