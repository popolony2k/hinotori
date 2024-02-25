(*<recv.pas>
 * Command line client tool to receive files using any network card.
 * Supported cards:
 * - OPTO-TECH Network/RS232/SD-Card for the MSX platform.
 * CopyLeft (c) 1995-2024 by PopolonY2k.
 * CopyLeft (c) since 2024 by Hinotori Team.
 *)

(*
 * This module depends on folowing include files (respect the order):
 * - /system/types.pas;
 * - /callproc/funcptr.pas;
 * - /socket/sockdefs.pas;
 * - /socket/socket.pas;
 * - /util/helpstr.pas;
 * - /system/systypes.pas;
 * - /timer/sleep.pas;
 * - /comm/optonet/optodrv.pas;
 * - /comm/optonet/optonet.pas;
 * - ./common/fthelp.pas;
 * - ./common/mnfstver.pas;
 * - /memory/memory.pas;
 * - /dos/msxdos.pas;
 * - /dos/msxdos2.pas;
 * - /dos/dos2file.pas;
 * - ./common/ftdefs.pas;
 *)

{$v-,c-,u-,a+,r-}

{$i ..\..\src\system\types.pas}
{$i ..\..\src\callproc\funcptr.pas}
{$i ..\..\src\socket\sockdefs.pas}
{$i ..\..\src\socket\socket.pas}
{$i ..\..\src\util\helpstr.pas}
{$i ..\..\src\system\systypes.pas}
{$i ..\..\src\timer\sleep.pas}
{$i ..\..\src\comm\optonet\optodrv.pas}
{$i ..\..\src\comm\optonet\optonet.pas}
{$i .\common\fthelp.pas}
{$i .\common\mnfstver.pas}
{$i ..\..\src\memory\memory.pas}
{$i ..\..\src\dos\msxdos.pas}
{$i ..\..\src\dos\msxdos2.pas}
{$i ..\..\src\dos\dos2file.pas}
{$i .\common\ftdefs.pas}


(*
 * Help and information functions.
 *)

(**
  * Print the software information.
  *)
Procedure ShowInfo;
Begin
  WriteLn( 'Manifest network tools Vrs.', ctManifestSuiteVer );
  WriteLn( 'Recv Vrs. ', ctRecvFileVer );
  WriteLn( 'CopyLeft (c) since 2013 by PopolonY2k.' );
  WriteLn( 'Check newer versions of this software at http://www.planetamessenger.org' );
  WriteLn;
End;

(**
  * Print the help screen.
  *)
Procedure ShowHelp;
Begin
  WriteLn( 'Utility to receive files from another connected peer.' );
  WriteLn;
  WriteLn( 'Usage: recv [-h] -a <ip_address> -p <port_number>' );
  WriteLn;
  WriteLn( '-h Show this help screen;' );
  WriteLn( '-a <ip_address> Specify the <ip_address> to listen;' );
  WriteLn( '-p <port_number> Specify the <port_number> to listen;' );
  WriteLn;
  WriteLn( 'Supported cards:' );
  WriteLn;
  WriteLn( '1) OPTO-TECH Network/RS232/SD-Card;' );
  WriteLn;
End;

(*
 * Protocol specific functions.
 *)

(**
  * Receive a file from the connected peer.
  * @param socket The connected socket to send to the another peer;
  * @param packet The pre-initialized packet container the address of
  * configured buffer to use in I/O operations;
  * @param ioParms The I/O communication parameters (timeout, retries, ...);
  *)
Procedure ReceiveFile( Var socket : TSocket;
                       Var packet : TSocketPacket;
                       Var ioParms : TIOParms );
Var
             nFileHandle,
             nTimeout        : Integer;
             nPacketCount    : Byte;
             bExit,
             bFatalError,
             bRestart,
             bRecvStarted,
             bIgnorePacket,
             bTimeoutStarted : Boolean;
             strFileName     : TFileName;
             ackPacket       : TSocketPacket;
             ackData         : TAckData;
             pData           : ^TTransferData;

Begin
  (* Packet and data initialization *)
  pData := Ptr( Ord( packet.pData ) );
  packet.nSize := SizeOf( TTransferData );

  (* Ack packet initialization *)
  ackPacket.nSize := SizeOf( TAckData );
  ackPacket.pData := Ptr( Addr( ackData ) );
  ackData.nType   := ctAckChunk;
  bExit := False;

  (* Package receiving *)
  Repeat
    bTimeoutStarted := False;
    bFatalError  := False;
    bRecvStarted := False;
    bREstart     := False;
    nFileHandle  := ctInvalidFileHandle;
    nPacketCount := 0;
    nTimeout     := 0;
    strFileName  := '';

    WriteLn( 'Waiting for peer connection.' );

    Repeat                        { File transfer processing loop }
      (* Timeout processing *)
      If( bTimeoutStarted )  Then
      Begin
        nTimeout := nTimeout + 1;
        Delay( 1 );
      End;

      FillChar( pData^.data, SizeOf( TTransferBuffer ), 0 );
      pData^.nType := ctUninitChunk;

      (* Receive the peer packet *)
      If( SocketRecvPacket( socket, packet ) <> SocketSuccess )  Then
      Begin
        WriteLn( 'Error to receive the packet from peer.' );
        bTimeoutStarted := True;
      End
      Else
      Begin
        (*
         * Just perform the packet processing if the received data is a valid
         * transfer packet in a valid connection state.
         *)
        If( ( ( pData^.nType = ctFileNameChunk ) And ( nPacketCount = 0 ) ) Or
            ( ( pData^.nType In [ctNextChunk,ctLastChunk] ) And
                bRecvStarted ) )  Then
        Begin
          bRecvStarted := True;             { Started a file transfer }
          ackData.nCount := pData^.nCount;

          WriteLn( 'Packet sequence received (', pData^.nCount, ')' );

          If( SocketSendPacket( socket, ackPacket ) <> SocketSuccess )  Then
          Begin
            WriteLn( 'Error to send the ack packet to peer.' );
            ackData.nCount  := nPacketCount;
            bTimeoutStarted := True;
          End
          Else
          Begin   { Process the received packet }
            bIgnorePacket   := False;
            bTimeoutStarted := False;
            nTimeout := 0;

            (* Check the packet sequencing *)
            If( nPacketCount <> pData^.nCount )  Then
            Begin
              WriteLn( 'Current sequence (', nPacketCount,
                       '). Received (', pData^.nCount, '). Ignoring.' );
              bIgnorePacket := True;
            End;

            If( Not bIgnorePacket )  Then
            Begin
              If( nPacketCount = ctMaxPacketCount )  Then
                nPacketCount := 0
              Else
                nPacketCount := nPacketCount + 1;

              Case( pData^.nType ) Of
                ctFileNameChunk :       { Process the file name }
                Begin
                  strFileName[0] := Char( pData^.nSize );
                  Move( pData^.data, strFileName[1], pData^.nSize );
                  nFileHandle := FileOpen( strFileName, 'w+' );

                  If( nFileHandle In [ctInvalidFileHandle,
                                      ctInvalidOpenMode] )  Then
                    WriteLn( 'Error to create the file ', strFileName )
                  Else
                    WriteLn( 'Receiving file ', strFileName );
                End;

                ctNextChunk,            { Process the file data chunks }
                ctLastChunk :
                Begin
                  If( nFileHandle In [ctInvalidFileHandle,
                                      ctInvalidOpenMode] )  Then
                  Begin
                    bFatalError := True;
                    WriteLn( 'The file ', strFileName, ' is not open.' );
                  End
                  Else
                  Begin
                    pData^.nSize := FileBlockWrite( nFileHandle,
                                                    pData^.data,
                                                    pData^.nSize );

                    WriteLn( 'Packet (', pData^.nCount, ') received.' );

                    If( pData^.nSize = ctReadWriteError )  Then
                      WriteLn( 'I/O error on file ', strFileName );

                    If( pData^.nType = ctLastChunk )  Then
                    Begin
                      If( Not FileClose( nFileHandle ) )  Then
                      Begin
                         bFatalError := True;
                         WriteLn( 'Error to close the file ', strFileName );
                      End
                      Else
                        WriteLn( 'File ', strFileName,
                                 ' successfully received.' );

                      WriteLn( 'File transfer finished.' );

                      bRestart := True;
                      bRecvStarted := False;
                      nPacketCount := 0;
                      ackData.nCount := 0;
                      nFileHandle  := ctInvalidFileHandle;
                    End;
                  End;
                End;
              End;
            End;
          End;
        End
        Else
          If( bRecvStarted )  Then
            bTimeoutStarted := True;

        Delay( 1 );
      End;

      If( bFatalError Or ( nTimeout >= ioParms.nTimeout ) )  Then
        bExit := True
      Else
        bExit := KeyPressed;
    Until( bExit Or bRestart );
  Until( bExit );

  If( nTimeout >= ioParms.nTimeout )  Then
  Begin
    WriteLn( 'Timeout reached at packet (', nPacketCount, ')' );

    If( Length( strFileName ) > 0 )  Then
      WriteLn( 'Error to receive the file ', strFileName );

    If( nFileHandle <> ctInvalidFileHandle )  Then
      If( Not FileClose( nFileHandle ) )  Then
        WriteLn( 'Error to close the file ', strFileName );

     nFileHandle  := ctInvalidFileHandle;
  End;
End;


(*
 * Main block
 *)

Var
       osVersion       : TMSXDOSVersion;
       packet          : TSocketPacket;
       socket          : TSocket;
       parms           : TCmdLineParms;
       data            : TTransferData;
       ioParms         : TIOParms;

Begin
  GetMSXDOSVersion( osVersion );

  If( osVersion.nKernelMajor < 2 )  Then
    WriteLn( 'This software works only on MSXDOS2 or higher' )
  Else
  Begin
    ShowInfo;
    ParseCmdLine( parms );

    If( Not parms.bHelp And parms.bPort And parms.bIPAddress )  Then
    Begin
      { Socket configuration }
      InitSocket( socket, Addr( OptoNetDrvSocketInit ) );

      (*
       * FIXME: The current firmware doesn't support to retrieve the
       * connection IPAddress, the the actually is impossible to receive
       * connection from any ip address (INADDR_ANY).
       *)
      socket.strIPAddress := parms.strIPAddress;  { FIXME: INADDR_ANY }
      socket.nPort := parms.nPort;
      socket.Connection.SocketType := SOCK_DGRAM;

      If( SocketConnect( socket ) = SocketSuccess )  Then
      Begin
        { Packet data buffer configuration }
        packet.pData := Ptr( Addr( data ) ); { Weird TP3 pointer deference }

        { I/O parameters configuration }
        ioParms.nTimeout := ctRecvTimeout;
        ioParms.nRetries := ctRetries;

        ReceiveFile( socket, packet, ioParms );

        If( SocketDisconnect( socket ) <> SocketSuccess )  Then
          WriteLn( 'Error to disconnect from peer.' );
      End
      Else
        WriteLn( 'Error to connect to the specified address:port.' );
    End
    Else
      ShowHelp;
  End;
End.
