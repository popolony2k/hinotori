(*<tstbig7.pas>
 * Implement unit tests and sample for using the Big Numbers
 * library <bigint.pas>, using TUint24.
 * Unit tests for:
 *    13) Add operations;
 *    14) Sub operations;
 *
 * Copyleft (c) since 1995 by PopolonY2k.
 *)
Program TestBigNumbers7;

(**
  *
  * $Id: tstbig7.pas 128 2020-07-08 17:51:23Z popolony2k $
  * $Author: popolony2k $
  * $Date: 2020-07-08 14:51:23 -0300 (Wed, 08 Jul 2020) $
  * $Revision: 128 $
  * $HeadURL: https://svn.code.sf.net/p/oldskooltech/code/msx/trunk/msxdos/pascal/tstbig7.pas $
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
Procedure Execute2432BitTests;
Var
        n24ConstVal,
        n24CompVal,
        n24Res        : TInt24;
        n32FirstOp    : TInt32;
        big24Res,
        big32FirstOp,
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
    big32FirstOp.nSize  := SizeOf( n32FirstOp );      { Data type size  }
    big32FirstOp.pValue := Ptr( Addr( n32FirstOp ) ); { Pointer to data type }

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

    TRACE( '13 - Adding Big Numbers (24bit vs 32bit resulting 24bit)' );
    TRACELN;

    PTRACE( pstrSep );
    TRACE( '13.1 - Adding 24bit values starting by 0 and increasing 1000' );
    TRACE( '      units until the result reach the limit value of 1500000' );
    PTRACE( pstrSep );

    bRet := TEST_OP( ' 13.1.1 - StrToBigInt()',
                     StrToBigInt( big24ConstVal, '1000' ), Success );
    bRet := TEST_OP( ' 13.1.2 - StrToBigInt()',
                     StrToBigInt( big24CompVal, '1500000' ), Success );
    bRet := TEST_OP( ' 13.1.3 - ResetBigInt()',
                     ResetBigInt( big32FirstOp ), Success );
    bRet := TEST_OP( ' 13.1.4 - ResetBigInt()',
                     ResetBigInt( big24Res ), Success );

    TRACELN;
    TRACE( 'Starting big number add operation' );

    Repeat
      If( CompareBigInt( big32FirstOp, big24CompVal ) <> LessThan ) Then
        bExit := True
      Else
      Begin
        opCode := AddBigInt( big24Res, big32FirstOp, big24ConstVal );

        If( opCode = Success )  Then
        Begin
          opCode := AssignBigInt( big32FirstOp, big24Res );

          If( opCode <> Success )  Then
          Begin
            bExit := True;
            bRet  := TEST_OP( '13.1.FatalError - CopyBigInt()',
                              opCode, Success );
          End;
          nCount := nCount + 1;
        End
        Else
        Begin
          bExit := True;
          bRet  := TEST_OP( '13.1.FatalError - AddBigInt()',
                            opCode, Success );
        End;
      End;
    Until( ( bExit = True ) Or ( nCount = ctMaxIterations ) );

    TRACE( 'Big number add operation finished' );
    TRACELN;

    bRet := TEST_INT( '13.1.6 - Iterations until 24Bit limit',
                      nCount,
                      ctMaxIterations );

    bRet := TEST_BIGINT_CMP( ' 13.1.5 - Results',
                             CompareBigInt( big32FirstOp, big24CompVal ),
                             Equals );

    If( bRet ) Then
    Begin
      bRet := TEST_OP( ' 13.1.7 - BigIntToStr()',
                       BigIntToStr( strRet, big32FirstOp ), Success );
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

    TRACE( '14 - Subtracting Big Numbers' );
    TRACELN;

    PTRACE( pstrSep );
    TRACE( '14.1 - Subtracting 24bit values starting by 1500000 and' );
    TRACE( '      decreasing 1000 units until the result reach zero' );
    PTRACE( pstrSep );

    bRet := TEST_OP( ' 14.1.1 - StrToBigInt()',
                     StrToBigInt( big24ConstVal, '1000' ), Success );
    bRet := TEST_OP( ' 14.1.2 - ResetBigInt()',
                     ResetBigInt( big24CompVal ), Success );
    bRet := TEST_OP( ' 14.1.3 - StrToBigInt()',
                     StrToBigInt( big32FirstOp, '1500000' ), Success );
    bRet := TEST_OP( ' 14.1.4 - ResetBigInt()',
                     ResetBigInt( big24Res ), Success );

    TRACELN;
    TRACE( 'Starting big number sub operation' );

    Repeat
      cmpCode := CompareBigInt( big32FirstOp, big24CompVal );

      If( cmpCode <> GreaterThan ) Then
      Begin
        bExit := True;
        bRet := TEST_BIGINT_CMP( ' 14.1.5 - CompareBigInt()', cmpCode, Equals );
      End
      Else
      Begin
        opCode := SubBigInt( big24Res, big32FirstOp, big24ConstVal );

        If( opCode = Success )  Then
        Begin
          opCode := AssignBigInt( big32FirstOp, big24Res );

          If( opCode <> Success )  Then
          Begin
            bExit := True;
            bRet  := TEST_OP( '14.1.FatalError - CopyBigInt()',
                              opCode, Success );
          End;

          nCount := nCount + 1;
        End
        Else
        Begin
          bExit := True;
          bRet  := TEST_OP( '14.1.FatalError - SubBigInt()',
                            opCode, Success );
        End;
      End;
    Until( ( bExit = True ) Or ( nCount = ctMaxIterations ) );

    TRACE( 'Big number sub operation finished' );
    TRACELN;

    bRet := TEST_INT( '14.1.7 - Iterations until 24Bit limit',
                      nCount,
                      ctMaxIterations );

    bRet := TEST_BIGINT_CMP( ' 14.1.6 - Results',
                             CompareBigInt( big32FirstOp, big24CompVal ),
                             Equals );

    If( bRet ) Then
    Begin
      bRet := TEST_OP( ' 14.1.8 - BigIntToStr()',
                       BigIntToStr( strRet, big32FirstOp ), Success );
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
  TRACE( 'Mixed type (24bit vs 32bit) big number operations' );
  TRACELN;

  Execute2432BitTests;  { Perform 24bits vs 32 Bits Big Number tests }
End.
