(*<tstbig1.pas>
 * Implement unit tests and sample for using the Big Numbers
 * library <bigint.pas>, using TUint24.
 * Unit tests for :
 *   1) TBigInt value assignment;
 *   2 & 3) TBigInt conversions;
 *
 * CopyLeft (c) 1995-2024 by PopolonY2k.
 * CopyLeft (c) since 2024 by Hinotori Team.
 *)
Program TestBigNumbers1;

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
        n24SecondOp,
        n24Res        : TInt24;
        big24SecondOp,
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

    big24SecondOp.nSize  := SizeOf( n24SecondOp );
    big24SecondOp.pValue := Ptr( Addr( n24SecondOp ) );

    big24Res.nSize  := SizeOf( n24Res );
    big24Res.pValue := Ptr( Addr( n24Res ) );

    big24ConstVal.nSize  := SizeOf( n24ConstVal );
    big24ConstVal.pValue := Ptr( Addr( n24ConstVal ) );

    big24CompVal.nSize  := SizeOf( n24CompVal );
    big24CompVal.pValue := Ptr( Addr( n24CompVal ) );
  End;

  (**
    * Execute Big Int variable assign values test.
    *)
  Procedure __AssignValuesTest;
  Begin
    TRACE( '1 - Assigning big values' );
    TRACELN;

    {
      At this point the program is ready to perform any operations based on
      value pointed by the source variable, the programmer can set the value
      to the variable, 'by hand', or using the Big number helper function,
      @see StrToBigNumber();
      Below is shown two ways to do this.
    }

    n24FirstOp[0] := 11;       { Setting the value 724660 to the }
    n24FirstOp[1] := 14;       { 24bit variable, manually  }
    n24FirstOp[2] := 180;

    (* 1.1- Setting a TBigInt from String - Value matching *)
    PTRACE( pstrSep );
    TRACE( '1.1 - Setting the 24bit value 724660, manually (byte to byte)' );
    PTRACE( pstrSep );

    If( TEST_OP( ' 1.1.1 - BigIntToStr()',
                 BigIntToStr( strRet, big24FirstOp ), Success ) )  Then
      bRet := TEST_STR( ' 1.1.2 - Value matching', strRet, '724660' );

    TRACELN;

    (* 1.2- Setting a TBigInt from String - Value matching *)
    PTRACE( pstrSep );
    TRACE( '1.2 - Setting the 24bit value 724660 from String' );
    PTRACE( pstrSep );

    If( TEST_OP( ' 1.2.1 - StrToBigInt()',
                 StrToBigInt( big24SecondOp, '724660' ), Success ) ) Then
      bRet := TEST_BIGINT_CMP( ' 1.2.2 - CompareBigInt()',
                               CompareBigInt( big24FirstOp, big24SecondOp ),
                               Equals );

    TRACELN;
  End;

  (**
    * Execute test for big number conversion.
    *)
  Procedure __ConvertNumberTest;
  Begin
    TRACE( '2 - Converting Big Numbers' );
    TRACELN;

    PTRACE( pstrSep );
    TRACE( '2.1 - Converting the 24bit value 788244, manual setting,' );
    TRACE( '      to String and performing the comparision between the' );
    TRACE( '      Strings values.' );
    PTRACE( pstrSep );

    n24FirstOp[0] := 12;       { Setting the value 788244 to the }
    n24FirstOp[1] := 7;        { 24bit variable, manually  }
    n24FirstOp[2] := 20;

    If( TEST_OP( ' 2.1.1 - BigIntToStr()',
                 BigIntToStr( strRet, big24FirstOp ), Success ) )  Then
      bRet := TEST_STR( ' 2.1.2 - Value matching', strRet, '788244' );

    TRACELN;

    PTRACE( pstrSep );
    TRACE( '2.2 - Converting the 24bit value 1512904, manual setting,' );
    TRACE( '      to Floating point (Real) and performing the comparision' );
    TRACE( '      between the String values.' );
    PTRACE( pstrSep );

    n24FirstOp[0] := 23;       { Setting the value 1512904 to the }
    n24FirstOp[1] := 21;       { 24bit variable, manually  }
    n24FirstOp[2] := 200;

    If( TEST_OP( ' 2.2.1 - BigIntToReal()',
                 BigIntToReal( fRes, big24FirstOp ), Success ) )  Then
      bRet := TEST_FLOAT( ' 2.2.2 - Value matching',
                          Int( fRes ), Int( 1.5129039999e+06 ) );

    TRACELN;
  End;

  (**
    * Execute test for big number to string conversion.
    *)
  Procedure __ConvertToStringTest;
  Var
            aStrValue : Array[0..11] Of String[7];
            nCount     : Byte;

  Begin
    bExit  := False;
    nCount := 0;

    { String results setup }
    aStrValue[0]  := '1000';
    aStrValue[1]  := '2000';
    aStrValue[2]  := '4000';
    aStrValue[3]  := '8000';
    aStrValue[4]  := '16000';
    aStrValue[5]  := '32000';
    aStrValue[6]  := '64000';
    aStrValue[7]  := '128000';
    aStrValue[8]  := '256000';
    aStrValue[9]  := '512000';
    aStrValue[10] := '1024000';
    aStrValue[11] := '2048000';

    TRACE( '3 - Converting Big Numbers to String' );
    TRACELN;

    PTRACE( pstrSep );
    TRACE( '3.1 - Multiplying 24bit values starting by 500 and multiplying ' );
    TRACE( '      by 2 until the result reach the result of 1500000,' );
    TRACE( '      comparing the results with constant strings.' );
    PTRACE( pstrSep );

    bRet := TEST_OP( ' 3.1.1 - StrToBigInt()',
                     StrToBigInt( big24ConstVal, '2' ), Success );
    bRet := TEST_OP( ' 3.1.2 - StrToBigInt()',
                     StrToBigInt( big24CompVal, '2048000' ), Success );
    bRet := TEST_OP( ' 3.1.3 - ResetBigInt()',
                     ResetBigInt( big24FirstOp ), Success );
    bRet := TEST_OP( ' 3.1.4 - StrToBigInt()',
                     StrToBigInt( big24Res, '500' ), Success );

    TRACELN;
    TRACE( 'Starting big number multiplication and conversion operation' );

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
            bRet  := TEST_OP( '3.1.FatalError - CopyBigInt()',
                              opCode, Success );
          End
          Else
          Begin
            bExit := Not TEST_OP( '3.1.5 - BigIntToStr()',
                                  BigIntToStr( strRet, big24Res ),
                                  Success );
            If( Not bExit )  Then
            Begin
              bExit := Not TEST_STR( '3.1.6 - Value Matching',
                                     strRet,
                                     aStrValue[nCount] );
              nCount := nCount + 1;
            End;
          End;
        End
        Else
        Begin
          bExit := True;
          bRet  := TEST_OP( '3.1.FatalError - MulBigInt()',
                            opCode, Success );
        End;
      End;
    Until( bExit = True );

    TRACE( 'Big number multiplication and conversion operation finished' );
    TRACELN;
  End;

{ Main procedure entry point }
Begin
  New( pStrSep );
  pstrSep^ := '-------------------------------------------------------------';
  __Setup;
  __AssignValuesTest;
  __ConvertNumberTest;
  __ConvertToStringTest;
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
