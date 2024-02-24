(*<pgrpbig.pas>
 * Implement the PopolonY2's unit test framework for use with
 * any Pascal application tests;
 * CopyLeft (c) since 1995 by PopolonY2k.
 *)

(**
  *
  * $Id: pgrpbig.pas 128 2020-07-08 17:51:23Z popolony2k $
  * $Author: popolony2k $
  * $Date: 2020-07-08 14:51:23 -0300 (Wed, 08 Jul 2020) $
  * $Revision: 128 $
  * $HeadURL: https://svn.code.sf.net/p/oldskooltech/code/msx/trunk/msxdos/pascal/pgrpbig.pas $
  *)

(*
 * This source file depends on following include files (respect the order):
 * - types.pas;
 * - math.pas;
 * - ptest.pas;
 * - ptestbig.pas;
 * - pgrptest.pas;
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
Function GRP_TEST_OP( strTestName : TTinyString;
                      opRetValue, opExpected : TOperationCode;
                      Var grp : TTestGroup ) : Boolean;
Var
      bRet : Boolean;
Begin
  bRet := TEST_OP( strTestName, opRetValue, opExpected );

  If( Not bRet )  Then
    grp.nFailedCount := grp.nFailedCount + 1
  Else
    grp.nSuccessCount := grp.nSuccessCount + 1;

  grp.nTestCount := grp.nTestCount + 1;

  GRP_TEST_OP := bRet;
End;

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
Function GRP_TEST_BIGINT_CMP( strTestName : TTinyString;
                              compCode, compExpected : TCompareCode;
                              Var grp : TTestGroup ) : Boolean;
Var
      bRet : Boolean;
Begin
  bRet := TEST_BIGINT_CMP( strTestName, compCode, compExpected );

  If( Not bRet )  Then
    grp.nFailedCount := grp.nFailedCount + 1
  Else
    grp.nSuccessCount := grp.nSuccessCount + 1;

  grp.nTestCount := grp.nTestCount + 1;

  GRP_TEST_BIGINT_CMP := bRet;
End;
