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
type TOperationCode = ( Success,
                        Overflow,
                        Underflow,
                        InvalidNumber,
                        NoMemoryAvailable,
                        IncompatibleParms,
                        NotImplemented );

(**
  * Comparision return codes.
  *)
type TCompareCode = ( Equals, GreaterThan, LessThan, CompareError );

(**
  * Big integer type definition for new extended
  * math operations.
  *)
type TBigInt = record
  nSize    : byte;
  pValue   : ^byte;
end;

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
function AddBigInt( var ret : TBigInt; op1, op2 : TBigInt ) : TOperationCode;
var
        nCount,
        nMaxOpSize : byte;
        RetCode    : TOperationCode;
        nOp1Addr,
        nOp2Addr,
        nRetAddr,
        nRes       : integer;

begin
  RetCode    := Success;
  nMaxOpSize := byte( Max( op1.nSize, op2.nSize ) );
  nMaxOpSize := byte( Max( nMaxOpSize, ret.nSize ) );
  nRetAddr   := ( Ord( ret.pValue ) + ret.nSize - 1 );
  nOp1Addr   := ( Ord( op1.pValue ) + op1.nSize - 1 );
  nOp2Addr   := ( Ord( op2.pValue ) + op2.nSize - 1 );
  nRes       := 0;
  nCount     := 0;

  { Clear the result variable }
  FillChar( ret.pValue^, ret.nSize, 0 );

  while( nCount < nMaxOpSize ) do
  begin
    if( nCount < op1.nSize )  then  { First operand }
      nRes := nRes + Mem[nOp1Addr-nCount];

    if( nCount < op2.nSize ) then   { Second operand }
      nRes := nRes + Mem[nOp2Addr-nCount];

    { Get the result and apply carry to next byte operation }
    if( nCount < ret.nSize )  then
    begin
      Mem[nRetAddr-nCount] := Lo( nRes );
      nRes := Hi( nres );
    end
    else
      if( Hi( nRes ) > 0 ) then  { Check overflow }
        nCount := nMaxOpSize; { Exit condition }

    nCount := nCount + 1;
  end;

  { Check overflow }
  if( nRes > 0 )  then
  begin
    { For overflow, fill all return bytes with FF value }
    FillChar( ret.pValue^, ret.nSize, $FF );
    RetCode := Overflow;
  end;

  AddBigInt := RetCode;
end;

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
function SubBigInt( var ret : TBigInt; op1, op2 : TBigInt ) : TOperationCode;
var
        nCount,
        nMaxOpSize : byte;
        RetCode    : TOperationCode;
        nOp1Addr,
        nOp2Addr,
        nRetAddr,
        nRes       : integer;
begin
  RetCode    := Success;
  nMaxOpSize := byte( Max( op1.nSize, op2.nSize ) );
  nMaxOpSize := byte( Max( nMaxOpSize, ret.nSize ) );
  nRetAddr   := ( Ord( ret.pValue ) + ret.nSize - 1 );
  nOp1Addr   := ( Ord( op1.pValue ) + op1.nSize - 1 );
  nOp2Addr   := ( Ord( op2.pValue ) + op2.nSize - 1 );
  nRes       := 0;
  nCount     := 0;

  { Clear the result variable }
  FillChar( ret.pValue^, ret.nSize, 0 );

  while( nCount < nMaxOpSize ) do
  begin
    if( nCount < op1.nSize )  then  { First operand }
      nRes := Mem[nOp1Addr-nCount] - nRes
    else
      nRes := -nRes;

    if( nCount < op2.nSize ) then   { Second operand }
      nRes := nRes - Mem[nOp2Addr-nCount];

    { Get the result and apply borrow to next byte operation }
    if( nCount < ret.nSize )  then
    begin
      Mem[nRetAddr-nCount] := Lo( nRes );
    end
    else
      nCount := nMaxOpSize;   { Exit condition }

    if( Hi( nRes ) > 0 )  then
      nRes := 1
    else
      nRes := 0;

    nCount := nCount + 1;
  end;

  { Check underflow }
  if( nRes = 1 )  then
  begin
    { For underflow, fill all return bytes with FE value }
    FillChar( ret.pValue^, ret.nSize, $FE );
    RetCode := Underflow;
  end;

  SubBigInt := RetCode;
end;

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
function MulBigInt( var ret : TBigInt; op1, op2 : TBigInt ) : TOperationCode;
var
       nOp1Addr,
       nOp2Addr,
       nRetAddr,
       nRes        : integer;
       nMaxOpSize,
       i, j        : byte;
       RetCode     : TOperationCode;
begin
  (*
   * This is a very grade school (elementary) method.
   * In future, for performance reasons, I'm planning change this method by
   * the performatic Karatsuba's algorithm.
   * Please visit http://en.wikipedia.org/wiki/Karatsuba_algorithm for more
   * method's detail.
   *)
  RetCode    := Success;
  nMaxOpSize := byte( Max( op1.nSize, op2.nSize ) );
  nMaxOpSize := byte( Max( nMaxOpSize, ret.nSize ) );
  nRetAddr   := ( Ord( ret.pValue ) + ret.nSize - 1 );
  nOp1Addr   := ( Ord( op1.pValue ) + op1.nSize - 1 );
  nOp2Addr   := ( Ord( op2.pValue ) + op2.nSize - 1 );
  nRes       := 0;

  { Clear the result variable }
  FillChar( ret.pValue^, ret.nSize, 0 );

  i := 0;

  while( i < nMaxOpSize ) do
  begin
    j := 0;
    while( j < nMaxOpSize ) do
    begin
      if( ( i+j ) < ret.nSize  )  then
        nRes := nRes + Mem[nRetAddr-(i+j)];

      if( ( i < op1.nSize ) and ( j < op2.nSize ) )  then
        nRes := ( nRes + ( Mem[nOp1Addr-i] * Mem[nOp2Addr-j] ) );

      { Check overflow  }
      if( ( Hi( nRes ) > 0 ) and ( ( i+j ) = ( ret.nSize - 1 ) ) )  then
        RetCode := Overflow;

      if( ( ( i+j ) < ret.nSize ) and ( RetCode <> Overflow ) )  then
        Mem[nRetAddr-(i+j)] := Lo( nRes )
      else
        if( ( RetCode = Overflow ) or
            ( ( ( i+j ) >= ret.nSize ) and ( Hi( nRes ) > 0 ) ) ) then
        begin
          i := nMaxOpSize;    { Exit condition for i }
          j := nMaxOpSize;    { Exit condition for j }
          RetCode := Overflow;
        end;

      nRes := Hi( nRes );
      j := j + 1;
    end;
    i := i + 1;
  end;

  { Check overflow }
  if( RetCode = Overflow )  then
  begin
    { For overflow, fill all return bytes with FF value }
    FillChar( ret.pValue^, ret.nSize, $FF );
  end;

  MulBigInt := RetCode;
end;

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
function DivBigInt( var ret : TBigInt; op1, op2 : TBigInt ) : TOperationCode;
var
       RetCode : TOperationCode;
begin
  { TODO: Finish Him !!!!!!!! Not implemented yet. }
  RetCode := NotImplemented;

  DivBigInt := RetCode;
end;

(**
  * Convert a Big integer value to builtin Real representation.
  * @param rRet The real variable to receive the conversion result;
  * @param value The big int representation of value to convert;
  * The code of this function was based on GNU libc library source code;
  * If the operation fails, the function return a @see TOperationCode
  * enumeration return code.
  *)
function BigIntToReal( var rRet : real; value : TBigInt ) : TOperationCode;
var
        RetCode  : TOperationCode;
        nTmp,
        nVal,
        nCount,
        nByte,
        nBits    : byte;
        nValAddr : integer;
begin
  RetCode  := Success;
  nValAddr := Ord( value.pValue );
  rRet     := 0.0;
  nCount   := 0;

  for nByte := ( value.nSize - 1 ) downto 0 do
  begin
    nVal := Mem[nValAddr+nByte];

    for nBits := 0 to 7 do
    begin
      nTmp := ( nVal shr nBits ) and 1;
      rRet := rRet + ( nTmp * Pow( 2, nCount ) );
      nCount := nCount + 1;
    end;
  end;

  BigIntToReal := RetCode;
end;

(**
  * Convert a string value to Big Integer representation.
  * @param ret The @see TBigInt variable to receive the conversion result;
  * @param strValue The big integer in string format to convert;
  * The code of this function was based on GNU libc library source
  * code;
  * If the operation fails, the function return a @see TOperationCode
  * enumeration return code.
  *)
function StrToBigInt( var ret : TBigInt; strValue : TString ) : TOperationCode;
var
        RetCode   : TOperationCode;
        nCte10,
        nLen,
        nTmp,
        nCount    : byte;
        nDigit,
        nRet      : integer;
        bError    : boolean;
        tmpVal    : TBigInt;
        cte10     : TBigInt;
        digit     : TBigInt;
begin
  RetCode := InvalidNumber;
  nLen    := Length( strValue );

  if( nLen > 0 )  then
    if( Abs( MaxAvail ) >= ret.nSize )  then
    begin
      GetMem( tmpVal.pValue, ret.nSize );
      bError       := false;
      nCount       := 1;
      nCte10       := 10;     { Constant used to big int mult. operation }
      cte10.nSize  := sizeof( nCte10 );
      cte10.pValue := Ptr( Addr( nCte10 ) );
      tmpVal.nSize := ret.nSize;
      digit.nSize  := sizeof( nDigit );
      digit.pValue := Ptr( Addr( nDigit ) );

      FillChar( ret.pValue^, ret.nSize, 0 );
      FillChar( tmpVal.pValue^, tmpVal.nSize, 0 );

      { Skip white spaces and Tab chars }
      while( ( ( strValue[nCount] = ' ' ) or
               ( byte( strValue[nCount] ) = $09 ) ) and
             ( nCount <= nLen ) ) do
        nCount := nCount + 1;

      while( ( nCount <= nLen ) and not bError ) do  { Start conversion }
      begin
        Val( strValue[nCount], nDigit, nRet );
        nDigit := Swap( nDigit );

        if( nRet = 0 )  then
        begin
          RetCode := MulBigInt( tmpVal, ret, cte10 );

          if( RetCode = Success )  then
          begin
            RetCode := AddBigInt( ret, tmpVal, digit );

            if( RetCode <> Success )  then
              bError := true;  { Exit number processing }
          end
          else
            bError := true;  { Exit number processing }
        end
        else
          bError := true;   { Exit number processing }

        nCount := nCount + 1;
      end;

      FreeMem( tmpVal.pValue, tmpVal.nSize );

      if( not bError )  then
        RetCode := Success;
    end
    else
      RetCode := NoMemoryAvailable;

  StrToBigInt := RetCode;
end;

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
function BigIntToStr( var strRet : TString; value : TBigInt ) : TOperationCode;
var
        RetCode  : TOperationCode;
        rRes     : real;
        nLen,
        nPos     : byte;
begin
  strRet := '';
  rRes   := 0.0;
  nPos   := 0;

  RetCode := BigIntToReal( rRes, value );

  if( RetCode = Success )  then
    begin
      Str( rRes:11:0, strRet );
      nLen := Length( strRet );

      { Perform a string trimming }
      while( ( nPos < nLen ) and ( strRet[nPos+1] = ' ' ) ) do
        nPos := nPos + 1;

      if( nPos > 0 ) then
        Delete( strRet, 1, nPos );
    end;

  BigIntToStr := RetCode;
end;

(**
  * Reset a big int value filling with zeroes;
  * @param op The operand to reset;
  * The function return a @see TCompareCode return code;
  *)
function ResetBigInt( var op : TBigInt ) : TOperationCode;
var
        retCode : TOperationCode;
begin
  if( op.pValue <> nil )  then
  begin
    FillChar( op.pValue^, op.nSize, 0 );
    retCode := Success;
  end
  else
    retCode := InvalidNumber;

  ResetBigInt := retCode;
end;

(**
  * Assign a big int to another big int;
  * @param opDest The destination operand;
  * @param opSrc The source operand;
  * The function return a @see TCompareCode return code;
  *)
function AssignBigInt( var opDest : TBigInt; opSrc : TBigInt ) : TOperationCode;
var
        nCount,
        nMaxOpSize   : byte;
        RetCode      : TOperationCode;
        nOpSrcAddr,
        nOpDestAddr,
        nValue       : integer;
begin
  if( ( opDest.pValue <> nil ) and ( opSrc.pValue <> nil ) )  then
  begin
    RetCode     := Success;
    nMaxOpSize  := byte( Max( opSrc.nSize, opDest.nSize ) );
    nOpSrcAddr  := ( Ord( opSrc.pValue ) + opSrc.nSize - 1 );
    nOpDestAddr := ( Ord( opDest.pValue ) + opDest.nSize - 1 );
    nCount      := 0;

    while( nCount < nMaxOpSize ) do
    begin
      nValue := 0;

      if( nCount < opSrc.nSize )  then  { Source operand }
        nValue := Mem[nOpSrcAddr-nCount];

      if( nCount < opDest.nSize )  then  { Destination operand }
        Mem[nOpDestAddr-nCount] := nValue
      else
        if( nValue <> 0 )  then   { Check overflow }
        begin
          nCount  := nMaxOpSize; { Exit condition }
          RetCode := Overflow;
          { For overflow, fill all return bytes with FF value }
          FillChar( opDest.pValue^, opDest.nSize, $FF );
        end;

      nCount := nCount + 1;
    end;
  end
  else
    RetCode := InvalidNumber;

  AssignBigInt := RetCode;
end;

(**
  * Compare two BigInt operands.
  * @param op1 The first operand to compare;
  * @param op2 The second operand to compare;
  * The function return a @see TCompareCode return code;
  *)
function CompareBigInt( op1, op2 : TBigInt ) : TCompareCode;
var
      RetCode     : TCompareCode;
      nOp1Value,
      nOp2Value,
      nMaxOpSize,
      nCount      : byte;
      nOp1Addr,
      nOp2Addr    : integer;

begin
  if( ( op1.pValue <> nil ) and ( op2.pValue <> nil ) )  then
  begin
    RetCode    := Equals;
    nMaxOpSize := byte( Max( op1.nSize, op2.nSize ) );
    nOp1Addr   := ( Ord( op1.pValue ) + op1.nSize - 1 );
    nOp2Addr   := ( Ord( op2.pValue ) + op2.nSize - 1 );
    nCount     := 0;

    while( nCount < nMaxOpSize ) do
    begin
      if( nCount < op1.nSize )  then  { Source operand }
        nOp1Value := Mem[nOp1Addr-nCount]
      else
        nOp1Value := 0;

      if( nCount < op2.nSize )  then  { Destination operand }
        nOp2Value := Mem[nOp2Addr-nCount]
      else
        nOp2Value := 0;

      if( nOp1Value > nOp2Value )  then
        RetCode := GreaterThan
      else
        if( nOp1Value < nOp2Value )  then
          RetCode := LessThan;

      nCount := nCount + 1;
    end;
  end
  else
    RetCode := CompareError;

  CompareBigInt := RetCode;
end;

(**
  * Perform a BigInt operand byte order swap.
  * @param op The big int to be swapped;
  * The function return a @see TOperationCode return code;
  *)
function SwapBigInt( op : TBigInt ) : TOperationCode;
var
       nOpStartAddr,
       nOpEndAddr    : integer;
       nTmp,
       nMaxCount,
       nCount        : byte;
       RetCode       : TOperationCode;

begin
  RetCode := Success;
  nOpStartAddr := ( Ord( op.pValue ) + op.nSize - 1 );
  nOpEndAddr   := Ord( op.pValue );
  nMaxCount    := ( ( op.nSize div 2 ) - 1 );

  for nCount := 0 to nMaxCount do
  begin
    nTmp := Mem[nOpStartAddr-nCount];
    Mem[nOpStartAddr-nCount] := Mem[nOpEndAddr+nCount];
    Mem[nOpEndAddr+nCount] := nTmp;
  end;

  SwapBigInt := RetCode;
end;
