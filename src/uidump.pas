(*<uidump.pas>
 * MSXDD Dump Tool user interface implementation.
 * CopyLeft (c) since 1995 by PopolonY2k.
 *)

(**
  *
  * $Id: uidump.pas 128 2020-07-08 17:51:23Z popolony2k $
  * $Author: popolony2k $
  * $Date: 2020-07-08 14:51:23 -0300 (Wed, 08 Jul 2020) $
  * $Revision: 128 $
  * $HeadURL: https://svn.code.sf.net/p/oldskooltech/code/msx/trunk/msxdos/pascal/uidump.pas $
  *)

(*
 * This source file depends on following include files (respect the order):
 * - types.pas;
 * - systypes.pas;
 * - helpchar.pas;
 * - helpcnv.pas;
 * - conbios.pas;
 * - vdpbios.pas;
 * - msxbios.pas;
 * - conio.pas;
 * - twindow.pas;
 * - ttext.pas;
 * - mddtypes.pas;
 * - funcptr.pas;
 * - math.pas;
 * - math16.pas;
 * - bigint.pas;
 * - doscodes.pas;
 *)

(* Constants to control dimension/position of screen components *)

Const     ctErrMsgX       : Byte = 12;     { Error message coordinates }
          ctErrMsgY       : Byte = 22;
          ctHexaX         : Byte = 3;      { Hexa display coordinates }
          ctHexaY         : Byte = 3;
          ctCharX         : Byte = 29;     { Character display coordinates }
          ctCharY         : Byte = 3;
          ctColsChar      : Byte = 7;      { Columns of character display }
          ctRowsChar      : Byte = 15;     { Rows of character display }
          ctColsHexa      : Byte = 23;     { Columns of hexa display }
          ctRowsHexa      : Byte = 15;     { Rows of hexa display }
          ctLStatusX      : Byte = 4;      { Left block status msg coordinates }
          ctLStatusY      : Byte = 22;
          ctLStatusBarX1  : Byte = 1;      { Left Status bar coordinates }
          ctLStatusBarY1  : Byte = 21;
          ctLStatusBarX2  : Byte = 11;
          ctLStatusBarY2  : Byte = 23;
          ctMaxTitleSize  : Byte = 23;     { Window title size }
          { Buffer management constants }
          ctInternalError        = -1;     { Internal error return code }
          ctUpdateContent        = 0;      { Update content return code }

(* Constants to control the screen massages and labels *)

          ctEditLabel        : String[4]  = 'EDIT';    { Edit label }
          ctDiskLabel        : String[4]  = 'DISK';    { Disk label }
          ctNotEnoughtMemory : String[18] = 'NOT ENOUGHT MEMORY';

(*
 * Internal structure to optimize the math operations for used
 * in device pointer management.
 *)
Type TOperations = Record
  nZero,
  nOne         : Byte;
  nRes         : TInt24;
  bigZero,
  bigOne,
  bigRes,
  bigDevicePtr : TBigInt;
End;


(**
  * Initialize the @see TOperations structure.
  * @param device The reference to @see TDeviceCtrl used to initialize the
  * @see TOperations structure;
  * @param oper The @see TOperations to initialize;
  *)
Procedure InitOperations( Var device : TDeviceCtrl;
                          Var oper : TOperations );
Begin
  With oper Do
  Begin
    With bigRes Do
    Begin
      nSize  := SizeOf( nRes );
      pValue := Ptr( Addr( nRes ) );
    End;

    With bigZero Do
    Begin
      nSize  := SizeOf( nZero );
      pValue := Ptr( Addr( nZero ) );
    End;

    With bigOne Do
    Begin
      nSize  := SizeOf( nOne );
      pValue := Ptr( Addr( nOne ) );
    End;

    nZero := 0;
    nOne  := 1;

    With bigDevicePtr Do
    Begin
      nSize  := SizeOf( device.Buffer.nDevicePtr );
      pValue := Ptr( Addr( device.Buffer.nDevicePtr ) );
    End;
  End;
End;

(**
  * Wait for the user entry and update the @see TBufferCtrl data based on
  * accepted keys and shortcuts.
  * ctKbKeyUp, ctKbKeyRight, ctKbCtrlA  - Increase I/O pointer;
  * ctKbKeyDown, ctKbKeyLeft, ctKbCtrlR - Decrease I/O pointer;
  * ctKbEsc     - Esc key pressed;
  * ctKbCtrlE   - <CTRL> + E pressed;
  * ctKbCtrlG   - <CTRL> + G pressed;
  * ctKbSelect  - Select key pressed;
  * ctKbNothing - No valid keys pressed;
  * The function return @see ctUpdateContent constant for
  * any pointer moving keyboard combination <CTRL>+A, <CTRL>+R, ...;
  * @param device The reference to @see TDeviceCtrl to update the buffer
  * based on typed key;
  * @param oper The @see TOperations struct with pre-initialized
  * data for device pointer math operations;
  *)
Function WaitUserInput( Var device : TDeviceCtrl;
                        Var oper : TOperations ) : Integer;
Var
      nRetKey  : Byte;
      opCode   : TOperationCode;
      cmpCode  : TCompareCode;

Begin
  opCode  := Success;
  nRetKey := Byte( ReadKey );

  With device Do
  Begin
    Case( nRetKey ) Of
      ctKbKeyRight,
      ctKbKeyUp,
      ctKbCtrlA  : Begin
                     Buffer.nMemoryPtr := ( Buffer.nMemoryPtr +
                                            ctScreenPageSize );

                     If( Buffer.nMemoryPtr >= Buffer.nDeviceBufferSize ) Then
                     Begin
                       If( Not bEndOfSector ) Then
                       Begin
                         opCode := AddBigInt( oper.bigRes,
                                              oper.bigDevicePtr,
                                              oper.bigOne );
                             If( opCode = Success )  Then
                         Begin
                           Buffer.nMemoryPtr := 0;
                           opCode := AssignBigInt( oper.bigDevicePtr,
                                                   oper.bigRes );
                         End;
                       End
                   Else
                       Begin
                         opCode := SubBigInt( oper.bigRes,
                                              oper.bigDevicePtr,
                                              oper.bigOne );
                         If( opCode = Success )  Then
                         Begin
                           opCode := AssignBigInt( oper.bigDevicePtr,
                                                   oper.bigRes );
                           Buffer.nMemoryPtr := Abs( Buffer.nDeviceBufferSize -
                                                     ctScreenPageSize );
                         End;
                       End;
                     End;

                     If( opCode = Success )  Then
                       nRetKey := ctUpdateContent
                     Else
                     Begin
                       nRetKey := ctInternalError;
                       Buffer.nMemoryPtr := ( Buffer.nMemoryPtr -
                                              ctScreenPageSize );
                     End;
                   End;
      ctKbKeyLeft,
      ctKbKeyDown,
      ctKbCtrlR  : Begin
                     cmpCode := CompareBigInt( oper.bigDevicePtr,
                                               oper.bigZero );
                     Buffer.nMemoryPtr := ( Buffer.nMemoryPtr -
                                            ctScreenPageSize );
                     If( ( Buffer.nMemoryPtr < 0 ) And
                         ( cmpCode = GreaterThan ) ) Then
                     Begin
                       opCode := SubBigInt( oper.bigRes,
                                            oper.bigDevicePtr,
                                            oper.bigOne );
                       If( opCode = Success )  Then
                       Begin
                         opCode := AssignBigInt( oper.bigDevicePtr,
                                                 oper.bigRes );
                         Buffer.nMemoryPtr := Abs( Buffer.nDeviceBufferSize -
                                                   ctScreenPageSize );
                       End;
                     End
                     Else
                       If( ( cmpCode = Equals ) And
                           ( Buffer.nMemoryPtr < 0 ) ) Then
                         Buffer.nMemoryPtr := 0;

                     If( opCode = Success )  Then
                       nRetKey := ctUpdateContent
                     Else
                     Begin
                       nRetKey := ctInternalError;
                       Buffer.nMemoryPtr := ( Buffer.nMemoryPtr +
                                              ctScreenPageSize );
                     End;
                   End;
      ctKbEsc,
      ctKbCtrlE,
      ctKbCtrlS,
      ctKbSelect :  Begin
                      If( bEndOfSector ) Then
                      Begin
                        opCode := SubBigInt( oper.bigRes,
                                             oper.bigDevicePtr,
                                             oper.bigOne );
                        If( opCode = Success )  Then
                        Begin
                          opCode := AssignBigInt( oper.bigDevicePtr,
                                                  oper.bigRes );
                          bEndOfSector := False;
                        End;
                      End;
                    End;

      Else nRetKey := ctKbNothing;
    End;
  End;

  WaitUserInput := nRetKey;
End;

(**
  * Show the I/O error messages on specific window position at screen.
  * @param device The device structure containing the error information;
  *)
Procedure ShowIOError( Var device : TDeviceCtrl );
Begin
  { Call the driver error handling }
  CallProc( device.nErrorHandlingFnAddr, Addr( device ) );

  WaitBlinking( ctErrMsgX, ctErrMsgY, device.Error.strMessage );
End;

(**
  * Show a message on left side status bar.
  * @param pstrMessage The message string to show;
  *)
Procedure ShowLeftStatusMsg( Var strMessage : TTinyString );
Begin
  _GotoXY( ctLStatusX, ctLStatusY );
  Write( strMessage );
End;

(**
  * Build all frames of the dump editor.
  *)
Procedure ShowFrames;
Begin
  { Hexadecimal frame }
  OpenWindow( ( ctHexaX - 2 ),
              ( ctHexaY - 2 ),
              ( ctHexaX + ctColsHexa + 1 ),
              ( ctHexaY + ctRowsHexa + 2 ) );

  { Character frame }
  OpenWindow( ( ctCharX - 2 ),
              ( ctCharY - 2 ),
              ( ctCharX + ctColsChar + 2 ),
              ( ctCharY + ctRowsChar + 2 ) );

  { Frame division borders }
  _GotoXY( ( ctCharX - 2 ), ( ctCharY - 2 ) );
  Write( #18 );

  _GotoXY( ( ctCharX - 2 ), ( ctCharY + ctRowsChar + 2 ) );
  Write( #17 );

  { Status bar ( Left + Right ) }
  OpenWindow( ctLStatusBarX1,
              ctLStatusBarY1,
              ctLStatusBarX2,
              ctLStatusBarY2 );
  ShowLeftStatusMsg( ctDiskLabel );

  OpenWindow( ctLStatusBarX2,
              ctLStatusBarY1,
              ( ctCharX + ctColsChar + 2 ),
              ctLStatusBarY2 );

  { Status bar division borders }
  _GotoXY( ctLStatusBarX2, ctLStatusBarY1 );
  Write( #18 );

  _GotoXY( ctLStatusBarX2, ctLStatusBarY2 );
  Write( #17 );
End;

(**
  * Show the buffer on character display.
  * @param BufferCtrl The buffer to print;
  *)
Procedure ShowCharDisplay( Var BufferCtrl : TBufferCtrl );
Var
      nCountI,
      nCountJ,
      nBuffCount  : Byte;
      nBaseAddr   : Integer;

Begin
  nBuffCount := 0;

  With BufferCtrl Do
  Begin
    nCountJ := 0;
    nBaseAddr := Addr( pDevData^ );

    While( nCountJ <= ctRowsChar ) Do
    Begin
      nCountI := 0;

      While( nCountI <= ctColsChar ) Do
      Begin
        _GotoXY( ( nCountI + ctCharX ), ( nCountJ + ctCharY ) );

        If( IsChar( Mem[nBaseAddr + nBuffCount + nMemoryPtr] ) ) Then
          Write( Char( Mem[nBaseAddr + nBuffCount + nMemoryPtr] ) )
        Else
          Write( '.' );

        nCountI := nCountI + 1;
        nBuffCount := nBuffCount + 1;
      End;

      nCountJ := nCountJ + 1;
    End;
  End;

  _GotoXY( ctHexaX, ctHexaY );
End;

(**
  * Show the buffer on hexadecimal display.
  * @param BufferCtrl The buffer to print;
  *)
Procedure ShowHexaDisplay( Var BufferCtrl : TBufferCtrl );
Var
      nCountI,
      nCountJ,
      nBuffCount  : Byte;
      nBaseAddr   : Integer;

Begin
  nBuffCount := 0;

  With BufferCtrl Do
  Begin
    nCountJ := 0;
    nBaseAddr := Addr( pDevData^ );

    While( nCountJ <= ctRowsHexa ) Do
    Begin
      nCountI := 0;

      While( nCountI <= ctColsHexa ) Do
      Begin
        _GotoXY( ( nCountI + ctHexaX ), ( nCountJ + ctHexaY ) );

        Write( ByteToHexa( Mem[nBaseAddr + nBuffCount + nMemoryPtr] ) );
        nCountI := nCountI + 3;
        nBuffCount := nBuffCount + 1;
      End;

      nCountJ := nCountJ + 1;
    End;
  End;
End;

(**
  * Edit the hexadecimal data of buffer of current memory pointer
  * block.
  * @param BufferCtrl Reference to a @see TBufferCtrl data to edit;
  *)
Procedure EditHexaData( Var BufferCtrl : TBufferCtrl );
Var
      nCurX,
      nCurY,
      nBufX,
      nBufY,
      nKeyCode   : Byte;
      strValue   : THexadecimal;
      nBaseAddr,
      nAddr,
      nIntVal,
      nTemp      : Integer;

(**
  * Update the editor cursor based on key code;
  *)
Procedure _UpdateCursor;
Begin
  { Key processing }
  Case( nKeyCode ) Of
    ctKbKeyUp    :  If( nCurY > ctHexaY )  Then
                    Begin
                      nCurY := ( nCurY - 1 );
                      nBufY := ( nBufY - 1 );
                    End;

    ctKbKeyDown  :  If( nCurY < ( ctHexaY + ctRowsHexa ) )  Then
                    Begin
                      nCurY := ( nCurY + 1 );
                      nBufY := ( nBufY + 1 );
                    End;

    ctKbKeyLeft  :  If( nCurX > ctHexaX )  Then
                    Begin
                      nCurX := ( nCurX - 3 );
                      nBufX := ( nBufX - 1 );
                    End;

    ctKbKeyRight :  If( nCurX < ( ctHexaX + ctColsHexa - 2 ) )  Then
                    Begin
                      nCurX :=  ( nCurX + 3 );
                      nBufX :=  ( nBufX + 1 );
                    End;
  End;
End;

Begin                { EditHexaData entry-point }
  nCurX := ctHexaX;
  nCurY := ctHexaY;
  nBufX := 0 ;
  nBufY := 0 ;
  nBaseAddr := Addr( BufferCtrl.pDevData^ );

  ShowLeftStatusMsg( ctEditLabel );
  SetCursorStatus( CursorEnabled );

  Repeat
    With BufferCtrl Do
    Begin
      nAddr := nBaseAddr + nMemoryPtr +
               IndexArray( nBufY, nBufX, ( ctColsChar + 1 ) );
      strValue := ByteToHexa( Mem[nAddr] );
      nKeyCode := GetString( nCurX, nCurY, strValue, 2, True, False );
      Val( '$' + strValue, nIntVal, nTemp );
      Mem[nAddr] := nIntVal;

      _GotoXY( ( ctCharX + nBufX ), ( ctCharY + nBufY ) );

      If( IsChar( Mem[nAddr] ) )  Then
        Write( Char( Mem[nAddr] ) )
      Else
        Write( '.' );

      _UpdateCursor;
    End;
  Until( nKeyCode In [ctKbSelect, ctKbEsc] );

  ShowLeftStatusMsg( ctDiskLabel );
  SetCursorStatus( CursorDisabled );
End;

(**
  * Show the dump data to the device assigned by the @see TDeviceCtrl.
  * This is the kernel of editor.
  * @param device The reference to the @see TDeviceCtrl assigned to a
  * valid device.
  *)
Procedure Dump( Var device : TDeviceCtrl );
Var
      bExit       : Boolean;
      nVal        : Byte;
      nDeviceAddr : Integer;
      strTitle    : TTinyString;
      oper        : TOperations;

Begin
  ShowFrames;
  InitOperations( device, oper );

  nDeviceAddr := Addr( device );

  { Get the device parameters }
  CallProc( device.nGetDevParmsFnAddr, nDeviceAddr );

  If( device.Error.nErrorCode <> 0 ) Then
  Begin
    ShowIOError( device );
    Exit;
  End
  Else
  Begin
    If( Abs( MemAvail ) >= device.Buffer.nDeviceBufferSize )  Then
    Begin
      { Allocate the device buffer data memory }
      GetMem( device.Buffer.pDevData, device.Buffer.nDeviceBufferSize );

      { Open the device }
      CallProc( device.nOpenDevFnAddr, nDeviceAddr );

      If( device.Error.nErrorCode = 0 )  Then
      Begin
        { Center the file name on the hexa decimal window, if any }
        If( Length( device.FileCtrl.strFileName ) > 0 )  Then
        Begin
          strTitle := device.FileCtrl.strFileName;

          If( Length( strTitle ) > ctMaxTitleSize )  Then  { Cut the title }
          Begin
            strTitle[0] := Char( ctMaxTitleSize - 3 );
            strTitle := strTitle + '...';
          End;

          nVal := ctHexaX + ( ( ctColsHexa - 2 - Length( strTitle ) ) Div 2 );
          _GotoXY( nVal, ( ctHexaY - 2 ) );
          Write( '[' + strTitle + ']' );
        End;

        bExit := False;
        nVal  := ctUpdateContent;

        Repeat
          Case( nVal ) Of
            ctInternalError :  Begin
                                 device.Error.nErrorCode := ctDOSInternalError;
                                 ShowIOError( device );
                               End;

            ctUpdateContent :  Begin
                                 { Seek to the next sector/record }
                                 CallProc( device.nSeekDevFnAddr,
                                           nDeviceAddr );

                                 { Load the sector/record }
                                 If( device.Error.nErrorCode = 0 ) Then
                                   CallProc( device.nReadDevFnAddr,
                                             nDeviceAddr );

                                 If( device.Error.nErrorCode <> 0 )  Then
                                   ShowIOError( device );

                                 ShowHexaDisplay( device.Buffer );
                                 ShowCharDisplay( device.Buffer );
                               End;
            ctKbEsc         :  bExit := True;
            ctKbCtrlE,
            ctKbSelect      :  EditHexaData( device.Buffer );
            ctKbCtrlS       :  Begin
                                 { Seek to the start of last loaded sector }
                                 CallProc( device.nSeekDevFnAddr,
                                           nDeviceAddr );

                                 { Write sector/record to disk }
                                 If( device.Error.nErrorCode = 0 )  Then
                                   CallProc( device.nWriteDevFnAddr,
                                             nDeviceAddr );

                                 If( device.Error.nErrorCode <> 0 )  Then
                                   ShowIOError( device );
                               End;
          End;

          If( Not bExit )  Then
            nVal := WaitUserInput( device, oper );

        Until( bExit );

        { Deallocate the device buffer data memory }
        FreeMem( device.Buffer.pDevData, device.Buffer.nDeviceBufferSize );

        { Close the device }
        CallProc( device.nCloseDevFnAddr, nDeviceAddr );
      End
      Else
        ShowIOError( device );
    End
    Else
      WaitBlinking( ctErrMsgX, ctErrMsgY, ctNotEnoughtMemory );
  End;
End;

