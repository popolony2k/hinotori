(*<opl4-i.pas>
 * Library for OPL4 (YMF278B) soundchip handling.
 * CopyLeft (c) 1995-2024 by PopolonY2k.
 * CopyLeft (c) since 2024 by Hinotori Team.
 *)

(*
 * This module depends on folowing include files (respect the order):
 * -
 *)

Const
       { OPL4 related constants }
       ctPortYMF278BStatus        : Byte = $C4;   { YMF278B Status }


(**
  * Find if a OPL4 soundchip is connected or not and initializes
  * internal driver data, if installed.
  *)
Function FindOPL4 : Boolean;
Var
         nStatus : Byte;
Begin
  nStatus  := Succ( Port[ctPortYMF278BStatus] );
  FindOPL4 := ( nStatus <> $00 );
End;
