(**<tprogres.pas>
  * Text user interface widgets implementation.
  * Implement progress indicators based widgets.
  * Copyright (c) since 1995 by PopolonY2k.
  *)

(**
  *
  * $Id: tprogres.pas 128 2020-07-08 17:51:23Z popolony2k $
  * $Author: popolony2k $
  * $Date: 2020-07-08 14:51:23 -0300 (Wed, 08 Jul 2020) $
  * $Revision: 128 $
  * $HeadURL: https://svn.code.sf.net/p/oldskooltech/code/msx/trunk/msxdos/pascal/tprogres.pas $
  *)

(*
 * This module depends on folowing include files (respect the order):
 * - types.pas;
 * - msxbios.pas;
 * - conio.pas;
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
