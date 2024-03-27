(*<lnkdlist.pas>
 * Linked list implementation.
 * CopyLeft (c) 1995-2024 by PopolonY2k.
 * CopyLeft (c) since 2024 by Hinotori Team.
 *)

(*
 * This module depends on folowing include files (respect the order):
 * - /system/types.pas;
 *)


(**
  * Linked list item definition.
  *)
type PLinkedListItem = ^TLinkedListItem;
     TLinkedListItem = record
  pValue      :  Pointer;                 { Pointer to the item value }
  pNextItem   :  PLinkedListItem;         { Pointer to the next item  }
end;

(**
  * List handle definition.
  *)
type PLinkedList = ^TLinkedList;
     TLinkedList = record
  pFirstItem       : PLinkedListItem;     { First List item           }
  pCurrentItem     : PLinkedListItem;     { Current list item         }
  nListSize        : integer;             { The linked list size      }
  nItemSize        : integer;             { The linked list item size }
end;


(**
  * Iterator function. Get the first item of a linked list.
  * @param list The list which item will be retrieved;
  *)
function GetFirstLinkedListItem( var list : TLinkedList ) : PLinkedListItem;
begin
  list.pCurrentItem := list.pFirstItem;
  GetFirstLinkedListItem := list.pFirstItem;
end;

(**
  * Iterator function. Get the next item of a linked list.
  * @param list The list which item will be retrieved;
  *)
function GetNextLinkedListItem( var list : TLinkedList ) : PLinkedListItem;
begin
  if( list.pCurrentItem <> nil )  then
    list.pCurrentItem := list.pCurrentItem^.pNextItem;

  GetNextLinkedListItem := list.pCurrentItem;
end;

(**
  * Iterator function. Get the last (valid) item of a linked list.
  * @param list The list which item will be retrieved;
  *)
function GetLastLinkedListItem( var list : TLinkedList ) : PLinkedListItem;
begin
  list.pCurrentItem := list.pFirstItem;

  if( list.pCurrentItem <> nil )  then
  begin
    while( list.pCurrentItem^.pNextItem <> nil ) do
      list.pCurrentItem := list.pCurrentItem^.pNextItem;
  end;

  GetLastLinkedListItem := list.pCurrentItem;
end;

(**
  * Add an item at the end of a linked list.
  * @param list The list which the item will be added;
  * @param pValue The pointer to the list value which will be stored;
  *)
function AddLinkedListItem( var list : TLinkedList;
                            pValue : Pointer ) : boolean;
var
       pParentItem,
       pNewItem       : PLinkedListItem;
       bIsParent      : boolean;

begin
  pParentItem := GetLastLinkedListItem( list );

  (* Check if list is empty *)
  if( pParentItem = nil )  then
  begin
    New( pParentItem );
    list.pFirstItem := pParentItem;
    pNewItem  := pParentItem;
    bIsParent := True;
  end
  else
  begin
    bIsParent := False;
    pNewItem  := nil;
  end;

  if( pParentItem <> nil )  then
  begin
    if( not bIsParent )  then
      New( pNewItem );

    if( pNewItem <> nil )  then
    begin
      if( list.nItemSize > 0 )  then
      begin
        GetMem( pNewItem^.pValue, list.nItemSize );
        Move( pValue^, pNewItem^.pValue^, list.nItemSize );
      end
      else
        pNewItem^.pValue := nil;

      pNewItem^.pNextItem := nil;
    end;

    if( not bIsParent )  then
      pParentItem^.pNextItem := pNewItem;
  end;

  (* Increment the list size *)
  if( pNewItem <> nil )  then
    list.nListSize := Succ( list.nListSize );

  AddLinkedListItem := ( pNewItem <> nil );
end;

(**
  * Get the list size.
  * @param list The list that the size will be retrieved;
  *)
function GetLinkedListSize( var list : TLinkedList ) : integer;
begin
  GetLinkedListSize := list.nListSize;
end;

(**
  * Check if the linked list is empty.
  * @param list The linked list to check;
  *)
function IsLinkedListEmpty( var list : TLinkedList ) : boolean;
begin
  IsLinkedListEmpty := ( ( list.nListSize = 0 ) or ( list.pFirstItem = nil ) );
end;

(**
  * Get a linked list item by the specified index;
  * @param list The list which item will be retrieved;
  * @param nIndex The item index that will retrieved;
  *)
function GetLinkedListItemByIndex( var list : TLinkedList;
                                   nIndex : integer ) : PLinkedListItem;
var
      nCount   : integer;
      pItem    : PLinkedListItem;

begin
  pItem  := GetFirstLinkedListItem( list );
  nCount := 0;

  while( ( pItem <> nil ) and ( nCount < nIndex ) )  do
  begin
    pItem  := pItem^.pNextItem;
    nCount := Succ( nCount );
  end;

  GetLinkedListItemByIndex := pItem;
end;

(**
  * Create and initialize a linked list;
  * @param list The list structure that will be initialized;
  * @param nItemSize The size of each item that will be added to the list;
  * @param nComparatorFn The procedure address to the comparator routine;
  *)
procedure CreateLinkedList( var list : TLinkedList; nItemSize : integer );
begin
  list.pFirstItem   := nil;
  list.pCurrentItem := nil;
  list.nItemSize  := nItemSize;
  list.nListSize  := 0;
end;

(**
  * Destroy and release a linked list;
  * @param list The list structure that will be initialized;
  *)
procedure DestroyLinkedList( var list : TLinkedList );
var
       pCurrentItem,
       pNextItem      : PLinkedListItem;

begin
  pCurrentItem := GetFirstLinkedListItem( list );

  (* Release all list's data *)
  while( pCurrentItem <> nil )  do
  begin
    pNextItem := pCurrentItem^.pNextItem;

    if( ( pCurrentItem^.pValue <> nil ) and ( list.nItemSize > 0 ) ) then
      FreeMem( pCurrentItem^.pValue, list.nItemSize );

    Dispose( pCurrentItem );
    pCurrentItem := pNextItem;
  end;

  (* Reset list data *)
  with list do
  begin
    pFirstItem   := nil;
    pCurrentItem := nil;
    nItemSize    := 0;
    nListSize    := 0;
  end;
end;
