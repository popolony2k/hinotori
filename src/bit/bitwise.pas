(*<bitwise.pas>
 * Bitwise functions implementation.
 * CopyLeft (c) 1995-2024 by PopolonY2k.
 * CopyLeft (c) since 2024 by Hinotori Team.
 *)

(*
 * This module depends on folowing include files (respect the order):
 * -
 *)

(**
  * Perform a bitwise check returning the comparision
  * result.
  * @param nCompareBits The bits to compare;
  * @param nValue The Value to check;
  *)
function BitCmp( nCompareBits, nValue : integer ) : boolean;
begin
  BitCmp := ( ( nValue and nCompareBits ) = nCompareBits );
end;
