(*<hooks.pas>
 * MSX system hooks management wrappers implementation for handling
 * interrupts in Z80 interrupt mode 1 (IM1);
 * CopyLeft (c) 1995-2024 by PopolonY2k.
 * CopyLeft (c) since 2024 by Hinotori Team.
 *)

(*
 * This module depends on following include files (respect the order):
 * -
 *)


(**
  * Internal modules types, constants and variables.
  *)
type THookType = ( H_KEYI, H_TIMI, H_NMI );  { All supported hooks }
type THookCode = array[0..4] of byte;        { The hook code       }

var
              __H_KEYI    : integer absolute $FD9A;  { H.KEYI hook }
              __H_TIMI    : integer absolute $FD9F;  { H.TIMI hook }
              __H_NMI     : integer absolute $FDD6;  { H.NMI  hook }

(**
  * Set a new H.TIMI function address.
  * @param hookType The hook type to set;
  * @param newHookCode The new hook code;
  * @param oldHookCode Reference to a buffer that will receive the old
  * hook code;
  *)
procedure SetHook( hookType : THookType;
                   newHookCode : THookCode;
                   var oldHookCode : THookCode );
var
         pHookAddr : ^byte;

begin
  inline( $F3 );     { DI }

  case( hookType ) of
    H_TIMI : pHookAddr := Ptr( Addr( __H_TIMI ) );

    H_KEYI : pHookAddr := Ptr( Addr( __H_KEYI ) );

    H_NMI  : pHookAddr := Ptr( Addr( __H_NMI ) );
  else
    pHookAddr := nil;
  end;

  if( pHookAddr <> nil )  then
  begin
    Move( pHookAddr^, oldHookCode, SizeOf( THookCode ) );
    Move( newHookCode, pHookAddr^, SizeOf( THookCode ) );
  end;

  inline( $FB );     { EI }
end;

(**
  * Reset the current hook, adding an empty function to this hook.
  * The function return the old hook address;
  * @param hookType The hook type to reset;
  * @param oldHookCode Reference to a buffer that will receive the old
  * hook code;
  *)
procedure ResetHook( hookType : THookType; var oldHookCode : THookCode );
var
         hookNOP : THookCode;

begin
  (*
   * This hook just executes a RET instruction code.
   *)
  FillChar( hookNOP, SizeOf( hookNOP ), $C9 );
  SetHook( hookType, hookNOP, oldHookCode );
end;
