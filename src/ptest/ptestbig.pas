(*<ptestbig.pas>
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
 * - /math/bigint.pas;
 *)

(**
  * Unit test helper function to check expected value for reported
  * operation passed by parameter;
  * @param strTestName The name of test to be printed at screen report;
  * @param opRetValue The value reported by last math function operation;
  * @param opExpected The expected value for the last math function
  * operation;
  * The function return true if opRetValue is equal opExpected;
  *)
Function TEST_OP( strTestName : TTinyString;
                  opRetValue, opExpected : TOperationCode ) : Boolean;
  (**
    * Helper function to convert a @see TOperationCode value to
    * String representation.
    * @param opValue The TOperationCode to convert;
    *)
  Function __OpToString( opValue : TOperationCode ) : TTinyString;
  Var
        strRet : TTinyString;
  Begin
    Case( opValue ) Of
      Success           : strRet := 'Success';
      Overflow          : strRet := 'Overflow';
      Underflow         : strRet := 'Underflow';
      InvalidNumber     : strRet := 'InvalidNumber';
      NoMemoryAvailable : strRet := 'NoMemoryAvailable';
      IncompatibleParms : strRet := 'IncompatibleParameters';
      NotImplemented    : strRet := 'NotImplemented';
    End;

    __OpToString := strRet;
  End;

Begin
  Write( '[', strTestName, '] ===> ' );

  If( opRetValue <> opExpected )  Then
    WriteLn( '[ERROR] - Value ',
             __OpToString( opRetValue ),
             ' expected ',
             __OpToString( opExpected ) )
  Else
    WriteLn( '[SUCCESS]' );

  TEST_OP := ( opRetValue = opExpected );
End;

(**
  * Unit test helper function to check expected value for reported
  * TBigInt comparision passed by parameter;
  * @param strTestName The name of test to be printed at screen report;
  * @param compCode The value reported by last math comparision code;
  * @param compExpected The expected value for the last math comparision
  * operation;
  * The function return true if compCode is equal compExpected;
  *)
Function TEST_BIGINT_CMP( strTestName : TTinyString;
                          compCode, compExpected : TCompareCode ) : Boolean;
  (**
    * Helper function to convert a @see TCompareCode value to
    * String representation.
    * @param compCode The TCompareCode to convert;
    *)
  Function __CompToString( compCode : TCompareCode ) : TTinyString;
  Var
        strRet : TTinyString;
  Begin
    Case( compCode ) Of
      Equals         : strRet := 'Equals';
      GreaterThan    : strRet := 'GreaterThan';
      LessThan       : strRet := 'LessThan';
      CompareError   : strRet := 'CompareError';
    End;

    __CompToString := strRet;
  End;

Begin
  Write( '[', strTestName, '] ===> ' );

  If( compCode <> compExpected )  Then
    WriteLn( '[ERROR] - Value ',
             __CompToString( compCode ),
             ' expected ',
             __CompToString( compExpected ) )
  Else
    WriteLn( '[SUCCESS]' );

  TEST_BIGINT_CMP := ( compCode = compExpected );
End;
