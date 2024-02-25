(*<tstbig9.pas>
 * Implement unit tests and sample for using the Big Numbers
 * library <bigint.pas>, using TUint24.
 * Unit tests for:
 *    16) Subtract operations between mixed types with exception cases;
 *
 * CopyLeft (c) 1995-2024 by PopolonY2k.
 * CopyLeft (c) since 2024 by Hinotori Team.
 *)
Program TestBigNumbers9;

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
  * Execute all mixed numbers (24bit vs 32bit, resulting 24bit),
  * big number tests.
  *)
Procedure ExecuteAllTests;
Var
        n24Cmp,
        n24Op,
        n24Res    : TInt24;
        n32Op,
        n32Res    : TInt32;
        big24Res,
        big32Res,
        big32Op,
        big24Cmp,
        big24Op   : TBigInt;
        cmpCode   : TCompareCode;
        opCode    : TOperationCode;
        strRet    : TString;
        pstrSep   : PShortString;

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
    big32Op.nSize   := SizeOf( n32Op );      { Data type size  }
    big32Op.pValue  := Ptr( Addr( n32Op ) ); { Pointer to data type }

    big32Res.nSize  := SizeOf( n32Res );
    big32Res.pValue := Ptr( Addr( n32Res ) );

    big24Op.nSize   := SizeOf( n24Op );
    big24Op.pValue  := Ptr( Addr( n24Op ) );

    big24Cmp.nSize  := SizeOf( n24Cmp );
    big24Cmp.pValue := Ptr( Addr( n24Cmp ) );

    big24Res.nSize  := SizeOf( n24Res );
    big24Res.pValue := Ptr( Addr( n24Res ) );
  End;

  (**
    * Execute test for big number sub operation between mixed
    * types.
    *)
  Procedure __SubTest;
  Var
          bRet : Boolean;

  Begin
    TRACE( '16 - Subtracting Big Numbers (24 vs 32 bit operations)' );
    TRACELN;

    PTRACE( pstrSep );
    TRACE( '16.1 - Subtracting 24bit to 32bit, result 24Bit' );
    PTRACE( pstrSep );

    TRACE( 'Subtract two simple 24bit numbers (the value fit in result)' );
    TRACELN;

    bRet := TEST_OP( '16.1.1 - StrToBigInt()',
                     StrToBigInt( big24Cmp, '788000' ), Success );
    bRet := TEST_OP( '16.1.2 - StrToBigInt()',
                     StrToBigInt( big24Op, '2048000' ), Success );
    bRet := TEST_OP( '16.1.3 - StrToBigInt()',
                     StrToBigInt( big32Op, '1260000' ), Success );
    bRet := TEST_OP( '16.1.4 - SubBigInt',
                     SubBigInt( big24Res, big24Op, big32Op ), Success );
    bRet := TEST_BIGINT_CMP( '16.1.5 - CompareBigInt()',
                             CompareBigInt( big24Res, big24Cmp ), Equals );
    bRet := TEST_OP( '16.1.6 - StrToBigInt()',
                     StrToBigInt( big32Op, '2048000' ), Success );
    bRet := TEST_OP( '16.1.7 - StrToBigInt()',
                     StrToBigInt( big24Op, '1260000' ), Success );
    bRet := TEST_OP( '16.1.8 - SubBigInt',
                     SubBigInt( big24Res, big32Op, big24Op ), Success );
    bRet := TEST_BIGINT_CMP( '16.1.9 - CompareBigInt()',
                             CompareBigInt( big24Res, big24Cmp ), Equals );

    TRACELN;
    TRACE( '1o Underflow case - The first 24bit operand is lesser than' );
    TRACE( 'the second 32bit operand.' );
    TRACELN;

    bRet := TEST_OP( '16.1.10 - StrToBigInt()',
                     StrToBigInt( big24Op, '1260000' ), Success );
    bRet := TEST_OP( '16.1.11 - StrToBigInt()',
                     StrToBigInt( big32Op, '2048000' ), Success );
    bRet := TEST_OP( '16.1.12 - SubBigInt',
                     SubBigInt( big24Res, big24Op, big32Op ), Underflow );

    TRACELN;
    TRACE( '2o Underflow case - The first 32bit operand is lesser than' );
    TRACE( 'the second 24bit operand.' );
    TRACELN;

    bRet := TEST_OP( '16.1.13 - StrToBigInt()',
                     StrToBigInt( big32Op, '1260000' ), Success );
    bRet := TEST_OP( '16.1.14 - StrToBigInt()',
                     StrToBigInt( big24Op, '2048000' ), Success );
    bRet := TEST_OP( '16.1.15 - SubBigInt',
                     SubBigInt( big24Res, big32Op, big24Op ), Underflow );

    TRACELN;
    TRACE( '3o Underflow case - First operand 24bit is zero and the' );
    TRACE( 'second operand 32bit is a 8bit value' );
    TRACELN;

    bRet := TEST_OP( '16.1.16 - ResetBigInt()',
                     ResetBigInt( big24Op ), Success );
    bRet := TEST_OP( '16.1.17 - StrToBigInt()',
                     StrToBigInt( big32Op, '1' ), Success );
    bRet := TEST_OP( '16.1.18 - SubBigInt',
                     SubBigInt( big24Res, big24Op, big32Op ), Underflow );

    TRACELN;
    TRACE( '4o Underflow case - First operand 24bit is zero and the' );
    TRACE( 'second operand 32bit is a 16bit value' );
    TRACELN;

    bRet := TEST_OP( '16.1.19 - ResetBigInt()',
                     ResetBigInt( big24Op ), Success );
    bRet := TEST_OP( '16.1.20 - StrToBigInt()',
                     StrToBigInt( big32Op, '256' ), Success );
    bRet := TEST_OP( '16.1.21 - SubBigInt',
                     SubBigInt( big24Res, big24Op, big32Op ), Underflow );

    TRACELN;
    TRACE( '5o Underflow case - First operand 24bit is zero and the' );
    TRACE( 'second operand 32bit is a 24bit value' );
    TRACELN;

    bRet := TEST_OP( '16.1.22 - ResetBigInt()',
                     ResetBigInt( big24Op ), Success );
    bRet := TEST_OP( '16.1.23 - StrToBigInt()',
                     StrToBigInt( big32Op, '1260000' ), Success );
    bRet := TEST_OP( '16.1.24 - SubBigInt',
                     SubBigInt( big24Res, big24Op, big32Op ), Underflow );

    TRACELN;
    TRACE( '6o Underflow case - First operand 24bit is zero and the' );
    TRACE( 'second operand 32bit is a 32bit value' );
    TRACELN;

    bRet := TEST_OP( '16.1.25 - ResetBigInt()',
                     ResetBigInt( big24Op ), Success );
    bRet := TEST_OP( '16.1.26 - StrToBigInt()',
                     StrToBigInt( big32Op, '4294967294' ), Success );
    bRet := TEST_OP( '16.1.27 - SubBigInt',
                     SubBigInt( big24Res, big24Op, big32Op ), Underflow );

    TRACELN;
    TRACE( '7o Underflow case - First operand 32bit is zero and the' );
    TRACE( 'second operand 24bit is a 8bit value' );
    TRACELN;

    bRet := TEST_OP( '16.1.28 - ResetBigInt()',
                     ResetBigInt( big32Op ), Success );
    bRet := TEST_OP( '16.1.29 - StrToBigInt()',
                     StrToBigInt( big24Op, '1' ), Success );
    bRet := TEST_OP( '16.1.30 - SubBigInt',
                     SubBigInt( big24Res, big32Op, big24Op ), Underflow );

    TRACELN;
    TRACE( '8o Underflow case - First operand 32bit is zero and the' );
    TRACE( 'second operand 24bit is a 16bit value' );
    TRACELN;

    bRet := TEST_OP( '16.1.31 - ResetBigInt()',
                     ResetBigInt( big32Op ), Success );
    bRet := TEST_OP( '16.1.32 - StrToBigInt()',
                     StrToBigInt( big24Op, '256' ), Success );
    bRet := TEST_OP( '16.1.33 - SubBigInt',
                     SubBigInt( big24Res, big32Op, big24Op ), Underflow );

    TRACELN;
    TRACE( '9o Underflow case - First operand 32bit is zero and the' );
    TRACE( 'second operand 24bit is a 24bit value' );
    TRACELN;

    bRet := TEST_OP( '16.1.34 - ResetBigInt()',
                     ResetBigInt( big32Op ), Success );
    bRet := TEST_OP( '16.1.35 - StrToBigInt()',
                     StrToBigInt( big24Op, '1260000' ), Success );
    bRet := TEST_OP( '16.1.36 - SubBigInt',
                     SubBigInt( big24Res, big32Op, big24Op ), Underflow );

    TRACELN;
  End;

Begin
  New( pStrSep );
  pstrSep^ := '-------------------------------------------------------------';
  __Setup;
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
  TRACE( '24Bit vs 32Bit big number operations' );
  TRACELN;

  ExecuteAllTests;  { Perform mixed types tests }
End.
