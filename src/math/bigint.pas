(*<bigint.pas>
 * Implement big int math functions for use with
 * new extended types like TUint24, TUint32
 * and others defined at <type.pas>.
 * CopyLeft (c) 1995-2024 by PopolonY2k.
 * CopyLeft (c) since 2024 by Hinotori Team.
 *)

(*
 * This source file depends on following include files (respect the order):
 * - /system/types.pas;
 * - /math/math.pas;
 * - /math/math16.pas;
 *)

(* Module definitions *)

(**
  * BigInt operation return codes.
  *)
Type TOperationCode = ( Success,
                        Overflow,
                        Underflow,
                        InvalidNumber,
                        NoMemoryAvailable,
                        IncompatibleParms,
                        NotImplemented );

(**
  * Comparision return codes.
  *)
Type TCompareCode = ( Equals, GreaterThan, LessThan, CompareError );

(**
  * Big integer type definition for new extended
  * math operations.
  *)
Type TBigInt = Record
  nSize    : Byte;
  pValue   : ^Byte;
End;

(* Large integer extended math functions *)

(**
  * Performs binary sum operation between two
  * operands.
  * @param ret Data that will receive the result of
  * the operation;
  * @param op1 The TBigInt record for the first operand;
  * @param op2 The TBigInt record for the second operand;
  * If the operation fails, the function return a @see TOperationCode
  * enumeration return code.
  *)
Function AddBigInt( Var ret : TBigInt; op1, op2 : TBigInt ) : TOperationCode;
Var
        nCount,
        nMaxOpSize : Byte;
        RetCode    : TOperationCode;
        nOp1Addr,
        nOp2Addr,
        nRetAddr,
        nRes       : Integer;

Begin
  RetCode    := Success;
  nMaxOpSize := Byte( Max( op1.nSize, op2.nSize ) );
  nMaxOpSize := Byte( Max( nMaxOpSize, ret.nSize ) );
  nRetAddr   := ( Ord( ret.pValue ) + ret.nSize - 1 );
  nOp1Addr   := ( Ord( op1.pValue ) + op1.nSize - 1 );
  nOp2Addr   := ( Ord( op2.pValue ) + op2.nSize - 1 );
  nRes       := 0;
  nCount     := 0;

  { Clear the result variable }
  FillChar( ret.pValue^, ret.nSize, 0 );

  While( nCount < nMaxOpSize ) Do
  Begin
    If( nCount < op1.nSize )  Then  { First operand }
      nRes := nRes + Mem[nOp1Addr-nCount];

    If( nCount < op2.nSize ) Then   { Second operand }
      nRes := nRes + Mem[nOp2Addr-nCount];

    { Get the result and apply carry to next byte operation }
    If( nCount < ret.nSize )  Then
    Begin
      Mem[nRetAddr-nCount] := Lo( nRes );
      nRes := Hi( nres );
    End
    Else
      If( Hi( nRes ) > 0 ) Then  { Check overflow }
        nCount := nMaxOpSize; { Exit condition }

    nCount := nCount + 1;
  End;

  { Check overflow }
  If( nRes > 0 )  Then
  Begin
    { For overflow, fill all return bytes with FF value }
    FillChar( ret.pValue^, ret.nSize, $FF );
    RetCode := Overflow;
  End;

  AddBigInt := RetCode;
End;

(**
  * Performs binary subtraction operation between two
  * operands.
  * @param ret Data that will receive the result of
  * the operation;
  * @param op1 The TBigInt record for the first operand;
  * @param op2 The TBigInt record for the second operand;
  * If the operation fails, the function return a @see TOperationCode
  * enumeration return code.
  *)
Function SubBigInt( Var ret : TBigInt; op1, op2 : TBigInt ) : TOperationCode;
Var
        nCount,
        nMaxOpSize : Byte;
        RetCode    : TOperationCode;
        nOp1Addr,
        nOp2Addr,
        nRetAddr,
        nRes       : Integer;
Begin
  RetCode    := Success;
  nMaxOpSize := Byte( Max( op1.nSize, op2.nSize ) );
  nMaxOpSize := Byte( Max( nMaxOpSize, ret.nSize ) );
  nRetAddr   := ( Ord( ret.pValue ) + ret.nSize - 1 );
  nOp1Addr   := ( Ord( op1.pValue ) + op1.nSize - 1 );
  nOp2Addr   := ( Ord( op2.pValue ) + op2.nSize - 1 );
  nRes       := 0;
  nCount     := 0;

  { Clear the result variable }
  FillChar( ret.pValue^, ret.nSize, 0 );

  While( nCount < nMaxOpSize ) Do
  Begin
    If( nCount < op1.nSize )  Then  { First operand }
      nRes := Mem[nOp1Addr-nCount] - nRes
    Else
      nRes := -nRes;

    If( nCount < op2.nSize ) Then   { Second operand }
      nRes := nRes - Mem[nOp2Addr-nCount];

    { Get the result and apply borrow to next byte operation }
    If( nCount < ret.nSize )  Then
    Begin
      Mem[nRetAddr-nCount] := Lo( nRes );
    End
    Else
      nCount := nMaxOpSize;   { Exit condition }

    If( Hi( nRes ) > 0 )  Then
      nRes := 1
    Else
      nRes := 0;

    nCount := nCount + 1;
  End;

  { Check underflow }
  If( nRes = 1 )  Then
  Begin
    { For underflow, fill all return bytes with FE value }
    FillChar( ret.pValue^, ret.nSize, $FE );
    RetCode := Underflow;
  End;

  SubBigInt := RetCode;
End;

(**
  * Performs binary multiplication operation between two
  * operands.
  * @param ret Data that will receive the result of
  * the operation;
  * @param op1 The TBigInt record for the first operand;
  * @param op2 The TBigInt record for the second operand;
  * If the operation fails, the function return a @see TOperationCode
  * enumeration return code.
  *)
Function MulBigInt( Var ret : TBigInt; op1, op2 : TBigInt ) : TOperationCode;
Var
       nOp1Addr,
       nOp2Addr,
       nRetAddr,
       nRes        : Integer;
       nMaxOpSize,
       i, j        : Byte;
       RetCode     : TOperationCode;
Begin
  (*
   * This is a very grade school (elementary) method.
   * In future, for performance reasons, I'm planning change this method by
   * the performatic Karatsuba's algorithm.
   * Please visit http://en.wikipedia.org/wiki/Karatsuba_algorithm for more
   * method's detail.
   *)
  RetCode    := Success;
  nMaxOpSize := Byte( Max( op1.nSize, op2.nSize ) );
  nMaxOpSize := Byte( Max( nMaxOpSize, ret.nSize ) );
  nRetAddr   := ( Ord( ret.pValue ) + ret.nSize - 1 );
  nOp1Addr   := ( Ord( op1.pValue ) + op1.nSize - 1 );
  nOp2Addr   := ( Ord( op2.pValue ) + op2.nSize - 1 );
  nRes       := 0;

  { Clear the result variable }
  FillChar( ret.pValue^, ret.nSize, 0 );

  i := 0;

  While( i < nMaxOpSize ) Do
  Begin
    j := 0;
    While( j < nMaxOpSize ) Do
    Begin
      If( ( i+j ) < ret.nSize  )  Then
        nRes := nRes + Mem[nRetAddr-(i+j)];

      If( ( i < op1.nSize ) And ( j < op2.nSize ) )  Then
        nRes := ( nRes + ( Mem[nOp1Addr-i] * Mem[nOp2Addr-j] ) );

      { Check overflow  }
      If( ( Hi( nRes ) > 0 ) And ( ( i+j ) = ( ret.nSize - 1 ) ) )  Then
        RetCode := Overflow;

      If( ( ( i+j ) < ret.nSize ) And ( RetCode <> Overflow ) )  Then
        Mem[nRetAddr-(i+j)] := Lo( nRes )
      Else
        If( ( RetCode = Overflow ) Or
            ( ( ( i+j ) >= ret.nSize ) And ( Hi( nRes ) > 0 ) ) ) Then
        Begin
          i := nMaxOpSize;    { Exit condition for i }
          j := nMaxOpSize;    { Exit condition for j }
          RetCode := Overflow;
        End;

      nRes := Hi( nRes );
      j := j + 1;
    End;
    i := i + 1;
  End;

  { Check overflow }
  If( RetCode = Overflow )  Then
  Begin
    { For overflow, fill all return bytes with FF value }
    FillChar( ret.pValue^, ret.nSize, $FF );
  End;

  MulBigInt := RetCode;
End;

(**
  * Performs binary division operation between two
  * operands.
  * @param ret Data that will receive the result of
  * the operation;
  * @param op1 The TBigInt record for the first operand;
  * @param op2 The TBigInt record for the second operand;
  * If the operation fails, the function return a @see TOperationCode
  * enumeration return code.
  *)
Function DivBigInt( Var ret : TBigInt; op1, op2 : TBigInt ) : TOperationCode;
Var
       RetCode : TOperationCode;
Begin
  { TODO: Finish Him !!!!!!!! Not implemented yet. }
  RetCode := NotImplemented;

  DivBigInt := RetCode;
End;

(**
  * Convert a Big integer value to builtin Real representation.
  * @param rRet The real variable to receive the conversion result;
  * @param value The big int representation of value to convert;
  * The code of this function was based on GNU libc library source code;
  * If the operation fails, the function return a @see TOperationCode
  * enumeration return code.
  *)
Function BigIntToReal( Var rRet : Real; value : TBigInt ) : TOperationCode;
Var
        RetCode  : TOperationCode;
        nTmp,
        nVal,
        nCount,
        nByte,
        nBits    : Byte;
        nValAddr : Integer;
Begin
  RetCode  := Success;
  nValAddr := Ord( value.pValue );
  rRet     := 0.0;
  nCount   := 0;

  For nByte := ( value.nSize - 1 ) DownTo 0 Do
  Begin
    nVal := Mem[nValAddr+nByte];

    For nBits := 0 To 7 Do
    Begin
      nTmp := ( nVal ShR nBits ) And 1;
      rRet := rRet + ( nTmp * Pow( 2, nCount ) );
      nCount := nCount + 1;
    End;
  End;

  BigIntToReal := RetCode;
End;

(**
  * Convert a string value to Big Integer representation.
  * @param ret The @see TBigInt variable to receive the conversion result;
  * @param strValue The big integer in string format to convert;
  * The code of this function was based on GNU libc library source
  * code;
  * If the operation fails, the function return a @see TOperationCode
  * enumeration return code.
  *)
Function StrToBigInt( Var ret : TBigInt; strValue : TString ) : TOperationCode;
Var
        RetCode   : TOperationCode;
        nCte10,
        nLen,
        nTmp,
        nCount    : Byte;
        nDigit,
        nRet      : Integer;
        bError    : Boolean;
        tmpVal    : TBigInt;
        cte10     : TBigInt;
        digit     : TBigInt;
Begin
  RetCode := InvalidNumber;
  nLen    := Length( strValue );

  If( nLen > 0 )  Then
    If( Abs( MaxAvail ) >= ret.nSize )  Then
    Begin
      GetMem( tmpVal.pValue, ret.nSize );
      bError       := False;
      nCount       := 1;
      nCte10       := 10;     { Constant used to big int mult. operation }
      cte10.nSize  := SizeOf( nCte10 );
      cte10.pValue := Ptr( Addr( nCte10 ) );
      tmpVal.nSize := ret.nSize;
      digit.nSize  := SizeOf( nDigit );
      digit.pValue := Ptr( Addr( nDigit ) );

      FillChar( ret.pValue^, ret.nSize, 0 );
      FillChar( tmpVal.pValue^, tmpVal.nSize, 0 );

      { Skip white spaces and Tab chars }
      While( ( ( strValue[nCount] = ' ' ) Or
               ( Byte( strValue[nCount] ) = $09 ) ) And
             ( nCount <= nLen ) ) Do
        nCount := nCount + 1;

      While( ( nCount <= nLen ) And Not bError ) Do  { Start conversion }
      Begin
        Val( strValue[nCount], nDigit, nRet );
        nDigit := Swap( nDigit );

        If( nRet = 0 )  Then
        Begin
          RetCode := MulBigInt( tmpVal, ret, cte10 );

          If( RetCode = Success )  Then
          Begin
            RetCode := AddBigInt( ret, tmpVal, digit );

            If( RetCode <> Success )  Then
              bError := True;  { Exit number processing }
          End
          Else
            bError := True;  { Exit number processing }
        End
        Else
          bError := True;   { Exit number processing }

        nCount := nCount + 1;
      End;

      FreeMem( tmpVal.pValue, tmpVal.nSize );

      If( Not bError )  Then
        RetCode := Success;
    End
    Else
      RetCode := NoMemoryAvailable;

  StrToBigInt := RetCode;
End;

(**
  * Convert a Big integer value to string representation.
  * @param strRet The @see TString variable to receive the conversion result;
  * @param value The big int representation of value to convert;
  * The code of this function was based on GNU libc library source code;
  * If the operation fails, the function return a @see TOperationCode
  * enumeration return code.
  * Unfortunatelly this method is based on builtin types aritmethic, in future
  * this should be rewritten to a full TBigInt compliant method;
  *)
Function BigIntToStr( Var strRet : TString; value : TBigInt ) : TOperationCode;
Var
        RetCode  : TOperationCode;
        rRes     : Real;
        nLen,
        nPos     : Byte;
Begin
  strRet := '';
  rRes   := 0.0;
  nPos   := 0;

  RetCode := BigIntToReal( rRes, value );

  If( RetCode = Success )  Then
    Begin
      Str( rRes:11:0, strRet );
      nLen := Length( strRet );

      { Perform a string trimming }
      While( ( nPos < nLen ) And ( strRet[nPos+1] = ' ' ) ) Do
        nPos := nPos + 1;

      If( nPos > 0 ) Then
        Delete( strRet, 1, nPos );
    End;

  BigIntToStr := RetCode;
End;

(**
  * Reset a big int value filling with zeroes;
  * @param op The operand to reset;
  * The function return a @see TCompareCode return code;
  *)
Function ResetBigInt( Var op : TBigInt ) : TOperationCode;
Var
        retCode : TOperationCode;
Begin
  If( op.pValue <> Nil )  Then
  Begin
    FillChar( op.pValue^, op.nSize, 0 );
    retCode := Success;
  End
  Else
    retCode := InvalidNumber;

  ResetBigInt := retCode;
End;

(**
  * Assign a big int to another big int;
  * @param opDest The destination operand;
  * @param opSrc The source operand;
  * The function return a @see TCompareCode return code;
  *)
Function AssignBigInt( Var opDest : TBigInt; opSrc : TBigInt ) : TOperationCode;
Var
        nCount,
        nMaxOpSize   : Byte;
        RetCode      : TOperationCode;
        nOpSrcAddr,
        nOpDestAddr,
        nValue       : Integer;
Begin
  If( ( opDest.pValue <> Nil ) And ( opSrc.pValue <> Nil ) )  Then
  Begin
    RetCode     := Success;
    nMaxOpSize  := Byte( Max( opSrc.nSize, opDest.nSize ) );
    nOpSrcAddr  := ( Ord( opSrc.pValue ) + opSrc.nSize - 1 );
    nOpDestAddr := ( Ord( opDest.pValue ) + opDest.nSize - 1 );
    nCount      := 0;

    While( nCount < nMaxOpSize ) Do
    Begin
      nValue := 0;

      If( nCount < opSrc.nSize )  Then  { Source operand }
        nValue := Mem[nOpSrcAddr-nCount];

      If( nCount < opDest.nSize )  Then  { Destination operand }
        Mem[nOpDestAddr-nCount] := nValue
      Else
        If( nValue <> 0 )  Then   { Check overflow }
        Begin
          nCount  := nMaxOpSize; { Exit condition }
          RetCode := Overflow;
          { For overflow, fill all return bytes with FF value }
          FillChar( opDest.pValue^, opDest.nSize, $FF );
        End;

      nCount := nCount + 1;
    End;
  End
  Else
    RetCode := InvalidNumber;

  AssignBigInt := RetCode;
End;

(**
  * Compare two BigInt operands.
  * @param op1 The first operand to compare;
  * @param op2 The second operand to compare;
  * The function return a @see TCompareCode return code;
  *)
Function CompareBigInt( op1, op2 : TBigInt ) : TCompareCode;
Var
      RetCode     : TCompareCode;
      nOp1Value,
      nOp2Value,
      nMaxOpSize,
      nCount      : Byte;
      nOp1Addr,
      nOp2Addr    : Integer;

Begin
  If( ( op1.pValue <> Nil ) And ( op2.pValue <> Nil ) )  Then
  Begin
    RetCode    := Equals;
    nMaxOpSize := Byte( Max( op1.nSize, op2.nSize ) );
    nOp1Addr   := ( Ord( op1.pValue ) + op1.nSize - 1 );
    nOp2Addr   := ( Ord( op2.pValue ) + op2.nSize - 1 );
    nCount     := 0;

    While( nCount < nMaxOpSize ) Do
    Begin
      If( nCount < op1.nSize )  Then  { Source operand }
        nOp1Value := Mem[nOp1Addr-nCount]
      Else
        nOp1Value := 0;

      If( nCount < op2.nSize )  Then  { Destination operand }
        nOp2Value := Mem[nOp2Addr-nCount]
      Else
        nOp2Value := 0;

      If( nOp1Value > nOp2Value )  Then
        RetCode := GreaterThan
      Else
        If( nOp1Value < nOp2Value )  Then
          RetCode := LessThan;

      nCount := nCount + 1;
    End;
  End
  Else
    RetCode := CompareError;

  CompareBigInt := RetCode;
End;

(**
  * Perform a BigInt operand byte order swap.
  * @param op The big int to be swapped;
  * The function return a @see TOperationCode return code;
  *)
Function SwapBigInt( op : TBigInt ) : TOperationCode;
Var
       nOpStartAddr,
       nOpEndAddr    : Integer;
       nTmp,
       nMaxCount,
       nCount        : Byte;
       RetCode       : TOperationCode;

Begin
  RetCode := Success;
  nOpStartAddr := ( Ord( op.pValue ) + op.nSize - 1 );
  nOpEndAddr   := Ord( op.pValue );
  nMaxCount    := ( ( op.nSize Div 2 ) - 1 );

  For nCount := 0 To nMaxCount Do
  Begin
    nTmp := Mem[nOpStartAddr-nCount];
    Mem[nOpStartAddr-nCount] := Mem[nOpEndAddr+nCount];
    Mem[nOpEndAddr+nCount] := nTmp;
  End;

  SwapBigInt := RetCode;
End;
