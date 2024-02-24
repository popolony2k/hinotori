(*<helpcnv.pas>
 * Helper functions to perform conversion between
 * builtin and new defined types.
 * CopyLeft (c) since 1995 by PopolonY2k.
 *)

(**
  *
  * $Id: helpcnv.pas 128 2020-07-08 17:51:23Z popolony2k $
  * $Author: popolony2k $
  * $Date: 2020-07-08 14:51:23 -0300 (Wed, 08 Jul 2020) $
  * $Revision: 128 $
  * $HeadURL: https://svn.code.sf.net/p/oldskooltech/code/msx/trunk/msxdos/pascal/helpcnv.pas $
  *)

(*
 * This source file depends on following include files (respect the order):
 * - types.pas;
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
