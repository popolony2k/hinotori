(*<tprogres.pas>
 * Text user interface widgets implementation.
 * Implement progress indicators based widgets.
 * CopyLeft (c) 1995-2024 by PopolonY2k.
 * CopyLeft (c) since 2024 by Hinotori Team.
 *)

(*
 * This module depends on folowing include files (respect the order):
 * - /system/types.pas;
 * - /bios/msxbios.pas;
 * - /console/conio.pas;
 *)


(*
 * Internal module variables.
 *)
var
      __aCursorIcons  : array[0..3] of char;
      __nCursorIdx    : byte;


(**
  * Draw a cyclic progress indicator with text caption.
  * This widget is interrupt safe.
  * @param strText The text caption to display;
  * @param nX The X coordinate of widget;
  * @param nY The Y coordinate of widget;
  * @param bReset Reset the widget status. When is reseted (True), the
  * caption is redrawn and the progress bar icon goes to initial state;
  *)
procedure ProgressCycle( strText : TTinyString;
                         nX, nY : byte;
                         bReset : boolean );
var
       CSRX : byte absolute $F3DD; { Current column-position of the cursor }

begin
  if( bReset )  then
  begin
    _GotoXY( nX, nY );
    Write( strText, ' ( )' );
    CSRX := CSRX - 2;
    __nCursorIdx := 0;
  end
  else
    _GotoXY( nX + byte( strText[0] ) + 2, nY );

  CHPUT( __aCursorIcons[__nCursorIdx] );

  if( __nCursorIdx = 3 )  then
    __nCursorIdx := 0
  else
    __nCursorIdx := Succ( __nCursorIdx );
end;

(**
  * Init the Progress bar TUI engine.
  *)
procedure InitProgressTUI;
begin
  __nCursorIdx := 0;
  __aCursorIcons[0] := '|';
  __aCursorIcons[1] := '/';
  __aCursorIcons[2] := '-';
  __aCursorIcons[3] := '\';
end;
