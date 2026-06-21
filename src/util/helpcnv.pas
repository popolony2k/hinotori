(*<helpcnv.pas>
 * Helper functions to perform conversion between
 * builtin and new defined types.
 * CopyLeft (c) 1995-2024 by PopolonY2k.
 * CopyLeft (c) since 2024 by Hinotori Team.
 *)

(*
 * This source file depends on following include files (respect the order):
 * - /system/types.pas;
 *)

(*
 * Internal module definitions.
 *)
const
        ctHexaVals : array[$0..$F] of char = '0123456789ABCDEF';


(**
  * Convert a byte number to hexadecimal
  * representation of the decimal number.
  * @param nValue The value to convert;
  *)
function ByteToHexa( nValue : integer ) : THexadecimal;
begin
  ByteToHexa := ctHexaVals[nValue shr 4] + ctHexaVals[nValue and $F];
end;
