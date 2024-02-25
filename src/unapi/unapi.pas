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
Const      ctERR_OK           = 0;    { Operation completed successfully }
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
Const     ctSpecEthernet      = 'ETHERNET';   { Ethernet specification }
          ctSpecTCPIP         = 'TCP/IP';     { TCP/IP specification }

(**
  * The specification identifier string name.
  *)
Type TUNAPISpecName = String[15];  { UNAPI specification identifier }

(**
  * The UNAPI implmementation pointer structure to store the
  * implementation address functions.
  *)
Type TUNAPIImplPointer = Record
  nSlotNumber     : TSlotNumber;
  nRAMSegment     : Byte;
  nEntryPointAddr : Integer;
End;


(**
  * Retrieve the total number of implementations available for the specified
  * specification;
  * @param strSpecName The UNAPI specification to search;
  *)
Function UNAPIDiscovery( strSpecName : TUNAPISpecName ) : Byte;
Var
     nCount,
     nLen      : Byte;
     regs      : TRegs;
     aARG      : Array[0..15] Of Char Absolute $F847;

Begin
  regs.B := 0;

  If( HasInstalledHook And ( strSpecName <> '' ) )  Then
  Begin
    regs.A := 0;
    regs.D := ctUNAPI;
    regs.E := ctUNAPI;
    nLen   := Length( strSpecName ) - 1;

    (*
     * Fill the specification parameter to pass to the discovery
     * function.
     * The ARG parameter is pointed by $F847 (16 byte Math pack buffer).
     *)
    For nCount := 0 To nLen Do
      aARG[nCount] := strSpecName[nCount+1];

    aARG[nCount+1] := #0;

    EXTBIO( regs );
  End;

  UNAPIDiscovery := regs.B;
End;

(**
  * Retrieve the implementation structure with the address for the required
  * implementation specification.
  * @param strSpecName The UNAPI specification to search;
  * @param impl The UNAPI @see TUNAPIImplPointer struct with the
  * implementation address routines to be called by user;
  *)
Function UNAPIGetImplementation( strSpecName : TUNAPISpecName;
                                 nImplIndex  : Byte;
                                 Var impl    : TUNAPIImplPointer ) : Boolean;
Var
     nCount,
     nLen      : Byte;
     regs      : TRegs;
     bRet      : Boolean;
     aARG      : Array[0..15] Of Char Absolute $F847;

Begin
  If( HasInstalledHook And ( strSpecName <> '' ) And ( nImplIndex > 0 ) )  Then
  Begin
    regs.A := nImplIndex;
    regs.D := ctUNAPI;
    regs.E := ctUNAPI;
    nLen   := Length( strSpecName ) - 1;
    bRet   := True;

    (*
     * Fill the specification parameter to pass to the discovery
     * function.
     * The ARG parameter is pointed by $F847 (16 byte Math pack buffer).
     *)
    For nCount := 0 To nLen Do
      aARG[nCount] := strSpecName[nCount+1];

    aARG[nCount+1] := #0;

    EXTBIO( regs );

    With impl Do
    Begin
      nSlotNumber := regs.A;
      nRAMSegment := regs.B;
      nEntryPointAddr := regs.HL;
    End;
  End
  Else
    bRet := False;

  UNAPIGetImplementation := bRet;

End;

{ UNAPI RAM Helper and Caller functions }

(**
  * Perform a UNAPI function call, and "automagically" choose the better way
  * to call the function, using direct call or the RAM Helper functions.
  * @param impl The pointer to the UNAPI implementation functions;
  * @param regs The parameters to pass to the UNAPI function called;
  *)
Procedure UNAPICallFn( Var impl : TUNAPIImplPointer; Var regs : TRegs );
Begin
  (*
   * Perform a inter-slot call.
   *)
  If( impl.nRAMSegment = $FF )  Then
  Begin
    regs.IY := impl.nSlotNumber;
    regs.IX := impl.nEntryPointAddr;
    CALSLT( regs );
  End
  Else
  Begin
    WriteLn( '-------------------------------------------' );
    WriteLn( 'RAM Helper segment implementation not ready' );
    WriteLn( '-------------------------------------------' );
    { TODO: RAMHelper call implementation }
  End;
End;
