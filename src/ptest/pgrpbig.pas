(*<pgrpbig.pas>
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
 * - /ptest/ptestbig.pas;
 * - /ptest/pgrptest.pas;
 *)

(**
  * Unit test helper function to check expected value for reported
  * operation passed by parameter;
  * @param strTestName The name of test to be printed at screen report;
  * @param opRetValue The value reported by last math function operation;
  * @param opExpected The expected value for the last math function
  * operation;
  * @param grp The reference to a group record to store the group
  * information tests;
  * The function return true if opRetValue is equal opExpected;
  *)
function GRP_TEST_OP( strTestName : TTinyString;
                      opRetValue, opExpected : TOperationCode;
                      var grp : TTestGroup ) : boolean;
var
      bRet : boolean;
begin
  bRet := TEST_OP( strTestName, opRetValue, opExpected );

  if( not bRet )  then
    grp.nFailedCount := grp.nFailedCount + 1
  else
    grp.nSuccessCount := grp.nSuccessCount + 1;

  grp.nTestCount := grp.nTestCount + 1;

  GRP_TEST_OP := bRet;
end;

(**
  * Unit test helper function to check expected value for reported
  * TBigInt comparision passed by parameter;
  * @param strTestName The name of test to be printed at screen report;
  * @param compCode The value reported by last math comparision code;
  * @param compExpected The expected value for the last math comparision
  * operation;
  * @param grp The reference to a group record to store the group
  * information tests;
  * The function return true if compCode is equal compExpected;
  *)
function GRP_TEST_BIGINT_CMP( strTestName : TTinyString;
                              compCode, compExpected : TCompareCode;
                              var grp : TTestGroup ) : boolean;
var
      bRet : boolean;
begin
  bRet := TEST_BIGINT_CMP( strTestName, compCode, compExpected );

  if( not bRet )  then
    grp.nFailedCount := grp.nFailedCount + 1
  else
    grp.nSuccessCount := grp.nSuccessCount + 1;

  grp.nTestCount := grp.nTestCount + 1;

  GRP_TEST_BIGINT_CMP := bRet;
end;
