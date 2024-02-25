(*<math32.pas>
 * Implement int32 math functions for use with the new extended type TUint32
 * CopyLeft (c) 1995-2024 by PopolonY2k.
 * CopyLeft (c) since 2024 by Hinotori Team.
 *)

(*
 * This source file depends on following include files (respect the order):
 * - /system/types.pas;
 * - /math/math.pas;
 *)

{$r-}

(**
  * Convert a 32Bit integer value to the builtin Real representation.
  * @param value The 32Bit int representation of value to be converted;
  * This function was taken from BigInt library implementation, that is
  * originaly based on the GNU libc library source code;
  *)
Function Int32ToReal( Var value : TInt32 ) : Real;
Var
        nTmp,
        nVal,
        nCount,
        nByte,
        nBits    : Byte;
        fRet     : Real;
Begin
  fRet   := 0.0;
  nCount := 0;

  For nByte := ( SizeOf( value ) - 1 ) DownTo 0 Do
  Begin
    nVal := value[nByte];

    For nBits := 0 To 7 Do
    Begin
      nTmp := ( nVal ShR nBits ) And 1;
      fRet := fRet + ( nTmp * Pow( 2, nCount ) );
      nCount := nCount + 1;
    End;
  End;

  Int32ToReal := fRet;
End;

{$r+}
