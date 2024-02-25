(*<ptest.pas>
 * Implement the PopolonY2's unit test framework for use with
 * any Pascal application tests;
 * CopyLeft (c) 1995-2024 by PopolonY2k.
 * CopyLeft (c) since 2024 by Hinotori Team.
 *)

(*
 * This source file depends on following include files (respect the order):
 * - /system/types.pas;
 * - /math/math.pas;
 *)

(**
  * Trace procedure to print a string to test standard output.
  * @param strValue The string value to print;
  *)
Procedure TRACE( strValue : TShortString );
Begin
  WriteLn( strValue );
End;

(**
  * Trace procedure to print a string pointer to test standard output.
  * @param strValue The string value to print;
  *)
Procedure PTRACE( pstrValue : PShortString );
Begin
  WriteLn( pstrValue^ );
End;

(**
  * Skip a line in standard output;
  *)
Procedure TRACELN;
Begin
  WriteLn;
End;

(**
  * Unit test helper function to check expected value for reported
  * Boolean passed by parameter;
  * @param strTestName The name of test to be printed at screen report;
  * @param bRetValue The value reported by last math function operation;
  * @param bExpected The expected value for the last math function
  * operation;
  * The function return true if bRetValue is equal bExpected;
  *)
Function TEST_BOOL( strTestName : TTinyString;
                    bRetValue, bExpected : Boolean ) : Boolean;
Begin
  Write( '[', strTestName, '] ===> ' );

  If( bRetValue <> bExpected )  Then
    WriteLn( '[ERROR] - Value ', bRetValue, ' expected ', bExpected )
  Else
    WriteLn( '[SUCCESS]' );

  TEST_BOOL := ( bRetValue = bExpected );
End;

(**
  * Unit test helper function to check expected value for reported
  * @see TString passed by parameter;
  * @param strTestName The name of test to be printed at screen report;
  * @param strRetValue The value reported by last math function operation;
  * @param strExpected The expected value for the last math function
  * operation;
  * The function return true if bRetValue is equal bExpected;
  *)
Function TEST_STR( strTestName : TTinyString;
                   strRetValue, strExpected : TString ) : Boolean;
Begin
  Write( '[', strTestName, '] ===> ' );

  If( strRetValue <> strExpected )  Then
    Begin
      WriteLn( '[ERROR] - Value ',  strRetValue, ' expected ', strExpected );
    End
  Else
    WriteLn( '[SUCCESS]' );

  TEST_STR := ( strRetValue = strExpected );
End;

(**
  * Unit test helper function to check expected value for reported
  * Floating point (Real) value passed by parameter;
  * @param strTestName The name of test to be printed at screen report;
  * @param fRetValue The value reported by last math function operation;
  * @param fExpected The expected value for the last math function
  * operation;
  * The function return true if fRetValue is equal fExpected;
  *)
Function TEST_FLOAT( strTestName : TTinyString;
                     fRetValue, fExpected : Real ) : Boolean;
Begin
  Write( '[', strTestName, '] ===> ' );

  If( fRetValue <> fExpected )  Then
    WriteLn( '[ERROR] - Value ', fRetValue, ' expected ', fExpected )
  Else
    WriteLn( '[SUCCESS]' );

  TEST_FLOAT := ( fRetValue = fExpected );
End;

(**
  * Unit test helper function to check expected value for reported
  * integer value passed by parameter;
  * @param strTestName The name of test to be printed at screen report;
  * @param nRetValue The value reported by last math function operation;
  * @param nExpected The expected value for the last math function
  * operation;
  * The function return true if nRetValue is equal nExpected;
  *)
Function TEST_INT( strTestName : TTinyString;
                   nRetValue, nExpected : Integer ) : Boolean;
Begin
  Write( '[', strTestName, '] ===> ' );

  If( nRetValue <> nExpected )  Then
    WriteLn( '[ERROR] - Value ', nRetValue, ' expected ', nExpected )
  Else
    WriteLn( '[SUCCESS]' );

  TEST_INT := ( nRetValue = nExpected );
End;
