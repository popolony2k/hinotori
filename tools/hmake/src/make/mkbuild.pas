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
 * - /memory/pointer.pas;
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
    * Parse identifier value.
    * @param pair The containing @see TIdentifierPair value that 
    * will be parsed and the content will return into the same 
    * variable;  
    *)
  function __ParseValue( var pair : TIdentifierPair ) : boolean;
  var
         nPos   : integer;
         nCount : integer;
         bRet   : boolean;

  begin
    bRet := ( MkCheckValidIdentifier( handle, pair ) );

    if( bRet )  then
    begin
      repeat
        with pair do
        begin
          nPos := Pos( '#', strValue );

          if( nPos <> 0 )  then
          begin
            nCount := Length( strValue );

            if( nCount > nPos )  then
              nCount := ( nCount - nPos );

            Delete( strValue, nPos, nCount );
            strValue := Trim( strValue );
          end;

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
          end;
        end;
      until( not bRet or ( nPos <= 0 ) );
    end;

    __ParseValue := bRet;  
  end;

  (**
    * Parse all make file valid tokens;
    * If the parsing is successful bRet is set to true
    * otherwise false;
    *)
  function __Parse : boolean;
  var
        nCount     : integer;
        bRet       : boolean;
        pItem      : PLinkedListItem;
        pTemp      : PLinkedListItem;
        tokenList  : TLinkedList;
        target     : TTarget;
        pair       : TIdentifierPair;
        pPair      : PIdentifierPair;
        identType  : TIdentifierType;
        pPtr       : TPointer;

  begin
    bRet      := true;
    bMustRead := true;
    identType := MkIdentifierType( handle, strLine );

    case identType of
      TIdentifierType.IDENT_VARIABLE, 
      TIdentifierType.IDENT_TARGETS :
        begin
          CreateLinkedList( tokenList, sizeof( TIdentifierValue ) );
          nCount := SplitString( strLine, aChToken[identType], tokenList );
          
          (* Process identifier - Only create and dereference pointers *)
          if( nCount > 0 )  then
          begin
            nCount := 0;
            pItem  := GetFirstLinkedListItem( tokenList );
            bRet   := ( pItem <> nil ); 

            if( bRet )  then
            begin
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
                  pPtr := ToPointer( target.targetPair );
                  Move( pPtr, pPair, sizeof( pPair ) );
                  Move( pItem^.pValue^, 
                        pPair^.strName, 
                        sizeof( pPair^.strName ) );

                  (* Check if target was already defined previously *)
                  bRet := ( MkFindTarget( handle, pPair^.strName ) = nil );

                  if( bRet )  then
                    CreateLinkedList( target.commandList, 
                                      sizeof( TIdentifierValue ) )
                  else
                    handle.strLastError := 'target [' + pPair^.strName + 
                                           '] already defined';
                end;
              end;

              pPair^.identType := identType;

              (* Assign identifier values *)
              while( bRet and ( pItem <> nil ) )  do
              begin
                if( ( nCount mod 2 ) = 0 )  then
                begin
                  Move( pItem^.pValue^, 
                        pPair^.strName, 
                        sizeof( pPair^.strName ) );
                end
                else
                begin
                  Move( pItem^.pValue^, 
                        pPair^.strValue, 
                        sizeof( pPair^.strValue ) );

                  if( __ParseValue( pPair^ ) )  then
                  begin
                    case identType of
                      TIdentifierType.IDENT_VARIABLE :
                      begin 
                        pTemp := AddLinkedListItem( handle.variableList, 
                                                    ToPointer( pPair^ ) );
                        bRet := ( pTemp <> nil );
                      end;
                      TIdentifierType.IDENT_TARGETS  :
                      begin
                        pTemp := AddLinkedListItem( handle.targetList, 
                                                    ToPointer( target ) );
                        bRet := ( pTemp <> nil );

                        (* 
                         * If there's no default target, it means that is 
                         * the first target being processed, so according makefile 
                         * rules (GNU), the first target id the default target.
                         *)
                        if( ( handle.pDefaultTarget = nil ) and bRet )  then
                          Move( pTemp^.pValue, 
                                handle.pDefaultTarget, 
                                sizeof( pTemp^.pValue ) );

                        if( bRet )  then
                          Move( pTemp^.pValue, pTargets, sizeof( pTargets ) );
                      end;
                    end;

                    if( not bRet )  then
                      handle.strLastError := 'Not enough memory -> ' + strLine;
                  end
                  else
                    bRet := false;
                end;

                if( bRet )  then
                begin
                  nCount := Succ( nCount );
                  pItem  := GetNextLinkedListItem( tokenList );
                  UpdateProgress( handle );
                end;
              end;
            end
            else
            begin
              handle.strLastError := 'Catastrophic parsing error';
            end;       
          end
          else
          begin
            handle.strLastError := 'Invalid identifier ' + strLine;
            bRet := false; 
          end;

          DestroyLinkedList( tokenList );
        end;

        TIdentifierType.IDENT_COMMAND:
        begin  (* Commands processing *)
          strLine := RemoveChar( Trim( strLine ), ctTAB );

          if( ( pTargets <> nil ) and ( strLine <> '' ) )  then
          begin
            bRet := ( AddLinkedListItem( pTargets^.commandList, 
                                        ToPointer( strLine ) ) <> nil );
            
            if( not bRet )  then
            begin
              handle.strLastError := 'Not enough memory';
            end;
          end;
        end;

        TIdentifierType.IDENT_NOP:
        begin
          bRet := false;
          handle.strLastError := 'Missing separator';
        end;
    end;

    UpdateProgress( handle );

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
    Write( #27, ctCSI, 'D' );
  
    while( bRet and not eof( handle.hFile ) ) do
    begin
      if( bMustRead )  then
        bRet := __ReadFile;

      if( bRet )  then
        bRet := __Parse;
    end;

    Write( #27, ctCSI, 'D' );
    Write( '*' );
    Write( #27, ctCSI, 'C' );
    WriteLn;
  end;

  MkBuild := bRet;
end;
