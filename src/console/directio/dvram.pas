(*<dvram.pas>
 * Direct VRAM access functions to optimize screen
 * I/O operations.
 * CopyLeft (c) 1995-2024 by PopolonY2k.
 * CopyLeft (c) since 2024 by Hinotori Team.
 *)

(*
 * This module depends on folowing include files (respect the order):
 * -
 *)

(**
  * @deprecated
  * This handle is deprecated and will be removed soon.
  * Prefer using the newer @see TTextHandle at <txthdnlr.pas>;
  * Handle to direct output operations.
  * Used by @see OpenDirectTextMode() and @see CloseDirectTextMode();
  *)
Type TOutputHandle = Record
  nConOutPtr : Integer;
End;


(**
  * Read data from VRAM using direct access through
  * VDP I/O ports.
  * @param nX The position based on X-AXIS of screen;
  * @param nY The position based on Y-AXIS of screen;
  * The function return the data read;
  *)
Function DirectRead( nX, nY : Byte ) : Byte;
Var
      nAddr    : Integer;
      nData    : Byte;
      LINL40   : Byte Absolute $F3AE; { Width for SCREEN 0 }

Begin
  nAddr := ( $000 + ( LINL40 * ( nY - 1 ) ) + ( nX - 1 ) );

  InLine( $F3 );                              { DI              }
  Port[$99] := Lo( nAddr );
  Port[$99] := ( Hi( nAddr ) And $3F ) or $40;

  InLine( $DB/$98/                            { IN A,( 98h )    }
          $DB/$98/                            { IN A,( 98h )    }
          $32/nData                           { LD ( nData ), A }
        );

  InLine( $FB );                              { EI              }

  DirectRead := nData;
End;

(**
  * Write a character to VRAM using direct access through
  * VDP I/O ports.
  * @param chChar The character to write;
  *)
Procedure DirectWrite( chChar : Char );
Var
       nAddr    : Integer;
       LINL40   : Byte Absolute $F3AE; { Width for SCREEN 0 }
       CRTCNT   : Byte Absolute $F3B1; { Number of lines on screen }
       CSRY     : Byte Absolute $F3DC; { Current row-position of the cursor }
       CSRX     : Byte Absolute $F3DD; { Current col-position of the cursor }

Begin
  If( Not ( chChar In[ #10, #13] ) )  Then     { Isn't CR/LF ?? }
  Begin
    nAddr := ( ( LINL40 * ( CSRY - 1 ) ) + ( CSRX - 1 ) );

    InLine( $F3 );                              { DI }
    Port[$99] := Lo( nAddr );
    Port[$99] := ( Hi( nAddr ) And $3F ) Or $40;
    Port[$98] := Byte( chChar );
    InLine( $FB );                              { EI }

    { Increase the cursor position }
    If( CSRX < LINL40 )  Then
      CSRX := Succ( CSRX );
  End
  Else
    If( ( chChar = #10 ) And ( CSRY < CRTCNT ) ) Then  { Line feed ?? }
    Begin
      CSRY := Succ( CSRY );
      CSRX := 1;
    End;
End;

(**
  * Read a VRAM data region using direct access through
  * VDP I/O ports.
  * @param nX1 The start position based on X-AXIS of screen;
  * @param nY1 The start position based on Y-AXIS of screen;
  * @param nBufferAddr The buffer address that will receive data;
  * This routine doesn't check VRAM screen boundaries (for performance);
  *)
Procedure DirectReadToBuffer( nX1, nY1, nX2, nY2 : Byte;
                              nBufferAddr : Integer );
Var
      nAddr    : Integer;
      nCountX,
      nCountY,
      nData    : Byte;
      LINL40   : Byte Absolute $F3AE; { Width for SCREEN 0 }

Begin
  InLine( $F3 );                              { DI              }

  For nCountX := nX1 To nX2 Do
    For nCountY := nY1 To nY2 Do
    Begin
      nAddr     := ( $000 + ( LINL40 * ( nCountY - 1 ) ) + ( nCountX - 1 ) );
      Port[$99] := Lo( nAddr );
      Port[$99] := ( Hi( nAddr ) And $3F ) or $40;

      InLine( $DB/$98/                        { IN A,( 98h )    }
              $DB/$98/                        { IN A,( 98h )    }
              $32/nData                       { LD ( nData ), A } );
      Mem[nBufferAddr] := nData;
      nBufferAddr := Succ( nBufferAddr );
    End;

  InLine( $FB );                              { EI              }
End;

(**
  * Write a data buffer directly to VRAM using direct access through
  * VDP I/O ports.
  * @param nX1 The start position based on X-AXIS of screen;
  * @param nY1 The start position based on Y-AXIS of screen;
  * @param nBufferAddr The buffer address with data content to transfer;
  * This routine doesn't check VRAM screen boundaries (for performance);
  *)
Procedure DirectWriteToBuffer( nX1, nY1, nX2, nY2 : Byte;
                               nBufferAddr : Integer );
Var
       nCountX,
       nCountY  : Byte;
       nAddr    : Integer;
       LINL40   : Byte Absolute $F3AE; { Width for SCREEN 0 }

Begin
  InLine( $F3 );                              { DI }
  For nCountX := nX1 To nX2 Do
    For nCountY := nY1 To nY2 Do
    Begin
      nAddr     := ( ( LINL40 * ( nCountY - 1 ) ) + ( nCountX - 1 ) );
      Port[$99] := Lo( nAddr );
      Port[$99] := ( Hi( nAddr ) And $3F ) Or $40;
      Port[$98] := Mem[nBufferAddr];
      nBufferAddr := Succ( nBufferAddr );
    End;
  InLine( $FB );                              { EI }
End;

(**
  * @deprecated
  * This routine is deprecated and will be removed soon.
  * Prefer using the newer @see SetTextHandler at <txthndlr.pas>;
  *
  * Open the video to use direct output function
  * @see DirectWrite.
  * @param handle Reference to the struct @see TOutputHandle
  * needed to initialize the direct output text mode;
  *)
Procedure OpenDirectTextMode( Var handle : TOutputHandle );
Begin
  handle.nConOutPtr := ConOutPtr;
  ConOutPtr := Addr( DirectWrite );
End;

(**
  * @deprecated
  * This routine is deprecated and will be removed soon.
  * Prefer using the newer @see RestoreTextHandler at <txthndlr.pas>;
  *
  * Close the direct access video mode, previously opened by
  * @see OpenDirectTextMode(), restoring the old text mode access;
  * @param handle The Reference to struct @see TOutputHandle
  * used to open the direct access mode;
  *)
Procedure CloseDirectTextMode( Var handle : TOutputHandle );
Begin
  ConOutPtr := handle.nConOutPtr;
  FillChar( handle, SizeOf( handle ), -1 );
End;
