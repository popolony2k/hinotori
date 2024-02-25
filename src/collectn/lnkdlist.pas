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
Type PLinkedListItem = ^TLinkedListItem;
     TLinkedListItem = Record
  pValue      :  Pointer;                 { Pointer to the item value }
  pNextItem   :  PLinkedListItem;         { Pointer to the next item  }
End;

(**
  * List handle definition.
  *)
Type PLinkedList = ^TLinkedList;
     TLinkedList = Record
  pFirstItem       : PLinkedListItem;     { First List item           }
  pCurrentItem     : PLinkedListItem;     { Current list item         }
  nListSize        : Integer;             { The linked list size      }
  nItemSize        : Integer;             { The linked list item size }
End;


(**
  * Iterator function. Get the first item of a linked list.
  * @param list The list which item will be retrieved;
  *)
Function GetFirstLinkedListItem( Var list : TLinkedList ) : PLinkedListItem;
Begin
  list.pCurrentItem := list.pFirstItem;
  GetFirstLinkedListItem := list.pFirstItem;
End;

(**
  * Iterator function. Get the next item of a linked list.
  * @param list The list which item will be retrieved;
  *)
Function GetNextLinkedListItem( Var list : TLinkedList ) : PLinkedListItem;
Begin
  If( list.pCurrentItem <> Nil )  Then
    list.pCurrentItem := list.pCurrentItem^.pNextItem;

  GetNextLinkedListItem := list.pCurrentItem;
End;

(**
  * Iterator function. Get the last (valid) item of a linked list.
  * @param list The list which item will be retrieved;
  *)
Function GetLastLinkedListItem( Var list : TLinkedList ) : PLinkedListItem;
Begin
  list.pCurrentItem := list.pFirstItem;

  If( list.pCurrentItem <> Nil )  Then
  Begin
    While( list.pCurrentItem^.pNextItem <> Nil ) Do
      list.pCurrentItem := list.pCurrentItem^.pNextItem;
  End;

  GetLastLinkedListItem := list.pCurrentItem;
End;

(**
  * Add an item at the end of a linked list.
  * @param list The list which the item will be added;
  * @param pValue The pointer to the list value which will be stored;
  *)
Function AddLinkedListItem( Var list : TLinkedList;
                            pValue : Pointer ) : Boolean;
Var
       pParentItem,
       pNewItem       : PLinkedListItem;
       bIsParent      : Boolean;

Begin
  pParentItem := GetLastLinkedListItem( list );

  (* Check if list is empty *)
  If( pParentItem = Nil )  Then
  Begin
    New( pParentItem );
    list.pFirstItem := pParentItem;
    pNewItem  := pParentItem;
    bIsParent := True;
  End
  Else
  Begin
    bIsParent := False;
    pNewItem  := Nil;
  End;

  If( pParentItem <> Nil )  Then
  Begin
    If( Not bIsParent )  Then
      New( pNewItem );

    If( pNewItem <> Nil )  Then
    Begin
      If( list.nItemSize > 0 )  Then
      Begin
        GetMem( pNewItem^.pValue, list.nItemSize );
        Move( pValue^, pNewItem^.pValue^, list.nItemSize );
      End
      Else
        pNewItem^.pValue := Nil;

      pNewItem^.pNextItem := Nil;
    End;

    If( Not bIsParent )  Then
      pParentItem^.pNextItem := pNewItem;
  End;

  (* Increment the list size *)
  If( pNewItem <> Nil )  Then
    list.nListSize := Succ( list.nListSize );

  AddLinkedListItem := ( pNewItem <> Nil );
End;

(**
  * Get the list size.
  * @param list The list that the size will be retrieved;
  *)
Function GetLinkedListSize( Var list : TLinkedList ) : Integer;
Begin
  GetLinkedListSize := list.nListSize;
End;

(**
  * Check if the linked list is empty.
  * @param list The linked list to check;
  *)
Function IsLinkedListEmpty( Var list : TLinkedList ) : Boolean;
Begin
  IsLinkedListEmpty := ( ( list.nListSize = 0 ) Or ( list.pFirstItem = Nil ) );
End;

(**
  * Get a linked list item by the specified index;
  * @param list The list which item will be retrieved;
  * @param nIndex The item index that will retrieved;
  *)
Function GetLinkedListItemByIndex( Var list : TLinkedList;
                                   nIndex : Integer ) : PLinkedListItem;
Var
      nCount   : Integer;
      pItem    : PLinkedListItem;

Begin
  pItem  := GetFirstLinkedListItem( list );
  nCount := 0;

  While( ( pItem <> Nil ) And ( nCount < nIndex ) )  Do
  Begin
    pItem  := pItem^.pNextItem;
    nCount := Succ( nCount );
  End;

  GetLinkedListItemByIndex := pItem;
End;

(**
  * Create and initialize a linked list;
  * @param list The list structure that will be initialized;
  * @param nItemSize The size of each item that will be added to the list;
  * @param nComparatorFn The procedure address to the comparator routine;
  *)
Procedure CreateLinkedList( Var list : TLinkedList; nItemSize : Integer );
Begin
  list.pFirstItem   := Nil;
  list.pCurrentItem := Nil;
  list.nItemSize := nItemSize;
  list.nListSize := 0;
End;

(**
  * Destroy and release a linked list;
  * @param list The list structure that will be initialized;
  *)
Procedure DestroyLinkedList( Var list : TLinkedList );
Var
       pCurrentItem,
       pNextItem      : PLinkedListItem;

Begin
  pCurrentItem := GetFirstLinkedListItem( list );

  (* Release all list's data *)
  While( pCurrentItem <> Nil )  Do
  Begin
    pNextItem := pCurrentItem^.pNextItem;

    If( ( pCurrentItem^.pValue <> Nil ) And ( list.nItemSize > 0 ) ) Then
      FreeMem( pCurrentItem^.pValue, list.nItemSize );

    Dispose( pCurrentItem );
    pCurrentItem := pNextItem;
  End;

  (* Reset list data *)
  With list Do
  Begin
    pFirstItem   := Nil;
    pCurrentItem := Nil;
    nItemSize    := 0;
    nListSize    := 0;
  End;
End;
