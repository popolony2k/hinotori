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
Var
      __aCursorIcons  : Array[0..3] Of Char;
      __nCursorIdx    : Byte;


(**
  * Draw a cyclic progress indicator with text caption.
  * This widget is interrupt safe.
  * @param strText The text caption to display;
  * @param nX The X coordinate of widget;
  * @param nY The Y coordinate of widget;
  * @param bReset Reset the widget status. When is reseted (True), the
  * caption is redrawn and the progress bar icon goes to initial state;
  *)
Procedure ProgressCycle( strText : TTinyString;
                         nX, nY : Byte;
                         bReset : Boolean );
Var
       CSRX : Byte Absolute $F3DD; { Current column-position of the cursor }

Begin
  If( bReset )  Then
  Begin
    _GotoXY( nX, nY );
    Write( strText, ' ( )' );
    CSRX := CSRX - 2;
    __nCursorIdx := 0;
  End
  Else
    _GotoXY( nX + Byte( strText[0] ) + 2, nY );

  CHPUT( __aCursorIcons[__nCursorIdx] );

  If( __nCursorIdx = 3 )  Then
    __nCursorIdx := 0
  Else
    __nCursorIdx := Succ( __nCursorIdx );
End;

(**
  * Init the Progress bar TUI engine.
  *)
Procedure InitProgressTUI;
Begin
  __nCursorIdx := 0;
  __aCursorIcons[0] := '|';
  __aCursorIcons[1] := '/';
  __aCursorIcons[2] := '-';
  __aCursorIcons[3] := '\';
End;
