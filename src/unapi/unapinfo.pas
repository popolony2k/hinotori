(*<unapinfo.pas>
 * UNAPI base information gathering routines.
 * All function addresses and EXTBIO function call is respecting
 * the UNAPI specification reached at Konamiman site at
 * http://www.konamiman.com.
 *
 * CopyLeft (c) 1995-2024 by PopolonY2k.
 * CopyLeft (c) since 2024 by Hinotori Team.
 *)

(*
 * This module depends on folowing include files (respect the order):
 * - /system/types.pas;
 * - /bios/msxbios.pas;
 * - /bios/extbio.pas;
 * - /unapi/unapi.pas;
 *)

const   ctNameStringSize = 63;    { Name string max size }

(**
  * UNAPI Version structure.
  *)
type TUNAPIVersion = record
  nMinor,
  nMajor   : byte;
end;

(**
  * UNAPI information.
  *)
type TUNAPIInfo = record
  strImplName     : string[ctNameStringSize];   { Implementation name }
  apiSpecVersion,                               { API spec. supported }
  apiImplVersion  : TUNAPIVersion;              { API impl. version   }
end;


(**
  * Retrieve the the implementation name and API version.
  * @param impl Reference to the implementation pointer previously found
  * by @see UNAPIGetImplementation;
  * @param info Reference to the @see TUNAPIInfo structure to receive
  * the UNAPI information;
  *)
procedure UNAPIGetInfo( var impl : TUNAPIImplPointer; var info : TUNAPIInfo );
var
     nPri,
     nSec,
     nValue,
     nCount  : byte;
     regs    : TRegs;

begin
  FillChar( regs, sizeof( regs ), 0 );
  nCount := 0;
  regs.A := 0;      { UNAPI_GET_INFO }

  UNAPICallFn( impl, regs );

  nValue := RDSLT( impl.nSlotNumber, regs.HL );

  (*
   * Retrieve the implementation name.
   *)
  while( ( nValue <> 0 ) and ( nCount < ctNameStringSize ) ) do
  begin
    info.strImplName[nCount+1] := char( nValue );
    nCount  := nCount + 1;
    nValue  := RDSLT( impl.nSlotNumber, regs.HL + nCount );
  end;

  if( nCount > 0 )  then
    info.strImplName[0] := char( nCount );

  (*
   * Get the specification and implementation
   * version.
   *)
  info.apiSpecVersion.nMinor := regs.E;
  info.apiSpecVersion.nMajor := regs.D;
  info.apiImplVersion.nMinor := regs.C;
  info.apiImplVersion.nMajor := regs.B;
end;
