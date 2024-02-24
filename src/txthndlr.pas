(**<txthndlr.pas>
  * Text mode handling for using Write/WriteLn I/O operations.
  * Copyright (c) since 1995 by PopolonY2k.
  *)

(**
  *
  * $Id: txthndlr.pas 128 2020-07-08 17:51:23Z popolony2k $
  * $Author: popolony2k $
  * $Date: 2020-07-08 14:51:23 -0300 (Wed, 08 Jul 2020) $
  * $Revision: 128 $
  * $HeadURL: https://svn.code.sf.net/p/oldskooltech/code/msx/trunk/msxdos/pascal/txthndlr.pas $
  *)

(*
 * This module depends on folowing include files (respect the order):
 * -
 *)


(**
  * Handle to direct output operations.
  * Used by @see SetTextHandler() and @see RestoreTextHandler();
  *)
Type TTextHandle = Record
  nConOutPtr : Integer;
End;


(**
  * Assign a new turbo pascal output I/O routines for using with a custom
  * I/O routine.
  * @param handle The result handler assigned by this routine to be used
  * with RestoreTextHandler.
  * @param nHandlerFn The address to a new I/O handler function to provide
  * a new behavior to Write/WriteLn routines;
  *)
Procedure SetTextHandler( Var handle : TTextHandle; nHandlerFn : Integer );
Begin
  handle.nConOutPtr := ConOutPtr;
  ConOutPtr := nHandlerFn;
End;

(**
  * Restore the previous pascal I/O routine, previously assigned by
  * @see SetTextHandler(), restoring the old I/O handling routine;
  * @param handle The Reference to struct @see TTextHandle used by
  * @see SetTextHandler routine;
  *)
Procedure RestoreTextHandler( Var handle : TTextHandle );
Begin
  ConOutPtr := handle.nConOutPtr;
  FillChar( handle, SizeOf( handle ), -1 );
End;
