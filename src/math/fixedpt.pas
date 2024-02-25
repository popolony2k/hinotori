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
Type TFixedPoint  = Integer;
     TUFixedPoint = TWord;
     TDynFixedPointArray = Array[0..0] Of TFixedPoint;
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
Function MulFixed( A, B : TFixedPoint; Q : Byte ) : TFixedPoint;
Begin
  MulFixed := TFixedPoint( TFixedPoint( A * B ) ShR Q );
End;

(**
  * Perform the division of two @link TFixedPoint values.
  * @param A The first value to divide;
  * @param B The second value to divide;
  * @param Q The Number of bits used to fixed point calculations;
  *)
Function DivFixed( A, B : TFixedPoint; Q : Byte ) : TFixedPoint;
Begin
  DivFixed := TFixedPoint( TFixedPoint( A ShL Q ) Div B );
End;

(**
  * Convert @link TFixedPoint to Real;
  * @param A The @link TFixedPoint to convert;
  * @param Q The Number of bits used to fixed point calculations;
  *)
Function FixedToReal( A : TFixedPoint; Q : Byte ): Real;
Begin
  FixedToReal := ( A / TFixedPoint( 1 ShL Q ) );
End;

(**
  * Convert Real to @link TFixedPoint;
  * @param R The Real value to convert;
  * @param Q The Number of bits used to fixed point calculations;
  *)
Function RealToFixed( R : Real; Q : Byte ) : TFixedPoint;
Begin
  RealToFixed := Round( ( R * TFixedPoint( 1 ShL Q ) ) );
End;

(**
  * Convert @link TFixedPoint to Integer;
  * @param A The @link TFixedPoint to convert;
  * @param Q The Number of bits used to fixed point calculations;
  *)
Function FixedToInt( A : TFixedPoint; Q : Byte ) : Integer;
Begin
  FixedToInt :=  TInteger( A Div ( 1 ShL Q ) ); {( A ShR Q );}
End;

(**
  * Convert Integer to @link TFixedPoint;
  * @param R The Integer value to convert;
  * @param Q The Number of bits used to fixed point calculations;
  *)
Function IntToFixed( I : Integer; Q : Byte ) : TFixedPoint;
Begin
  IntToFixed :=  TFixedPoint( I * ( 1 ShL Q ) ); {( I ShL Q );}
End;

(**
  * Get the @see TFixedPoint fractional part;
  * @param A The @link TFixedPoint value to retrieve the fractional part;
  * @param Q The Number of bits used to fixed point calculations;
  *)
Function FixedFracPart( A : TFixedPoint; Q : Byte ) : Integer;
Begin
  FixedFracPart := ( A And Q );
End;

{ Unsigned operations - Is missing several manipulations (WIP) }

(**
  * Perform the multiplication between a @link TFixedPoint and
  * a @link TUFixedPoint values.
  * @param A The first value to multiply;
  * @param B The second value to multiply;
  * @param Q The Number of bits used to fixed point calculations;
  *)
Function MulFixedUFixed( A : TFixedPoint;
                         B : TUFixedPoint; Q : Byte ) : TUFixedPoint;
Begin
  MulFixedUFixed := TUFixedPoint ( TFixedPoint( A Div 2 ) *
                                   TUFixedPoint( B ShR ( Q - 1 ) ) );
End;
