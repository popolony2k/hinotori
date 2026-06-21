(*<optonet.pas>
 * Low level network implementation for OPTO-TECH multi-card
 * Network/RS232/SD-Card for MSX platform.
 * CopyLeft (c) 1995-2024 by PopolonY2k.
 * CopyLeft (c) since 2024 by Hinotori Team.
 *)

(*
 * This module depends on folowing include files (respect the order):
 * - /system/systypes.pas;
 * - /timer/sleep.pas;
 * - /comm/optonet/optodrv.pas;
 * - /socket/sockdefs.pas;
 * - /system/types.pas;
 * - /util/helpstr.pas;
 *)

(*
 * Internal addresses and commands used by all OptoNet compatible cards.
 *)
const
           { Ethernet commands }
           ctCMDSetIPAddr         = 30;   { Set a new board IP address }
           ctCMDSetGatewayAddr    = 35;   { Set gateway IP address }
           ctCMDResetIPAddr       = ctCMDResetToDefault; { Reset to default }
                                                         { IP address       }
           ctCMDSetRemoteIPAddr   = 45;   { Set remote IP address }
           ctCMDSetPort           = 47;   { Set port (default 10001) }
           ctCMDSendUDPPacket     = 50;   { Send a UDP packet }
           ctCMDResolveDNS        = 60;   { Resolve DNS }

           { SD Card communication }
           ctCMDSDCardOn          = 10;   { Turn SDCard On and disable }
                                          { serial and ethernet modes }

(* Low level board functions. Don't use this directly. *)

(**
  * Set the port to use in the next call to @link __OptoNetSetAddress();
  * @param nPort The port to set;
  *)
function __OptoNetSetPort( nPort : integer ) : TSocketResult;
begin
  __OptoClearBuffers( ctCommandPort );
  __OptoWritePort( ctDataPort, Hi( nPort ) );   { Local port }
  __OptoWritePort( ctDataPort, Lo( nPort ) );
  __OptoWritePort( ctDataPort, Hi( nPort ) );   { Remote port }
  __OptoWritePort( ctDataPort, Lo( nPort ) );
  __OptoWritePort( ctCommandPort, ctCMDSetPort );

  (*
   * FIXME:
   * The Wait() below exist because there problems on the current
   * firmware to process commands at full speed call.
   * This will be fixed until the end of OptoNet network development.
   *)
  Sleep( ctCommandPortWait );

  __OptoNetSetPort := SocketSuccess;
end;

(**
  * Set a IP address into the board.
  * @param nCMD A valid board command to set new IP;
  * @param strAddress A valid internet address to set on the board;
  *)
function __OptoNetSetAddress( nCMD : byte;
                              strAddress : TIPAddress ) : TSocketResult;
var
     aStrIPAddr  : TStringArray;
     aIntIPAddr  : array[0..3] of integer;
     nCount      : byte;
     nCode       : integer;
     ResultCode  : TSocketResult;

begin
  nCount := Split( strAddress, '.', aStrIPAddr );

  if( nCount = 4 )  then
  begin
    ResultCode := SocketSuccess;
    nCount := 0;

    while( nCount < 4 ) do
    begin
      Val( aStrIPAddr[nCount], aIntIPAddr[nCount], nCode );

      if( nCode <> 0 )  then
      begin
        nCount := 4;
        ResultCode := SocketInvalidIP;
      end
      else
        nCount := nCount + 1;
    end;
  end
  else
    ResultCode := SocketInvalidIP;

  { Send command to the board }
  if( ResultCode = SocketSuccess )  then
  begin
    __OptoClearBuffers( ctCommandPort );

    for nCount := 0 to 3 do
      __OptoWritePort( ctDataPort, aIntIPAddr[nCount] );

    __OptoWritePort( ctCommandPort, nCMD );

    (*
     * FIXME:
     * The Wait() below exist because there problems on the current
     * firmware to process commands at full speed call.
     * This will be fixed until the end of OptoNet network development.
     *)
    Sleep( ctCommandPortWait );

    __OptoClearBuffers( ctCommandPort );
  end;

  __OptoNetSetAddress := ResultCode;
end;

(**
  * Send a UDP data to the board.
  * @param strData The data to be sent;
  *)
function __OptoNetSendUDPPacket( var packet : TSocketPacket ) : TSocketResult;
var
         nPacketAddress : integer;
         nPacketSize,
         nCount         : byte;
         ResultCode     : TSocketResult;

begin
  if( packet.nSize > 0 )  then
  begin
    nPacketAddress := Ord( packet.pData );
    nPacketSize    := packet.nSize - 1;

    for nCount := 0 to nPacketSize do
      __OptoWritePort( ctDataPort, Mem[nPacketAddress + nCount] );

    __OptoWritePort( ctCommandPort, ctCMDSendUDPPacket );

    ResultCode := SocketSuccess;

    (*
     * FIXME:
     * The Wait() below exist because there problems on the current
     * firmware to process commands at full speed call.
     * This will be fixed until the end of OptoNet network development.
     *)
    Sleep( ctCommandPortWait );
  end
  else
    ResultCode := SocketInvalidPacket;

  __OptoNetSendUDPPacket := ResultCode;
end;

(**
  * Receive a UDP data from the board.
  * @param packet The data to be received;
  *)
function __OptoNetRecvUDPPacket( var packet : TSocketPacket ) : TSocketResult;
var
         nPacketAddress : integer;
         nPacketSize,
         nCount         : byte;
         ResultCode     : TSocketResult;

begin
  nPacketAddress := Ord( packet.pData );
  (* Request the buffer size to board *)
  __OptoWritePort( ctCommandPort, ctCMDRequestBufferSize );

  nPacketSize := __OptoReadPort( ctDataPort );

  if( nPacketSize > 0 )  then
  begin
    packet.nSize := nPacketSize;
    nPacketSize  := nPacketSize - 1;

    for nCount := 0 to nPacketSize do
      Mem[nPacketAddress + nCount] := __OptoReadPort( ctDataPort );
  end;

  (*
   * FIXME:
   * The Wait() below exist because there problems on the current
   * firmware to process commands at full speed call.
   * This will be fixed until the end of OptoNet network development.
   *)
  Sleep( ctCommandPortWait );

  ResultCode := SocketSuccess;

  __OptoNetRecvUDPPacket := ResultCode;
end;

(*
 * Driver functions to provide abstract socket compatibility.
 *)

(**
  * Function provided by OptoNet driver to provide socket connection.
  * @param nDriverParms The pointer to the @see TDriverParms struct
  * containing the driver input and output parameters;
  *)
procedure __OptoNetDrvConnect( nDriverParms : integer );
var
       pParms      : PDriverParms;
       pSock       : PSocket;
       pResult     : PSocketResult;
begin
  pParms := Ptr( nDriverParms );

  with pParms^ do
  begin
    pSock   := Ptr( nInParm );
    pResult := Ptr( nOutParm );

    with pSock^ do
    begin
      Connection.nSocketHandle := 0;
      pResult^ := __OptoNetSetPort( nPort );

      if( pResult^ = SocketSuccess )  then
      begin
        pResult^ := __OptoNetSetAddress( ctCMDSetRemoteIPAddr, strIPAddress );

        if( pResult^ = SocketSuccess )  then
          Connection.nSocketHandle := 1;   { Simulating a valid handle }
      end;
    end;
  end;
end;

(**
  * Function provided by OptoNet driver to provide socket Disconnection.
  * @param nDriverParms The pointer to the @see TDriverParms struct
  * containing the driver input and output parameters;
  *)
procedure __OptoNetDrvDisconnect( nDriverParms : integer );
var
       pParms      : PDriverParms;
       pSock       : PSocket;
       pResult     : PSocketResult;
begin
  pParms := Ptr( nDriverParms );

  with pParms^ do
  begin
    pSock   := Ptr( nInParm );
    pResult := Ptr( nOutParm );

    with pSock^ do
    begin
      Connection.nSocketHandle := 0;
      pResult^ := SocketSuccess;
    end;
  end;
end;

(**
  * Function provided by OptoNet driver to provide send a information
  * through a socket.
  * @param nDriverParms The pointer to the @see TDriverParms struct
  * containing the driver input and output parameters;
  *)
procedure __OptoNetDrvSendPacket( nDriverParms : integer );
var
       pParms      : PDriverParms;
       pPacket     : PSocketPacket;
       pResult     : PSocketResult;
begin
  pParms := Ptr( nDriverParms );

  with pParms^ do
  begin
    pPacket := Ptr( nInParm );
    pResult := Ptr( nOutParm );

    if( pPacket^.pSock^.Connection.SocketType = SOCK_DGRAM )  then
      pResult^ := __OptoNetSendUDPPacket( pPacket^ )
    else
      pResult^ := SocketNotImplemented;
  end;
end;

(**
  * Function provided by OptoNet driver to provide receive a information
  * from the socket.
  * @param nDriverParms The pointer to the @see TDriverParms struct
  * containing the driver input and output parameters;
  *)
procedure __OptoNetDrvRecvPacket( nDriverParms : integer );
var
       pParms      : PDriverParms;
       pPacket     : PSocketPacket;
       pResult     : PSocketResult;
begin
  pParms := Ptr( nDriverParms );

  with pParms^ do
  begin
    pPacket := Ptr( nInParm );
    pResult := Ptr( nOutParm );

    if( pPacket^.pSock^.Connection.SocketType = SOCK_DGRAM )  then
      pResult^ := __OptoNetRecvUDPPacket( pPacket^ )
    else
      pResult^ := SocketNotImplemented;
  end;
end;

(**
  * Function provided by OptoNet driver to provide socket initialization.
  * @param nDriverParms The pointer to the @see TDriverParms struct
  * containing the driver input and output parameters;
  *)
procedure OptoNetDrvSocketInit( nDriverParms : integer );
var
       pParms    : PDriverParms;
       pSock     : PSocket;
begin
  pParms := Ptr( nDriverParms );

  with pParms^ do
  begin
    pSock := Ptr( nInParm );

    with pSock^ do
    begin
      DriverLayer.nConnectFn    := Addr( __OptoNetDrvConnect );
      DriverLayer.nDisconnectFn := Addr( __OptoNetDrvDisconnect );
      DriverLayer.nSendPacketFn := Addr( __OptoNetDrvSendPacket );
      DriverLayer.nRecvPacketFn := Addr( __OptoNetDrvRecvPacket );;
    end;
  end;
end;
