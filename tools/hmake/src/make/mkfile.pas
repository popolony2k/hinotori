(*<mkfile.pas>
 * Hinotori makefile file I/O routines.
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
 * Open a make file for processing.
 * @param strFileName The make file name to open;
 * @param handle A @see TMakeHandle of the opened makefile
 * that will be used to perform all make operations;
 * The function will return true for success operation 
 * otherwise false;
 *)
function MkOpen( strFileName : TFileName; var handle : TMakeHandle ) : boolean;
begin
  {$i-}
  Assign( handle.hFile, strFileName );
  Reset( handle.hFile );
  {$i+}

  handle.bIsOpen := ( IOResult = 0 );

  if( handle.bIsOpen )  then
  begin
    CreateLinkedList( handle.variableList, sizeof( TIdentifierPair ) );
    CreateLinkedList( handle.targetList, sizeof( TTarget ) );
  end;

  MkOpen := ( handle.bIsOpen );
end;

(**
 * Close a previously open make file.
 * @param handle The handle of a makefile previously opened by @see MkOpen;
 * The function will return true if the operation was successfull otherwise false;
 *)
function MkClose( var handle : TMakeHandle ) : boolean;
var
      pItem     : PLinkedListItem;
      target    : TTarget;

begin
  if( handle.bIsOpen )  then
  begin
    DestroyLinkedList( handle.variableList );

    (* Destroy target list and its command list *)
    pItem := GetFirstLinkedListItem( handle.targetList );

    while( pItem <> nil )  do
    begin
      Move( pItem^.pValue^, target, sizeof( target ) );
      DestroyLinkedList( target.commandList );
      pItem := GetNextLinkedListItem( handle.targetList );
    end;

    DestroyLinkedList( handle.targetList );

    {$i-}
    Close( handle.hFile );
    {$i+}
    handle.bIsOpen := false;
  end;

  MkClose := ( IOResult = 0 );
end;
