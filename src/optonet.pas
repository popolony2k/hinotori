(*<optonet.pas>
 * Low level network implementation for OPTO-TECH multi-card
 * Network/RS232/SD-Card for MSX platform.
 * CopyLeft (c) since 2013 by PopolonY2k.
 *)

(**
  *
  * $Id: optonet.pas 128 2020-07-08 17:51:23Z popolony2k $
  * $Author: popolony2k $
  * $Date: 2020-07-08 14:51:23 -0300 (Wed, 08 Jul 2020) $
  * $Revision: 128 $
  * $HeadURL: https://svn.code.sf.net/p/oldskooltech/code/msx/trunk/msxdos/pascal/optonet.pas $
  *)

(*
 * This module depends on folowing include files (respect the order):
 * - systypes.pas;
 * - sleep.pas;
 * - optodrv.pas;
 * - sockdefs.pas;
 * - types.pas;
 * - helpstr.pas;
 *)

(*
 * Internal addresses and commands used by all OptoNet compatible cards.
 *)
Const
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
Function __OptoNetSetPort( nPort : Integer ) : TSocketResult;
Begin
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
End;

(**
  * Set a IP address into the board.
  * @param nCMD A valid board command to set new IP;
  * @param strAddress A valid internet address to set on the board;
  *)
Function __OptoNetSetAddress( nCMD : Byte;
                              strAddress : TIPAddress ) : TSocketResult;
Var
     aStrIPAddr  : TStringArray;
     aIntIPAddr  : Array[0..3] Of Integer;
     nCount      : Byte;
     nCode       : Integer;
     ResultCode  : TSocketResult;

Begin
  nCount := Split( strAddress, '.', aStrIPAddr );

  If( nCount = 4 )  Then
  Begin
    ResultCode := SocketSuccess;
    nCount := 0;

    While( nCount < 4 ) Do
    Begin
      Val( aStrIPAddr[nCount], aIntIPAddr[nCount], nCode );

      If( nCode <> 0 )  Then
      Begin
        nCount := 4;
        ResultCode := SocketInvalidIP;
      End
      Else
        nCount := nCount + 1;
    End;
  End
  Else
    ResultCode := SocketInvalidIP;

  { Send command to the board }
  If( ResultCode = SocketSuccess )  Then
  Begin
    __OptoClearBuffers( ctCommandPort );

    For nCount := 0 To 3 Do
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
  End;

  __OptoNetSetAddress := ResultCode;
End;

(**
  * Send a UDP data to the board.
  * @param strData The data to be sent;
  *)
Function __OptoNetSendUDPPacket( Var packet : TSocketPacket ) : TSocketResult;
Var
         nPacketAddress : Integer;
         nPacketSize,
         nCount         : Byte;
         ResultCode     : TSocketResult;

Begin
  If( packet.nSize > 0 )  Then
  Begin
    nPacketAddress := Ord( packet.pData );
    nPacketSize    := packet.nSize - 1;

    For nCount := 0 To nPacketSize Do
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
  End
  Else
    ResultCode := SocketInvalidPacket;

  __OptoNetSendUDPPacket := ResultCode;
End;

(**
  * Receive a UDP data from the board.
  * @param packet The data to be received;
  *)
Function __OptoNetRecvUDPPacket( Var packet : TSocketPacket ) : TSocketResult;
Var
         nPacketAddress : Integer;
         nPacketSize,
         nCount         : Byte;
         ResultCode     : TSocketResult;

Begin
  nPacketAddress := Ord( packet.pData );
  (* Request the buffer size to board *)
  __OptoWritePort( ctCommandPort, ctCMDRequestBufferSize );

  nPacketSize := __OptoReadPort( ctDataPort );

  If( nPacketSize > 0 )  Then
  Begin
    packet.nSize := nPacketSize;
    nPacketSize  := nPacketSize - 1;

    For nCount := 0 To nPacketSize Do
      Mem[nPacketAddress + nCount] := __OptoReadPort( ctDataPort );
  End;

  (*
   * FIXME:
   * The Wait() below exist because there problems on the current
   * firmware to process commands at full speed call.
   * This will be fixed until the end of OptoNet network development.
   *)
  Sleep( ctCommandPortWait );

  ResultCode := SocketSuccess;

  __OptoNetRecvUDPPacket := ResultCode;
End;

(*
 * Driver functions to provide abstract socket compatibility.
 *)

(**
  * Function provided by OptoNet driver to provide socket connection.
  * @param nDriverParms The pointer to the @see TDriverParms struct
  * containing the driver input and output parameters;
  *)
Procedure __OptoNetDrvConnect( nDriverParms : Integer );
Var
       pParms      : PDriverParms;
       pSock       : PSocket;
       pResult     : PSocketResult;
Begin
  pParms := Ptr( nDriverParms );

  With pParms^ Do
  Begin
    pSock   := Ptr( nInParm );
    pResult := Ptr( nOutParm );

    With pSock^ Do
    Begin
      Connection.nSocketHandle := 0;
      pResult^ := __OptoNetSetPort( nPort );

      If( pResult^ = SocketSuccess )  Then
      Begin
        pResult^ := __OptoNetSetAddress( ctCMDSetRemoteIPAddr, strIPAddress );

        If( pResult^ = SocketSuccess )  Then
          Connection.nSocketHandle := 1;   { Simulating a valid handle }
      End;
    End;
  End;
End;

(**
  * Function provided by OptoNet driver to provide socket Disconnection.
  * @param nDriverParms The pointer to the @see TDriverParms struct
  * containing the driver input and output parameters;
  *)
Procedure __OptoNetDrvDisconnect( nDriverParms : Integer );
Var
       pParms      : PDriverParms;
       pSock       : PSocket;
       pResult     : PSocketResult;
Begin
  pParms := Ptr( nDriverParms );

  With pParms^ Do
  Begin
    pSock   := Ptr( nInParm );
    pResult := Ptr( nOutParm );

    With pSock^ Do
    Begin
      Connection.nSocketHandle := 0;
      pResult^ := SocketSuccess;
    End;
  End;
End;

(**
  * Function provided by OptoNet driver to provide send a information
  * through a socket.
  * @param nDriverParms The pointer to the @see TDriverParms struct
  * containing the driver input and output parameters;
  *)
Procedure __OptoNetDrvSendPacket( nDriverParms : Integer );
Var
       pParms      : PDriverParms;
       pPacket     : PSocketPacket;
       pResult     : PSocketResult;
Begin
  pParms := Ptr( nDriverParms );

  With pParms^ Do
  Begin
    pPacket := Ptr( nInParm );
    pResult := Ptr( nOutParm );

    If( pPacket^.pSock^.Connection.SocketType = SOCK_DGRAM )  Then
      pResult^ := __OptoNetSendUDPPacket( pPacket^ )
    Else
      pResult^ := SocketNotImplemented;
  End;
End;

(**
  * Function provided by OptoNet driver to provide receive a information
  * from the socket.
  * @param nDriverParms The pointer to the @see TDriverParms struct
  * containing the driver input and output parameters;
  *)
Procedure __OptoNetDrvRecvPacket( nDriverParms : Integer );
Var
       pParms      : PDriverParms;
       pPacket     : PSocketPacket;
       pResult     : PSocketResult;
Begin
  pParms := Ptr( nDriverParms );

  With pParms^ Do
  Begin
    pPacket := Ptr( nInParm );
    pResult := Ptr( nOutParm );

    If( pPacket^.pSock^.Connection.SocketType = SOCK_DGRAM )  Then
      pResult^ := __OptoNetRecvUDPPacket( pPacket^ )
    Else
      pResult^ := SocketNotImplemented;
  End;
End;

(**
  * Function provided by OptoNet driver to provide socket initialization.
  * @param nDriverParms The pointer to the @see TDriverParms struct
  * containing the driver input and output parameters;
  *)
Procedure OptoNetDrvSocketInit( nDriverParms : Integer );
Var
       pParms    : PDriverParms;
       pSock     : PSocket;
Begin
  pParms := Ptr( nDriverParms );

  With pParms^ Do
  Begin
    pSock := Ptr( nInParm );

    With pSock^ Do
    Begin
      DriverLayer.nConnectFn    := Addr( __OptoNetDrvConnect );
      DriverLayer.nDisconnectFn := Addr( __OptoNetDrvDisconnect );
      DriverLayer.nSendPacketFn := Addr( __OptoNetDrvSendPacket );
      DriverLayer.nRecvPacketFn := Addr( __OptoNetDrvRecvPacket );;
    End;
  End;
End;
