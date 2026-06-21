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
type TOutputHandle = record
  nConOutPtr : integer;
end;


(**
  * Read data from VRAM using direct access through
  * VDP I/O ports.
  * @param nX The position based on X-AXIS of screen;
  * @param nY The position based on Y-AXIS of screen;
  * The function return the data read;
  *)
function DirectRead( nX, nY : byte ) : byte;
var
      nAddr    : integer;
      nData    : byte;
      LINL40   : byte absolute $F3AE; { Width for SCREEN 0 }

begin
  nAddr := ( $000 + ( LINL40 * ( nY - 1 ) ) + ( nX - 1 ) );

  inline( $F3 );                              { DI              }
  Port[$99] := Lo( nAddr );
  Port[$99] := ( Hi( nAddr ) and $3F ) or $40;

  inline( $DB/$98/                            { IN A,( 98h )    }
          $DB/$98/                            { IN A,( 98h )    }
          $32/nData                           { LD ( nData ), A }
        );

  inline( $FB );                              { EI              }

  DirectRead := nData;
end;

(**
  * Write a character to VRAM using direct access through
  * VDP I/O ports.
  * @param chChar The character to write;
  *)
procedure DirectWrite( chChar : char );
var
       nAddr    : integer;
       LINL40   : byte absolute $F3AE; { Width for SCREEN 0 }
       CRTCNT   : byte absolute $F3B1; { Number of lines on screen }
       CSRY     : byte absolute $F3DC; { Current row-position of the cursor }
       CSRX     : byte absolute $F3DD; { Current col-position of the cursor }

begin
  if( not ( chChar in[ #10, #13] ) )  then     { Isn't CR/LF ?? }
  begin
    nAddr := ( ( LINL40 * ( CSRY - 1 ) ) + ( CSRX - 1 ) );

    inline( $F3 );                              { DI }
    Port[$99] := Lo( nAddr );
    Port[$99] := ( Hi( nAddr ) and $3F ) or $40;
    Port[$98] := byte( chChar );
    inline( $FB );                              { EI }

    { Increase the cursor position }
    if( CSRX < LINL40 )  then
      CSRX := Succ( CSRX );
  end
  else
    if( ( chChar = #10 ) and ( CSRY < CRTCNT ) ) then  { Line feed ?? }
    begin
      CSRY := Succ( CSRY );
      CSRX := 1;
    end;
end;

(**
  * Read a VRAM data region using direct access through
  * VDP I/O ports.
  * @param nX1 The start position based on X-AXIS of screen;
  * @param nY1 The start position based on Y-AXIS of screen;
  * @param nBufferAddr The buffer address that will receive data;
  * This routine doesn't check VRAM screen boundaries (for performance);
  *)
procedure DirectReadToBuffer( nX1, nY1, nX2, nY2 : byte;
                              nBufferAddr : integer );
var
      nAddr    : integer;
      nCountX,
      nCountY,
      nData    : byte;
      LINL40   : byte absolute $F3AE; { Width for SCREEN 0 }

begin
  inline( $F3 );                              { DI              }

  for nCountX := nX1 to nX2 do
    for nCountY := nY1 to nY2 do
    begin
      nAddr     := ( $000 + ( LINL40 * ( nCountY - 1 ) ) + ( nCountX - 1 ) );
      Port[$99] := Lo( nAddr );
      Port[$99] := ( Hi( nAddr ) and $3F ) or $40;

      inline( $DB/$98/                        { IN A,( 98h )    }
              $DB/$98/                        { IN A,( 98h )    }
              $32/nData                       { LD ( nData ), A } );
      Mem[nBufferAddr] := nData;
      nBufferAddr := Succ( nBufferAddr );
    end;

  inline( $FB );                              { EI              }
end;

(**
  * Write a data buffer directly to VRAM using direct access through
  * VDP I/O ports.
  * @param nX1 The start position based on X-AXIS of screen;
  * @param nY1 The start position based on Y-AXIS of screen;
  * @param nBufferAddr The buffer address with data content to transfer;
  * This routine doesn't check VRAM screen boundaries (for performance);
  *)
procedure DirectWriteToBuffer( nX1, nY1, nX2, nY2 : byte;
                               nBufferAddr : integer );
var
       nCountX,
       nCountY  : byte;
       nAddr    : integer;
       LINL40   : byte absolute $F3AE; { Width for SCREEN 0 }

begin
  inline( $F3 );                              { DI }
  for nCountX := nX1 to nX2 do
    for nCountY := nY1 to nY2 do
    begin
      nAddr     := ( ( LINL40 * ( nCountY - 1 ) ) + ( nCountX - 1 ) );
      Port[$99] := Lo( nAddr );
      Port[$99] := ( Hi( nAddr ) and $3F ) or $40;
      Port[$98] := Mem[nBufferAddr];
      nBufferAddr := Succ( nBufferAddr );
    end;
  inline( $FB );                              { EI }
end;

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
procedure OpenDirectTextMode( var handle : TOutputHandle );
begin
  handle.nConOutPtr := ConOutPtr;
  ConOutPtr := Addr( DirectWrite );
end;

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
procedure CloseDirectTextMode( var handle : TOutputHandle );
begin
  ConOutPtr := handle.nConOutPtr;
  FillChar( handle, sizeof( handle ), -1 );
end;
