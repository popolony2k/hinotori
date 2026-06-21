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
function Int32ToReal( var value : TInt32 ) : real;
var
        nTmp,
        nVal,
        nCount,
        nByte,
        nBits    : byte;
        fRet     : real;
begin
  fRet   := 0.0;
  nCount := 0;

  for nByte := ( sizeof( value ) - 1 ) downto 0 do
  begin
    nVal := value[nByte];

    for nBits := 0 to 7 do
    begin
      nTmp := ( nVal shr nBits ) and 1;
      fRet := fRet + ( nTmp * Pow( 2, nCount ) );
      nCount := nCount + 1;
    end;
  end;

  Int32ToReal := fRet;
end;

{$r+}
