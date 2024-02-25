(*<tstbig5.pas>
 * Implement unit tests and sample for using the Big Numbers
 * library <bigint.pas>, using TUint24.
 * Unit tests for:
 *    10) Exception cases for multiplication operations;
 *    11) Exception cases for division operations (reserved for future use);
 *
 * CopyLeft (c) 1995-2024 by PopolonY2k.
 * CopyLeft (c) since 2024 by Hinotori Team.
 *)
Program TestBigNumbers5;

(*
 * This source file depends on following include files (respect the order):
 * - /system/types.pas;
 * - /math/math.pas;
 * - /bigint/bigint.pas;
 * - /ptest/ptest.pas;
 * - /ptest/ptestbig.pas;
 *)

{$i types.pas}
{$i math.pas}
{$i bigint.pas}
{$i ptest.pas}
{$i ptestbig.pas}


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
    * Execute exception tests for big number multiplication operation.
    *)
  Procedure __ExceptionMultTest;
  Const
           ctMaxIterations : Integer = 23;
  Var
           nCount : Integer;
  Begin
    bExit  := False;
    nCount := 0;

    TRACE( '10 - Exceptions for Multiplying Big Numbers' );
    TRACELN;

    PTRACE( pstrSep );
    TRACE( '10.1 - Multiply 24bit values starting with 1 and multiplying ' );
    TRACE( '       it by 2 until the result exceed the 24Bit limit.' );
    PTRACE( pstrSep );

    bRet := TEST_OP( ' 10.1.1 - StrToBigInt()',
                     StrToBigInt( big24ConstVal, '2' ), Success );
    bRet := TEST_OP( ' 10.1.2 - StrToBigInt()',
                     StrToBigInt( big24Res, '1' ), Success );
    bRet := TEST_OP( ' 10.1.3 - ResetBigInt()',
                     ResetBigInt( big24FirstOp ), Success );

    TRACELN;
    TRACE( 'Starting big number mult. operation' );

    Repeat
      opCode := MulBigInt( big24FirstOp, big24Res, big24ConstVal );

      If( opCode = Success )  Then
      Begin
        opCode := AssignBigInt( big24Res, big24FirstOp );

        If( opCode <> Success )  Then
        Begin
          bExit := True;
          bRet  := TEST_OP( '10.1.FatalError - CopyBigInt()',
                            opCode, Success );
        End;
        nCount := nCount + 1;
      End
      Else
      Begin
        bExit := True;
        bRet  := TEST_OP( '10.1.4 - Overflow test', opCode, Overflow );
      End;
    Until( ( bExit = True ) Or ( nCount > ctMaxIterations ) );

    TRACE( 'Big number mult. operation finished' );
    TRACELN;

    bRet := TEST_INT( '10.1.5 - Iterations until 24Bit limit',
                      nCount,
                      ctMaxIterations );

    TRACELN;
  End;

Begin
  New( pStrSep );
  pstrSep^ := '-------------------------------------------------------------';
  __Setup;
  __ExceptionMultTest;
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
