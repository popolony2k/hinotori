(*<tstbig3.pas>
 * Implement unit tests and sample for using the Big Numbers
 * library <bigint.pas>, using TUint24.
 * Unit tests for:
 *    6) Multiplication operations;
 *    7) Division operations (reserved for future use);
 *
 * CopyLeft (c) 1995-2024 by PopolonY2k.
 * CopyLeft (c) since 2024 by Hinotori Team.
 *)
Program TestBigNumbers3;

(*
 * This source file depends on following include files (respect the order):
 * - /system/types.pas;
 * - /math/math.pas;
 * - /bigint/bigint.pas;
 * - /ptest/ptest.pas;
 * - /ptest/ptestbig.pas;
 *)

{$i ../../src/system/types.pas}
{$i ../../src/math/math.pas}
{$i ../../src/math/bigint.pas}
{$i ../../src/ptest/ptest.pas}
{$i ../../src//ptest/ptestbig.pas}


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
    * Execute test for big number multiplication operation.
    *)
  Procedure __MulTest;
  Const
               ctMaxIterations : Integer = 12;
  Var
               nCount : Integer;
  Begin
    bExit  := False;
    nCount := 0;

    TRACE( '6 - Multiplying Big Numbers' );
    TRACELN;

    PTRACE( pstrSep );
    TRACE( '6.1 - Multiplying 24bit values starting by 500 and multiplying ' );
    TRACE( '      by 2 until the result reach the result of 1500000' );
    PTRACE( pstrSep );

    bRet := TEST_OP( ' 6.1.1 - StrToBigInt()',
                     StrToBigInt( big24ConstVal, '2' ), Success );
    bRet := TEST_OP( ' 6.1.2 - StrToBigInt()',
                     StrToBigInt( big24CompVal, '2048000' ), Success );
    bRet := TEST_OP( ' 6.1.3 - ResetBigInt()',
                     ResetBigInt( big24FirstOp ), Success );
    bRet := TEST_OP( ' 6.1.4 - StrToBigInt()',
                     StrToBigInt( big24Res, '500' ), Success );

    TRACELN;
    TRACE( 'Starting big number multiplication operation' );

    Repeat
      If( CompareBigInt( big24Res, big24CompVal ) <> LessThan ) Then
        bExit := True
      Else
      Begin
        opCode := MulBigInt( big24FirstOp, big24Res, big24ConstVal );

        If( opCode = Success )  Then
        Begin
          opCode := AssignBigInt( big24Res, big24FirstOp );

          If( opCode <> Success )  Then
          Begin
            bExit := True;
            bRet  := TEST_OP( '6.1.FatalError - CopyBigInt()',
                              opCode, Success );
          End;
          nCount := nCount + 1;
        End
        Else
        Begin
          bExit := True;
          bRet  := TEST_OP( '6.1.FatalError - MulBigInt()',
                            opCode, Success );
        End;
      End;
    Until( ( bExit = True ) Or ( nCount = ctMaxIterations ) );

    TRACE( 'Big number multiplication operation finished' );
    TRACELN;

    bRet := TEST_BIGINT_CMP( ' 6.1.5 - Results',
                             CompareBigInt( big24Res, big24CompVal ),
                             Equals );

    bRet := TEST_INT( '6.1.6 - Iterations until 24Bit limit',
                      nCount,
                      ctMaxIterations );

    If( bRet ) Then
    Begin
      bRet := TEST_OP( ' 6.1.7 - BigIntToStr()',
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
  __MulTest;
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
