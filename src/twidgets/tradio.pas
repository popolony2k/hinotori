(*<tradio.pas>
 * Text user interface widgets implementation.
 * Implement the radio menu based widget.
 * CopyLeft (c) 1995-2024 by PopolonY2k.
 * CopyLeft (c) since 2024 by Hinotori Team.
 *)

(*
 * This module depends on folowing include files (respect the order):
 * - /system/types.pas;
 * - /util/helpchar.pas;
 * - /bios/msxbios.pas;
 * - /console/conio.pas;
 *)

(*
 * Constant definitions for Widgets module.
 *)
Const
          ctRadioSel : Char    = '*'; { Radio widget selection char }

(*
 * New type definitions for widgets management.
 *)
Type TMenuItem  = Array[0..21] Of PTinyString;


(**
  * Action returned by any @see TMenuItem based widget.
  * NoSelection - When no item was selected;
  * ItemSelected - One item was selected;
  * NextWidget - The TAB Key was typed, passing the control
  * to the next widget;
  *)
Type TSelectionAction = ( NoSelection,
                          ItemSelected,
                          NextWidget );


(**
  * Manage a Radio button widget retrieving the user selection
  * made by the input device;
  * @param nX The X-Axis coordinate to positioning the radio button widget;
  * @param nY The Y-Axis coordinate to positioning the radio button widget;
  * @param nItemPos The item index of selection made by user;
  * The function return the @TSelectionAction with the latest user operation.
  *)
Function RadioButton( nX, nY : Byte;
                      Items : TMenuItem;
                      Var nItemPos : Byte ) : TSelectionAction;
Var
    nCount,
    nOldItem    : Byte;
    chOption    : Char;
    Selection   : TSelectionAction;

Begin
  nCount := 0;

  { Fill the radiobuttons with items }
  While( Items[nCount] <> Nil ) Do
  Begin
    _GotoXY( nX, nY + nCount );
    Write( '( )' + Items[nCount]^ );
    nCount := nCount + 1;
  End;

  nCount   := nCount - 1;
  nOldItem := nItemPos;

  Repeat
    _GotoXY( ( nX + 1 ), ( nY + nItemPos ) );
    Write( ctRadioSel );
    chOption := ReadKey;

    (* Key processing *)
    Case( Byte( chOption ) ) Of
      ctKbKeyDown,
      ctKbKeyRight :  Begin
                        _GotoXY( ( nX + 1 ), ( nY + nItemPos ) );
                        Write( ' ' );

                        If( nItemPos = nCount ) Then
                          nItemPos := 0
                        Else
                          nItemPos := nItemPos + 1;
                      End;
      ctKbKeyUp,
      ctKbKeyLeft  :  Begin
                        _GotoXY( ( nX + 1 ), ( nY + nItemPos ) );
                        Write( ' ' );

                        If( nItemPos = 0 ) Then
                          nItemPos := nCount
                        Else
                          nItemPos := nItemPos - 1;
                      End;
    End;
  Until( Byte( chOption ) In [ctKbReturn, ctKbEsc, ctKbTab] );

  Case Byte( chOption ) Of
    ctKbReturn :   Selection := ItemSelected;
    ctKbTab    :   Selection := NextWidget;
    ctKbEsc    :   Begin
                     nItemPos  := nOldItem;
                     Selection := NoSelection;
                     _GotoXY( ( nX + 1 ), nY );  { Clear selection }
                     Write( ' ' );
                   End;
  End;

  RadioButton := Selection;
End;
