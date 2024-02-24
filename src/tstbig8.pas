(*<tstbig8.pas>
 * Implement unit tests and sample for using the Big Numbers
 * library <bigint.pas>, using TUint24.
 * Unit tests for:
 *    15) Sum operations between mixed types with exception cases;
 *
 * Copyleft (c) since 1995 by PopolonY2k.
 *)
Program TestBigNumbers8;

(**
  *
  * $Id: tstbig8.pas 128 2020-07-08 17:51:23Z popolony2k $
  * $Author: popolony2k $
  * $Date: 2020-07-08 14:51:23 -0300 (Wed, 08 Jul 2020) $
  * $Revision: 128 $
  * $HeadURL: https://svn.code.sf.net/p/oldskooltech/code/msx/trunk/msxdos/pascal/tstbig8.pas $
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
    * Execute test for big number add operation between mixed
    * types.
    *)
  Procedure __AddTest;
  Var
          bRet : Boolean;

  Begin
    TRACE( '15 - Adding Big Numbers (24 vs 32 bit operations)' );
    TRACELN;

    PTRACE( pstrSep );
    TRACE( '15.1 - Adding 24bit to 32bit, result 24Bit' );
    PTRACE( pstrSep );

    TRACE( 'Adding two simple 24bit numbers (the value fit in result)' );
    TRACELN;

    bRet := TEST_OP( '15.1.1 - StrToBigInt()',
                     StrToBigInt( big24Cmp, '3308000' ), Success );
    bRet := TEST_OP( '15.1.2 - StrToBigInt()',
                     StrToBigInt( big24Op, '1260000' ), Success );
    bRet := TEST_OP( '15.1.3 - StrToBigInt()',
                     StrToBigInt( big32Op, '2048000' ), Success );
    bRet := TEST_OP( '15.1.4 - AddBigInt',
                     AddBigInt( big24Res, big24Op, big32Op ), Success );
    bRet := TEST_BIGINT_CMP( '15.1.5 - CompareBigInt()',
                             CompareBigInt( big24Res, big24Cmp ), Equals );
    bRet := TEST_OP( '15.1.6 - AddBigInt',
                     AddBigInt( big24Res, big32Op, big24Op ), Success );
    bRet := TEST_BIGINT_CMP( '15.1.7 - CompareBigInt()',
                             CompareBigInt( big24Res, big24Cmp ), Equals );

    TRACELN;
    TRACE( '1o Overflow case - 24bit value store the limit value and the' );
    TRACE( '32Bit value store the next bit to overflow the 24bit result by' );
    TRACE( 'using a 8bit value' );
    TRACELN;

    bRet := TEST_OP( '15.1.8 - StrToBigInt()',
                     StrToBigInt( big24Op, '16777215' ), Success );
    bRet := TEST_OP( '15.1.9 - StrToBigInt()',
                     StrToBigInt( big32Op, '1' ), Success );
    bRet := TEST_OP( '15.1.10 - AddBigInt',
                     AddBigInt( big24Res, big24Op, big32Op ), Overflow );
    bRet := TEST_OP( '15.1.11 - AddBigInt',
                     AddBigInt( big24Res, big32Op, big24Op ), Overflow );

    TRACELN;
    TRACE( '2o Overflow case - 24bit value store the limit value and the' );
    TRACE( '32Bit value store the next bit to overflow the 24bit result by' );
    TRACE( 'using a 16bit value' );
    TRACELN;

    bRet := TEST_OP( '15.1.12 - StrToBigInt()',
                     StrToBigInt( big24Op, '16777215' ), Success );
    bRet := TEST_OP( '15.1.13 - StrToBigInt()',
                     StrToBigInt( big32Op, '256' ), Success );
    bRet := TEST_OP( '15.1.14 - AddBigInt',
                     AddBigInt( big24Res, big24Op, big32Op ), Overflow );
    bRet := TEST_OP( '15.1.15 - AddBigInt',
                     AddBigInt( big24Res, big32Op, big24Op ), Overflow );

    TRACELN;
    TRACE( '3o Overflow case - 24bit value store the limit value and the' );
    TRACE( '32Bit value store the next bit to overflow the 24bit result by' );
    TRACE( 'using a 24bit value' );
    TRACELN;

    bRet := TEST_OP( '15.1.16 - StrToBigInt()',
                     StrToBigInt( big24Op, '16777215' ), Success );
    bRet := TEST_OP( '15.1.17 - StrToBigInt()',
                     StrToBigInt( big32Op, '16777215' ), Success );
    bRet := TEST_OP( '15.1.18 - AddBigInt',
                     AddBigInt( big24Res, big24Op, big32Op ), Overflow );
    bRet := TEST_OP( '15.1.19 - AddBigInt',
                     AddBigInt( big24Res, big32Op, big24Op ), Overflow );

    TRACELN;
    TRACE( '4o Overflow case - 24bit value store the limit value and the' );
    TRACE( '32Bit value store the next bit to overflow the 24bit result by' );
    TRACE( 'using a 32bit value' );
    TRACELN;

    bRet := TEST_OP( '15.1.20 - StrToBigInt()',
                     StrToBigInt( big24Op, '16777215' ), Success );
    bRet := TEST_OP( '15.1.21 - StrToBigInt()',
                     StrToBigInt( big32Op, '19999999' ), Success );
    bRet := TEST_OP( '15.1.22 - AddBigInt',
                     AddBigInt( big24Res, big24Op, big32Op ), Overflow );
    bRet := TEST_OP( '15.1.23 - AddBigInt',
                     AddBigInt( big24Res, big32Op, big24Op ), Overflow );

    TRACELN;
    TRACE( '5o Overflow case - 32bit value store the limit for 24bit' );
    TRACE( 'value and the 24Bit value store the next bit to overflow the' );
    TRACE( '24bit result by using a 8bit value' );
    TRACELN;

    bRet := TEST_OP( '15.1.24 - StrToBigInt()',
                     StrToBigInt( big32Op, '16777215' ), Success );
    bRet := TEST_OP( '15.1.25 - StrToBigInt()',
                     StrToBigInt( big24Op, '1' ), Success );
    bRet := TEST_OP( '15.1.26 - AddBigInt',
                     AddBigInt( big24Res, big24Op, big32Op ), Overflow );
    bRet := TEST_OP( '15.1.27 - AddBigInt',
                     AddBigInt( big24Res, big32Op, big24Op ), Overflow );

    TRACELN;
    TRACE( '6o Overflow case - 32bit value store the limit for 24bit' );
    TRACE( 'value and the 24Bit value store the next bit to overflow the' );
    TRACE( '24bit result by using a 16bit value' );
    TRACELN;

    bRet := TEST_OP( '15.1.28 - StrToBigInt()',
                     StrToBigInt( big32Op, '16777215' ), Success );
    bRet := TEST_OP( '15.1.29 - StrToBigInt()',
                     StrToBigInt( big24Op, '256' ), Success );
    bRet := TEST_OP( '15.1.30 - AddBigInt',
                     AddBigInt( big24Res, big24Op, big32Op ), Overflow );
    bRet := TEST_OP( '15.1.31 - AddBigInt',
                     AddBigInt( big24Res, big32Op, big24Op ), Overflow );

    TRACELN;
    TRACE( '7o Overflow case - 32bit value store the limit for 24bit' );
    TRACE( 'value and the 24Bit value store the next bit to overflow the' );
    TRACE( '24bit result by using a 24bit value' );
    TRACELN;

    bRet := TEST_OP( '15.1.32 - StrToBigInt()',
                     StrToBigInt( big32Op, '16777215' ), Success );
    bRet := TEST_OP( '15.1.33 - StrToBigInt()',
                     StrToBigInt( big24Op, '16777215' ), Success );
    bRet := TEST_OP( '15.1.34 - AddBigInt',
                     AddBigInt( big24Res, big24Op, big32Op ), Overflow );
    bRet := TEST_OP( '15.1.35 - AddBigInt',
                     AddBigInt( big24Res, big32Op, big24Op ), Overflow );

    TRACELN;
  End;

Begin
  New( pStrSep );
  pstrSep^ := '-------------------------------------------------------------';
  __Setup;
  __AddTest;
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
