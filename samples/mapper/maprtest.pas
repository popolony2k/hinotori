(*<maprtest.pas>
 * Memory mapper routines test.
 *
 * - Routines tested:
 * - InitMapper;
 * - GetMapperPageByAddress;
 * - PutMapperPageByAddress;
 * - AllocMapperSegment;
 * - FreeMapperSegment;
 *
 * CopyLeft (c) 1995-2024 by PopolonY2k.
 * CopyLeft (c) since 2024 by Hinotori Team.
 *)


{-----------------------------------------------------------------------------}
{                      PopolonY2k Framework dependencies                      }
{-----------------------------------------------------------------------------}

{$i ..\..\src\system\types.pas}
{$i ..\..\src\util\helpchar.pas}
{$i ..\..\src\bios\msxbios.pas}
{$i ..\..\src\bios\extbio.pas}
{$i ..\..\src\mapper\maprdefs.pas}
{$i ..\..\src\mapper\maprbase.pas}
{$i ..\..\src\mapper\maprallc.pas}
{$i ..\..\src\mapper\maprpage.pas}

{-----------------------------------------------------------------------------}
{                             Module definitions                              }
{-----------------------------------------------------------------------------}

Type TMappedBuffer = Array[0..ctMapperPageSize] Of Char; { Mapped 16K bufr }


{-----------------------------------------------------------------------------}
{                              Helper functions                               }
{-----------------------------------------------------------------------------}

(**
  * Print part of a buffer content passed as reference.
  * @param aBuffer Reference to buffer to be printed;
  *)
Procedure PrintBuffer( Var aBuffer : TMappedBuffer );
Const
       __ctMaxCol   : Byte = 10;

Var
       x, y  : Byte;

Begin
  For y := 0 To __ctMaxCol Do
    For x := 0 To __ctMaxCol Do
    Begin
      GotoXY( ( x + 1 ), ( y + 1 ) );
      Write( aBuffer[( x + y ) * __ctMaxCol] );
    End;

  WriteLn;
  WriteLn( 'Press <enter> to continue' );
  ReadLn;
  ClrScr;
End;

{-----------------------------------------------------------------------------}
{                    Main program variables and constants                     }
{-----------------------------------------------------------------------------}

Const
           ctDefaultPage  = $8000;     { Default page for data - Page 2 }

Var
      maprHandle       : TMapperHandle;
      chKey            : Char;
      nActiveSegmentId : Byte;
      aSegments        : Array[0..1] Of Byte;
      aDataBuffer      : TMappedBuffer Absolute ctDefaultPage;


{-----------------------------------------------------------------------------}
{                          Main program entry point                           }
{-----------------------------------------------------------------------------}

Begin    { Main program entry }
  ClrScr;

  { Initialize mapper system }
  If( Not InitMapper( maprHandle ) )  Then
  Begin
    WriteLn( 'Error to initialize Mapper' );
    Exit;
  End;

  WriteLn( 'Mapper succesfully initialized' );

  { Get the current segment used by data buffer on stack }
  aSegments[0] := GetMapperPageByAddress( maprHandle, Addr( aDataBuffer ) );

  WriteLn( 'Main Segment -> ', aSegments[0], ' on page 2' );
  WriteLn( 'Press <enter> to see it''s content' );
  ReadLn;
  ClrScr;

  { Fill page 2 on Main Segment, fully with X character }
  FillChar( aDataBuffer, SizeOf( aDataBuffer ), 'X' );
  PrintBuffer( aDataBuffer );

  { Alloc new segment to put data (MSXDOS2 BIOS) }
  If( Not AllocMapperSegment( maprHandle,
                              UseSpecifiedSlotOnly,
                              maprHandle.nPriMapperSlotId,
                              UserSegment, aSegments[1] ) )  Then
  Begin
    WriteLn( 'Mapper segment allocation failed' );
    Exit;
  End;

  WriteLn( 'New Segment -> ', aSegments[1], ' successfully allocated' );
  WriteLn( 'Type <enter> to see it''s content' );
  ReadLn;
  ClrScr;

  { Activate page 2 content to the New Segment allocated }
  PutMapperPageByAddress( maprHandle, aSegments[1], Addr( aDataBuffer ) );

  { Fill page 2 on New Segment fully with Y character }
  FillChar( aDataBuffer, SizeOf( aDataBuffer ), 'Y' );

  PrintBuffer( aDataBuffer );

  nActiveSegmentId := aSegments[1];

  { Handle user switch segment contents }
  Repeat
    GotoXY( 1, 19 );
    WriteLn( 'Active Segment -> ', nActiveSegmentId );
    WriteLn;
    WriteLn( '0 - Switch to Main Segment ', aSegments[0] );
    WriteLn( '1 - Switch to New Segment  ', aSegments[1] );
    WriteLn( 'ESC - exit' );
    chKey := ReadKey;

    If( chKey In ['0', '1'] ) Then
    Begin
      nActiveSegmentId := aSegments[Byte( chKey ) - Byte( '0' )];

      { Activate page 2 content to segment chosen by user }
      PutMapperPageByAddress( maprHandle,
                              nActiveSegmentId,
                              Addr( aDataBuffer ) );

      { Show segment content }
      PrintBuffer( aDataBuffer );
    End;
  Until( chKey = #27 );

  WriteLn;

  { Release all segments allocated by the application }
  If( Not FreeMapperSegment( maprHandle,
                             maprHandle.nPriMapperSlotId,
                             aSegments[1] ) ) Then
  Begin
    WriteLn( 'SegmentId -> ', aSegments[1], ' deallocation failed' );
    Exit;
  End;

  WriteLn( 'All segments successfully deallocated' );
End.
