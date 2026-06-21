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
procedure TRACE( strValue : TShortString );
begin
  WriteLn( strValue );
end;

(**
  * Trace procedure to print a string pointer to test standard output.
  * @param strValue The string value to print;
  *)
procedure PTRACE( pstrValue : PShortString );
begin
  WriteLn( pstrValue^ );
end;

(**
  * Skip a line in standard output;
  *)
procedure TRACELN;
begin
  WriteLn;
end;

(**
  * Unit test helper function to check expected value for reported
  * Boolean passed by parameter;
  * @param strTestName The name of test to be printed at screen report;
  * @param bRetValue The value reported by last math function operation;
  * @param bExpected The expected value for the last math function
  * operation;
  * The function return true if bRetValue is equal bExpected;
  *)
function TEST_BOOL( strTestName : TTinyString;
                    bRetValue, bExpected : boolean ) : boolean;
begin
  Write( '[', strTestName, '] ===> ' );

  if( bRetValue <> bExpected )  then
    WriteLn( '[ERROR] - Value ', bRetValue, ' expected ', bExpected )
  else
    WriteLn( '[SUCCESS]' );

  TEST_BOOL := ( bRetValue = bExpected );
end;

(**
  * Unit test helper function to check expected value for reported
  * @see TString passed by parameter;
  * @param strTestName The name of test to be printed at screen report;
  * @param strRetValue The value reported by last math function operation;
  * @param strExpected The expected value for the last math function
  * operation;
  * The function return true if bRetValue is equal bExpected;
  *)
function TEST_STR( strTestName : TTinyString;
                   strRetValue, strExpected : TString ) : boolean;
begin
  Write( '[', strTestName, '] ===> ' );

  if( strRetValue <> strExpected )  then
    begin
      WriteLn( '[ERROR] - Value ',  strRetValue, ' expected ', strExpected );
    end
  else
    WriteLn( '[SUCCESS]' );

  TEST_STR := ( strRetValue = strExpected );
end;

(**
  * Unit test helper function to check expected value for reported
  * Floating point (Real) value passed by parameter;
  * @param strTestName The name of test to be printed at screen report;
  * @param fRetValue The value reported by last math function operation;
  * @param fExpected The expected value for the last math function
  * operation;
  * The function return true if fRetValue is equal fExpected;
  *)
function TEST_FLOAT( strTestName : TTinyString;
                     fRetValue, fExpected : real ) : boolean;
begin
  Write( '[', strTestName, '] ===> ' );

  if( fRetValue <> fExpected )  then
    WriteLn( '[ERROR] - Value ', fRetValue, ' expected ', fExpected )
  else
    WriteLn( '[SUCCESS]' );

  TEST_FLOAT := ( fRetValue = fExpected );
end;

(**
  * Unit test helper function to check expected value for reported
  * integer value passed by parameter;
  * @param strTestName The name of test to be printed at screen report;
  * @param nRetValue The value reported by last math function operation;
  * @param nExpected The expected value for the last math function
  * operation;
  * The function return true if nRetValue is equal nExpected;
  *)
function TEST_INT( strTestName : TTinyString;
                   nRetValue, nExpected : integer ) : boolean;
begin
  Write( '[', strTestName, '] ===> ' );

  if( nRetValue <> nExpected )  then
    WriteLn( '[ERROR] - Value ', nRetValue, ' expected ', nExpected )
  else
    WriteLn( '[SUCCESS]' );

  TEST_INT := ( nRetValue = nExpected );
end;
