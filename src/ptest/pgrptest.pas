(*<pgrptest.pas>
 * Implement the PopolonY2's unit test framework for use with
 * any Pascal application tests;
 * CopyLeft (c) 1995-2024 by PopolonY2k.
 * CopyLeft (c) since 2024 by Hinotori Team.
 *)

(*
 * This source file depends on following include files (respect the order):
 * - /system/types.pas;
 * - /math/math.pas;
 * - /ptest/ptest.pas;
 *)

(**
  * Group indentifier structure. Used to perform actions using group
  * test functions.
  *)
type TTestGroup = record
  strGrpName     : TTinyString;    { Test group identification }
  nTestCount,                      { Number of tests performed }
  nSuccessCount,                   { Number of succeeded tests }
  nFailedCount   : integer;        { Number of failed tests    }
end;


(**
  * Test group initialization.
  * @param grp The group data structure to initialize;
  *)
procedure ResetGroup( var grp : TTestGroup );
begin
  with grp  do
  begin
    strGrpName    := '';
    nTestCount    := 0;
    nSuccessCount := 0;
    nFailedCount  := 0;
  end;
end;

(**
  * Show trace information for the specified group.
  * @param grp The group to show information;
  *)
procedure TraceGroup( grp : TTestGroup );
var
      strTmp : TTinyString;
begin
  TRACE( 'Group ' + grp.strGrpName + ' results' );
  Str( grp.nTestCount, strTmp );
  TRACE( '  +-----> Number of tests : ' + strTmp );
  Str( grp.nSuccessCount, strTmp );
  TRACE( '  +-----> Succeeded tests : ' + strTmp );
  Str( grp.nFailedCount, strTmp );
  TRACE( '  +-----> Failed tests    : ' + strTmp );
end;

(**
  * Unit test helper function to check expected value for reported
  * Boolean passed by parameter;
  * @param strTestName The name of test to be printed at screen report;
  * @param bRetValue The value reported by last math function operation;
  * @param bExpected The expected value for the last math function
  * operation;
  * @param grp The reference to a group record to store the group
  * information tests;
  * The function return true if bRetValue is equal bExpected;
  *)
function GRP_TEST_BOOL( strTestName : TTinyString;
                        bRetValue, bExpected : boolean;
                        var grp : TTestGroup ) : boolean;
var
      bRet : boolean;
begin
  bRet := TEST_BOOL( strTestName, bRetValue, bExpected );

  if( not bRet )  then
    grp.nFailedCount := grp.nFailedCount + 1
  else
    grp.nSuccessCount := grp.nSuccessCount + 1;

  grp.nTestCount := grp.nTestCount + 1;

  GRP_TEST_BOOL := bRet;
end;

(**
  * Unit test helper function to check expected value for reported
  * @see TString passed by parameter;
  * @param strTestName The name of test to be printed at screen report;
  * @param strRetValue The value reported by last math function operation;
  * @param strExpected The expected value for the last math function
  * operation;
  * @param grp The reference to a group record to store the group
  * information tests;
  * The function return true if bRetValue is equal bExpected;
  *)
function GRP_TEST_STR( strTestName : TTinyString;
                       strRetValue, strExpected : TString;
                       var grp : TTestGroup ) : boolean;
var
      bRet : boolean;
begin
  bRet := TEST_STR( strTestName, strRetValue, strExpected );

  if( not bRet )  then
    grp.nFailedCount := grp.nFailedCount + 1
  else
    grp.nSuccessCount := grp.nSuccessCount + 1;

  grp.nTestCount := grp.nTestCount + 1;

  GRP_TEST_STR := bRet;
end;

(**
  * Unit test helper function to check expected value for reported
  * Floating point (Real) value passed by parameter;
  * @param strTestName The name of test to be printed at screen report;
  * @param fRetValue The value reported by last math function operation;
  * @param fExpected The expected value for the last math function
  * operation;
  * @param grp The reference to a group record to store the group
  * information tests;
  * The function return true if fRetValue is equal fExpected;
  *)
function GRP_TEST_FLOAT( strTestName : TTinyString;
                         fRetValue, fExpected : real;
                         var grp : TTestGroup ) : boolean;
var
      bRet : boolean;
begin
  bRet := TEST_FLOAT( strTestName, fRetValue, fExpected );

  if( not bRet )  then
    grp.nFailedCount := grp.nFailedCount + 1
  else
    grp.nSuccessCount := grp.nSuccessCount + 1;

  grp.nTestCount := grp.nTestCount + 1;

  GRP_TEST_FLOAT := bRet;
end;

(**
  * Unit test helper function to check expected value for reported
  * integer value passed by parameter;
  * @param strTestName The name of test to be printed at screen report;
  * @param nRetValue The value reported by last math function operation;
  * @param nExpected The expected value for the last math function
  * operation;
  * @param grp The reference to a group record to store the group
  * information tests;
  * The function return true if nRetValue is equal nExpected;
  *)
function GRP_TEST_INT( strTestName : TTinyString;
                       nRetValue, nExpected : integer;
                       var grp : TTestGroup ) : boolean;
var
      bRet : boolean;
begin
  bRet := TEST_INT( strTestName, nRetValue, nExpected );

  if( not bRet )  then
    grp.nFailedCount := grp.nFailedCount + 1
  else
    grp.nSuccessCount := grp.nSuccessCount + 1;

  grp.nTestCount := grp.nTestCount + 1;

  GRP_TEST_INT := bRet;
end;
