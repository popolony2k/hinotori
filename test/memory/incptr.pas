(*<incptr.pas>
 * Implement unit tests and sample for using the Big Numbers
 * library <bigint.pas>, using TUint24.
 * Unit tests for :
 *   1) Pointer operations;
 *   2 & 3) TBigInt conversions;
 *
 * CopyLeft (c) 1995-2024 by PopolonY2k.
 * CopyLeft (c) since 2024 by Hinotori Team.
 *)
program TestIncPtr;

(*
 * This source file depends on following include files (respect the order):
 * - /system/types.pas;
 * - /memory/pointer.pas;
 *)

{$i ..\..\src\system\types.pas}
{$i ..\..\src\memory\pointer.pas}
{$i ..\..\src\ptest\ptest.pas}


(**
  * Internal data structure definition for testing.
  *)
type PTestData = ^TTestData;
     TTestData = record
  strData  : TTinyString;
  bBoolVal : boolean;
end;


(**
  * Test the IncPtr implementation.
  *)
procedure IncPtrTest;

const __ctMaxItems = 10;

var
      strMsg      : TTinyString;
      strExpected : TTinyString;
      pData       : PTestData;
      pPointer    : TPointer;
      bRet        : boolean;
      bExpected   : boolean;
      nCounter    : byte;
      aData       : array [0..__ctMaxItems] of TTestData;
      boolSet     : array[false..true] of string[6];


  (**
    * Get expected bool value based on nCount parameter;
    * @param nCount Counter parameter to generate expected bool;
    *)
  function __GetExpectedBool( nCount : byte ) : boolean;
  begin
    __GetExpectedBool := ( ( nCount mod 2 ) <> 0 );
  end;

  (**
    * Get expected string value based on nCount parameter;
    * @param nCount Counter parameter to generate expected string;
    *)
  function __GetExpectedString( nCount : byte ) : TTinyString;
   begin
     __GetExpectedString := 'ABC - ' + char( ( nCount + byte( '0' ) ) );
  end;

  (**
    * Setup test.
    *)
  procedure __SetupTest;
  var 
        nCounter : byte;

  begin
    boolSet[true]  := 'true';
    boolSet[false] := 'false';

    for nCounter := 0 to __ctMaxItems do
    begin
      aData[nCounter].strData  := __GetExpectedString( nCounter );
      aData[nCounter].bBoolVal := __GetExpectedBool( nCounter );
    end;
  end;

(*
 * IncPtrTest main entry point.
 *)
begin
  __SetupTest;

  TRACE( 'IncPtrTest() - Incrementing pointer test' );

  bRet     := true;
  nCounter := 0;
  pPointer := ToPointer( aData );

  while( ( nCounter < __ctMaxItems ) and bRet ) do
  begin
    Move( pPointer, pData, sizeof( pPointer ) );
    strExpected := __GetExpectedString( nCounter );
    strMsg := 'strData test ( "' + pData^.strData + 
              '" == "' + strExpected + '" )';
    bRet   := TEST_STR( strMsg, pData^.strData, strExpected );

    if( not bRet )  then
      Exit;
  
    bExpected := __GetExpectedBool( nCounter );
    strMsg := 'bBoolVal ( "' + boolSet[pData^.bBoolVal] + 
              '" == "' + boolSet[bExpected] + '" )';
    bRet := TEST_BOOL( strMsg, pData^.bBoolVal, bExpected );

    if( not bRet )  then
      Exit;

    IncPtr( pPointer, sizeof( TTestData ) );
    nCounter := Succ( nCounter );
  end;

  TRACELN;
end;

(*
 * Main test entry point.
 *)
begin
  IncPtrTest;
end.