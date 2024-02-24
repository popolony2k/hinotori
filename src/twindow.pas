(**<twindow.pas>
  * Text user interface widgets implementation.
  * Implements windows based widgets.
  * Copyright (c) since 1995 by PopolonY2k.
  *)

(**
  *
  * $Id: twindow.pas 128 2020-07-08 17:51:23Z popolony2k $
  * $Author: popolony2k $
  * $Date: 2020-07-08 14:51:23 -0300 (Wed, 08 Jul 2020) $
  * $Revision: 128 $
  * $HeadURL: https://svn.code.sf.net/p/oldskooltech/code/msx/trunk/msxdos/pascal/twindow.pas $
  *)

(*
 * This module depends on folowing include files (respect the order):
 * - types.pas;
 * - helpchar.pas;
 * - msxbios.pas;
 * - conio.pas;
 *)


(**
  * Open a window widget in specified coordinates.
  * @param nX1 Initial X-Axis coordinate of window;
  * @param nY1 Initial Y-Axis coordinate of window;
  * @param nX2 Final X-Axis coordinate of window;
  * @param nY2 Final Y-Axis coordinate of window;
  *)
Procedure OpenWindow( nX1, nY1, nX2, nY2 : Byte );
Var
     nCounter : Byte;

Begin
  _GotoXY( nX1, nY1 ); { Top-Left corner     }
  Write( #24 );
  _GotoXY( nX2, nY1 ); { Top-Right corner    }
  Write( #25 );
  _GotoXY( nX2, nY2 ); { Bottom right corner }
  Write( #27 );
  _GotoXY( nX1, nY2 ); { Bottom left         }
  Write( #26 );

  (* Horizontal lines *)
  For nCounter := ( nX1 + 1 ) To ( nX2 - 1 ) Do
  Begin
    _GotoXY( nCounter, nY1 );
    Write( #23 );
    _GotoXY( nCounter, nY2 );
    Write( #23 );
  End;

  (* Vertical lines *)
  For nCounter := ( nY1 + 1 ) To ( nY2 - 1 ) Do
  Begin
    _GotoXY( nX1, nCounter );
    Write( #22 );
    _GotoXY( nX2, nCounter );
    Write( #22 );
  End;
End;
