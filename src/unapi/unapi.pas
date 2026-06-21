(*<unapi.pas>
 * UNAPI base discovery and specification implementation.
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
 *)

(*
 * UNAPI error codes. The codes below is according TCP/IP UNAPI specification
 * item 3.
 *)
const      ctERR_OK           = 0;    { Operation completed successfully }
           ctERR_NOT_IMP      = 1;    { Capability not implemented }
           ctERR_NO_NETWORK   = 2;    { No network connection available }
           ctERR_NO_DATA      = 3;    { No incoming data available }
           ctERR_INV_PARAM    = 4;    { Invalid input parameter }
           ctERR_QUERY_EXISTS = 5;    { Another query is already in progress }
           ctERR_INV_IP       = 6;    { Invalid IP address }
           ctERR_NO_DNS       = 7;    { No DNS servers are configured }
           ctERR_DNS          = 8;    { Error returned by DNS server }
           ctERR_NO_FREE_CONN = 9;    { No free connections available }
           ctERR_CONN_EXISTS  = 10;   { Connection already exists }
           ctERR_NO_CONN      = 11;   { Connection does not exists }
           ctERR_CONN_STATE   = 12;   { Invalid connection state }
           ctERR_BUFFER       = 13;   { Insufficient output buffer space }
           ctERR_LARGE_DGRAM  = 14;   { Datagram is too large }
           ctERR_INV_OPER     = 15;   { Invalid operation }

(**
  * Standard specifications available.
  *)
const     ctSpecEthernet      = 'ETHERNET';   { Ethernet specification }
          ctSpecTCPIP         = 'TCP/IP';     { TCP/IP specification }

(**
  * The specification identifier string name.
  *)
type TUNAPISpecName = string[15];  { UNAPI specification identifier }

(**
  * The UNAPI implmementation pointer structure to store the
  * implementation address functions.
  *)
type TUNAPIImplPointer = record
  nSlotNumber     : TSlotNumber;
  nRAMSegment     : byte;
  nEntryPointAddr : integer;
end;


(**
  * Retrieve the total number of implementations available for the specified
  * specification;
  * @param strSpecName The UNAPI specification to search;
  *)
function UNAPIDiscovery( strSpecName : TUNAPISpecName ) : byte;
var
     nCount,
     nLen      : byte;
     regs      : TRegs;
     aARG      : array[0..15] of char absolute $F847;

begin
  regs.B := 0;

  if( HasInstalledHook and ( strSpecName <> '' ) )  then
  begin
    regs.A := 0;
    regs.D := ctUNAPI;
    regs.E := ctUNAPI;
    nLen   := Length( strSpecName ) - 1;

    (*
     * Fill the specification parameter to pass to the discovery
     * function.
     * The ARG parameter is pointed by $F847 (16 byte Math pack buffer).
     *)
    for nCount := 0 to nLen do
      aARG[nCount] := strSpecName[nCount+1];

    aARG[nCount+1] := #0;

    EXTBIO( regs );
  end;

  UNAPIDiscovery := regs.B;
end;

(**
  * Retrieve the implementation structure with the address for the required
  * implementation specification.
  * @param strSpecName The UNAPI specification to search;
  * @param impl The UNAPI @see TUNAPIImplPointer struct with the
  * implementation address routines to be called by user;
  *)
function UNAPIGetImplementation( strSpecName : TUNAPISpecName;
                                 nImplIndex  : byte;
                                 var impl    : TUNAPIImplPointer ) : boolean;
var
     nCount,
     nLen      : byte;
     regs      : TRegs;
     bRet      : boolean;
     aARG      : array[0..15] of char absolute $F847;

begin
  if( HasInstalledHook and ( strSpecName <> '' ) and ( nImplIndex > 0 ) )  then
  begin
    regs.A := nImplIndex;
    regs.D := ctUNAPI;
    regs.E := ctUNAPI;
    nLen   := Length( strSpecName ) - 1;
    bRet   := true;

    (*
     * Fill the specification parameter to pass to the discovery
     * function.
     * The ARG parameter is pointed by $F847 (16 byte Math pack buffer).
     *)
    for nCount := 0 to nLen do
      aARG[nCount] := strSpecName[nCount+1];

    aARG[nCount+1] := #0;

    EXTBIO( regs );

    with impl do
    begin
      nSlotNumber := regs.A;
      nRAMSegment := regs.B;
      nEntryPointAddr := regs.HL;
    end;
  end
  else
    bRet := false;

  UNAPIGetImplementation := bRet;

end;

{ UNAPI RAM Helper and Caller functions }

(**
  * Perform a UNAPI function call, and "automagically" choose the better way
  * to call the function, using direct call or the RAM Helper functions.
  * @param impl The pointer to the UNAPI implementation functions;
  * @param regs The parameters to pass to the UNAPI function called;
  *)
procedure UNAPICallFn( var impl : TUNAPIImplPointer; var regs : TRegs );
begin
  (*
   * Perform a inter-slot call.
   *)
  if( impl.nRAMSegment = $FF )  then
  begin
    regs.IY := impl.nSlotNumber;
    regs.IX := impl.nEntryPointAddr;
    CALSLT( regs );
  end
  else
  begin
    WriteLn( '-------------------------------------------' );
    WriteLn( 'RAM Helper segment implementation not ready' );
    WriteLn( '-------------------------------------------' );
    { TODO: RAMHelper call implementation }
  end;
end;
