(*<drvdisk.pas>
 * Driver implementation for disk operations.
 * CopyLeft (c) since 1995 by PopolonY2k.
 *)

(**
  *
  * $Id: drvdisk.pas 128 2020-07-08 17:51:23Z popolony2k $
  * $Author: popolony2k $
  * $Date: 2020-07-08 14:51:23 -0300 (Wed, 08 Jul 2020) $
  * $Revision: 128 $
  * $HeadURL: https://svn.code.sf.net/p/oldskooltech/code/msx/trunk/msxdos/pascal/drvdisk.pas $
  *)

(*
 * This source file depends on following include files (respect the order):
 * - memory.pas;
 * - types.pas;
 * - msxdos.pas;
 * - dpb.pas;
 * - dosio.pas;
 * - doscodes.pas;
 * - math.pas;
 * - bigint.pas;
 * - iohandle.pas;
 *)

(**
  * Implement the method to get the device parameters.
  * @param nParm The address of the @see TDeviceCtrl structure
  * with device parameters;
  *)
Procedure GetSectorDevParms( nParm : Integer );
Var
        bigRes,
        bigTmp,
        bigDevicePtr,
        bigPtrPartitionStart : TBigInt;
        nBigRes,
        nBigTmp              : TInt24;
        pDevice              : ^TDeviceCtrl;
        wrkspc               : TIDEWorkspace;
        DPB                  : TDPB;
        opCode               : TOperationCode;

Begin
  pDevice := Ptr( nParm );

  With pDevice^ Do
  Begin
    IDECtrl.ptrDriveField := Nil;
    GetIDEInfo( IDECtrl.info );

    If( ( nDeviceNumber <= ctDriveFieldSize ) And
        ( IDECtrl.info.nSlotNumber <> ctUnitializedSlot ) )  Then
    Begin
      FillChar( wrkspc, SizeOf( TIDEWorkspace ), 0 );

      If( GetIDEWorkSpace( IDECtrl.info, wrkspc ) )  Then
      Begin
        IDECtrl.ptrDriveField := wrkspc.ptrDriveField[nDeviceNumber];
        FillChar( nBigTmp, SizeOf( nBigTmp ), 0 );
        FillChar( nBigRes, SizeOf( nBigRes ), 0 );

        With bigTmp Do
        Begin
          nSize  := SizeOf( nBigTmp );
          pValue := Ptr( Addr( nBigTmp ) );
        End;

        With bigRes Do
        Begin
          nSize  := SizeOf( nBigRes );
          pValue := Ptr( Addr( nBigRes ) );
        End;

        With bigDevicePtr Do
        Begin
          nSize  := SizeOf( Buffer.nDevicePtr );
          pValue := Ptr( Addr( Buffer.nDevicePtr ) );
        End;

        With bigPtrPartitionStart Do
        Begin
          nSize  := SizeOf( IDECtrl.ptrDriveField^.n24PartitionStart );
          pValue := Ptr( Addr( IDECtrl.ptrDriveField^.n24PartitionStart ) );
        End;

        (* JUST FOR IDE OPERATIONS: When the user configure the option
         * -s <sector_number> at command line, the behavior of the option
         * -d <drive> will be overriden by the -s option depending if the
         * -r parameter was called at startup.
         * When MSXDUMP is started with the -r parameter, the parameter
         * -s <sector_number>, describes the sector number relative to the
         * start sector position of the drive passed by -d <drive> option.
         * If there's no -r parameter at startup, the -s <sector_number>
         * parameter describes the absolute sector position relative to
         * the start of selected disk sector (sector zero).
         *)
        If( CompareBigInt( bigDevicePtr, bigTmp ) = Equals )  Then  { = 0 }
        Begin
          opCode := AssignBigInt( bigDevicePtr, bigPtrPartitionStart );
          opCode := SwapBigInt( bigDevicePtr );
        End
        Else
          If( Not IDECtrl.bAbsoluteStartSector )  Then
          Begin
            opCode := AssignBigInt( bigTmp, bigPtrPartitionStart );
            opCode := SwapBigInt( bigTmp );
            opCode := AddBigInt( bigRes, bigDevicePtr, bigTmp );

            If( opCode = Success )  Then
              opCode := AssignBigInt( bigDevicePtr, bigRes )
            Else
              FillChar( Buffer.nDevicePtr, SizeOf( Buffer.nDevicePtr ), 0 );
          End;
      End;
    End;

    If( GetDPB( nDeviceNumber, DPB ) <> ctError ) Then
    Begin
      Buffer.nDeviceBufferSize := DPB.nBytesPerSector;
      Error.nErrorCode := ctDOSSuccess;
    End
    Else
    Begin
      Buffer.nDeviceBufferSize := 0;
      Error.nErrorCode := ctDOSInvalidDeviceOper;
    End;
  End;
End;

(**
  * Implement the method to open a device.
  * @param nParm The address of the @see TDeviceCtrl structure
  * with device parameters;
  *)
Procedure OpenSectorDev( nParm : Integer );
Var
        pDevice : ^TDeviceCtrl;

Begin
  pDevice := Ptr( nParm );

  With pDevice^ Do
  Begin
    If( IDECtrl.ptrDriveField = Nil )  Then
      BDOS( ctSetDMA, Addr( Buffer.pDevData^ ) );

    Error.nErrorCode := ctDOSSuccess;
    bEndOfSector := False;
  End;
End;

(**
  * Implement the method to close a device.
  * @param nParm The address of the @see TDeviceCtrl structure
  * with device parameters;
  *)
Procedure CloseSectorDev( nParm : Integer );
Var
        pDevice : ^TDeviceCtrl;

Begin
  pDevice := Ptr( nParm );

  With pDevice^ Do
  Begin
    If( IDECtrl.ptrDriveField = Nil )  Then
      BDOS( ctSetDMA, ctInitDMA );

    Error.nErrorCode := ctDOSSuccess;
  End;
End;

(**
  * Implement the method to perform a seek operation of the device.
  * @param nParm The address of the @see TDeviceCtrl structure
  * with device parameters;
  *)
Procedure SeekSectorDev( nParm : Integer );
Var
        pDevice : ^TDeviceCtrl;

Begin
  pDevice := Ptr( nParm );

  With pDevice^ Do
  Begin
    Error.nErrorCode := ctDOSSuccess;
  End;
End;

(**
  * Implement the method to read from device.
  * @param nParm The address of the @see TDeviceCtrl structure
  * with device parameters;
  *)
Procedure ReadSectorDev( nParm : Integer );
Var
        pDevice      : ^TDeviceCtrl;
        nDevicePtr   : Integer;
        bigDevicePtr : TBigInt;
        opCode       : TOperationCode;

Begin
  pDevice := Ptr( nParm );

  With pDevice^ Do
  Begin
    If( IDECtrl.ptrDriveField = Nil )  Then
    Begin
      nDevicePtr := Addr( Buffer.nDevicePtr ) + 1;
      nDevicePtr := Swap( GetInteger( nDevicePtr ) );

      If( AbsoluteRead( nDeviceNumber, nDevicePtr, 1 ) <> ctOk )  Then
      Begin
        If( OSEnv.nOSVersion < 2 )  Then
          Error.nErrorCode := ctDOSEndOfFile
        Else
          Error.nErrorCode := GetLastErrorCode;

        bEndOfSector := True;
      End
      Else
      Begin
        Error.nErrorCode := ctDOSSuccess;
        bEndOfSector := False;
      End;
    End
    Else
    Begin
      With IDECtrl Do
      Begin
        With bigDevicePtr Do
        Begin
          nSize  := SizeOf( Buffer.nDevicePtr );
          pValue := Ptr( Addr( Buffer.nDevicePtr ) );
        End;

        opCode := SwapBigInt( bigDevicePtr );
        Error.nErrorCode := SunAbsoluteSectorRead( info.nSlotNumber,
                                                   ptrDriveField,
                                                   Buffer.nDevicePtr,
                                                   1,
                                                   Addr( Buffer.pDevData^ ) );
        opCode := SwapBigInt( bigDevicePtr );

        If( Error.nErrorCode = ctDISKIOSuccess )  Then
        Begin
          Error.nErrorCode := ctDOSSuccess;
          bEndOfSector := False;
        End
        Else
          bEndOfSector := True;
      End;
    End;
  End;
End;

(**
  * Implement the method to write to device.
  * @param nParm The address of the @see TDeviceCtrl structure
  * with device parameters;
  *)
Procedure WriteSectorDev( nParm : Integer );
Var
        pDevice      : ^TDeviceCtrl;
        nDevicePtr   : Integer;
        bigDevicePtr : TBigInt;
        opCode       : TOperationCode;

Begin
  pDevice := Ptr( nParm );

  With pDevice^ Do
  Begin
    If( IDECtrl.ptrDriveField = Nil )  Then
    Begin
      nDevicePtr := Addr( Buffer.nDevicePtr ) + 1;
      nDevicePtr := Swap( GetInteger( nDevicePtr ) );

      If( AbsoluteWrite( nDeviceNumber, nDevicePtr, 1 ) <> ctOk )  Then
      Begin
        If( OSEnv.nOSVersion < 2 )  Then
          Error.nErrorCode := ctDOSEndOfFile
        Else
          Error.nErrorCode := GetLastErrorCode;

        bEndOfSector := True;
      End
      Else
      Begin
        Error.nErrorCode := ctDOSSuccess;
        bEndOfSector := False;
      End;
    End
    Else
    Begin
      With IDECtrl Do
      Begin
        With bigDevicePtr Do
        Begin
          nSize  := SizeOf( Buffer.nDevicePtr );
          pValue := Ptr( Addr( Buffer.nDevicePtr ) );
        End;

        opCode := SwapBigInt( bigDevicePtr );
        Error.nErrorCode := SunAbsoluteSectorWrite( info.nSlotNumber,
                                                    ptrDriveField,
                                                    Buffer.nDevicePtr,
                                                    1,
                                                    Addr( Buffer.pDevData^ ) );
        opCode := SwapBigInt( bigDevicePtr );

        If( Error.nErrorCode = ctDISKIOSuccess )  Then
        Begin
          Error.nErrorCode := ctDOSSuccess;
          bEndOfSector := False;
        End
        Else
          bEndOfSector := True;
      End;
    End;
  End;
End;

(**
  * Implement the method to control error handling.
  * @param nParm The address of the @see TDeviceCtrl structure
  * with device parameters;
  *)
Procedure ErrorHandlingSectorDev( nParm : Integer );
Var
        pDevice : ^TDeviceCtrl;

Begin
  pDevice := Ptr( nParm );

  With pDevice^ Do
  Begin
    If( OSEnv.nOSVersion < 2 )  Then
    Begin
      If( Error.nErrorCode = ctDOSInvalidDeviceOper )  Then
        Error.strMessage := 'Invalid operation'
      Else
      If( Error.nErrorCode = ctDOSEndOfFile )  Then
        Error.strMessage := 'No more sectors'
      Else
        Error.strMessage := 'Error - Verify the device';
    End
    Else
      GetErrorMessage( Error.nErrorCode, Error.strMessage );
  End;
End;
