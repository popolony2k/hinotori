(*<tmenu.pas>
 * Text user interface widgets implementation.
 * Implement the menu based widgets.
 * CopyLeft (c) 1995-2024 by PopolonY2k.
 * CopyLeft (c) since 2024 by Hinotori Team.
 *)

(*
 * This module depends on folowing include files (respect the order):
 * - /system/types.pas;
 * - /util/helpchar.pas;
 * - /dos/msxbios.pas;
 * - /console/conio.pas;
 *)

(*
 * Constant definitions for Widgets module.
 *)
const
          ctRadioSel : char    = '*'; { Radio widget selection char }

(*
 * New type definitions for widgets management.
 *)
type TMenuItem  = array[0..21] of PTinyString;


(**
  * Action returned by any @see TMenuItem based widget.
  * NoSelection - When no item was selected;
  * ItemSelected - One item was selected;
  * NextWidget - The TAB Key was typed, passing the control
  * to the next widget;
  *)
type TSelectionAction = ( NoSelection,
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
function RadioButton( nX, nY : byte;
                      Items : TMenuItem;
                      var nItemPos : byte ) : TSelectionAction;
var
    nCount,
    nOldItem    : byte;
    chOption    : char;
    Selection   : TSelectionAction;

begin
  nCount := 0;

  { Fill the radiobuttons with items }
  while( Items[nCount] <> nil ) do
  begin
    _GotoXY( nX, nY + nCount );
    Write( '( )' + Items[nCount]^ );
    nCount := nCount + 1;
  end;

  nCount := nCount - 1;

  repeat
    nOldItem := nItemPos;
    _GotoXY( nX + 1, nY + nItemPos );
    Write( ctRadioSel );
    chOption := ReadKey;

    (* Key processing *)
    case( byte( chOption ) ) of
      ctKbKeyDown,
      ctKbKeyRight :  begin
                        if( nItemPos = nCount ) then
                          nItemPos := 0
                        else
                          nItemPos := nItemPos + 1;
                      end;
      ctKbKeyUp,
      ctKbKeyLeft  :  begin
                        if( nItemPos = 0 ) then
                          nItemPos := nCount
                        else
                          nItemPos := nItemPos - 1;
                      end;
    end;

    if( not ( byte( chOption ) in [ctKbReturn, ctKbEsc, ctKbTab] ) )  then
    begin
      _GotoXY( ( nX + 1 ), ( nY + nOldItem ) );
      Write( ' ' );
    end;
  until( byte( chOption ) in [ctKbReturn, ctKbEsc, ctKbTab] );

  case byte( chOption ) of
    ctKbReturn :   Selection := ItemSelected;
    ctKbTab    :   Selection := NextWidget;
    ctKbEsc    :   begin
                     Selection := NoSelection;
                     nItemPos  := -1;
                     _GotoXY( ( nX + 1 ), nY );  { Clear selection }
                     Write( ' ' );
                   end;
  end;

  RadioButton := Selection;
end;
