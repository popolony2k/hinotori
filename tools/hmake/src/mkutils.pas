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
 * - ./mktypes.pas;
 *)

(**
  * Internal module variable definition.
  *)
const 
       __ctCSI   = '['; { Control Sequence Introducer.
                          On Unix is '[', on MSXDOS is empty char }

(**
  * Initialize build engine.
  * @param handle A @see TMakeHandle that will be initialized;
  *)
procedure MkInit( var handle : TMakeHandle );
begin
  with handle do
  begin
    nCursor    := 0;
    aCursor[0] := '|';
    aCursor[1] := '/';
    aCursor[2] := '-';
    aCursor[3] := '\';
  end;
end;

(**
  * Update progress indicator.
  * @param handle A @see TMakeHandle of makefile that
  * has been processed;
  *)
procedure UpdateProgress( var handle : TMakeHandle );
begin
  with handle do
  begin
    Write( #27, __ctCSI, 'D' );
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
procedure PrintDebug( var handle : TMakeHandle );
var
    pItem     : PLinkedListItem;
    pCmdItem  : PLinkedListItem;
    pair      : TIdentifierPair;
    target    : TTarget;
    command   : TIdentifierValue;

begin
  pItem := GetFirstLinkedListItem( handle.variableList );

  WriteLn;
  
  if( pItem <> nil )  then
    WriteLn( 'VARIABLES ======');

  WriteLn;
  
  while( pItem <> nil )  do
  begin
    Move( pItem^.pValue^, pair, sizeof( pair ) );
    WriteLn( 'Item Name  -> ', pair.strName );
    WriteLn( 'Item Value -> ', pair.strValue );
    WriteLn( '-----------------------' );

    pItem := GetNextLinkedListItem( handle.variableList );
  end;

  pItem := GetFirstLinkedListItem( handle.targetList );

  Writeln;

  if( pItem <> nil )  then
    WriteLn( 'TARGETS ======');

  WriteLn;

  while( pItem <> nil )  do
  begin
    Move( pItem^.pValue^, target, sizeof( target ) );
    WriteLn( 'Item Name  -> ', target.target.strName );
    WriteLn( 'Item Value -> ', target.target.strValue );

    pCmdItem := GetFirstLinkedListItem( target.commandList );

    if( pCmdItem <> nil )  then
      WriteLn( 'COMMANDS ======');

    while( pCmdItem <> nil )  do
    begin
      Move( pCmdItem^.pValue^, command, sizeof( command ) );
      WriteLn( 'CMD -> ', command );
      pCmdItem := GetNextLinkedListItem( target.commandList );
    end;

    WriteLn( '-----------------------' );

    pItem := GetNextLinkedListItem( handle.targetList );
  end;
end;
