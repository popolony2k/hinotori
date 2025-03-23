(*<mkutils.pas>
 * Hinotori makefile util routines.
 *
 * CopyLeft (c) 1995-2024 by PopolonY2k.
 * CopyLeft (c) since 2024 by Hinotori Team.
 *)

(*
 * This module depends on folowing include files (respect the order):
 *
 * - /system/types.pas;
 * - /collectn/lnkdlist.pas;
 * - ./make/mktypes.pas;
 *)

(**
  * Module constant definitions.
  *)
const 
       ctTAB        = #9;  { TAB chracter definition }
       ctCSI_MSXDOS = '';  { Control Sequence Introducer. MSX-DOS }
       ctCSI_UNIX   = '['; { Control Sequence Introducer. UNIX }
 

(**
  * Initialize build engine.
  * @param handle A @see TMakeHandle that will be initialized;
  *)
procedure MkInit( var handle : TMakeHandle );
begin
  with handle do
  begin
    nCursor    := 0;
    nLastLine  := 0;
    bIsOpen    := false;
    bDebugMode := false;
    aCursor[0] := '|';
    aCursor[1] := '/';
    aCursor[2] := '-';
    aCursor[3] := '\';
    strLastError   := '';
    pDefaultTarget := nil;

    CreateLinkedList( handle.variableList, sizeof( TIdentifierPair ) );
    CreateLinkedList( handle.targetList, sizeof( TTarget ) );
  end;
end;

(**
  * Destroy all resources allocated by makefile processing.
  * @param handle The handle to be released;
  *)
procedure MkDestroy( var handle : TMakeHandle );
var
      pItem     : PLinkedListItem;
      target    : TTarget;

begin
  DestroyLinkedList( handle.variableList );

  (* Destroy target list and its command list *)
  pItem := GetFirstLinkedListItem( handle.targetList );

  while( pItem <> nil )  do
  begin
    Move( pItem^.pValue^, target, sizeof( target ) );
    DestroyLinkedList( target.commandList );
    DestroyLinkedList( target.targetNameList );
    DestroyLinkedList( target.pPreReqList^ );
    Dispose( target.pPreReqList );

    pItem := GetNextLinkedListItem( handle.targetList );
  end;

  DestroyLinkedList( handle.targetList );
end;

(**
  * Update progress indicator.
  * @param handle A @see TMakeHandle of makefile that
  * has been processed;
  *)
procedure MkUpdateProgress( var handle : TMakeHandle );
begin
  with handle do
  begin
    Write( #27, chCSI, 'D' );
    Write( aCursor[nCursor] );

    if( nCursor = 3 )  then
      nCursor := 0
    else
      nCursor := nCursor + 1;
  end;
end;

(**
  * Helper function used by debug only operations,
  * @param handle reference to a valid TMakeHandle with data;
  *)
procedure MkPrintDebug( var handle : TMakeHandle );

  (**
    * Print target list.
    * @param pItem Pointer to the target object on list;
    *)
  procedure __PrintTarget( pItem : TPointer );
  var
          pItemValue  : PLinkedListItem;
          identName   : TIdentifierName;
          identValue  : TIdentifierValue;
          pItemTarget : PTarget;

  begin
    Move( pItem, pItemTarget, sizeof( pItemTarget ) );

    (* Targets *)
    pItemValue := GetFirstLinkedListItem( pItemTarget^.targetNameList );

    if( pItemValue <> nil )  then
    begin
      Write( 'TARGET  -> ' );

      while( pItemValue <> nil )  do
      begin
        Move( pItemValue^.pValue^, identName, sizeof( identName ) );
        Write( identName, ' ' );
        pItemValue := GetNextLinkedListItem( pItemTarget^.targetNameList );
      end;

      WriteLn;
    end;

    (* Pre-requisites *)
    pItemValue := GetFirstLinkedListItem( pItemTarget^.pPreReqList^ );

    if( pItemValue <> nil )  then
    begin
      Write( 'PRE-REQUISITE  -> ' );

      while( pItemValue <> nil )  do
      begin
        Move( pItemValue^.pValue^, identValue, sizeof( identValue ) );
        Write( identValue, ' ' );
        pItemValue := GetNextLinkedListItem( pItemTarget^.pPreReqList^ );
      end;

      WriteLn;
    end;

    (* Commands *)
    pItemValue := GetFirstLinkedListItem( pItemTarget^.commandList );

    if( pItemValue <> nil )  then
      WriteLn( 'COMMANDS ======');

    while( pItemValue <> nil )  do
    begin
      Move( pItemValue^.pValue^, identValue, sizeof( identValue ) );
      WriteLn( 'CMD -> ', identValue );
      pItemValue := GetNextLinkedListItem( pItemTarget^.commandList );
    end;

    WriteLn( '-----------------------' );
  end;


(*
 * MkPrintDebug main entry point.
 *)
var
    pTargetPtr : TPointer;
    pItem      : PLinkedListItem;
    pair       : TIdentifierPair;

begin
  pItem := GetFirstLinkedListItem( handle.variableList );

  WriteLn;
  
  if( pItem <> nil )  then
    WriteLn( 'VARIABLES ======');

  WriteLn;
  
  while( pItem <> nil )  do
  begin
    Move( pItem^.pValue^, pair, sizeof( pair ) );
    WriteLn( 'Name  -> ', pair.strName );
    WriteLn( 'Value -> ', pair.strValue );
    WriteLn( '-----------------------' );

    pItem := GetNextLinkedListItem( handle.variableList );
  end;

  pItem := GetFirstLinkedListItem( handle.targetList );

  Writeln;

  if( pItem <> nil )  then
    WriteLn( 'TARGETS ======');

  WriteLn;

  (* Print all targets *)
  while( pItem <> nil )  do
    begin
      __PrintTarget( pItem^.pValue );
      pItem := GetNextLinkedListItem( handle.targetList );
    end;

  if( handle.pDefaultTarget <> nil )  then
  begin
    Writeln;
    WriteLn( 'DEFAULT TARGET ======');

    Move( handle.pDefaultTarget, pTargetPtr, sizeof( pTargetPtr ) ); 
    __PrintTarget( pTargetPtr );
  end
end;
