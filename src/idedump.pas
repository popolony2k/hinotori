(*<idedump.pas>
 * Sample code using the PopolonY2's IDE function library.
 * CopyLeft (c) since 1995 by PopolonY2k.
 *)
Program IDEDump;

(**
  *
  * $Id: idedump.pas 128 2020-07-08 17:51:23Z popolony2k $
  * $Author: popolony2k $
  * $Date: 2020-07-08 14:51:23 -0300 (Wed, 08 Jul 2020) $
  * $Revision: 128 $
  * $HeadURL: https://svn.code.sf.net/p/oldskooltech/code/msx/trunk/msxdos/pascal/idedump.pas $
  *)

{$v-,c-,u-,a+,r-}

(* Please respect include dependency order *)

{$i memory.pas}
{$i types.pas}
{$i msxbios.pas}
{$i doscodes.pas}
{$i bitwise.pas}
{$i sltsrch.pas}
{$i suntypes.pas}
{$i sunwrksp.pas}
{$i sunio.pas}
{$i math.pas}
{$i math16.pas}
{$i bigint.pas}
{$i helpchar.pas}


(* Module definitions *)
Const
              ctSectorsToRead = 1;    { Number of sectors to read }
              ctSectorSize    = 512;  { Sector buffer size }
              ctMaxCol        = 40;   { Number of chars by column }
              ctDumpScrPosX   = 1;    { Dump screen pos X }
              ctDumpScrPosY   = 10;   { Dump screen pos Y }

(**
  * The sector buffer type.
  *)
Type TSectorBuffer = Array [0..ctSectorSize] Of Byte;


(* Support routines *)

(**
  * Dump the sector buffer to screen.
  * @param buffer The buffer to print on screen;
  * @param nPage The page numbert of data shown on screen;
  *)
Procedure Dump( Var buffer : TSectorBuffer; nPage : Integer );
Var
        nCount,
        nBufferSize : Integer;
        nCountChar  : Byte;

Begin
  nBufferSize := ( SizeOf( buffer ) - 1 );
  nCountChar  := 0;

  GotoXY( ctDumpScrPosX, ctDumpScrPosY );
  WriteLn( 'Page ', nPage );

  For nCount := 0 To nBufferSize Do
  Begin
    nCountChar := nCountChar + 1;

    If( IsChar( buffer[nCount] ) )  Then
      Write( Char( buffer[nCount] ) )
    Else
      Write( '.' );

    If( nCountChar = ctMaxCol )  Then
    Begin
      nCountChar := 0;
      WriteLn;
    End;
  End;
End;


(* Main block *)

Var      info                 : TIDEInfo;
         wrkspc               : TIDEWorkspace;
         sectorBuffer         : TSectorBuffer;
         nKey,
         nDISKIO,
         nPrimarySlot,
         nSecondarySlot       : Byte;
         nWrkspc,
         nPage,
         nSectorBufferAddr    : Integer;
         bSeek                : Boolean;
         n24SectorPos,
         n24Zero,
         n24One,
         n24Result            : TInt24;
         bigSectorPos,
         bigZero,
         bigOne,
         bigResult,
         bigPtrPartitionStart : TBigInt;
         opCode               : TOperationCode;
         cmpCode              : TCompareCode;

Begin
  ClrScr;
  WriteLn( 'MSX IDE low level I/O sample' );
  WriteLn( 'CopyLeft (c) Since 1995 by PopolonY2k' );
  WriteLn( 'http://www.planetamessenger.org' );
  WriteLn;

  GetIDEInfo( info );

  If( info.nSlotNumber <> ctUnitializedSlot )  Then
    Begin
      (* Data initialization *)
      FillChar( wrkspc, SizeOf( TIDEWorkspace ), 0 );
      FillChar( n24SectorPos, SizeOf( n24SectorPos ), 0 );
      FillChar( n24Zero, SizeOf( n24Zero ), 0 );
      FillChar( n24Result, SizeOf( n24Result ), 0 );

      { Setup the 24bit type for sector operations }
      With bigSectorPos Do
      Begin
        nSize  := SizeOf( n24SectorPos );
        pValue := Ptr( Addr( n24SectorPos ) );
      End;

      With bigZero Do
      Begin
        nSize  := SizeOf( n24Zero );
        pValue := Ptr( Addr( n24Zero ) );
      End;

      With bigOne Do
      Begin
        nSize  := SizeOf( n24One );
        pValue := Ptr( Addr( n24One ) );
      End;

      With bigResult Do
      Begin
        nSize  := SizeOf( n24Result );
        pValue := Ptr( Addr( n24Result ) );
      End;

      opCode := StrToBigInt( bigOne, '1' );

      nSectorBufferAddr := Addr( sectorBuffer );

      If( ParamCount > 0 ) Then
        Val( ParamStr( 1 ), nWrkSpc, nPage )
      Else
        nWrkSpc := 0;

      bSeek := True;
      nPage := 0;

      SplitSlotNumber( info.nSlotNumber, nPrimarySlot, nSecondarySlot );

      WriteLn( 'IDE found at Slot -> ',
               nPrimarySlot, '-', nSecondarySlot );

      WriteLn( 'BIOS version      -> ',
               info.nMajor, '.',
               info.nMinor, '.',
               info.nRevision );

      WriteLn;
      WriteLn( '         IDE sector dump (', nWrkSpc, ')' );
      WriteLn( '----------------------------------------' );
      WriteLn;

      If( GetIDEWorkSpace( info, wrkspc ) )  Then
        Begin
          With bigPtrPartitionStart Do
          Begin
            nSize  := SizeOf( TInt24 );
            pValue := Ptr( Addr( wrkspc.ptrDriveField[nWrkSpc]^.n24PartitionStart ) );
          End;

          opCode := AssignBigInt( bigSectorPos, bigPtrPartitionStart );
          opCode := SwapBigInt( bigSectorPos );

          Repeat
            FillChar( sectorBuffer, SizeOf( sectorBuffer ), 0 );

            If( bSeek )  Then
            Begin
              opCode  := SwapBigInt( bigSectorPos );
              nDISKIO := SunAbsoluteSectorRead( info.nSlotNumber,
                                                wrkspc.ptrDriveField[nWrkSpc],
                                                n24SectorPos,
                                                ctSectorsToRead,
                                                nSectorBufferAddr );
              opCode  := SwapBigInt( bigSectorPos );

              If( nDISKIO = ctDISKIOSuccess )  Then
                Dump( sectorBuffer, nPage )
              Else
                WriteLn( 'Error to access the IDE device sector' );
            End;

            While Not KeyPressed Do;
            nKey  := Byte( ReadKey );

            { Perform 24bit operations to navigate on IDE device sectors }
            If( ( nKey = ctKbKeyRight ) Or ( nKey = ctKbKeyUp ) )  Then
            Begin
              opCode := AddBigInt( bigResult, bigSectorPos, bigOne );
              bSeek  := True;
              nPage  := nPage + 1;
            End
            Else
              If( ( nKey = ctKbKeyLeft ) Or ( nKey = ctKbKeyDown ) )  Then
              Begin
                cmpCode := CompareBigInt( bigSectorPos, bigZero );

                If( cmpCode <> Equals )  Then
                Begin
                  opCode := SubBigInt( bigResult, bigSectorPos, bigOne );
                  bSeek  := True;
                  nPage  := nPage - 1;
                End
                Else
                  bSeek := False;
              End
              Else
                bSeek := False;

            opCode := AssignBigInt( bigSectorPos, bigResult );

          Until( nKey = ctKbEsc );

          ClrScr;
        End
      Else
        WriteLn( 'Error to get the IDE workspace information' );
    End
  Else
    WriteLn( 'IDE interface not found' );
End.
