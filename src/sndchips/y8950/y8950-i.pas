(*<y8950-i.pas>
 * Library for the Y8950 (Philips Music Module) soundchip handling.
 * CopyLeft (c) 1995-2024 by PopolonY2k.
 * CopyLeft (c) since 2024 by Hinotori Team.
 *)

(*
 * This module depends on folowing include files (respect the order):
 * -
 *)

Const
       { Y8950 related constants }
       ctPortY8950RegisterWrite   : Byte = $C0;   { Y8950 reg. write port }


(**
  * Discover if there is a Y8950 soundchip connected to computer.
  *)
Function FindY8950 : Boolean;
Begin
  FindY8950 := ( Port[ctPortY8950RegisterWrite] = $06 );
End;
