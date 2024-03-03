(*<tstbig2.pas>
 * Implement unit tests and sample for using the Big Numbers
 * library <bigint.pas>, using TUint24.
 * Unit tests for:
 *    4) Add operations;
 *    5) Sub operations;
 *
 * CopyLeft (c) 1995-2024 by PopolonY2k.
 * CopyLeft (c) since 2024 by Hinotori Team.
 *)
Program TestBigNumbers2;

(*
 * This source file depends on following include files (respect the order):
 * - /system/types.pas;
 * - /math/math.pas;
 * - /math/math16.pas; 
 * - /bigint/bigint.pas;
 * - /ptest/ptest.pas;
 * - /ptest/ptestbig.pas;
 *)

{$i ..\..\src\system\types.pas}
{$i ..\..\src\math\math.pas}
{$i ..\..\src\math\math16.pas}
{$i ..\..\src\math\bigint.pas}
{$i ..\..\src\ptest\ptest.pas}
{$i ..\..\src\ptest\ptestbig.pas}


(**
  * Execute all 24bit, big number tests.
  *)
Procedure Execute24BitTests;
Var
        n24ConstVal,
        n24CompVal,
        n24FirstOp,
        n24Res        : TInt24;
        big24Res,
        big24FirstOp,
        big24ConstVal,
        big24CompVal  : TBigInt;
        cmpCode       : TCompareCode;
        opCode        : TOperationCode;
        strRet        : TString;
        pstrSep       : PShortString;
        bExit,
        bRet          : Boolean;
        fRes          : Real;

  (**
    * The PopolonY2k's Big Numbers library for 8bit Turbo Pascal (CPM/MSXDOS)
    * was created thinking to be extensible for any other types in future,
    * then a independent and abstract model was developed in mind, this
    * includes a definition of a new type @see TBigInt that can accept any
    * other real types, including builtin pascal integer types Byte and
    * Integer.
    * To use the new math operators you must to do a single setup operation
    * to perform TBigInt data manipulation, using the new math operations
    * for big numbers.
    *)
  Procedure __Setup;
  Begin
    big24FirstOp.nSize  := SizeOf( n24FirstOp );      { Data type size  }
    big24FirstOp.pValue := Ptr( Addr( n24FirstOp ) ); { Pointer to data type }

    big24Res.nSize  := SizeOf( n24Res );
    big24Res.pValue := Ptr( Addr( n24Res ) );

    big24ConstVal.nSize  := SizeOf( n24ConstVal );
    big24ConstVal.pValue := Ptr( Addr( n24ConstVal ) );

    big24CompVal.nSize  := SizeOf( n24CompVal );
    big24CompVal.pValue := Ptr( Addr( n24CompVal ) );
  End;

  (**
    * Execute test for big number add operation.
    *)
  Procedure __AddTest;
  Const
           ctMaxIterations : Integer = 1500;
  Var
           nCount : Integer;
  Begin
    bExit  := False;
    nCount := 0;

    TRACE( '4 - Adding Big Numbers' );
    TRACELN;

    PTRACE( pstrSep );
    TRACE( '4.1 - Adding 24bit values starting by 0 and increasing 1000' );
    TRACE( '      units until the result reach the limit value of 1500000' );
    PTRACE( pstrSep );

    bRet := TEST_OP( ' 4.1.1 - StrToBigInt()',
                     StrToBigInt( big24ConstVal, '1000' ), Success );
    bRet := TEST_OP( ' 4.1.2 - StrToBigInt()',
                     StrToBigInt( big24CompVal, '1500000' ), Success );
    bRet := TEST_OP( ' 4.1.3 - ResetBigInt()',
                     ResetBigInt( big24FirstOp ), Success );
    bRet := TEST_OP( ' 4.1.4 - ResetBigInt()',
                     ResetBigInt( big24Res ), Success );

    TRACELN;
    TRACE( 'Starting big number add operation' );

    Repeat
      If( CompareBigInt( big24Res, big24CompVal ) <> LessThan ) Then
        bExit := True
      Else
      Begin
        opCode := AddBigInt( big24FirstOp, big24Res, big24ConstVal );

        If( opCode = Success )  Then
        Begin
          opCode := AssignBigInt( big24Res, big24FirstOp );

          If( opCode <> Success )  Then
          Begin
            bExit := True;
            bRet  := TEST_OP( '4.1.FatalError - CopyBigInt()',
                              opCode, Success );
          End;
          nCount := nCount + 1;
        End
        Else
        Begin
          bExit := True;
          bRet  := TEST_OP( '4.1.FatalError - AddBigInt()',
                            opCode, Success );
        End;
      End;
    Until( ( bExit = True ) Or ( nCount = ctMaxIterations ) );

    TRACE( 'Big number add operation finished' );
    TRACELN;

    bRet := TEST_BIGINT_CMP( ' 4.1.5 - Results',
                             CompareBigInt( big24Res, big24CompVal ),
                             Equals );

    bRet := TEST_INT( '4.1.6 - Iterations until 24Bit limit',
                      nCount,
                      ctMaxIterations );

    If( bRet ) Then
    Begin
      bRet := TEST_OP( ' 4.1.7 - BigIntToStr()',
                       BigIntToStr( strRet, big24Res ), Success );
      If( bRet )  Then
        TRACE( 'The calculated 24Bit number is ' + strRet )
      Else
        TRACE( 'Error to retrieve calculated 24Bit number' );
    End;

    TRACELN;
  End;

  (**
    * Execute test for big number sub operation.
    *)
  Procedure __SubTest;
  Const
           ctMaxIterations : Integer = 1500;
  Var
           nCount : Integer;
  Begin
    bExit  := False;
    nCount := 0;

    TRACE( '5 - Subtracting Big Numbers' );
    TRACELN;

    PTRACE( pstrSep );
    TRACE( '5.1 - Subtracting 24bit values starting by 1500000 and' );
    TRACE( '      decreasing 1000 units until the result reach zero' );
    PTRACE( pstrSep );

    bRet := TEST_OP( ' 5.1.1 - StrToBigInt()',
                     StrToBigInt( big24ConstVal, '1000' ), Success );
    bRet := TEST_OP( ' 5.1.2 - ResetBigInt()',
                     ResetBigInt( big24CompVal ), Success );
    bRet := TEST_OP( ' 5.1.3 - StrToBigInt()',
                     StrToBigInt( big24Res, '1500000' ), Success );
    bRet := TEST_OP( ' 5.1.4 - ResetBigInt()',
                     ResetBigInt( big24FirstOp ), Success );

    TRACELN;
    TRACE( 'Starting big number sub operation' );

    Repeat
      cmpCode := CompareBigInt( big24Res, big24CompVal );

      If( cmpCode <> GreaterThan ) Then
      Begin
        bExit := True;
        bRet := TEST_BIGINT_CMP( ' 5.1.5 - CompareBigInt()', cmpCode, Equals );
      End
      Else
      Begin
        opCode := SubBigInt( big24FirstOp, big24Res, big24ConstVal );

        If( opCode = Success )  Then
        Begin
          opCode := AssignBigInt( big24Res, big24FirstOp );

          If( opCode <> Success )  Then
          Begin
            bExit := True;
            bRet  := TEST_OP( '5.1.FatalError - CopyBigInt()',
                              opCode, Success );
          End;

          nCount := nCount + 1;
        End
        Else
        Begin
          bExit := True;
          bRet  := TEST_OP( '5.1.FatalError - SubBigInt()',
                            opCode, Success );
        End;
      End;
    Until( ( bExit = True ) Or ( nCount = ctMaxIterations ) );

    TRACE( 'Big number sub operation finished' );
    TRACELN;

    bRet := TEST_BIGINT_CMP( ' 5.1.6 - Results',
                             CompareBigInt( big24Res, big24CompVal ),
                             Equals );

    bRet := TEST_INT( '5.1.7 - Iterations until 24Bit limit',
                      nCount,
                      ctMaxIterations );

    If( bRet ) Then
    Begin
      bRet := TEST_OP( ' 5.1.8 - BigIntToStr()',
                       BigIntToStr( strRet, big24Res ), Success );
      If( bRet )  Then
        TRACE( 'The calculated 24Bit number is ' + strRet )
      Else
        TRACE( 'Error to retrieve calculated 24Bit number' );
    End;

    TRACELN;
  End;

Begin
  New( pStrSep );
  pstrSep^ := '-------------------------------------------------------------';
  __Setup;
  __AddTest;
  __SubTest;
  Release( pstrSep );
End;

(* Main program entry point to Tests *)
Begin
  ClrScr;

  TRACE( 'Big Integer math functions unit tests.' );
  TRACE( 'CopyLeft (c) Since 1995 by PopolonY2k' );
  TRACE( 'Project home at http://www.planetamessenger.org' );
  TRACELN;
  TRACELN;
  TRACE( '24Bit big number operations' );
  TRACELN;

  Execute24BitTests;  { Perform 24bits Big Number tests }
End.
