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
       strLine      : TString;
       bMustRead    : boolean;
       bRet         : boolean;
       pTargets     : PTarget;

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
         bRet   : boolean;

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
            strValue := Trim( strValue );
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
        chToken    : char;
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
    identType := MkGetIdentifier( strLine );

    case identType of
      TIdentifierType.IDENT_VARIABLE :  chToken := '=';
      TIdentifierType.IDENT_TARGETS  :  chToken := ':'; 
    end;

    if( identType in [ TIdentifierType.IDENT_VARIABLE, 
                       TIdentifierType.IDENT_TARGETS ] )  then
    begin
      CreateLinkedList( tokenList, sizeof( TIdentifierValue ) );
      nCount := SplitString( strLine, chToken, tokenList );
      
      (* Process identifier - Only create and dereference pointers *)
      if( nCount > 0 )  then
      begin
        nCount := 0;
        pItem  := GetFirstLinkedListItem( tokenList );

        case identType of
          TIdentifierType.IDENT_VARIABLE :
          begin
            pPtr := ToPointer( pair );
            Move( pPtr, pPair, sizeof( pPair ) );
          end;

          TIdentifierType.IDENT_TARGETS  :
          begin
            CreateLinkedList( target.commandList, sizeof( TIdentifierValue ) );
            pPtr := ToPointer( target.targetPair );
            Move( pPtr, pPair, sizeof( pPair ) );
          end;
        end;

        pPair^.identType := identType;

        (* Assign identifier values *)
        while( bRet and ( pItem <> nil ) )  do
        begin
          if( ( nCount mod 2 ) = 0 )  then
            Move( pItem^.pValue^, pPair^.strName, sizeof( pPair^.strName ) )
          else
          begin
            Move( pItem^.pValue^, pPair^.strValue, sizeof( pPair^.strValue ) );

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

                  (* If there's no default target, it means that is 
                   * the first target being processed, so according makefile 
                   * rules (GNU), the first target id the default target.
                   *)
                  if( ( handle.pDefaultTarget = nil ) and bRet )  then
                    Move( pTemp^.pValue, handle.pDefaultTarget, sizeof( pTemp^.pValue ) );

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
        handle.strLastError := 'Invalid identifier ' + strLine;
        bRet := false; 
      end;

      DestroyLinkedList( tokenList );
    end
    else
    begin  (* Commands processing *)
      if( ( pTargets <> nil ) and ( Trim( strLine ) <> '' ) )  then
      begin
        bRet := ( AddLinkedListItem( pTargets^.commandList, 
                                     ToPointer( strLine ) ) <> nil );
        
        if( bRet )  then
        begin
          handle.strLastError := 'Not enough memory -> '  + strLine;
        end;
      end;

      UpdateProgress( handle );
    end;

    __Parse := bRet;
  end;

(*
 * MkBuid main routine
 *)
begin
  bRet := handle.bIsOpen;

  if( bRet )  then
  begin
    bMustRead  := true;
    pTargets   := nil;

    Write( 'Processing ( )' );
    Write( #27, __ctCSI, 'D' );
  
    while( bRet and not eof( handle.hFile ) ) do
    begin
      if( bMustRead )  then
        bRet := __ReadFile;

      if( bRet )  then
        bRet := __Parse;
    end;

    Write( #27, __ctCSI, 'D' );
    Write( '*' );
    Write( #27, __ctCSI, 'C' );
    WriteLn;
  end;

  MkBuild := bRet;
end;
