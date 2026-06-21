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
function TEST_OP( strTestName : TTinyString;
                  opRetValue, opExpected : TOperationCode ) : boolean;
  (**
    * Helper function to convert a @see TOperationCode value to
    * String representation.
    * @param opValue The TOperationCode to convert;
    *)
  function __OpToString( opValue : TOperationCode ) : TTinyString;
  var
        strRet : TTinyString;
  begin
    case( opValue ) of
      Success           : strRet := 'Success';
      Overflow          : strRet := 'Overflow';
      Underflow         : strRet := 'Underflow';
      InvalidNumber     : strRet := 'InvalidNumber';
      NoMemoryAvailable : strRet := 'NoMemoryAvailable';
      IncompatibleParms : strRet := 'IncompatibleParameters';
      NotImplemented    : strRet := 'NotImplemented';
    end;

    __OpToString := strRet;
  end;

begin
  Write( '[', strTestName, '] ===> ' );

  if( opRetValue <> opExpected )  then
    WriteLn( '[ERROR] - Value ',
             __OpToString( opRetValue ),
             ' expected ',
             __OpToString( opExpected ) )
  else
    WriteLn( '[SUCCESS]' );

  TEST_OP := ( opRetValue = opExpected );
end;

(**
  * Unit test helper function to check expected value for reported
  * TBigInt comparision passed by parameter;
  * @param strTestName The name of test to be printed at screen report;
  * @param compCode The value reported by last math comparision code;
  * @param compExpected The expected value for the last math comparision
  * operation;
  * The function return true if compCode is equal compExpected;
  *)
function TEST_BIGINT_CMP( strTestName : TTinyString;
                          compCode, compExpected : TCompareCode ) : boolean;
  (**
    * Helper function to convert a @see TCompareCode value to
    * String representation.
    * @param compCode The TCompareCode to convert;
    *)
  function __CompToString( compCode : TCompareCode ) : TTinyString;
  var
        strRet : TTinyString;
  begin
    case( compCode ) of
      Equals         : strRet := 'Equals';
      GreaterThan    : strRet := 'GreaterThan';
      LessThan       : strRet := 'LessThan';
      CompareError   : strRet := 'CompareError';
    end;

    __CompToString := strRet;
  end;

begin
  Write( '[', strTestName, '] ===> ' );

  if( compCode <> compExpected )  then
    WriteLn( '[ERROR] - Value ',
             __CompToString( compCode ),
             ' expected ',
             __CompToString( compExpected ) )
  else
    WriteLn( '[SUCCESS]' );

  TEST_BIGINT_CMP := ( compCode = compExpected );
end;
