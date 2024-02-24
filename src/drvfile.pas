(*<drvfile.pas>
 * Driver implementation for file operations.
 * CopyLeft (c) since 1995 by PopolonY2k.
 *)

(**
  *
  * $Id: drvfile.pas 128 2020-07-08 17:51:23Z popolony2k $
  * $Author: popolony2k $
  * $Date: 2020-07-08 14:51:23 -0300 (Wed, 08 Jul 2020) $
  * $Revision: 128 $
  * $HeadURL: https://svn.code.sf.net/p/oldskooltech/code/msx/trunk/msxdos/pascal/drvfile.pas $
  *)

(*
 * This source file depends on following include files (respect the order):
 * - memory.pas;
 * - types.pas;
 * - msxdos.pas;
 * - msxdos2.pas;
 * - dos2file.pas;
 * - doscodes.pas;
 * - tpcodes.pas;
 * - iohandle.pas;
 * - dos2err.pas;
 *)

(* Internal modules functions - INTERNAL USE ONLY *)

(**
  * Return if the error code represent a end of file  code for a given
  * operating system;
  * @param device The @see TDeviceCtrl structure containing de data to
  * check;
  *)
Function __CheckOSEndOfFile( Var device : TDeviceCtrl ) : Boolean;
Var
    bResult : Boolean;

Begin
  With device Do
  Begin
    If( OSEnv.nOSVersion < 2 )  Then
      bResult := Error.nErrorCode In [ctTPSeekBeyondEOF,
                                      ctTPUnexpectedEOF]
    Else
      bResult := Error.nErrorCode In [ctDOSEndOfFile];
  End;

  __CheckOSEndOfFile := bResult;
End;

(**
  * Implement the method to get the device parameters.
  * @param nParm The address of the @see TDeviceCtrl structure
  * with device parameters;
  *)
Procedure GetFileDevParms( nParm : Integer );
Var
        pDevice : ^TDeviceCtrl;

Begin
  pDevice := Ptr( nParm );

  With pDevice^ Do
  Begin
    Buffer.nDeviceBufferSize := ctDefIOBufferSize;
    Error.nErrorCode := 0;
    Error.strMessage := '';
  End;
End;

(**
  * Implement the method to open a device.
  * @param nParm The address of the @see TDeviceCtrl structure
  * with device parameters;
  *)
Procedure OpenFileDev( nParm : Integer );
Var
        pDevice : ^TDeviceCtrl;

Begin
  pDevice := Ptr( nParm );

  With pDevice^ Do
  Begin
    Error.strMessage := '';

    If( OSEnv.nOSVersion < 2 )  Then
    Begin
      {$i-}
      Assign( FileCtrl.fpFile, FileCtrl.strFileName );
      Reset( FileCtrl.fpFile );
      Error.nErrorCode := IOResult;
      {$i+}
    End
    Else
    Begin
      FileCtrl.nFileHandle := FileOpen( FileCtrl.strFileName, 'rw' );
      Error.nErrorCode := 0;

      If( FileCtrl.nFileHandle In [ctInvalidFileHandle,
                                   ctInvalidOpenMode] )  Then
      Begin
        Error.nErrorCode := GetLastErrorCode;

        { Non MSXDOS2 opening errors }
        If( Error.nErrorCode = 0 )  Then
        Begin
          Case( FileCtrl.nFileHandle ) Of
            { TODO: Add correct DOS 2 code for invalid open mode }
            ctInvalidOpenMode   : Error.nErrorCode := ctDOSFileNotFound;
            ctInvalidFileHandle : Error.nErrorCode := ctDOSInvalidFileHandle;
          End;
        End;
      End;
    End;
  End;
End;

(**
  * Implement the method to close a device.
  * @param nParm The address of the @see TDeviceCtrl structure
  * with device parameters;
  *)
Procedure CloseFileDev( nParm : Integer );
Var
        pDevice : ^TDeviceCtrl;

Begin
  pDevice := Ptr( nParm );

  With pDevice^ Do
  Begin
    Error.strMessage := '';

    If( OSEnv.nOSVersion < 2 )  Then
    Begin
      {$i-}
      Close( FileCtrl.fpFile );
      Error.nErrorCode := IOResult;
      {$i+}
    End
    Else
    Begin
      Error.nErrorCode := 0;

      If( Not FileClose( FileCtrl.nFileHandle ) )  Then
        Error.nErrorCode := GetLastErrorCode;
    End;
  End;
End;

(**
  * Implement the method to perform a seek operation of the device.
  * @param nParm The address of the @see TDeviceCtrl structure
  * with device parameters;
  *)
Procedure SeekFileDev( nParm : Integer );
Var
        pDevice      : ^TDeviceCtrl;
        nDevicePtr,
        nNewPos      : Integer;

Begin
  pDevice := Ptr( nParm );

  With pDevice^ Do
  Begin
    Error.strMessage := '';

    nDevicePtr := Addr( Buffer.nDevicePtr ) + 1;
    nDevicePtr := Swap( GetInteger( nDevicePtr ) );

    If( OSEnv.nOSVersion < 2 )  Then
    Begin
      {$i-}
      Seek( FileCtrl.fpFile, nDevicePtr );
      Error.nErrorCode := IOResult;
      {$i+}
    End
    Else
    Begin
      Error.nErrorCode := 0;

      If( Not FileSeek( FileCtrl.nFileHandle,
                        ( nDevicePtr * Buffer.nDeviceBufferSize ),
                        ctSeekSet,
                        nNewPos ) ) Then
        Error.nErrorCode := GetLastErrorCode;
    End;

    bEndOfSector := __CheckOSEndOfFile( pDevice^ );
  End;
End;

(**
  * Implement the method to read from device.
  * @param nParm The address of the @see TDeviceCtrl structure
  * with device parameters;
  *)
Procedure ReadFileDev( nParm : Integer );
Var
        pDevice    : ^TDeviceCtrl;

Begin
  pDevice := Ptr( nParm );

  With pDevice^ Do
  Begin
    Error.strMessage := '';

    If( OSEnv.nOSVersion < 2 )  Then
    Begin
      {$i-}
      BlockRead( FileCtrl.fpFile, Buffer.pDevData^, 1 );
      Error.nErrorCode := IOResult;
      {$i+}
    End
    Else
    Begin
      Error.nErrorCode := 0;

      If( FileBlockRead( FileCtrl.nFileHandle,
                         Buffer.pDevData^,
                         Buffer.nDeviceBufferSize ) = ctReadWriteError )  Then
        Error.nErrorCode := GetLastErrorCode;
    End;

    (* Check if the EOF was reached *)
    bEndOfSector := __CheckOSEndOfFile( pDevice^ );
  End;
End;

(**
  * Implement the method to write to device.
  * @param nParm The address of the @see TDeviceCtrl structure
  * with device parameters;
  *)
Procedure WriteFileDev( nParm : Integer );
Var
        pDevice      : ^TDeviceCtrl;

Begin
  pDevice := Ptr( nParm );

  With pDevice^ Do
  Begin
    Error.strMessage := '';

    If( OSEnv.nOSVersion < 2 )  Then
    Begin
      {$i-}
      BlockWrite( FileCtrl.fpFile, Buffer.pDevData^, 1 );
      Error.nErrorCode := IOResult;
      {$i+}
    End
    Else
    Begin
      Error.nErrorCode := 0;

      If( FileBlockWrite( FileCtrl.nFileHandle,
                          Buffer.pDevData^,
                          Buffer.nDeviceBufferSize ) = ctReadWriteError )  Then
        Error.nErrorCode := GetLastErrorCode;
    End;

    bEndOfSector := __CheckOSEndOfFile( pDevice^ );
  End;
End;

(**
  * Implement the method to control error handling.
  * @param nParm The address of the @see TDeviceCtrl structure
  * with device parameters;
  *)
Procedure ErrorHandlingFileDev( nParm : Integer );
Var
        pDevice : ^TDeviceCtrl;

Begin
  pDevice := Ptr( nParm );

  With pDevice^ Do
  Begin
    If( OSEnv.nOSVersion < 2 )  Then
    Begin
      Case Error.nErrorCode Of
        ctTPFileNotFound  :  Error.strMessage := 'File not found';
        ctTPUnexpectedEOF :  Error.strMessage := 'End of file';
        ctTPSeekBeyondEOF :  Error.strMessage := 'Seek beyond end of file';
        Else  Error.strMessage := 'Error - Verify the device';
      End;
    End
    Else
      GetErrorMessage( Error.nErrorCode, Error.strMessage );
  End;
End;
