(*<tstbig12.pas>
 * Implement unit tests and sample for using the Big Numbers
 * library <bigint.pas>, using TUint24.
 * Unit tests for:
 *    20) Data comparision operations between mixed types
 *        with exception cases;
 *
 * CopyLeft (c) 1995-2024 by PopolonY2k.
 * CopyLeft (c) since 2024 by Hinotori Team.
 *)
Program TestBigNumbers12;

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
  Procedure __CompTest;
  Var
          bRet : Boolean;

  Begin
    TRACE( '20 - Comparing Big Numbers (24 vs 32 bit operations)' );
    TRACELN;

    PTRACE( pstrSep );
    TRACE( '20.1 - Comparing 24bit with 32bit data type' );
    PTRACE( pstrSep );
    TRACELN;
    TRACE( '20.1.1 - The values are equals.' );
    TRACELN;

    bRet := TEST_OP( '20.1.2 - StrToBigInt()',
                     StrToBigInt( big24Op, '16777215' ), Success );
    bRet := TEST_OP( '20.1.3 - StrToBigInt()',
                     StrToBigInt( big32Op, '16777215' ), Success );
    bRet := TEST_BIGINT_CMP( '20.1.4 - CompareBigInt()',
                             CompareBigInt( big24Op, big32Op ), Equals );

    TRACELN;
    TRACE( '20.1.5 - The 32bit is greater than 24bit variable.' );
    TRACELN;

    bRet := TEST_OP( '20.1.6 - StrToBigInt()',
                     StrToBigInt( big24Op, '16777215' ), Success );
    bRet := TEST_OP( '20.1.7 - StrToBigInt()',
                     StrToBigInt( big32Op, '16777216' ), Success );
    bRet := TEST_BIGINT_CMP( '20.1.8 - CompareBigInt()',
                             CompareBigInt( big24Op, big32Op ), LessThan );
    bRet := TEST_BIGINT_CMP( '20.1.9 - CompareBigInt()',
                             CompareBigInt( big32Op, big24Op ), GreaterThan );

    TRACELN;
    TRACE( '20.1.10 - The 32bit is less than 24bit variable.' );
    TRACELN;

    bRet := TEST_OP( '20.1.11 - StrToBigInt()',
                     StrToBigInt( big24Op, '16777215' ), Success );
    bRet := TEST_OP( '20.1.12 - StrToBigInt()',
                     StrToBigInt( big32Op, '16777214' ), Success );
    bRet := TEST_BIGINT_CMP( '20.1.13 - CompareBigInt()',
                             CompareBigInt( big24Op, big32Op ), GreaterThan );
    bRet := TEST_BIGINT_CMP( '20.1.14 - CompareBigInt()',
                             CompareBigInt( big32Op, big24Op ), LessThan );
    TRACELN;
  End;

Begin
  New( pStrSep );
  pstrSep^ := '-------------------------------------------------------------';
  __Setup;
  __CompTest;
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
