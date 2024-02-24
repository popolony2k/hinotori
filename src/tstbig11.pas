(*<tstbig11.pas>
 * Implement unit tests and sample for using the Big Numbers
 * library <bigint.pas>, using TUint24.
 * Unit tests for:
 *    19) Data assignment operations between mixed types with exception cases;
 *
 * Copyleft (c) since 1995 by PopolonY2k.
 *)
Program TestBigNumbers11;

(**
  *
  * $Id: tstbig11.pas 128 2020-07-08 17:51:23Z popolony2k $
  * $Author: popolony2k $
  * $Date: 2020-07-08 14:51:23 -0300 (Wed, 08 Jul 2020) $
  * $Revision: 128 $
  * $HeadURL: https://svn.code.sf.net/p/oldskooltech/code/msx/trunk/msxdos/pascal/tstbig11.pas $
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
  Procedure __AssignTest;
  Var
          bRet : Boolean;

  Begin
    TRACE( '19 - Assigning Big Numbers (24 vs 32 bit operations)' );
    TRACELN;

    PTRACE( pstrSep );
    TRACE( '19.1 - Copying 24bit to 32bit data' );
    PTRACE( pstrSep );

    bRet := TEST_OP( '19.1.1 - StrToBigInt()',
                     StrToBigInt( big24Op, '16777215' ), Success );
    bRet := TEST_OP( '19.1.2 - CopyBigInt',
                     AssignBigInt( big32Res, big24Op ), Success );
    bRet := TEST_BIGINT_CMP( '19.1.3 - CompareBigInt()',
                             CompareBigInt( big32Res, big24Op ), Equals );
    TRACELN;
    PTRACE( pstrSep );
    TRACE( '19.1.4 - Copying a 24Bit value of 32bit variable to 24bit data' );
    PTRACE( pstrSep );

    bRet := TEST_OP( '19.1.5 - StrToBigInt()',
                     StrToBigInt( big32Op, '16777215' ), Success );
    bRet := TEST_OP( '19.1.6 - CopyBigInt',
                     AssignBigInt( big24Res, big32Op ), Success );
    bRet := TEST_BIGINT_CMP( '19.1.7 - CompareBigInt()',
                             CompareBigInt( big24Res, big32Op ), Equals );
    TRACELN;
    TRACE( '1o Overflow case - Copying a 32Bit value to 24Bit variable' );
    TRACELN;

    bRet := TEST_OP( '19.1.8 - StrToBigInt()',
                     StrToBigInt( big32Op, '16777216' ), Success );
    bRet := TEST_OP( '19.1.9 - CopyBigInt',
                     AssignBigInt( big24Res, big32Op ), Overflow );
    TRACELN;
  End;

Begin
  New( pStrSep );
  pstrSep^ := '-------------------------------------------------------------';
  __Setup;
  __AssignTest;
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
