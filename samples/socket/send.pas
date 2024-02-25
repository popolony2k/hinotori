(*<send.pas>
 * Command line client tool to send files using any network card.
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
{$i ..\..\src\comm\optinet\optodrv.pas}
{$i ..\..\src\comm\optonet\optonet.pas}
{$i .\common\fthelp.pas}
{$i .\common\mnfstver.pas}
{$i ..\..\src\memory\memory.pas}
{$i ..\..\src\dos\msxdos.pas}
{$i ..\..\src\\dos\msxdos2.pas}
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
  WriteLn( 'Send Vrs. ', ctSendFileVer );
  WriteLn( 'CopyLeft (c) since 2013 by PopolonY2k.' );
  WriteLn( 'Check newer versions of this software at http://www.planetamessenger.org' );
  WriteLn;
End;

(**
  * Print the help screen.
  *)
Procedure ShowHelp;
Begin
  WriteLn( 'Utility to send files to another connected peer.' );
  WriteLn;
  WriteLn( 'Usage: send [-h] -a <ip_address> -p <port_number>' );
  WriteLn;
  WriteLn( '-h Show this help screen;' );
  WriteLn( '-a <ip_address> Specify the <ip_address> to connect;' );
  WriteLn( '-p <port_number> Specify the <port_number> to connect;' );
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
  * Send a file through the connected peer.
  * @param socket The connected socket to send to the another peer;
  * @param packet The pre-initialized packet container the address of
  * configured buffer to use in I/O operations;
  * @param strFileName The file to send;
  * @param ioParms The I/O communication parameters (timeout, retries, ...);
  *)
Procedure SendFile( Var socket : TSocket;
                    Var packet : TSocketPacket;
                    Var strFileName : TFileName;
                    Var ioParms : TIOParms );
Var
             nFileHandle,
             nBufferSize,
             nSize,
             nAckTimeoutCount  : Integer;
             nSendRetries      : Byte;
             bExit,
             bSendRetry        : Boolean;
             szPath            : Array[0..ctMaxPath] Of Char;
             aParsedFileName   : Array[0..10] Of Char;
             aExtension        : Array[0..2] Of Char;
             ackPacket         : TSocketPacket;
             ackData           : TAckData;
             pData             : ^TTransferData;
             regs              : TRegs;

Begin
  nFileHandle := FileOpen( strFileName, 'r' );

  If( nFileHandle In [ctInvalidFileHandle, ctInvalidOpenMode] )  Then
    WriteLn( 'Error to open the specified file' )
  Else
  Begin
    (* Packet and data initialization *)
    pData := Ptr( Ord( packet.pData ) );
    pData^.nType  := ctFileNameChunk;
    pData^.nCount := 0;
    packet.nSize  := SizeOf( TTransferData );
    nBufferSize   := SizeOf( TTransferBuffer );
    FillChar( pData^.data, nBufferSize, 0 );

    (* Ack packet initialization *)
    ackPacket.nSize := SizeOf( TAckData );
    ackPacket.pData := Ptr( Addr( ackData ) );

    (* Parse the filename. *)
    nSize := Length( strFileName );
    Move( strFileName[1], szPath, nSize );
    szPath[nSize] := #0;
    FillChar( aParsedFileName, SizeOf( aParsedFileName ), 0 );

    With regs Do
    Begin
      C  := ctParseFileName;
      DE := Addr( szPath );
      HL := Addr( aParsedFileName );
    End;

    MSXBDOS( regs );

    (* Parse the file name *)
    pData^.nSize := Pos( ' ', aParsedFileName );

    If( ( pData^.nSize = 0 ) Or ( pData^.nSize > 8 ) )  Then
      pData^.nSize := 8
    Else
      pData^.nSize := pData^.nSize - 1;

    Move( aParsedFileName, pData^.data, pData^.nSize );

    (* Parse the file extension *)
    Move( aParsedFileName[8], aExtension, 3 );
    nSize := Pos( ' ', aExtension );

    Case( nSize ) Of
      0     : nSize := 3;
      1     : nSize := 0;
      Else
        nSize := nSize - 1;
    End;

    If( nSize > 0 )  Then
    Begin
      pData^.data[pData^.nSize] := Byte( '.' );
      pData^.nSize := pData^.nSize + 1;
      Move( aExtension, pData^.data[pData^.nSize], nSize );
      pData^.nSize := pData^.nSize + nSize;
    End;

    (* Packages sending *)
    Repeat
      nSendRetries := 0;
      bSendRetry   := False;
      bExit := False;

      Repeat
        (* Retry count *)
        If( bSendRetry )  Then
        Begin
          nSendRetries := nSendRetries + 1;
          WriteLn( 'Packet ', pData^.nCount,
                   ' lost. Retrying (', nSendRetries, ')' );
        End;

        nAckTimeoutCount := 0;
        bSendRetry := True;

        If( SocketSendPacket( socket, packet ) <> SocketSuccess )  Then
        Begin
          WriteLn( 'Error to send the packet to peer.' );
          pData^.nType := ctLastChunk;
          nSize := ctReadWriteError;
          bExit := KeyPressed;
          Delay( 1 );
        End
        Else
        Begin
          Repeat
            ackData.nCount := 0;
            ackData.nType  := ctUninitChunk;

            If( SocketRecvPacket( socket, ackPacket ) <> SocketSuccess )  Then
            Begin
              WriteLn( 'Error to receive the ack packet from peer.' );
              nAckTimeoutCount := nAckTimeoutCount + 1;
              Delay( 1 );
            End
            Else
            Begin
              If( ackData.nType = ctAckChunk )  Then
              Begin
                nAckTimeoutCount := 0;

                If( ackData.nCount = pData^.nCount ) Then
                Begin
                  bSendRetry := False;
                  nSendRetries := 0;
                  WriteLn( 'Packet (', pData^.nCount,') successfully sent.' );
                End;
              End
              Else
              Begin
                nAckTimeoutCount := nAckTimeoutCount + 1;
                Delay( 1 );
              End;
            End;

            bExit := KeyPressed;
          Until( ( nAckTimeoutCount >= ioParms.nTimeout ) Or
                 ( nAckTimeoutCount = 0 ) Or bExit );

          If( nAckTimeoutCount >= ioParms.nTimeout )  Then
            WriteLn( 'Ack timeout reached' );
        End;

        Delay( 1 );
      Until( Not bSendRetry Or ( nSendRetries >= ioParms.nRetries ) Or bExit );

      If( nSendRetries >= ioParms.nRetries )  Then
      Begin
        WriteLn( 'Number of retries reached' );
        pData^.nType := ctLastChunk;
      End;

      If( pData^.nType <> ctLastChunk )  Then
      Begin
        FillChar( pData^.data, nBufferSize, 0 );
        nSize := FileBlockRead( nFileHandle,
                                pData^.data,
                                nBufferSize );

        If( nSize = nBufferSize ) Then   { Control the chunk buffering }
          pData^.nType := ctNextChunk
        Else
          pData^.nType := ctLastChunk;

        If( nSize = ctReadWriteError )  Then
          nSize := 0;

        pData^.nSize := nSize;

        If( pData^.nCount = ctMaxPacketCount )  Then
          pData^.nCount := 0
        Else
          pData^.nCount := pData^.nCount + 1;
      End
      Else
      Begin
        If( ( nSendRetries < ioParms.nRetries ) And
            ( nSize <> ctReadWriteError ) )  Then
          WriteLn( 'The file was successfully sent.' );

        nSize := ctReadWriteError;
      End;
    Until( ( nSize = ctReadWriteError ) Or bExit );

    If( Not FileClose( nFileHandle ) )  Then
      WriteLn( 'Error to close the file.' );
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
       strFileName     : TFileName;
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

      socket.strIPAddress := parms.strIPAddress;
      socket.nPort := parms.nPort;
      socket.Connection.SocketType := SOCK_DGRAM;

      If( SocketConnect( socket ) = SocketSuccess )  Then
      Begin
        { Packet data buffer configuration }
        packet.pData := Ptr( Addr( data ) ); { Weird TP3 pointer deference }
        { I/O parameters configuration }
        ioParms.nTimeout := ctSendTimeout;
        ioParms.nRetries := ctRetries;
        strFileName := '';

        While( strFileName = '' )  Do
        Begin
          WriteLn( 'Type the file name to send' );
          ReadLn( strFileName );
        End;

        SendFile( socket, packet, strFileName, ioParms );

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
