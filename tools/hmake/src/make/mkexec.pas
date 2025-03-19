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
  *)
function MkExecute( var handle : TMakeHandle ) : boolean;

  (*
   *  Supported default targets
   *)
  const   
            __ctTargetPHONY = '.PHONY';

  (* MkExecute main variables *)
  var
      pPhonyList      : PLinkedList;
      pTargetNameItem : PLinkedListItem;
      strTargetName   : TIdentifierName;
  
  (**
    * Check if there's a .PHONY target defined on Makefile that matches
    * the target entry passed as parameter;
    * @param target The target name that will be checked;
    *)
  function __IsTargetPHONY( var targetName : TIdentifierValue ) : boolean;
  var
        bRet     : boolean;
        pItem    : PLinkedListItem;
        strValue : TIdentifierValue;

  begin
    bRet := ( pPhonyList <> nil );

    if( bRet )  then
    begin
      pItem := GetFirstLinkedListItem( pPhonyList^ );

      while( bRet and ( pItem <> nil ) ) do
      begin
        Move( pItem^.pValue^, strValue, sizeof( strValue ) );
        bRet  := ( strValue <> targetName ); 
        pItem := GetNextLinkedListItem( pPhonyList^ );
      end;

      bRet := not bRet; 
    end;

    __IsTargetPHONY := bRet;
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

      bRet := MkReplaceReferences( handle, strCommand );
  
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
    *)
  function __ExecTarget( pTargetItem : PTarget ) : boolean;
  var
      bRet            : boolean;
      pNextTargetItem : PTarget;
      targetPair      : TIdentifierPair;
      pItem           : PLinkedListItem;

  begin
    bRet := ( pTargetItem <> nil );

    if( bRet )  then
    begin
      targetPair := pTargetItem^.targetPair;
      // TODO: MOVE __ReplaceReferences to the Build stage ??
      bRet := MkReplaceReferences( handle, targetPair.strName ) and 
              MkReplaceReferences( handle, targetPair.strValue );
      
      if( handle.bDebugMode )  then
      begin
        WriteLn;
        WriteLn( 'Executing target [', strTargetName, ']' );
        WriteLn( '-----------------------' );
      end;

      if( bRet )  then
      begin
        { Iterate on target pre-requisites list }
        pItem := GetFirstLinkedListItem( pTargetItem^.preReqList );

        while( bRet and ( pItem <> nil ) ) do
        begin
          bRet := __IsTargetPHONY( targetPair.strName );

          if( not bRet )  then
            bRet := not MkCheckTarget( targetPair );

          if( bRet )  then
          begin
            Move( pItem^.pValue^, 
                  targetPair.strValue, 
                  sizeof( targetPair.strValue ) );

            if( not MkCheckTarget( targetPair ) )  then
            begin
              pNextTargetItem := MkFindTarget( handle, targetPair.strValue );
              bRet := ( pNextTargetItem <> nil );

              if( bRet )  then
                bRet := __ExecTarget( pNextTargetItem )
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
            
            pItem  := GetNextLinkedListItem( pTargetItem^.preReqList );
          end
          else
          begin
            handle.nLastLine := -1;
            handle.strLastError := 'hmake: *** ''' + 
                      targetPair.strName + 
                      '''. is up to date.';
          end;
        end;

        if( bRet )  then
          bRet := __ExecCommands( pTargetItem^.commandList );
      end;
    end
    else
    begin
      handle.nLastLine := -1;
      handle.strLastError := 'hmake: *** No rule to make target ''' + 
                             strTargetName + 
                             '''.  Stop.';
    end;

    if( handle.bDebugMode )  then
    begin
      WriteLn( '-----------------------' );
    end;

    __ExecTarget := bRet;
  end;

(*
 * MkExecute main routine
 *)
var
    pTargetItem     : PTarget;
    pPhonyTarget    : PTarget;
    strPhonyIdent   : TIdentifierName;
    bRet            : boolean;

begin
  bRet := true;

  if( GetLinkedListSize( handle.pUsrTargetList^ ) > 0 )  then
  begin
    pTargetNameItem := GetFirstLinkedListItem( handle.pUsrTargetList^ );
    Move( pTargetNameItem^.pValue^, strTargetName, sizeof( strTargetName ) );
    pTargetItem := MkFindTarget( handle, strTargetName );
  end
  else
    pTargetItem := handle.pDefaultTarget;

  if( not bRet )  then
  begin
    MkExecute := bRet;
    exit;
  end;

  (* Initialize PHONY list *)
  strPhonyIdent := __ctTargetPHONY;
  pPhonyTarget  := MkFindTarget( handle, strPhonyIdent );
  pPhonyList    := nil;

  if( pPhonyTarget <> nil )  then
  begin
    New( pPhonyList );
    CreateLinkedList( pPhonyList^, sizeof( TIdentifierValue ) );
    bRet := ( SplitString( pPhonyTarget^.targetPair.strValue, ' ', 
                           pPhonyList^ ) >= 0 );
  end;

  (* Execute target *)
  bRet := __ExecTarget( pTargetItem );

  // if( bRet and bListNotEmpty )  then
  // begin
  //   pTargetNameItem := GetNextLinkedListItem( handle.pUsrTargetList^ );
  //   bHasMoreTargets := ( pTargetNameItem <> nil );

  //   if( bHasMoreTargets )  then
  //   begin
  //     Move( pTargetNameItem^.pValue^, strTargetName, sizeof( strTargetName ) );
  //     pTargetItem := MkFindTarget( handle, strTargetName );
  //   end;
  // end; 

  if( pPhonyTarget <> nil )  then
  begin
    DestroyLinkedList( pPhonyList^ );
    Dispose( pPhonyList );
  end;

  MkExecute := bRet;
end;
