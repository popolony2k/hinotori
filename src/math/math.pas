(*<math.pas>
 * Implement extends math functions present in new Turbo Pascal releases
 * and other languages;
 * CopyLeft (c) 1995-2024 by PopolonY2k.
 * CopyLeft (c) since 2024 by Hinotori Team.
 *)

(*
 * This source file depends on following include files (respect the order):
 * -
 *)

(**
  * Calculate the power of a number by another number.
  * @param x The base number;
  * @param y The power number;
  *)
Function Pow( x, y : Real ) : Real;
Begin
  Pow := Exp( y * Ln( x ) );
End;
