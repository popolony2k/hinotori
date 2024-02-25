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
Procedure InitSocket( Var socket : TSocket; nInitDriverFnAddr : Integer );
Var
     parms : TDriverParms;

Begin
  With socket Do
  Begin
    Connection.nSocketHandle  := 0;
    FillChar( DriverLayer, SizeOf( DriverLayer ), 0 );
  End;

  With parms Do
  Begin
    nInParm  := Addr( socket );
    nOutParm := 0;
  End;

  CallProc( nInitDriverFnAddr, Addr( parms ) );
End;

(**
  * Try to connect with another peer using the socket specification passed
  * by parameter.
  * @param socket The socket containing the information about the connection
  * to be stablished;
  * The function @return a @see TSocketResult return status;
  *)
Function SocketConnect( Var socket : TSocket ) : TSocketResult;
Var
        parms      : TDriverParms;
        ResultCode : TSocketResult;

Begin
  If( socket.DriverLayer.nConnectFn <> 0 )  Then
  Begin
    With parms Do
    Begin
      nInParm  := Addr( socket );
      nOutParm := Addr( ResultCode );
    End;

    CallProc( socket.DriverLayer.nConnectFn, Addr( parms ) );
  End
  Else
    ResultCode := SocketNotInitialized;

  SocketConnect := ResultCode;
End;

(**
  * Disconnect from a previous session connected by @see SocketConnect
  * function;
  * @param socket The socket containing the information about the connection
  * to be disconnected;
  *)
Function SocketDisconnect( Var socket : TSocket ) : TSocketResult;
Var
       parms      : TDriverParms;
       ResultCode : TSocketResult;

Begin
  If( socket.DriverLayer.nDisconnectFn <> 0 )  Then
  Begin
    If( socket.Connection.nSocketHandle <> 0 )  Then
    Begin
      With parms Do
      Begin
        nInParm  := Addr( socket );
        nOutParm := Addr( ResultCode );
      End;

      CallProc( socket.DriverLayer.nDisconnectFn, Addr( parms ) );
    End
    Else
      ResultCode := SocketNotConnected;
  End
  Else
    ResultCode := SocketNotInitialized;

  SocketDisconnect := ResultCode;
End;

(**
  * Send a packet through the ethernet card.
  * @param socket The socket with a stablished connection with the card;
  * @param packet The packet to send to the connected peer, through the card;
  *)
Function SocketSendPacket( Var socket : TSocket;
                           Var packet : TSocketPacket ) : TSocketResult;
Var
       parms      : TDriverParms;
       ResultCode : TSocketResult;

Begin
  If( socket.DriverLayer.nSendPacketFn <> 0 )  Then
  Begin
    If( ( socket.Connection.nSocketHandle > 0 ) Or
        ( socket.Connection.SocketType = SOCK_DGRAM ) )  Then
    Begin
      packet.pSock := Ptr( Addr( socket ) );

      With parms Do
      Begin
        nInParm  := Addr( packet );
        nOutParm := Addr( ResultCode );
      End;

      CallProc( socket.DriverLayer.nSendPacketFn, Addr( parms ) );
    End
    Else
      ResultCode := SocketNotConnected;
  End
  Else
    ResultCode := SocketNotInitialized;

  SocketSendPacket := ResultCode;
End;

(**
  * Receive a packet from the ethernet card.
  * @param socket The socket with a stablished connection with the card;
  * @param packet The packet to receive from the connected peer;
  *)
Function SocketRecvPacket( Var socket : TSocket;
                           Var packet : TSocketPacket ) : TSocketResult;
Var
       parms      : TDriverParms;
       ResultCode : TSocketResult;

Begin
  If( socket.DriverLayer.nRecvPacketFn <> 0 )  Then
  Begin
    If( ( socket.Connection.nSocketHandle > 0 ) Or
        ( socket.Connection.SocketType = SOCK_DGRAM ) ) Then
    Begin
      packet.pSock := Ptr( Addr( socket ) );

      With parms Do
      Begin
        nInParm  := Addr( packet );
        nOutParm := Addr( ResultCode );
      End;

      CallProc( socket.DriverLayer.nRecvPacketFn, Addr( parms ) );
    End
    Else
      ResultCode := SocketNotConnected;
  End
  Else
    ResultCode := SocketNotInitialized;

  SocketRecvPacket := ResultCode;
End;
