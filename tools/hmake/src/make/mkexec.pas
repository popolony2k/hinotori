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
  * @param pUserTargetList Pointer to an user target list
  * passed as parameter on command line by user;
  *)
function MkExecute( var handle : TMakeHandle; pUsrTargetList : PLinkedList ) : boolean;

  (*
   *  Supported default targets
   *)
  const   
            __ctTargetPHONY = '.PHONY';

  (* MkExecute main variables *)
  var
      pPhonyList      : PLinkedList;
      strTargetName   : TIdentifierName;


  (**
    * Print target debug information.
    * @param strTargetName The target name info to print;
    *)
  procedure __PrintTargetName( strTargetName : TIdentifierValue );
  begin
    if( handle.bDebugMode )  then
    begin
      WriteLn;
      WriteLn( 'Executing target [', strTargetName, ']' );
      WriteLn( '-----------------------' );
    end;
  end;

  (**
    * Print line separator.
    *)
  procedure __PrintSeparator;
  begin
    if( handle.bDebugMode )  then
    begin
      WriteLn( '-----------------------' );
    end;
  end;
  
  (**
    * Check if there's a .PHONY target defined on Makefile that matches
    * the target entry passed as parameter;
    * @param strTargetName The target name that will be checked;
    *)
  function __IsTargetPHONY( var strTargetName : TIdentifierValue ) : boolean;
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
        bRet  := ( strValue <> strTargetName ); 
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
    * @param pTargetList list of targets that will be processed;  
    *)
  function __ExecTarget( pTargetItem : PTarget; pTargetList : PLinkedList ) : boolean;
  var
      bRet            : boolean;
      pNextTargetItem : PTarget;
      targetPair      : TIdentifierPair;
      pTargetNameItem : PLinkedListItem;
      pPreReqItem     : PLinkedListItem;

  begin
    bRet := ( pTargetItem <> nil );

    if( bRet )  then
    begin
      pPreReqItem := GetFirstLinkedListItem( pTargetItem^.pPreReqList^ );
      pTargetNameItem := pTargetList^.pCurrentItem;

      while( bRet and ( pTargetNameItem <> nil ) ) do
      begin
        Move( pTargetNameItem^.pValue^, 
              targetPair.strName, 
              sizeof( targetPair.strName ) );

        __PrintTargetName( targetPair.strName );

        bRet := __IsTargetPHONY( targetPair.strName );

        if( not bRet )  then
          bRet := not MkCheckTarget( targetPair );

        if( pPreReqItem = nil )  then
        begin
          pTargetItem := MkFindTarget( handle, targetPair.strName );
          pPreReqItem := GetFirstLinkedListItem( pTargetItem^.pPreReqList^ );
        end;

        while( bRet and ( pPreReqItem <> nil ) ) do
        begin
          if( bRet )  then
          begin
            Move( pPreReqItem^.pValue^, 
                  targetPair.strValue, 
                  sizeof( targetPair.strValue ) );

            if( not MkCheckTarget( targetPair ) )  then
            begin
              pNextTargetItem := MkFindTarget( handle, targetPair.strValue );
              bRet := ( pNextTargetItem <> nil );

              if( bRet )  then
                bRet := __ExecTarget( pNextTargetItem, pTargetItem^.pPreReqList )
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
          end
          else
          begin
            handle.nLastLine := -1;
            handle.strLastError := 'hmake: *** ''' + 
                      targetPair.strName + 
                      '''. is up to date.';
          end;
          
          pPreReqItem := GetNextLinkedListItem( pTargetItem^.pPreReqList^ );
        end;

        if( bRet )  then
        begin
          if( pPreReqItem = nil )  then         
             pTargetItem := MkFindTarget( handle, targetPair.strName );
  
          bRet := __ExecCommands( pTargetItem^.commandList );
        end;

        __PrintSeparator;

        pTargetNameItem := GetNextLinkedListItem( pTargetList^ );
      end;
    end
    else
    begin
      handle.nLastLine := -1;
      handle.strLastError := 'hmake: *** No rule to make target ''' + 
                             strTargetName + 
                             '''.  Stop.';
    end;

    __ExecTarget := bRet;
  end;

(*
 * MkExecute main routine
 *)
var
    pTargetItem     : PTarget;
    pPhonyTarget    : PTarget;
    pTargetNameItem : PLinkedListItem;
    strPhonyIdent   : TIdentifierName;

begin
  if( GetLinkedListSize( pUsrTargetList^ ) > 0 )  then
  begin
    pTargetNameItem := GetFirstLinkedListItem( pUsrTargetList^ );
    Move( pTargetNameItem^.pValue^, strTargetName, sizeof( strTargetName ) );
    pTargetItem := MkFindTarget( handle, strTargetName );
  end
  else
    pTargetItem := handle.pDefaultTarget;

  (* Initialize PHONY target list *)
  strPhonyIdent := __ctTargetPHONY;
  pPhonyTarget  := MkFindTarget( handle, strPhonyIdent );
  pPhonyList    := nil;

  if( pPhonyTarget <> nil )  then
    pPhonyList := pPhonyTarget^.pPreReqList;

  (* Execute target *)
  MkExecute := __ExecTarget( pTargetItem, pUsrTargetList );
end;
