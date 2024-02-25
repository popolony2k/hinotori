(*<tstbig15.pas>
 * Implement unit tests and sample for using the Big Numbers
 * library <bigint.pas>, using TInt24.
 * Unit tests for:
 *    23) Multiplication operations between mixed types with exception cases;
 *
 * CopyLeft (c) 1995-2024 by PopolonY2k.
 * CopyLeft (c) since 2024 by Hinotori Team.
 *)
Program TestBigNumbers15;

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
  * Execute all mixed numbers (24bit vs 32bit, resulting 32bit),
  * big number tests.
  *)
Procedure ExecuteAllTests;
Var
        n24Op     : TInt24;
        n32Op,
        n32Cmp,
        n32Res    : TInt32;
        big24Res,
        big32Res,
        big32Op,
        big32Cmp,
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

    big32Cmp.nSize  := SizeOf( n32Cmp );
    big32Cmp.pValue := Ptr( Addr( n32Cmp ) );
  End;

  (**
    * Execute test for big number sub operation between mixed
    * types.
    *)
  Procedure __MulTest;
  Var
          bRet : Boolean;

  Begin
    TRACE( '23 - Multiplying Big Numbers (24 vs 32 bit operations)' );
    TRACELN;

    PTRACE( pstrSep );
    TRACE( '23.1 - Multiplying 24bit to 32bit, result 32Bit' );
    PTRACE( pstrSep );

    TRACE( 'Multiply (24bit and 32bit) numbers (the value fit in result)' );
    TRACELN;

    bRet := TEST_OP( '23.1.1 - StrToBigInt()',
                     StrToBigInt( big32Cmp, '100599395' ), Success );
    bRet := TEST_OP( '23.1.2 - StrToBigInt()',
                     StrToBigInt( big24Op, '81457' ), Success );
    bRet := TEST_OP( '23.1.3 - StrToBigInt()',
                     StrToBigInt( big32Op, '1235' ), Success );
    bRet := TEST_OP( '23.1.4 - MulBigInt',
                     MulBigInt( big32Res, big24Op, big32Op ), Success );
    bRet := TEST_BIGINT_CMP( '23.1.5 - CompareBigInt()',
                             CompareBigInt( big32Res, big32Cmp ), Equals );
    bRet := TEST_OP( '23.1.6 - StrToBigInt()',
                     StrToBigInt( big32Op, '81457' ), Success );
    bRet := TEST_OP( '23.1.7 - StrToBigInt()',
                     StrToBigInt( big24Op, '1235' ), Success );
    bRet := TEST_OP( '23.1.8 - MulBigInt',
                     MulBigInt( big32Res, big32Op, big24Op ), Success );
    bRet := TEST_BIGINT_CMP( '23.1.9 - CompareBigInt()',
                             CompareBigInt( big32Res, big32Cmp ), Equals );

    TRACELN;
    TRACE( '1o Overflow case - The first 24bit operand is lesser than' );
    TRACE( 'the second 32bit operand.' );
    TRACELN;

    bRet := TEST_OP( '23.1.10 - StrToBigInt()',
                     StrToBigInt( big24Op, '20000' ), Success );
    bRet := TEST_OP( '23.1.11 - StrToBigInt()',
                     StrToBigInt( big32Op, '1237891' ), Success );
    bRet := TEST_OP( '23.1.12 - MulBigInt',
                     MulBigInt( big32Res, big24Op, big32Op ), Overflow );

    TRACELN;
    TRACE( '2o Overflow case - The first 32bit operand is lesser than' );
    TRACE( 'the second 24bit operand.' );
    TRACELN;

    bRet := TEST_OP( '23.1.13 - StrToBigInt()',
                     StrToBigInt( big32Op, '20000' ), Success );
    bRet := TEST_OP( '23.1.14 - StrToBigInt()',
                     StrToBigInt( big24Op, '1237891' ), Success );
    bRet := TEST_OP( '23.1.15 - MulBigInt',
                     MulBigInt( big32Res, big32Op, big24Op ), Overflow );

    TRACELN;
    TRACE( '3o Test case - First operand 24bit is zero and the' );
    TRACE( 'second operand 32bit is a value higher than zero' );
    TRACELN;

    bRet := TEST_OP( '23.1.16 - ResetBigInt()',
                     ResetBigInt( big24Op ), Success );
    bRet := TEST_OP( '23.1.17 - ResetBigInt()',
                     ResetBigInt( big32Cmp ), Success );
    bRet := TEST_OP( '23.1.18 - StrToBigInt()',
                     StrToBigInt( big32Op, '100' ), Success );
    bRet := TEST_OP( '23.1.19 - MulBigInt',
                     MulBigInt( big32Res, big24Op, big32Op ), Success );
    bRet := TEST_BIGINT_CMP( '23.1.20 - CompareBigInt()',
                             CompareBigInt( big32Res, big32Cmp ), Equals );
    TRACELN;

    TRACE( '4o Test case - First operand 32bit is zero and the' );
    TRACE( 'second operand 24bit is a value higher than zero' );
    TRACELN;

    bRet := TEST_OP( '23.1.21 - ResetBigInt()',
                     ResetBigInt( big32Op ), Success );
    bRet := TEST_OP( '23.1.22 - ResetBigInt()',
                     ResetBigInt( big32Cmp ), Success );
    bRet := TEST_OP( '23.1.23 - StrToBigInt()',
                     StrToBigInt( big24Op, '100' ), Success );
    bRet := TEST_OP( '23.1.24 - MulBigInt',
                     MulBigInt( big32Res, big32Op, big24Op ), Success );
    bRet := TEST_BIGINT_CMP( '23.1.25 - CompareBigInt()',
                             CompareBigInt( big32Res, big32Cmp ), Equals );
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
  TRACE( '24Bit vs 32Bit big number operations' );
  TRACELN;

  ExecuteAllTests;  { Perform mixed types tests }
End.
