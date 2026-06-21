(*<fixedpt.pas>
 * Fixed point implementation in Turbo Pascal.
 * CopyLeft (c) 1995-2024 by PopolonY2k.
 * CopyLeft (c) since 2024 by Hinotori Team.
 *)

(*
 * This module depends on folowing include files (respect the order):
 * - /system/types.pas;
 *)

(**
  * New fixed point definitions.
  *)
type TFixedPoint  = integer;
     TUFixedPoint = TWord;
     TDynFixedPointArray = array[0..0] of TFixedPoint;
     PDynFixedPointArray = ^TDynFixedPointArray;


(**
  * Just for historical. This opeeration is teh same
  * as a normal + Pascal integer operation;
  * Perform the sum of two @link TFixedPoint values.
  * @param A The first value to add;
  * @param B The second value to add;
  *
Function AddFixed( A, B : TFixedPoint ) : TFixedPoint;
Begin
  AddFixed := ( A + B );
End;
*)

(**
  * Just for historical. This opeeration is teh same
  * as a normal - Pascal integer operation;
  * Perform the subtraction of two @link TFixedPoint values.
  * @param A The first value to subtract;
  * @param B The second value to subtract;
  *
Function SubFixed( A, B : TFixedPoint ) : TFixedPoint;
Begin
  SubFixed := ( A - B );
End;
*)

(**
  * Perform the multiplication of two @link TFixedPoint values.
  * @param A The first value to multiply;
  * @param B The second value to multiply;
  * @param Q The Number of bits used to fixed point calculations;
  *)
function MulFixed( A, B : TFixedPoint; Q : byte ) : TFixedPoint;
begin
  MulFixed := TFixedPoint( TFixedPoint( A * B ) shr Q );
end;

(**
  * Perform the division of two @link TFixedPoint values.
  * @param A The first value to divide;
  * @param B The second value to divide;
  * @param Q The Number of bits used to fixed point calculations;
  *)
function DivFixed( A, B : TFixedPoint; Q : byte ) : TFixedPoint;
begin
  DivFixed := TFixedPoint( TFixedPoint( A shl Q ) div B );
end;

(**
  * Convert @link TFixedPoint to Real;
  * @param A The @link TFixedPoint to convert;
  * @param Q The Number of bits used to fixed point calculations;
  *)
function FixedToReal( A : TFixedPoint; Q : byte ): real;
begin
  FixedToReal := ( A / TFixedPoint( 1 shl Q ) );
end;

(**
  * Convert Real to @link TFixedPoint;
  * @param R The Real value to convert;
  * @param Q The Number of bits used to fixed point calculations;
  *)
function RealToFixed( R : real; Q : byte ) : TFixedPoint;
begin
  RealToFixed := Round( ( R * TFixedPoint( 1 shl Q ) ) );
end;

(**
  * Convert @link TFixedPoint to Integer;
  * @param A The @link TFixedPoint to convert;
  * @param Q The Number of bits used to fixed point calculations;
  *)
function FixedToInt( A : TFixedPoint; Q : byte ) : integer;
begin
  FixedToInt :=  TInteger( A div ( 1 shl Q ) ); {( A ShR Q );}
end;

(**
  * Convert Integer to @link TFixedPoint;
  * @param R The Integer value to convert;
  * @param Q The Number of bits used to fixed point calculations;
  *)
function IntToFixed( I : integer; Q : byte ) : TFixedPoint;
begin
  IntToFixed :=  TFixedPoint( I * ( 1 shl Q ) ); {( I ShL Q );}
end;

(**
  * Get the @see TFixedPoint fractional part;
  * @param A The @link TFixedPoint value to retrieve the fractional part;
  * @param Q The Number of bits used to fixed point calculations;
  *)
function FixedFracPart( A : TFixedPoint; Q : byte ) : integer;
begin
  FixedFracPart := ( A and Q );
end;

{ Unsigned operations - Is missing several manipulations (WIP) }

(**
  * Perform the multiplication between a @link TFixedPoint and
  * a @link TUFixedPoint values.
  * @param A The first value to multiply;
  * @param B The second value to multiply;
  * @param Q The Number of bits used to fixed point calculations;
  *)
function MulFixedUFixed( A : TFixedPoint;
                         B : TUFixedPoint; Q : byte ) : TUFixedPoint;
begin
  MulFixedUFixed := TUFixedPoint ( TFixedPoint( A div 2 ) *
                                   TUFixedPoint( B shr ( Q - 1 ) ) );
end;
