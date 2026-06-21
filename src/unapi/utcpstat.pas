(*<utcpstat.pas>
 * UNAPI TCP/IP capabilities and status routines.
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

(**
  * UNAPI TCP capabilities structure.
  *)
type PTCPCapabilities = ^TTCPCapabilities;     { Capabilities pointer }
     TTCPCapabilities = record
  SendRcvICMP               : 0..1; { Send and receive ICMP echo messages }
                                    { (PING) }
  LocalResolvHostName       : 0..1; { Resolv host names querying local }
                                    { hosts file or database }
  DNSResolvHostName         : 0..1; { Resolv host names querying a DNS server }
  OpenTCPActiveMode         : 0..1; { Open TCP connections in active mode }
  OpenTCPPassiveModeR       : 0..1; { Open TCP connections in passive mode, }
                                    { with specified remote socket }
  OpenTCPPassiveMode        : 0..1; { Open TCP connectios in passive mode }
                                    { with unspecified remote socket }
  SendRecvTCPUrgent         : 0..1; { Send and receive TCP urgent data }
  ExplictSetTCPPushBit      : 0..1; { Explicitly set the PUSH bit when }
                                    { sending TCP data }
  SendTCPDataBeforeStablish : 0..1; { Send data to a TCP connection before }
                                    { the STABLISHED state is reached }
  FlushTCPOutputBuffer      : 0..1; { Flush teh output buffer of a TCP }
                                    { connection }
  OpenUDPConnections        : 0..1; { Open UDP connections }
  OpenRAWIPConnections      : 0..1; { Open RAW IP connections }
  ExplicitSetTTLTOSOutDgram : 0..1; { Explicitly set TTL and TOS for }
                                    { outgoing Datagrams }
  ExplicitAutoPingReply     : 0..1; { Explicitly set the automatic reply }
                                    { to PINGs ON or OFF }
  AutomaticIPAddressSetup   : 0..1; { Automatically obtain the IP addresses, }
                                    { by using DHCP or an equivalent protocol }
  Unused                    : 0..1; { Unused }
end;

(**
  * Additional information about the internal working
  * parameters of the implementation.
  *)
type PTCPFeatures = ^TTCPFeatures;              { Features pointer }
     TTCPFeatures = record
  LinkPointToPoint          : 0..1; { Physical link is point to point }
  LinkWireless              : 0..1; { Physical link is wireless }
  SharedConnectionPool      : 0..1; { Connection pool is shared by TCP, UDP }
                                    { and RAW IP }
  CheckNetStateIsExpensive  : 0..1; { Check the network state requires }
                                    { sending a packet in loopback mode, or }
                                    { other expensive (time consuming) }
                                    { procedure }
  HardwareAssistedTCP       : 0..1; { The TCP/IP is assisted by external }
                                    { hardware }
  SupportLoopbackAddress    : 0..1; { The loopback address (127.0.0.1) is }
                                    { supported }
  HasHostnameCache          : 0..1; { A host name cache is implemented }
  IPFragementedDatagram     : 0..1; { IP Datagram framentation is supported }
  UserTimeoutConnection     : 0..1; { User timeout suggested when opening a }
                                    { TCP connection is actually applied }
  Unused                    : 0..6; { Unused }
end;

(**
  * Link level protocol.
  *)
type TLinkLevelProtocol = ( OtherUnspecified,
                            SLIP,
                            PPP,
                            Ethernet );

(**
  * Connection pool size and status.
  *)
type TConnectionPoolStatus = record
  nMaxTCPSimConnSupported   : byte; { Max. simultaneous TCP conn. supported }
  nMaxUDPSimConnSupported   : byte; { Max. simultaneous UDP conn. supported }
  nFreeTCPConnAvailable     : byte; { Free TCP conn. currently available }
  nFreeUDPConnAvailable     : byte; { Free UDP conn. currently available }
  nMaxRAWSimIPConnAvailable : byte; { Max. simultaneous RAW conn. available }
  nFreeRAWConnAvailable     : byte; { Free RAW conn. currently available }
end;

(**
  * Maximum datagram size allowed.
  *)
type TDatagramSize = record
  nMaxIncomingSize          : integer; { Maximum incoming datagram size }
  nMaxOutgoingSize          : integer; { Maximum outgoing datagram size }
end;

(**
  * Capabilities structure with all other grouped structures.
  *)
type TUNAPITCPCapabilities = record
  TCPCapabilities      : TTCPCapabilities;
  TCPFeatures          : TTCPFeatures;
  LinkLevelProtocol    : TLinkLevelProtocol;
  ConnectionPoolStatus : TConnectionPoolStatus;
  DatagramSize         : TDatagramSize;
end;



(**
  * Get the information about the TCP/IP and capabilities and
  * features.
  * @param impl The pointer to the UNAPI implementation functions;
  * @param cap The structure containing the requested capabilities;
  *)
function UNAPIGetTCPCapabilities( var impl : TUNAPIImplPointer;
                                  var cap : TUNAPITCPCapabilities ) : boolean;
var
     nCount,
     nValue    : byte;
     regs      : TRegs;
     pCap      : PTCPCapabilities;
     pFeatures : PTCPFeatures;

begin
  FillChar( regs, sizeof( regs ), 0 );
  nCount := 1;

  repeat
    regs.A := 1;      { TCPIP_GET_CAPAB }

    UNAPICallFn( impl, regs );
    nValue := RDSLT( impl.nSlotNumber, regs.HL );

    (*
     * Fill the complete capabilities structure.
     *)
    case nCount of
      1 : begin     { TCP Capabilities/Features/Link level protocol }
            pCap := Ptr( regs.HL );
            Move( pCap^, cap.TCPCapabilities, sizeof( TTCPCapabilities ) );

            { Features }
            pFeatures := Ptr( regs.DE );
            Move( pFeatures^, cap.TCPFeatures, sizeof( TTCPFeatures ) );

            { Link level protocol }
            case regs.B of
              0 : cap.LinkLevelProtocol := OtherUnspecified;
              1 : cap.LinkLevelProtocol := SLIP;
              2 : cap.LinkLevelProtocol := PPP;
              3 : cap.LinkLevelProtocol := Ethernet;
            end;
          end;
      2 : begin     { Connection pool size and status }
            with cap.ConnectionPoolStatus do
            begin
              nMaxTCPSimConnSupported   := regs.B;
              nMaxUDPSimConnSupported   := regs.C;
              nFreeTCPConnAvailable     := regs.D;
              nFreeUDPConnAvailable     := regs.E;
              nMaxRAWSimIPConnAvailable := regs.H;
              nFreeRAWConnAvailable     := regs.L;
            end;
          end;
      3 : begin     { Maximum datagram size allowed }
            with cap.DatagramSize do
            begin
              nMaxIncomingSize := regs.HL;
              nMaxOutgoingSize := regs.DE;
            end;
          end;
    end;

    nCount := nCount + 1;

  until( ( nCount > 3 ) or ( regs.A <> ctErr_Ok ) );

  UNAPIGetTCPCapabilities := ( regs.A = ctErr_OK );
end;
