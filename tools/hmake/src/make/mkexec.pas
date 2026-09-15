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
    * Return the directory part of a path (everything before the last slash).
    * Returns '.' when the path contains no directory separator.
    * @param strPath The path to split;
    *)
  function __DirPart( strPath : TIdentifierName ) : TIdentifierName;
  var
      nLast : integer;
      nIdx  : integer;

  begin
    nLast := 0;

    for nIdx := 1 to Length( strPath ) do
      if( ( strPath[nIdx] = '/' ) or ( strPath[nIdx] = '\' ) )  then
        nLast := nIdx;

    if( nLast = 0 )  then
      __DirPart := '.'
    else
      __DirPart := Copy( strPath, 1, nLast - 1 );
  end;

  (**
    * Return the file part of a path (everything after the last slash).
    * Returns the whole string when the path contains no directory separator.
    * @param strPath The path to split;
    *)
  function __FilePart( strPath : TIdentifierName ) : TIdentifierName;
  var
      nLast : integer;
      nIdx  : integer;

  begin
    nLast := 0;

    for nIdx := 1 to Length( strPath ) do
      if( ( strPath[nIdx] = '/' ) or ( strPath[nIdx] = '\' ) )  then
        nLast := nIdx;

    if( nLast = 0 )  then
      __FilePart := strPath
    else
      __FilePart := Copy( strPath, nLast + 1, Length( strPath ) - nLast );
  end;

  (**
    * Replace automatic variables ($@, $<, $^, $+, $*, $%, $?) and their
    * directory ($xD) and file ($xF) suffix variants in a command string.
    * D/F variants are replaced first so the base variable token is still intact.
    * @param strCommand The command string to perform replacement on;
    * @param strTargetName The name of the target currently being built;
    * @param strStem The stem from a pattern-rule match (empty for exact targets);
    * @param pTgt Pointer to the target structure;
    * @param pInstPreReq Instantiated prereq list for pattern rules (nil = use pTgt's list);
    *)
  procedure __ReplaceAutoVars( var strCommand   : TIdentifierValue;
                               strTargetName    : TIdentifierName;
                               strStem          : TIdentifierName;
                               pTgt             : PTarget;
                               pInstPreReq      : PLinkedList );
  var
      strPreReqs        : TIdentifierValue;
      strFirstPreReq    : TIdentifierValue;
      strPreReqsDirs    : TIdentifierValue;
      strPreReqsFiles   : TIdentifierValue;
      strOutOfDate      : TIdentifierValue;
      strOutOfDateDirs  : TIdentifierValue;
      strOutOfDateFiles : TIdentifierValue;
      strValue          : TIdentifierValue;
      checkPair         : TIdentifierPair;
      pItem             : PLinkedListItem;
      bFirst            : boolean;
      bOutOfDateFirst   : boolean;

  begin
    (* Use instantiated list for pattern rules, else the target's own list *)
    strFirstPreReq    := '';
    strPreReqs        := '';
    strPreReqsDirs    := '';
    strPreReqsFiles   := '';
    strOutOfDate      := '';
    strOutOfDateDirs  := '';
    strOutOfDateFiles := '';
    bFirst            := true;
    bOutOfDateFirst   := true;

    if( pInstPreReq <> nil )  then
      pItem := pInstPreReq^.pFirstItem
    else
      pItem := pTgt^.pPreReqList^.pFirstItem;

    while( pItem <> nil )  do
    begin
      Move( pItem^.pValue^, strValue, sizeof( strValue ) );

      if( bFirst )  then
      begin
        strFirstPreReq  := strValue;
        strPreReqs      := strValue;
        strPreReqsDirs  := __DirPart( strValue );
        strPreReqsFiles := __FilePart( strValue );
        bFirst          := false;
      end
      else
      begin
        strPreReqs      := strPreReqs      + ' ' + strValue;
        strPreReqsDirs  := strPreReqsDirs  + ' ' + __DirPart( strValue );
        strPreReqsFiles := strPreReqsFiles + ' ' + __FilePart( strValue );
      end;

      (* $? : prerequisites newer than the target (or target still
         missing). Re-checked here, against the target's real prereq
         list, rather than reused from whatever __ExecTarget saw earlier
         — by the time commands run, prerequisites have already been
         (re)built, so this reflects their current, post-build mtimes. *)
      checkPair.strName  := strTargetName;
      checkPair.strValue := strValue;

      if( not MkCheckTarget( checkPair ) )  then
      begin
        if( bOutOfDateFirst )  then
        begin
          strOutOfDate      := strValue;
          strOutOfDateDirs  := __DirPart( strValue );
          strOutOfDateFiles := __FilePart( strValue );
          bOutOfDateFirst   := false;
        end
        else
        begin
          strOutOfDate      := strOutOfDate      + ' ' + strValue;
          strOutOfDateDirs  := strOutOfDateDirs  + ' ' + __DirPart( strValue );
          strOutOfDateFiles := strOutOfDateFiles + ' ' + __FilePart( strValue );
        end;
      end;

      pItem := pItem^.pNextItem;
    end;

    (* D/F suffix variants — must be replaced before the base variables *)
    ReplaceAll( strCommand, '$@D', __DirPart( strTargetName ) );
    ReplaceAll( strCommand, '$@F', __FilePart( strTargetName ) );
    ReplaceAll( strCommand, '$<D', __DirPart( strFirstPreReq ) );
    ReplaceAll( strCommand, '$<F', __FilePart( strFirstPreReq ) );
    ReplaceAll( strCommand, '$^D', strPreReqsDirs );
    ReplaceAll( strCommand, '$^F', strPreReqsFiles );
    ReplaceAll( strCommand, '$+D', strPreReqsDirs );
    ReplaceAll( strCommand, '$+F', strPreReqsFiles );
    ReplaceAll( strCommand, '$*D', __DirPart( strStem ) );
    ReplaceAll( strCommand, '$*F', __FilePart( strStem ) );
    ReplaceAll( strCommand, '$%D', '' );
    ReplaceAll( strCommand, '$%F', '' );
    ReplaceAll( strCommand, '$?D', strOutOfDateDirs );
    ReplaceAll( strCommand, '$?F', strOutOfDateFiles );

    (* Base automatic variables *)
    ReplaceAll( strCommand, '$@', strTargetName );
    ReplaceAll( strCommand, '$<', strFirstPreReq );
    ReplaceAll( strCommand, '$^', strPreReqs );
    ReplaceAll( strCommand, '$+', strPreReqs );
    ReplaceAll( strCommand, '$*', strStem );
    ReplaceAll( strCommand, '$?', strOutOfDate );

    (* $% — archive-member name; not applicable without archive-member
       target syntax (lib(member.o)), which this implementation does not
       support. Replaced with empty to avoid shell expansion. *)
    ReplaceAll( strCommand, '$%', '' );
  end;

  (**
    * Build an instantiated prereq list by replacing '%' with strStem in each
    * entry of the pattern target's prereq list.  Caller owns the returned list
    * and must call DestroyLinkedList + Dispose when done.
    * Returns nil when pPreReqList is nil or allocation fails.
    * @param pPreReqList The pattern target's prerequisite list;
    * @param strStem The stem to substitute for '%';
    *)
  function __InstantiatePreReqList( pPreReqList : PLinkedList;
                                    strStem     : TIdentifierName ) : PLinkedList;
  var
      pResult  : PLinkedList;
      pItem    : PLinkedListItem;
      strValue : TIdentifierValue;
      strInst  : TIdentifierValue;
      pPtr     : pointer;

  begin
    pResult := nil;

    if( pPreReqList <> nil )  then
    begin
      New( pResult );
      CreateLinkedList( pResult^, sizeof( TIdentifierValue ) );
      pItem := pPreReqList^.pFirstItem;

      while( pItem <> nil )  do
      begin
        Move( pItem^.pValue^, strValue, sizeof( strValue ) );
        strInst := strValue;
        ReplaceAll( strInst, '%', strStem );
        pPtr := ToPointer( strInst );
        AddLinkedListItem( pResult^, pPtr );
        pItem := pItem^.pNextItem;
      end;
    end;

    __InstantiatePreReqList := pResult;
  end;

  (**
    * Execute a commandlist passed as parameter.
    * @param pTgt Pointer to the target struture of command to execute;
    * @param strCurrentTarget The name of the target currently being built;
    *)
  function __ExecCommands( pTgt : PTarget;
                           strCurrentTarget : TIdentifierName;
                           strStem          : TIdentifierName;
                           pInstPreReq      : PLinkedList ) : boolean;
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
    pItem := GetFirstLinkedListItem( pTgt^.commandList );
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
        __ReplaceAutoVars( strCommand, strCurrentTarget, strStem, pTgt, pInstPreReq );

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

      pItem := GetNextLinkedListItem( pTgt^.commandList );
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
    * @param pTargetList List of targets that will be processed;
    * @param bFirstLevel Flag informing if this function call is the top
    * most level call (first level call to this function);
    * @param strStem Stem from a pattern-rule match (empty for exact targets);
    *)
  function __ExecTarget( pTargetItem : PTarget;
                         pTargetList : PLinkedList;
                         bFirstLevel : boolean;
                         strStem     : TIdentifierName ) : boolean;

    (*
     * Explicit execution-frame stack, used in place of native recursion.
     * On MSX/TP3.3f the call stack is only a few KB, and each recursive
     * call used to carry a TIdentifierPair (81 + 256 bytes) plus several
     * more short strings on the native stack — three or four levels of
     * prerequisite chaining (an entirely ordinary Makefile shape) could
     * exhaust it. Frames here are heap-allocated (New/Dispose) and chained
     * via pPrev instead, so recursion depth no longer costs native stack;
     * only the heap limits how deep a dependency chain can go.
     *
     * Each frame keeps exactly the locals the previous recursive version
     * held live across the point where it called itself, plus a `phase`
     * marking where to resume. Pushing a frame is the iterative stand-in
     * for a recursive call; popping one and feeding its result back via
     * `bChildResult` is the stand-in for that call returning.
     *)
    type
        TExecPhase = ( xpInit, xpOuterTop, xpInnerTop,
                       xpInnerAfterChild, xpAfterInner, xpCleanup );

        PExecFrame = ^TExecFrame;
        TExecFrame = record
          phase           : TExecPhase;
          pPrev           : PExecFrame;
          pTargetItem     : PTarget;
          pTargetList     : PLinkedList;
          bFirstLevel     : boolean;
          strStem         : TIdentifierName;
          bRet            : boolean;
          targetPair      : TIdentifierPair;
          pTargetNameItem : PLinkedListItem;
          pPreReqItem     : PLinkedListItem;
          pInstPreReqList : PLinkedList;
          pActivePreReq   : PLinkedList;
        end;

  var
      pTop            : PExecFrame;
      pChild          : PExecFrame;
      pNextTargetItem : PTarget;
      strNextStem     : TIdentifierName;
      bChildResult    : boolean;
      bDone           : boolean;

    (**
      * Push a new execution frame — the iterative equivalent of a
      * recursive call to __ExecTarget — on top of the frame stack.
      *)
    procedure __PushExecFrame( pItem : PTarget; pList : PLinkedList;
                               bFirst : boolean; strSt : TIdentifierName );
    var
        pFrame : PExecFrame;

    begin
      New( pFrame );

      pFrame^.phase           := xpInit;
      pFrame^.pPrev           := pTop;
      pFrame^.pTargetItem     := pItem;
      pFrame^.pTargetList     := pList;
      pFrame^.bFirstLevel     := bFirst;
      pFrame^.strStem         := strSt;
      pFrame^.bRet            := false;
      pFrame^.pTargetNameItem := nil;
      pFrame^.pPreReqItem     := nil;
      pFrame^.pInstPreReqList := nil;
      pFrame^.pActivePreReq   := nil;

      pTop := pFrame;
    end;

  begin
    pTop         := nil;
    bDone        := false;
    bChildResult := false;

    __PushExecFrame( pTargetItem, pTargetList, bFirstLevel, strStem );

    while( not bDone ) do
    begin
      case pTop^.phase of

        xpInit:
          begin
            (* Pattern-rule fallback: if no exact target, try pattern match *)
            if( pTop^.pTargetItem = nil )  then
            begin
              strNextStem       := '';
              pTop^.pTargetItem := MkFindPatternTarget( handle, strTargetName, strNextStem );

              if( pTop^.pTargetItem <> nil )  then
                pTop^.strStem := strNextStem;
            end;

            pTop^.bRet := ( pTop^.pTargetItem <> nil );

            if( pTop^.bRet )  then
            begin
              (* For pattern rules, build an instantiated prereq list *)
              if( pTop^.strStem <> '' )  then
                pTop^.pInstPreReqList := __InstantiatePreReqList( pTop^.pTargetItem^.pPreReqList, pTop^.strStem )
              else
                pTop^.pInstPreReqList := nil;

              if( pTop^.pInstPreReqList <> nil )  then
                pTop^.pActivePreReq := pTop^.pInstPreReqList
              else
                pTop^.pActivePreReq := pTop^.pTargetItem^.pPreReqList;

              pTop^.pPreReqItem     := GetFirstLinkedListItem( pTop^.pActivePreReq^ );
              pTop^.pTargetNameItem := pTop^.pTargetList^.pCurrentItem;

              pTop^.phase := xpOuterTop;
            end
            else
            begin
              handle.nLastLine    := -1;
              handle.strLastError := 'hmake: *** No rule to make target ''' +
                                     strTargetName +
                                     '''.  Stop.';
              pTop^.phase := xpCleanup;
            end;
          end;

        xpOuterTop:
          begin
            if( pTop^.bRet and ( pTop^.pTargetNameItem <> nil ) )  then
            begin
              Move( pTop^.pTargetNameItem^.pValue^,
                    pTop^.targetPair.strName,
                    sizeof( pTop^.targetPair.strName ) );

              __PrintTargetName( pTop^.targetPair.strName );

              pTop^.bRet := __IsTargetPHONY( pTop^.targetPair.strName );

              if( not pTop^.bRet )  then
                pTop^.bRet := not MkCheckTarget( pTop^.targetPair );

              if( not pTop^.bFirstLevel and ( pTop^.pPreReqItem = nil ) )  then
              begin
                pTop^.pTargetItem := MkFindTarget( handle, pTop^.targetPair.strName );

                if( pTop^.pTargetItem = nil )  then
                begin
                  strNextStem       := '';
                  pTop^.pTargetItem := MkFindPatternTarget( handle, pTop^.targetPair.strName, strNextStem );
                  if( pTop^.pTargetItem <> nil )  then
                    pTop^.strStem := strNextStem;
                end;

                if( pTop^.pTargetItem = nil )  then
                begin
                  pTop^.bRet := false;
                  handle.nLastLine    := -1;
                  handle.strLastError := 'hmake: *** No rule to make target ''' +
                                         pTop^.targetPair.strName + '''.  Stop.';
                end
                else
                begin
                  if( pTop^.strStem <> '' )  then
                  begin
                    if( pTop^.pInstPreReqList <> nil )  then
                    begin
                      DestroyLinkedList( pTop^.pInstPreReqList^ );
                      Dispose( pTop^.pInstPreReqList );
                    end;

                    pTop^.pInstPreReqList := __InstantiatePreReqList( pTop^.pTargetItem^.pPreReqList, pTop^.strStem );

                    if( pTop^.pInstPreReqList <> nil )  then
                      pTop^.pActivePreReq := pTop^.pInstPreReqList
                    else
                      pTop^.pActivePreReq := pTop^.pTargetItem^.pPreReqList;
                  end
                  else
                    pTop^.pActivePreReq := pTop^.pTargetItem^.pPreReqList;

                  pTop^.pPreReqItem := GetFirstLinkedListItem( pTop^.pActivePreReq^ );
                end;
              end;

              pTop^.phase := xpInnerTop;
            end
            else
              pTop^.phase := xpCleanup;
          end;

        xpInnerTop:
          begin
            if( pTop^.bRet and ( pTop^.pPreReqItem <> nil ) )  then
            begin
              Move( pTop^.pPreReqItem^.pValue^,
                    pTop^.targetPair.strValue,
                    sizeof( pTop^.targetPair.strValue ) );

              if( not MkCheckTarget( pTop^.targetPair ) )  then
              begin
                strNextStem     := '';
                pNextTargetItem := MkFindTarget( handle, pTop^.targetPair.strValue );

                if( pNextTargetItem = nil )  then
                  pNextTargetItem := MkFindPatternTarget( handle, pTop^.targetPair.strValue, strNextStem );

                if( pNextTargetItem = nil )  then
                begin
                  pTop^.bRet := false;
                  handle.nLastLine    := -1;
                  handle.strLastError := 'hmake: *** No rule to make target ''' +
                            pTop^.targetPair.strValue +
                            ''', needed by '''  +
                            pTop^.targetPair.strName  +
                            '''.  Stop.';

                  (* Mirrors the original: the cursor still advances even
                     when no rule is found, since the loop only stops on
                     the next condition check. *)
                  pTop^.pPreReqItem := GetNextLinkedListItem( pTop^.pActivePreReq^ );
                end
                else
                begin
                  (* "Recurse": push a child frame and come back here,
                     at xpInnerAfterChild, once it has been fully run. *)
                  pTop^.phase := xpInnerAfterChild;
                  __PushExecFrame( pNextTargetItem, pTop^.pActivePreReq, false, strNextStem );
                end;
              end
              else
                pTop^.pPreReqItem := GetNextLinkedListItem( pTop^.pActivePreReq^ );
            end
            else
              pTop^.phase := xpAfterInner;
          end;

        xpInnerAfterChild:
          begin
            pTop^.bRet        := bChildResult;
            pTop^.pPreReqItem := GetNextLinkedListItem( pTop^.pActivePreReq^ );
            pTop^.phase       := xpInnerTop;
          end;

        xpAfterInner:
          begin
            if( pTop^.bRet )  then
            begin
              if( pTop^.pPreReqItem = nil )  then
              begin
                pTop^.pTargetItem := MkFindTarget( handle, pTop^.targetPair.strName );

                if( pTop^.pTargetItem = nil )  then
                begin
                  strNextStem       := '';
                  pTop^.pTargetItem := MkFindPatternTarget( handle, pTop^.targetPair.strName, strNextStem );
                  if( pTop^.pTargetItem <> nil )  then
                    pTop^.strStem := strNextStem;
                end;
              end;

              if( pTop^.pTargetItem <> nil )  then
                pTop^.bRet := __ExecCommands( pTop^.pTargetItem, pTop^.targetPair.strName,
                                              pTop^.strStem, pTop^.pInstPreReqList )
              else
              begin
                pTop^.bRet := false;
                handle.nLastLine    := -1;
                handle.strLastError := 'hmake: *** No rule to make target ''' +
                                       pTop^.targetPair.strName + '''.  Stop.';
              end;
            end;

            __PrintSeparator;

            pTop^.pTargetNameItem := GetNextLinkedListItem( pTop^.pTargetList^ );
            pTop^.phase           := xpOuterTop;
          end;

        xpCleanup:
          begin
            if( pTop^.pInstPreReqList <> nil )  then
            begin
              DestroyLinkedList( pTop^.pInstPreReqList^ );
              Dispose( pTop^.pInstPreReqList );
            end;

            bChildResult := pTop^.bRet;
            pChild       := pTop;
            pTop         := pTop^.pPrev;

            Dispose( pChild );

            bDone := ( pTop = nil );

            if( not bDone )  then
              pTop^.phase := xpInnerAfterChild;
          end;

      end; (* case pTop^.phase *)
    end; (* while not bDone *)

    __ExecTarget := bChildResult;
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
  (* Initialize PHONY target list *)
  strPhonyIdent := __ctTargetPHONY;
  pPhonyTarget  := MkFindTarget( handle, strPhonyIdent );
  pPhonyList    := nil;

  if( pPhonyTarget <> nil )  then
    pPhonyList := pPhonyTarget^.pPreReqList;

  (* Execute target *)
  if( GetLinkedListSize( pUsrTargetList^ ) > 0 )  then
  begin
    pTargetNameItem := GetFirstLinkedListItem( pUsrTargetList^ );
    Move( pTargetNameItem^.pValue^, strTargetName, sizeof( strTargetName ) );
    pTargetItem := MkFindTarget( handle, strTargetName );
    MkExecute   := __ExecTarget( pTargetItem, pUsrTargetList, true, '' );
  end
  else
  begin
    pTargetItem     := handle.pDefaultTarget;
    pTargetNameItem := GetFirstLinkedListItem( pTargetItem^.targetNameList );
    Move( pTargetNameItem^.pValue^, strTargetName, sizeof( strTargetName ) );
    MkExecute := __ExecTarget( pTargetItem, @pTargetItem^.targetNameList, true, '' );
  end;
end;
