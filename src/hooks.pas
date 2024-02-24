(*<hooks.pas>
 * MSX system hooks management wrappers implementation for handling
 * interrupts in Z80 interrupt mode 1 (IM1);
 * CopyLeft (c) since 1995 by PopolonY2k.
 *)

(**
  *
  * $Id: hooks.pas 128 2020-07-08 17:51:23Z popolony2k $
  * $Author: popolony2k $
  * $Date: 2020-07-08 14:51:23 -0300 (Wed, 08 Jul 2020) $
  * $Revision: 128 $
  * $HeadURL: https://svn.code.sf.net/p/oldskooltech/code/msx/trunk/msxdos/pascal/hooks.pas $
  *)

(*
 * This module depends on following include files (respect the order):
 * -
 *)


(**
  * Internal modules types, constants and variables.
  *)
Type THookType = ( H_KEYI, H_TIMI, H_NMI );  { All supported hooks }
Type THookCode = Array[0..4] Of Byte;        { The hook code       }

Var
              __H_KEYI    : Integer Absolute $FD9A;  { H.KEYI hook }
              __H_TIMI    : Integer Absolute $FD9F;  { H.TIMI hook }
              __H_NMI     : Integer Absolute $FDD6;  { H.NMI  hook }

(**
  * Set a new H.TIMI function address.
  * @param hookType The hook type to set;
  * @param newHookCode The new hook code;
  * @param oldHookCode Reference to a buffer that will receive the old
  * hook code;
  *)
Procedure SetHook( hookType : THookType;
                   newHookCode : THookCode;
                   Var oldHookCode : THookCode );
Var
         pHookAddr : ^Byte;

Begin
  Inline( $F3 );     { DI }

  Case( hookType ) Of
    H_TIMI : pHookAddr := Ptr( Addr( __H_TIMI ) );

    H_KEYI : pHookAddr := Ptr( Addr( __H_KEYI ) );

    H_NMI  : pHookAddr := Ptr( Addr( __H_NMI ) );
  Else
    pHookAddr := Nil;
  End;

  If( pHookAddr <> Nil )  Then
  Begin
    Move( pHookAddr^, oldHookCode, SizeOf( THookCode ) );
    Move( newHookCode, pHookAddr^, SizeOf( THookCode ) );
  End;

  Inline( $FB );     { EI }
End;

(**
  * Reset the current hook, adding an empty function to this hook.
  * The function return the old hook address;
  * @param hookType The hook type to reset;
  * @param oldHookCode Reference to a buffer that will receive the old
  * hook code;
  *)
Procedure ResetHook( hookType : THookType; Var oldHookCode : THookCode );
Var
         hookNOP : THookCode;

Begin
  (*
   * This hook just executes a RET instruction code.
   *)
  FillChar( hookNOP, SizeOf( hookNOP ), $C9 );
  SetHook( hookType, hookNOP, oldHookCode );
End;
