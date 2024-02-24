(*<utcpstat.pas>
 * UNAPI TCP/IP capabilities and status routines.
 * All function addresses and EXTBIO function call is respecting
 * the UNAPI specification reached at Konamiman site at
 * http://www.konamiman.com.
 *
 * CopyLeft (c) since 1995 by PopolonY2k.
 *)

(**
  *
  * $Id: utcpstat.pas 128 2020-07-08 17:51:23Z popolony2k $
  * $Author: popolony2k $
  * $Date: 2020-07-08 14:51:23 -0300 (Wed, 08 Jul 2020) $
  * $Revision: 128 $
  * $HeadURL: https://svn.code.sf.net/p/oldskooltech/code/msx/trunk/msxdos/pascal/utcpstat.pas $
  *)

(*
 * This module depends on folowing include files (respect the order):
 * - types.pas;
 * - msxbios.pas;
 * - extbio.pas;
 * - unapi.pas;
 *)

(**
  * UNAPI TCP capabilities structure.
  *)
Type PTCPCapabilities = ^TTCPCapabilities;     { Capabilities pointer }
     TTCPCapabilities = Record
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
End;

(**
  * Additional information about the internal working
  * parameters of the implementation.
  *)
Type PTCPFeatures = ^TTCPFeatures;              { Features pointer }
     TTCPFeatures = Record
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
End;

(**
  * Link level protocol.
  *)
Type TLinkLevelProtocol = ( OtherUnspecified,
                            SLIP,
                            PPP,
                            Ethernet );

(**
  * Connection pool size and status.
  *)
Type TConnectionPoolStatus = Record
  nMaxTCPSimConnSupported   : Byte; { Max. simultaneous TCP conn. supported }
  nMaxUDPSimConnSupported   : Byte; { Max. simultaneous UDP conn. supported }
  nFreeTCPConnAvailable     : Byte; { Free TCP conn. currently available }
  nFreeUDPConnAvailable     : Byte; { Free UDP conn. currently available }
  nMaxRAWSimIPConnAvailable : Byte; { Max. simultaneous RAW conn. available }
  nFreeRAWConnAvailable     : Byte; { Free RAW conn. currently available }
End;

(**
  * Maximum datagram size allowed.
  *)
Type TDatagramSize = Record
  nMaxIncomingSize          : Integer; { Maximum incoming datagram size }
  nMaxOutgoingSize          : Integer; { Maximum outgoing datagram size }
End;

(**
  * Capabilities structure with all other grouped structures.
  *)
Type TUNAPITCPCapabilities = Record
  TCPCapabilities      : TTCPCapabilities;
  TCPFeatures          : TTCPFeatures;
  LinkLevelProtocol    : TLinkLevelProtocol;
  ConnectionPoolStatus : TConnectionPoolStatus;
  DatagramSize         : TDatagramSize;
End;



(**
  * Get the information about the TCP/IP and capabilities and
  * features.
  * @param impl The pointer to the UNAPI implementation functions;
  * @param cap The structure containing the requested capabilities;
  *)
Function UNAPIGetTCPCapabilities( Var impl : TUNAPIImplPointer;
                                  Var cap : TUNAPITCPCapabilities ) : Boolean;
Var
     nCount,
     nValue    : Byte;
     regs      : TRegs;
     pCap      : PTCPCapabilities;
     pFeatures : PTCPFeatures;

Begin
  FillChar( regs, SizeOf( regs ), 0 );
  nCount := 1;

  Repeat
    regs.A := 1;      { TCPIP_GET_CAPAB }

    UNAPICallFn( impl, regs );
    nValue := RDSLT( impl.nSlotNumber, regs.HL );

    (*
     * Fill the complete capabilities structure.
     *)
    Case nCount Of
      1 : Begin     { TCP Capabilities/Features/Link level protocol }
            pCap := Ptr( regs.HL );
            Move( pCap^, cap.TCPCapabilities, SizeOf( TTCPCapabilities ) );

            { Features }
            pFeatures := Ptr( regs.DE );
            Move( pFeatures^, cap.TCPFeatures, SizeOf( TTCPFeatures ) );

            { Link level protocol }
            Case regs.B Of
              0 : cap.LinkLevelProtocol := OtherUnspecified;
              1 : cap.LinkLevelProtocol := SLIP;
              2 : cap.LinkLevelProtocol := PPP;
              3 : cap.LinkLevelProtocol := Ethernet;
            End;
          End;
      2 : Begin     { Connection pool size and status }
            With cap.ConnectionPoolStatus Do
            Begin
              nMaxTCPSimConnSupported   := regs.B;
              nMaxUDPSimConnSupported   := regs.C;
              nFreeTCPConnAvailable     := regs.D;
              nFreeUDPConnAvailable     := regs.E;
              nMaxRAWSimIPConnAvailable := regs.H;
              nFreeRAWConnAvailable     := regs.L;
            End;
          End;
      3 : Begin     { Maximum datagram size allowed }
            With cap.DatagramSize Do
            Begin
              nMaxIncomingSize := regs.HL;
              nMaxOutgoingSize := regs.DE;
            End;
          End;
    End;

    nCount := nCount + 1;

  Until( ( nCount > 3 ) Or ( regs.A <> ctErr_Ok ) );

  UNAPIGetTCPCapabilities := ( regs.A = ctErr_OK );
End;
