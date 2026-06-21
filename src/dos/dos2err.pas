(*<dos2err.pas>
 * Wrapper to MSXDOS2 error messages management calls.
 * CopyLeft (c) 1995-2024 by PopolonY2k.
 * CopyLeft (c) since 2024 by Hinotori Team.
 *)

(*
 * This module depends on folowing include files (respect the order):
 * - /system/memory.pas;
 * - /system/types.pas;
 * - /dos/msxdos.pas;
 * - /dos/msxdos2.pas;
 *)

const       ctMSXDOSMsgSize = 65;  { Error message buffer size }


(**
  * MSXDOS error and message string.
  *)
type TMSXDOSString = string[ctMSXDOSMsgSize];


(**
  * Get the error code, caused by the previous MSX-DOS function call.
  *)
function GetLastErrorCode : byte;
var
       regs  : TRegs;

begin
  regs.C := ctGetPreviousErrorCode;
  MSXBDOS( regs );
  GetLastErrorCode := regs.B;
end;

(**
  * Get the error message based on MSX-DOS error code passed by
  * parameter;
  * @param nErrorCode The error code to get the message string;
  * @param strErrMsg A reference to string that will receive the error
  * message;
  *)
procedure GetErrorMessage( nErrorCode : byte; var strErrMsg : TMSXDOSString );
var
      regs      : TRegs;
      szErrMsg  : array[0..ctMSXDOSMsgSize] of char;
      nZeroPos  : byte;

begin
  strErrMsg := '';
  regs.C    := ctExplainErrorCode;
  regs.B    := nErrorCode;
  regs.DE   := Addr( szErrMsg );
  MSXBDOS( regs );

  if( ( regs.B = 0 ) or ( regs.B = nErrorCode ) )  then
  begin
    nZeroPos := Pos( #0, szErrMsg );

    if( nZeroPos > 0 )  then
    begin
      strErrMsg[0] := char( nZeroPos );
      Move( szErrMsg, strErrMsg[1], nZeroPos );
    end;
  end;
end;
