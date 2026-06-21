(*<socket.pas>
 * Implementation of the independent network communication layer for
 * use with any network card present on MSX.
 * CopyLeft (c) 1995-2024 by PopolonY2k.
 * CopyLeft (c) since 2024 by Hinotori Team.
 *)

(*
 * This module depends on folowing include files (respect the order):
 * - /socket/sockdefs.pas;
 * - /callproc/funcptr.pas;
 *)


(* High level Network API *)

(**
  * Initialize the socket before to start the use of network functions.
  * @param socket The socket that will be initialized;
  * @param nInitDriverFnAddr The function address of the driver that
  * will be used to communicate using sockets;
  *)
procedure InitSocket( var socket : TSocket; nInitDriverFnAddr : integer );
var
     parms : TDriverParms;

begin
  with socket do
  begin
    Connection.nSocketHandle  := 0;
    FillChar( DriverLayer, sizeof( DriverLayer ), 0 );
  end;

  with parms do
  begin
    nInParm  := Addr( socket );
    nOutParm := 0;
  end;

  CallProc( nInitDriverFnAddr, Addr( parms ) );
end;

(**
  * Try to connect with another peer using the socket specification passed
  * by parameter.
  * @param socket The socket containing the information about the connection
  * to be stablished;
  * The function @return a @see TSocketResult return status;
  *)
function SocketConnect( var socket : TSocket ) : TSocketResult;
var
        parms      : TDriverParms;
        ResultCode : TSocketResult;

begin
  if( socket.DriverLayer.nConnectFn <> 0 )  then
  begin
    with parms do
    begin
      nInParm  := Addr( socket );
      nOutParm := Addr( ResultCode );
    end;

    CallProc( socket.DriverLayer.nConnectFn, Addr( parms ) );
  end
  else
    ResultCode := SocketNotInitialized;

  SocketConnect := ResultCode;
end;

(**
  * Disconnect from a previous session connected by @see SocketConnect
  * function;
  * @param socket The socket containing the information about the connection
  * to be disconnected;
  *)
function SocketDisconnect( var socket : TSocket ) : TSocketResult;
var
       parms      : TDriverParms;
       ResultCode : TSocketResult;

begin
  if( socket.DriverLayer.nDisconnectFn <> 0 )  then
  begin
    if( socket.Connection.nSocketHandle <> 0 )  then
    begin
      with parms do
      begin
        nInParm  := Addr( socket );
        nOutParm := Addr( ResultCode );
      end;

      CallProc( socket.DriverLayer.nDisconnectFn, Addr( parms ) );
    end
    else
      ResultCode := SocketNotConnected;
  end
  else
    ResultCode := SocketNotInitialized;

  SocketDisconnect := ResultCode;
end;

(**
  * Send a packet through the ethernet card.
  * @param socket The socket with a stablished connection with the card;
  * @param packet The packet to send to the connected peer, through the card;
  *)
function SocketSendPacket( var socket : TSocket;
                           var packet : TSocketPacket ) : TSocketResult;
var
       parms      : TDriverParms;
       ResultCode : TSocketResult;

begin
  if( socket.DriverLayer.nSendPacketFn <> 0 )  then
  begin
    if( ( socket.Connection.nSocketHandle > 0 ) or
        ( socket.Connection.SocketType = SOCK_DGRAM ) )  then
    begin
      packet.pSock := Ptr( Addr( socket ) );

      with parms do
      begin
        nInParm  := Addr( packet );
        nOutParm := Addr( ResultCode );
      end;

      CallProc( socket.DriverLayer.nSendPacketFn, Addr( parms ) );
    end
    else
      ResultCode := SocketNotConnected;
  end
  else
    ResultCode := SocketNotInitialized;

  SocketSendPacket := ResultCode;
end;

(**
  * Receive a packet from the ethernet card.
  * @param socket The socket with a stablished connection with the card;
  * @param packet The packet to receive from the connected peer;
  *)
function SocketRecvPacket( var socket : TSocket;
                           var packet : TSocketPacket ) : TSocketResult;
var
       parms      : TDriverParms;
       ResultCode : TSocketResult;

begin
  if( socket.DriverLayer.nRecvPacketFn <> 0 )  then
  begin
    if( ( socket.Connection.nSocketHandle > 0 ) or
        ( socket.Connection.SocketType = SOCK_DGRAM ) ) then
    begin
      packet.pSock := Ptr( Addr( socket ) );

      with parms do
      begin
        nInParm  := Addr( packet );
        nOutParm := Addr( ResultCode );
      end;

      CallProc( socket.DriverLayer.nRecvPacketFn, Addr( parms ) );
    end
    else
      ResultCode := SocketNotConnected;
  end
  else
    ResultCode := SocketNotInitialized;

  SocketRecvPacket := ResultCode;
end;
