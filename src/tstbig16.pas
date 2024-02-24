(*<tstbig16.pas>
 * Implement unit tests and sample for using the Big Numbers
 * library <bigint.pas>, using TInt24.
 * Unit tests for:
 *    23) Test for SwapBigInt() function;
 *
 * Copyleft (c) since 1995 by PopolonY2k.
 *)
Program TestBigNumbers16;

(**
  *
  * $Id: tstbig16.pas 128 2020-07-08 17:51:23Z popolony2k $
  * $Author: popolony2k $
  * $Date: 2020-07-08 14:51:23 -0300 (Wed, 08 Jul 2020) $
  * $Revision: 128 $
  * $HeadURL: https://svn.code.sf.net/p/oldskooltech/code/msx/trunk/msxdos/pascal/tstbig16.pas $
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
  * Execute all tests with SwapBigInt possibilities.
  *)
Procedure ExecuteAllTests;
Var
        n24Op,
        n24Res    : TInt24;
        n32Op,
        n32Res    : TInt32;
        big24Op,
        big24Res,
        big32Op,
        big32Res  : TBigInt;
        cmpCode   : TCompareCode;
        opCode    : TOperationCode;
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
    big32Op.nSize  := SizeOf( n32Op );      { Data type size  }
    big32Op.pValue := Ptr( Addr( n32Op ) ); { Pointer to data type }

    big24Op.nSize  := SizeOf( n24Op );
    big24Op.pValue := Ptr( Addr( n24Op ) );

    big24Res.nSize  := SizeOf( n24Res );
    big24Res.pValue := Ptr( Addr( n24Res ) );

    big32Res.nSize  := SizeOf( n32Res );
    big32Res.pValue := Ptr( Addr( n32Res ) );
  End;

  (**
    * Execute test for SwapBigInt function.
    *)
  Procedure __SwapBigIntTest;
  Var
          bRet   : Boolean;

  Begin
    TRACE( '24.1 - Swapping 24Bit values' );
    TRACELN;

    PTRACE( pstrSep );
    TRACE( '24Bit Swap operations' );
    PTRACE( pstrSep );
    TRACELN;

    bRet := TEST_OP( '24.1.1 - Setting 16Bit value to 26195',
                     StrToBigInt( big24Op, '26195' ), Success );
    bRet := TEST_OP( '24.1.2 - Setting 24Bit res to 5465600',
                     StrToBigInt( big24Res, '5465600' ), Success );
    bRet := TEST_OP( '24.1.3 - SwapBigInt()',
                     SwapBigInt( big24Op ), Success );
    bRet := TEST_BIGINT_CMP( '24.1.4 - CompareBigInt()',
                             CompareBigInt( big24Res, big24Op ), Equals );

    TRACELN;

    bRet := TEST_OP( '24.2.1 - Setting 24Bit value to 16713314',
                     StrToBigInt( big24Op, '16713314' ), Success );
    bRet := TEST_OP( '24.2.2 - Setting 24Bit res, to 6424319',
                     StrToBigInt( big24Res, '6424319' ), Success );
    bRet := TEST_OP( '24.2.3 - SwapBigInt()',
                     SwapBigInt( big24Op ), Success );
    bRet := TEST_BIGINT_CMP( '24.2.4 - CompareBigInt()',
                             CompareBigInt( big24Res, big24Op ), Equals );

    TRACELN;

    TRACE( '25.1 - Swapping 32Bit values' );
    TRACELN;

    PTRACE( pstrSep );
    TRACE( '25Bit Swap operations' );
    PTRACE( pstrSep );
    TRACELN;

    bRet := TEST_OP( '25.1.1 - Setting 24Bit value to 5465600',
                     StrToBigInt( big32Op, '5465600' ), Success );
    bRet := TEST_OP( '25.1.2 - Setting 32Bit res to 6705920',
                     StrToBigInt( big32Res, '6705920' ), Success );
    bRet := TEST_OP( '25.1.3 - SwapBigInt()',
                     SwapBigInt( big32Op ), Success );
    bRet := TEST_BIGINT_CMP( '25.1.4 - CompareBigInt()',
                             CompareBigInt( big32Res, big32Op ), Equals );

    TRACELN;

    bRet := TEST_OP( '25.2.1 - Setting 32Bit value to 275141417',
                     StrToBigInt( big32Op, '275141417' ), Success );
    bRet := TEST_OP( '25.2.2 - Setting 32Bit res, to 693331472',
                     StrToBigInt( big32Res, '693331472' ), Success );
    bRet := TEST_OP( '25.2.3 - SwapBigInt()',
                     SwapBigInt( big32Op ), Success );
    bRet := TEST_BIGINT_CMP( '25.2.4 - CompareBigInt()',
                             CompareBigInt( big32Res, big32Op ), Equals );

    TRACELN;
  End;

Begin
  New( pStrSep );
  pstrSep^ := '-------------------------------------------------------------';
  __Setup;
  __SwapBigIntTest;
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
  TRACE( '24Bit and 32Bit big number byte order swap operations' );
  TRACELN;

  ExecuteAllTests;  { Perform mixed types tests }
End.
