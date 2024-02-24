(*<tstbig10.pas>
 * Implement unit tests and sample for using the Big Numbers
 * library <bigint.pas>, using TUint24.
 * Unit tests for:
 *    17) Multiplication operations between mixed types with exception cases;
 *
 * Copyleft (c) since 1995 by PopolonY2k.
 *)
Program TestBigNumbers10;

(**
  *
  * $Id: tstbig10.pas 128 2020-07-08 17:51:23Z popolony2k $
  * $Author: popolony2k $
  * $Date: 2020-07-08 14:51:23 -0300 (Wed, 08 Jul 2020) $
  * $Revision: 128 $
  * $HeadURL: https://svn.code.sf.net/p/oldskooltech/code/msx/trunk/msxdos/pascal/tstbig10.pas $
  *)

(*
 * This source file depends on following include files (respect the order):
 * - types.pas;
 * - math.pas;
 * - bigint.pas;
 * - ptest.pas;
 * - ptestbig.pas;
 *)

{$i types.pas}
{$i math.pas}
{$i bigint.pas}
{$i ptest.pas}
{$i ptestbig.pas}


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
  Procedure __MulTest;
  Var
          bRet : Boolean;

  Begin
    TRACE( '17 - Multiplying Big Numbers (24 vs 32 bit operations)' );
    TRACELN;

    PTRACE( pstrSep );
    TRACE( '17.1 - Multiplying 24bit to 32bit, result 24Bit' );
    PTRACE( pstrSep );

    TRACE( 'Multiply two simple 24bit numbers (the value fit in result)' );
    TRACELN;

    bRet := TEST_OP( '17.1.1 - StrToBigInt()',
                     StrToBigInt( big24Cmp, '10019211' ), Success );
    bRet := TEST_OP( '17.1.2 - StrToBigInt()',
                     StrToBigInt( big24Op, '81457' ), Success );
    bRet := TEST_OP( '17.1.3 - StrToBigInt()',
                     StrToBigInt( big32Op, '123' ), Success );
    bRet := TEST_OP( '17.1.4 - MulBigInt',
                     MulBigInt( big24Res, big24Op, big32Op ), Success );
    bRet := TEST_BIGINT_CMP( '17.1.5 - CompareBigInt()',
                             CompareBigInt( big24Res, big24Cmp ), Equals );
    bRet := TEST_OP( '17.1.6 - StrToBigInt()',
                     StrToBigInt( big32Op, '81457' ), Success );
    bRet := TEST_OP( '17.1.7 - StrToBigInt()',
                     StrToBigInt( big24Op, '123' ), Success );
    bRet := TEST_OP( '17.1.8 - MulBigInt',
                     MulBigInt( big24Res, big32Op, big24Op ), Success );
    bRet := TEST_BIGINT_CMP( '17.1.9 - CompareBigInt()',
                             CompareBigInt( big24Res, big24Cmp ), Equals );

    TRACELN;
    TRACE( '1o Overflow case - The first 24bit operand is lesser than' );
    TRACE( 'the second 32bit operand.' );
    TRACELN;

    bRet := TEST_OP( '17.1.10 - StrToBigInt()',
                     StrToBigInt( big24Op, '2000' ), Success );
    bRet := TEST_OP( '17.1.11 - StrToBigInt()',
                     StrToBigInt( big32Op, '12678' ), Success );
    bRet := TEST_OP( '17.1.12 - MulBigInt',
                     MulBigInt( big24Res, big24Op, big32Op ), Overflow );

    TRACELN;
    TRACE( '2o Overflow case - The first 32bit operand is lesser than' );
    TRACE( 'the second 24bit operand.' );
    TRACELN;

    bRet := TEST_OP( '17.1.13 - StrToBigInt()',
                     StrToBigInt( big32Op, '2000' ), Success );
    bRet := TEST_OP( '17.1.14 - StrToBigInt()',
                     StrToBigInt( big24Op, '12678' ), Success );
    bRet := TEST_OP( '17.1.15 - MulBigInt',
                     MulBigInt( big24Res, big32Op, big24Op ), Overflow );

    TRACELN;
    TRACE( '3o Test case - First operand 24bit is zero and the' );
    TRACE( 'second operand 32bit is a value higher than zero' );
    TRACELN;

    bRet := TEST_OP( '17.1.16 - ResetBigInt()',
                     ResetBigInt( big24Op ), Success );
    bRet := TEST_OP( '17.1.17 - ResetBigInt()',
                     ResetBigInt( big24Cmp ), Success );
    bRet := TEST_OP( '17.1.18 - StrToBigInt()',
                     StrToBigInt( big32Op, '100' ), Success );
    bRet := TEST_OP( '17.1.19 - MulBigInt',
                     MulBigInt( big24Res, big24Op, big32Op ), Success );
    bRet := TEST_BIGINT_CMP( '17.1.20 - CompareBigInt()',
                             CompareBigInt( big24Res, big24Cmp ), Equals );
    TRACELN;

    TRACE( '4o Test case - First operand 32bit is zero and the' );
    TRACE( 'second operand 24bit is a value higher than zero' );
    TRACELN;

    bRet := TEST_OP( '17.1.21 - ResetBigInt()',
                     ResetBigInt( big32Op ), Success );
    bRet := TEST_OP( '17.1.22 - ResetBigInt()',
                     ResetBigInt( big24Cmp ), Success );
    bRet := TEST_OP( '17.1.23 - StrToBigInt()',
                     StrToBigInt( big24Op, '100' ), Success );
    bRet := TEST_OP( '17.1.24 - MulBigInt',
                     MulBigInt( big24Res, big32Op, big24Op ), Success );
    bRet := TEST_BIGINT_CMP( '17.1.25 - CompareBigInt()',
                             CompareBigInt( big24Res, big24Cmp ), Equals );
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
