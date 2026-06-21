(*<sockdefs.pas>
 * PopolonY2k socket abstract implementation to use on MSX platform.
 * CopyLeft (c) 1995-2024 by PopolonY2k.
 * CopyLeft (c) since 2024 by Hinotori Team.
 *)

(*
 * This module depends on folowing include files (respect the order):
 * -
 *)


(* Internet module definitions *)

type TIPAddress     = string[15];                  { IP Addr. representation }
     TSocketTypes   = ( SOCK_DGRAM, SOCK_STREAM ); { Socket types }
     TSocketResult  = ( SocketSuccess,             { Network result codes }
                        SocketError,
                        SocketTimeoutReached,
                        SocketNotInitialized,
                        SocketNotConnected,
                        SocketInvalidIP,
                        SocketInvalidPacket,
                        SocketInvalidGateway,
                        SocketPortAlreadyInUse,
                        SocketNotImplemented );
     PSocketResult  = ^TSocketResult;

const            INADDR_ANY       : TIPAddress = '0.0.0.0';
                 INADDR_LOOPBACK  : TIPAddress = '127.0.0.1';
                 INADDR_NONE      : TIPAddress = '255.255.255.255';

(* Driver layer definitions *)

(**
  * Driver functions to be registered by specific driver layer and that
  * will be used on each socket;
  *)
type TNetworkDriverLayer = record
  nConnectFn,
  nDisconnectFn,
  nSendPacketFn,
  nRecvPacketFn : integer;
end;

(**
  * Strucuture to pass and receive parameters from driver functions.
  *)
type TDriverParms = record
  nInParm,
  nOutParm      : integer;
end;

type PDriverParms = ^TDriverParms;

(* Network layer definitions *)

(**
  * Socket handle specification.
  *)
type TSocketHandle = record
  nSocketHandle    : integer;     { Future use to communicate with the board }
  SocketType       : TSocketTypes;
end;

(**
  * Structure with the socket connection specification.
  *)
type TSocket = record
  strIPAddress     : TIPAddress;
  nPort            : integer;
  Connection       : TSocketHandle;
  DriverLayer      : TNetworkDriverLayer;
end;

type PSocket = ^TSocket;

(**
  * Packet structure to send data packet to the network board.
  *)
type TSocketPacket = record
  nSize     : integer;
  pData     : ^byte;
  pSock     : PSocket;
end;

type PSocketPacket = ^TSocketPacket;
