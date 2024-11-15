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
 * - /memory/{platform}/pointer.pas;  (depends on architecture)
  * - /dos/dosutil.pas;
 * - ./make/mktypes.pas;
 * - ./make/mkhelper.pas;
 * - ./make/{platform}}/mkoscall.pas   (depends on architecture)
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
   * Replace the pair prerequisite macro, when there's a macro on this property
   * by corresponding value present on list passed as parameter;
   * @param pair The pair with macro data to be replaced;
   * @param pPreReqList Pointer to list with values of macro to replace on 
   * pair;
   *)
  procedure __ReplaceMacro( var pair : TIdentifierPair; 
                            pPreReqList : PLinkedList );
  var
      pItem       : PLinkedListItem;
      strValue    : TIdentifierValue;
      strFileName : TFileName;
      strFileExt  : TFileExt;
      bFound      : boolean;

  begin
    if( pPreReqList <> nil )  then
    begin
      pItem  := GetFirstLinkedListItem( pPreReqList^ );
      bFound := false;

      while( ( pItem <> nil ) and not bFound )  do
      begin
        Move( pItem^.pValue^, strValue, sizeof( strValue ) );

        if( SplitFileName( strValue, strFileName, strFileExt ) )  then
        begin
          bFound := ( Pos( '%.' + strFileExt, pair.strName ) > 0 );
        end;

        pItem := GetNextLinkedListItem( pPreReqList^ );
      end;

      if( bFound )  then
      begin
        if( handle.bDebugMode )  then
        begin
          WriteLn( 'Target (Macro)    => ', pair.strName, ':', pair.strValue );
        end;

        ReplaceAll( pair.strName, '%', strFileName );
        ReplaceAll( pair.strValue, '%', strFileName );

        if( handle.bDebugMode )  then
        begin
          WriteLn( 'Target (Replaced) => ', pair.strName, ':', pair.strValue );
          WriteLn;
        end;
      end;
    end;
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
          if( not handle.bSilentMode )  then
            WriteLn( strCommand );

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
    * @param pTargetItem Pointer to the target that will be processed.
    * @param pParentPreReqList The parent list with prerequisites to be 
    * used on macro substitution when target is a macro;
    * If empty, the default will be processed;
    *)
  function __ExecTarget( pTargetItem : PTarget; 
                         pParentPreReqList : PLinkedList;
                         bFirstLevel : boolean ) : boolean;
  var
      bRet            : boolean;
      pNextTargetItem : PTarget;
      targetPair      : TIdentifierPair;
      pPreReqList     : PLinkedList;
      pItem           : PLinkedListItem;

  begin
    bRet := ( pTargetItem <> nil );

    if( bRet )  then
    begin
      targetPair := pTargetItem^.targetPair;
      bRet := __ReplaceReferences( targetPair.strValue );

      if( handle.bDebugMode )  then
      begin
        WriteLn;
        WriteLn( 'Executing target [', targetPair.strName, ']' );
        WriteLn( '-----------------------' );
      end;

      if( bRet )  then
      begin
        New( pPreReqList );
        CreateLinkedList( pPreReqList^, sizeof( TIdentifierValue ) );

        { Iterate on pre-requisites list }
        if( SplitString( targetPair.strValue, ' ', pPreReqList^ ) >= 0 )  then
          pItem := GetFirstLinkedListItem( pPreReqList^ )
        else
          pItem := nil;

        if(pItem = nil)  then
        begin
          bRet := not MkCheckTarget( targetPair );

          // TODO: Add IsPhonyarget check here
          
          { PHONY target execution }
          if( not bRet )  then
          begin
              handle.nLastLine := -1;
              handle.strLastError := 'hmake: *** ''' + 
                        targetPair.strName + 
                        '''. is up to date.'; 
          end;
        end;

        while( bRet and ( pItem <> nil ) ) do
        begin
          Move( pItem^.pValue^, 
                targetPair.strValue, 
                sizeof( targetPair.strValue ) );   

          if( MkCheckTarget( targetPair ) )  then
          begin
            pNextTargetItem := MkFindTarget( handle, targetPair.strValue );
            bRet := ( pNextTargetItem <> nil );

            if( bRet )  then
              bRet := __ExecTarget( pNextTargetItem, pPreReqList, false )
            else
            begin
              handle.nLastLine := -1;
              handle.strLastError := 'hmake: *** No rule to make target ''' + 
                        targetPair.strValue + 
                        '''. needed by '''  + 
                        targetPair.strName  + 
                        '''  Stop.';
            end;
          end;
          
          pItem  := GetNextLinkedListItem( pPreReqList^ );
        end;

        if( bRet )  then
          bRet := __ExecCommands( pTargetItem^.commandList );

        DestroyLinkedList( pPreReqList^ );
        Dispose( pPreReqList );
      end;
    end
    else
    begin
      handle.nLastLine := -1;
      handle.strLastError := 'hmake: *** No rule to make target ''' + 
                             strTarget + 
                             '''.  Stop.';
    end;

    if( handle.bDebugMode )  then
    begin
      WriteLn( '-----------------------' );
    end;

    __ExecTarget := bRet;
  end;

(* MkExecute main routine *)
var
      pTargetItem : PTarget;

(*
 * MkExecute main routine
 *)
begin
  if( Length( strTarget ) > 0 )  then
    pTargetItem := MkFindTarget( handle, strTarget )
  else
    pTargetItem := handle.pDefaultTarget;

  MkExecute := __ExecTarget( pTargetItem, nil, true );
end;
