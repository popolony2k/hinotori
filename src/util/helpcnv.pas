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
Const
        ctHexaVals : Array[$0..$F] Of Char = '0123456789ABCDEF';


(**
  * Convert a byte number to hexadecimal
  * representation of the decimal number.
  * @param nValue The value to convert;
  *)
Function ByteToHexa( nValue : Integer ) : THexadecimal;
Begin
  ByteToHexa := ctHexaVals[nValue ShR 4] + ctHexaVals[nValue And $F];
End;
