(*<pgrptest.pas>
 * Implement the PopolonY2's unit test framework for use with
 * any Pascal application tests;
 * CopyLeft (c) since 1995 by PopolonY2k.
 *)

(**
  *
  * $Id: pgrptest.pas 128 2020-07-08 17:51:23Z popolony2k $
  * $Author: popolony2k $
  * $Date: 2020-07-08 14:51:23 -0300 (Wed, 08 Jul 2020) $
  * $Revision: 128 $
  * $HeadURL: https://svn.code.sf.net/p/oldskooltech/code/msx/trunk/msxdos/pascal/pgrptest.pas $
  *)

(*
 * This source file depends on following include files (respect the order):
 * - types.pas;
 * - math.pas;
 * - ptest.pas;
 *)

(**
  * Group indentifier structure. Used to perform actions using group
  * test functions.
  *)
Type TTestGroup = Record
  strGrpName     : TTinyString;    { Test group identification }
  nTestCount,                      { Number of tests performed }
  nSuccessCount,                   { Number of succeeded tests }
  nFailedCount   : Integer;        { Number of failed tests    }
End;


(**
  * Test group initialization.
  * @param grp The group data structure to initialize;
  *)
Procedure ResetGroup( Var grp : TTestGroup );
Begin
  With grp  Do
  Begin
    strGrpName    := '';
    nTestCount    := 0;
    nSuccessCount := 0;
    nFailedCount  := 0;
  End;
End;

(**
  * Show trace information for the specified group.
  * @param grp The group to show information;
  *)
Procedure TraceGroup( grp : TTestGroup );
Var
      strTmp : TTinyString;
Begin
  TRACE( 'Group ' + grp.strGrpName + ' results' );
  Str( grp.nTestCount, strTmp );
  TRACE( '  +-----> Number of tests : ' + strTmp );
  Str( grp.nSuccessCount, strTmp );
  TRACE( '  +-----> Succeeded tests : ' + strTmp );
  Str( grp.nFailedCount, strTmp );
  TRACE( '  +-----> Failed tests    : ' + strTmp );
End;

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
Function GRP_TEST_BOOL( strTestName : TTinyString;
                        bRetValue, bExpected : Boolean;
                        Var grp : TTestGroup ) : Boolean;
Var
      bRet : Boolean;
Begin
  bRet := TEST_BOOL( strTestName, bRetValue, bExpected );

  If( Not bRet )  Then
    grp.nFailedCount := grp.nFailedCount + 1
  Else
    grp.nSuccessCount := grp.nSuccessCount + 1;

  grp.nTestCount := grp.nTestCount + 1;

  GRP_TEST_BOOL := bRet;
End;

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
Function GRP_TEST_STR( strTestName : TTinyString;
                       strRetValue, strExpected : TString;
                       Var grp : TTestGroup ) : Boolean;
Var
      bRet : Boolean;
Begin
  bRet := TEST_STR( strTestName, strRetValue, strExpected );

  If( Not bRet )  Then
    grp.nFailedCount := grp.nFailedCount + 1
  Else
    grp.nSuccessCount := grp.nSuccessCount + 1;

  grp.nTestCount := grp.nTestCount + 1;

  GRP_TEST_STR := bRet;
End;

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
Function GRP_TEST_FLOAT( strTestName : TTinyString;
                         fRetValue, fExpected : Real;
                         Var grp : TTestGroup ) : Boolean;
Var
      bRet : Boolean;
Begin
  bRet := TEST_FLOAT( strTestName, fRetValue, fExpected );

  If( Not bRet )  Then
    grp.nFailedCount := grp.nFailedCount + 1
  Else
    grp.nSuccessCount := grp.nSuccessCount + 1;

  grp.nTestCount := grp.nTestCount + 1;

  GRP_TEST_FLOAT := bRet;
End;

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
Function GRP_TEST_INT( strTestName : TTinyString;
                       nRetValue, nExpected : Integer;
                       Var grp : TTestGroup ) : Boolean;
Var
      bRet : Boolean;
Begin
  bRet := TEST_INT( strTestName, nRetValue, nExpected );

  If( Not bRet )  Then
    grp.nFailedCount := grp.nFailedCount + 1
  Else
    grp.nSuccessCount := grp.nSuccessCount + 1;

  grp.nTestCount := grp.nTestCount + 1;

  GRP_TEST_INT := bRet;
End;
