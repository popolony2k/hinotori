(*<mkbuild.pas>
 * Hinotori make file parse and build routines.
 *
 * CopyLeft (c) 1995-2024 by PopolonY2k.
 * CopyLeft (c) since 2024 by Hinotori Team.
 *)

(*
 * This module depends on folowing include files (respect the order):
 *
 * - /system/types.pas;
 * - /collectn/lnkdlist.pas;
 * - /memory/fpc/pointer.pas;  (depends on archtecture)
 * - /memory/msx/pointer.pas;  (depends on archtecture)
 * - /util/helpstr.pas;
 * - ./make/mktypes.pas;
 * - ./make/mkhelper.pas;
 * - ./make/mkutils.pas;
 *)


(**
 * Parse and build the makefile data struct. This function will 
 * parse the makefile, creating all needed infrastructure needed
 * by building process of a project;
 * @param handle The handle of a makefile previously opened by 
 * @see MkOpen;
 * The function will return true if the operation was successfull 
 * otherwise false;
 *)
function MkBuild( var handle : TMakeHandle ) : boolean;
var
       strLine      : TIdentifierValue;
       bMustRead    : boolean;
       bRet         : boolean;
       pTargets     : PTarget;
       aChToken     : array [IDENT_VARIABLE..IDENT_TARGETS] of char;

  (**
    * Read comtent from file.
    * The function return true when operation is success
    * otherwise false;
    *)
  function __ReadFile : boolean;
  begin
      {$i-}
      ReadLn( handle.hFile, strLine );
      {$i+}

      handle.nLastLine := Succ( handle.nLastLine );
      __ReadFile := ( IOResult = 0 );
  end;

  (**
    * Create the target list with all targets passed by parameter.
    * @param handle The handle of a makefile previously opened by 
    * @see MkOpen;
     * @param target The @link TTarget data struct where list will be 
    * created;
    * @param strTarget The target string with all targets separated by space;
    * The function return false if some target already exist os list is empty;
    *)
  function __CreateTargetList( var handle : TMakeHandle; 
                               var target : TTarget; 
                               strTarget : TIdentifierName ) : boolean;
  var
    pItem      : PLinkedListItem;
    pStrTarget : PIdentifierName;
    bRet       : boolean;

  begin
    with target do
    begin
      bRet := false;

      (* Create list with all targets (Multi-target) *)
      CreateLinkedList( targetNameList, 
                        sizeof( TIdentifierName ) );

      if( SplitString( strTarget, ' ', targetNameList ) > 0 ) then
      begin
        pItem := GetFirstLinkedListItem( targetNameList );
        bRet  := ( pItem <> nil ); 
        
        while( bRet and ( pItem <> nil ) )  do
        begin
          Move( pItem^.pValue, pStrTarget, sizeof( pStrTarget ) );
          bRet  := ( MkFindTarget( handle, pStrTarget^ ) = nil );

          if( bRet )  then
          begin
            if( MkReplaceReferences( handle, pStrTarget^ ) ) then;
            pItem := GetNextLinkedListItem( targetNameList );
          end
          else
            handle.strLastError := 'target [' + pStrTarget^ + 
                                   '] already defined'
        end;
      end;
    end;

    __CreateTargetList := bRet;
  end;

 (**
    * Create the pre-requisites list with all pre-requisites passed by 
    * parameter.
    * @param handle The handle of a makefile previously opened by 
    * @see MkOpen;
    * @param target The @link TTarget data struct where list will be 
    * created;
    * @param strPrereq The pre-requisite string with all pre-requisites 
    * separated by space;
    * The function return false if something goes wrong;
    *)
  function __CreatePrerequisiteList( var handle : TMakeHandle;
                                     var target : TTarget; 
                                     strPrereq : TIdentifierValue ) : boolean;
  var 
         pItem      : PLinkedListItem;
         bRet       : boolean;
         pStrPrereq : PIdentifierValue;

  begin
    with target do 
    begin
      New( pPreReqList );
      CreateLinkedList( pPreReqList^, sizeof( TIdentifierValue ) );
      bRet := ( SplitString( strPrereq, ' ', pPreReqList^ ) >= 0 );     

      if( bRet )  then
      begin
        pItem := GetFirstLinkedListItem( pPreReqList^ );
        
        while( bRet and ( pItem <> nil ) )  do
        begin
          Move( pItem^.pValue, pStrPrereq, sizeof( pStrPrereq ) );
          if( MkReplaceReferences( handle, pStrPrereq^ ) ) then;
          pItem := GetNextLinkedListItem( pPreReqList^ );
        end;
      end
      else
        handle.strLastError := 'error processing pre-requisite [' + 
                               strPrereq + ']';
    end;

    __CreatePrerequisiteList := bRet;
  end;

  (**
    * Parse identifier value.
    * @param pair The containing @see TIdentifierPair value that 
    * will be parsed and the content will return into the same 
    * variable;  
    *)
  function __ParseValue( var pair : TIdentifierPair ) : boolean;
  var
         nPos : integer;
         bRet : boolean;

  begin
    bRet := ( MkCheckValidIdentifier( handle, pair ) );

    if( bRet )  then
    begin
      repeat
        with pair do
        begin
          nPos := Pos( '\', strValue );

          if( nPos > 0 )  then
          begin
            strValue := Copy( strValue, 1, ( nPos - 1 ) );
            strValue := RemoveChar( Trim( strValue ), ctTAB );
            bRet := __ReadFile;

            if( bRet )  then
            begin
              nPos := Pos( '\', strLine );

              (*
               * Already read data from file, process in the next loop.
               *)
              if( nPos <= 0 )  then
                bMustRead := ( ( Pos( ':', strLine ) = 0 ) and 
                               ( Pos( '=', strLine ) = 0 ) );

              if( bMustRead )  then
              begin
                strValue := strValue + ' ' + Trim( strLine );
              end;
            end
            else
              handle.strLastError := 'Error reading makefile';
          end
          else
            strValue := Trim( strValue );
        end;
      until( not bRet or ( nPos <= 0 ) );
    end;

    __ParseValue := bRet;  
  end;

  (**
    * Parse the target content.
    * @param target Reference to target to process;
    * @param pPair The pointer to pair with target data that will be 
    * processed.
    *)
  function __ParseTarget( var target : TTarget; 
                          pPair : PIdentifierPair ) : boolean;
  var 
        bRet    : boolean;
        pItem   : PLinkedListItem;

  begin
    (* Check if target was already defined previously *)
    bRet := ( MkFindTarget( handle, pPair^.strName ) = nil );

    if( bRet )  then
      bRet := __CreateTargetList( handle, 
                                  target, 
                                  pPair^.strName );

    if( bRet )  then
      bRet := __CreatePrerequisiteList( handle, 
                                        target, 
                                        pPair^.strValue );

    if( bRet )  then
    begin
      pItem := AddLinkedListItem( handle.targetList, 
                                  ToPointer( target ) );
      bRet := ( pItem <> nil );

      (* 
      * If there's no default target, it means that is 
      * the first target being processed, so according 
      * makefile rules (GNU), the first target id the 
      * default target.
      *)
      if( ( handle.pDefaultTarget = nil ) and bRet )  then
        Move( pItem^.pValue, 
              handle.pDefaultTarget, 
              sizeof( pItem^.pValue ) );

      if( bRet )  then
        Move( pItem^.pValue, 
              pTargets, 
              sizeof( pTargets ) )
      else
        handle.strLastError := 'Not enough memory -> ' + strLine;
    end;

    __ParseTarget := bRet;
  end;

  (**
    * Parse command.
    *)
  function __ParseCommand : boolean;
  var
          bRet   : boolean;

  begin
    strLine := RemoveChar( Trim( strLine ), ctTAB );

    if( ( pTargets <> nil ) and ( strLine <> '' ) )  then
    begin
      bRet := ( AddLinkedListItem( pTargets^.commandList, 
                                    ToPointer( strLine ) ) <> nil );
      
      if( not bRet )  then
        handle.strLastError := 'Not enough memory';
    end;

    __ParseCommand := bRet;
  end;

  (**
    * Parse the identifier by its type.
    * @param identType The identifier type to process;
    * @param target Reference to target to process;
    * @param pair Reference to a valid @see TIdentifier variable;
    * @param pPair Reference to a pointer to receive the pair 
    * variable deferenced pointer, when identType is IDENT_VARIABLE;
    *)
  function __ParseIdentifier( identType : TIdentifierType;
                              var target : TTarget;
                              var pair   : TIdentifierPair;
                              var pPair  : PIdentifierPair ) : boolean;
  var
        bRet    : boolean;
        pPtr    : TPointer;

  begin
    bRet := true;

    case identType of
      TIdentifierType.IDENT_VARIABLE :
      begin
        (* Cannot assign variable in targets *)
        if( handle.pDefaultTarget <> nil )  then
        begin
          handle.strLastError := 'Cannot assign variable in targets';
          bRet := false;
        end
        else
        begin
          pPtr := ToPointer( pair );
          Move( pPtr, pPair, sizeof( pPair ) );
        end;
      end;

      TIdentifierType.IDENT_TARGETS  :
      begin
        CreateLinkedList( target.commandList, 
                          sizeof( TIdentifierValue ) );
      end;
    end;

    pPair^.identType := identType;

    __ParseIdentifier := bRet;
  end;

  (**
    * Read identifier data content.
    * @param identType The identifier type to process;
    * @param target Reference to target to process;
    * @param tokenList Reference to a valid @see TLinkedList token list;
    * @param pair Reference to a valid @see TIdentifier variable;
    *)
  function __ReadIdentifierData( identType : TIdentifierType;
                                 var target : TTarget;
                                 var tokenList : TLinkedList;
                                 pPair  : PIdentifierPair ) : boolean;
  var
      nCount   : integer;
      bRet     : boolean;
      pItem    : PLinkedListItem;

  begin
    nCount := 0;
    pItem  := GetFirstLinkedListItem( tokenList );
    bRet   := ( pItem <> nil );

    if( not bRet )  then
      handle.strLastError := 'Catastrophic parsing error';

    while( bRet and ( pItem <> nil ) )  do
    begin
      if( ( nCount mod 2 ) = 0 )  then
      begin
        Move( pItem^.pValue^, 
              pPair^.strName, 
              sizeof( pPair^.strName ) );
        pPair^.strName := Trim( pPair^.strName );
      end
      else
      begin
        Move( pItem^.pValue^, 
              pPair^.strValue, 
              sizeof( pPair^.strValue ) );
        
        bRet := __ParseValue( pPair^ );

        if( bRet )  then
        begin
          case identType of
            TIdentifierType.IDENT_VARIABLE :
            begin 
              bRet := AddLinkedListItem( handle.variableList, 
                                          ToPointer( pPair^ ) ) <> nil;

              if( not bRet )  then
                handle.strLastError := 'Not enough memory -> ' +
                                        strLine;
            end;

            TIdentifierType.IDENT_TARGETS  :
              bRet := __ParseTarget( target, pPair );
          end;
        end;
      end;

      if( bRet )  then
      begin
        nCount := Succ( nCount );
        pItem  := GetNextLinkedListItem( tokenList );
        MkUpdateProgress( handle );
      end;
    end;

    __ReadIdentifierData := bRet;
  end;

  (**
    * Parse all make file valid tokens;
    * If the parsing is successful bRet is set to true
    * otherwise false;
    *)
  function __Parse : boolean;
  var
        nCount         : integer;
        bRet           : boolean;
        bTargetRemark  : boolean;
        bRegularRemark : boolean;
        tokenList      : TLinkedList;
        target         : TTarget;
        pair           : TIdentifierPair;
        pPair          : PIdentifierPair;
        identType      : TIdentifierType;

  begin
    bRet      := true;
    bMustRead := true;

    (* Remove remarks *)
    nCount := Pos( '#', strLine );
    bTargetRemark  := ( ( nCount = 1 ) and ( handle.pDefaultTarget <> nil ) );
    bRegularRemark := ( ( nCount >= 1 ) and ( handle.pDefaultTarget = nil ) ); 

    if( bTargetRemark or bRegularRemark )  then 
      Delete( strLine, nCount, ( Length( strLine ) - nCount + 1 ) );

    identType := MkIdentifierType( handle, strLine );

    case identType of

      TIdentifierType.IDENT_COMMAND:
        __ParseCommand;

      TIdentifierType.IDENT_NOP:
      begin
        bRet := false;
        handle.strLastError := 'Missing separator';
      end;

      TIdentifierType.IDENT_VARIABLE, 
      TIdentifierType.IDENT_TARGETS :
      begin
        CreateLinkedList( tokenList, sizeof( TIdentifierValue ) );
        nCount := SplitString( strLine, aChToken[identType], tokenList );
        
        if( nCount > 0 )  then
        begin
          bRet := __ParseIdentifier( identType, target, pair, pPair );

          if( bRet )  then
            bRet := __ReadIdentifierData( identType,
                                          target,
                                          tokenList,
                                          pPair );
        end
        else
        begin
          handle.strLastError := 'Invalid identifier ' + strLine;
          bRet := false; 
        end;

        DestroyLinkedList( tokenList );
      end;
    end;

    MkUpdateProgress( handle );

    __Parse := bRet;
  end;

(*
 * MkBuid main routine
 *)
begin
  bRet := handle.bIsOpen;

  if( bRet )  then
  begin
    (* General perser init *)
    bMustRead  := true;
    pTargets   := nil;
    aChToken[IDENT_VARIABLE] := '=';
    aChToken[IDENT_TARGETS]  := ':';

    Write( 'Processing ( )' );
    Write( #27, handle.chCSI, 'D' );
  
    while( bRet and not eof( handle.hFile ) ) do
    begin
      if( bMustRead )  then
        bRet := __ReadFile;

      if( bRet )  then
        bRet := __Parse;
    end;

    Write( #27, handle.chCSI, 'D' );
    Write( '*' );
    Write( #27, handle.chCSI, 'C' );
    WriteLn;
  end;

  MkBuild := bRet;
end;
