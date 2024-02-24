(*<vgmfile.pas>
 * Library for VGM music handling.
 * Check for newer VGM format definition at following URL address below
 * http://www.smspower.org/Music/VGMFileFormat?from=Development.VGMFormat
 * CopyLeft (c) since 1995 by PopolonY2k.
 *)

(**
  *
  * $Id: vgmfile.pas 145 2021-05-05 02:54:06Z popolony2k $
  * $Author: popolony2k $
  * $Date: 2021-05-04 23:54:06 -0300 (Tue, 04 May 2021) $
  * $Revision: 145 $
  * $HeadURL: https://svn.code.sf.net/p/oldskooltech/code/msx/trunk/msxdos/pascal/vgmfile.pas $
  *)

(*
 * This module depends on folowing include files (respect the order):
 * - types.pas;
 * - databufr.pas;
 * - msxdos.pas;
 * - msxdos2.pas;
 * - msxbios.pas;
 * - dos2file.pas;
 * - vgmtypes.pas;
 * - extbio.pas;
 * - maprdefs.pas;
 * - maprbase.pas;
 * - maprallc.pas;
 * - maprpage.pas;
 *)

(**
  * Header position index (Version 1.70). All fields are 32Bit, except when
  * the comments shows the field's real size.
  *)
Const
        ctFileIdentification    = $00;   { File identification }
        ctEOFOffset             = $04;   { End of File Offset  }
        ctVersionNumber         = $08;   { VGM Version number  }
        ctTotalSamples          = $18;   { Total samples }
        ctLoopSamples           = $20;   { Loop samples  }
        ctRate                  = $24;   { Rate          }
        ctVGMDataOffset         = $34;   { VGM data offset }
        ctReserved1             = $7D;   { Reserved - 8Bit }
        ctReserved2             = $97;   { Reserved - 8Bit }
        ctReserved3             = $B8;   { Reserverd }
        ctExtraHeaderOffset     = $BC;   { Extra header offset }
        ctReserved4             = $C0;   { Reserved - Free space }


(**
  * Open a specified VGM file passed by parameter, returning the header
  * and VGM data content to play;
  * @param strFileName The file name that will be opened;
  * @param data The @see TVGMData structure containing the VGM
  * data to be played. Is something fails, the bValidContent flag will be
  * False;
  *)
Procedure OpenVGM( strFileName : TFileName; Var data : TVGMData );

(*
 * Internal local constants.
 *)
Const
       __ctDiskBufferSize = 2047;  { The disk buffer size (zero starting) }

(*
 * Local data.
 *)
Var
         hFile,
         nSegmentId,
         nMaxMapperSegsChunks : Byte;
         aDiskBuffer          : Array[0..__ctDiskBufferSize] Of Byte;
         pCurrentPosPtr       : Pointer;
         bError,
         bEndOfFile           : Boolean;
         nActiveSlotId        : TSlotNumber;
         handle               : TMapperHandle;


  (**
    * This procedure retrieves all mandatory fields accepted by all versions
    * of VGM format.
    *)
  Procedure __GetMandatoryFields;
  Begin
    (* EOF Offset *)
    GetData( Addr( aDiskBuffer ),
             Addr( data.header.nEOFOffset ),
             ctEOFOffset,
             SizeOf( data.header.nEOFOffset ) );

    (*
     * FileFormat Version.
     * For versions prior to 1.50, VGM data must start at offset 0x40 so in
     * this case the HeaderSize is 0x40 (64Bytes).
     *)
    GetData( Addr( aDiskBuffer ),
             Addr( data.header.nVersionNumber ),
             ctVersionNumber,
             SizeOf( data.header.nVersionNumber ) );

    (* GD3 Offset *)
    GetData( Addr( aDiskBuffer ),
             Addr( data.header.nGD3Offset ),
             ctGD3Offset,
             SizeOf( data.header.nGD3Offset ) );

    (* Total Samples *)
    GetData( Addr( aDiskBuffer ),
             Addr( data.header.nTotalSamples ),
             ctTotalSamples,
             SizeOf( data.header.nTotalSamples ) );

    (* Loop Offset *)
    GetData( Addr( aDiskBuffer ),
             Addr( data.header.nLoopOffset ),
             ctLoopOffset,
             SizeOf( data.header.nLoopOffset ) );

    (* Loop # samples *)
    GetData( Addr( aDiskBuffer ),
             Addr( data.header.nLoopSamples ),
             ctLoopSamples,
             SizeOf( data.header.nLoopSamples ) );

    (* Rate - Before 1.01 will be filled with zeroes *)
    GetData( Addr( aDiskBuffer ),
             Addr( data.header.nRate ),
             ctRate,
             SizeOf( data.header.nRate ) );

    (* VGM Data Offset - Before 1.01 will be filled with zeroes *)
    GetData( Addr( aDiskBuffer ),
             Addr( data.header.nVGMDataOffset ),
             ctVGMDataOffset,
             SizeOf( data.header.nVGMDataOffset ) );

    (* Calculates the Header size *)
    If( ( data.header.nVersionNumber[0] <= $50 ) And
        ( data.header.nVersionNumber[1] <= $1 ) )  Then
    Begin
      data.nHeaderSize := ctHeaderSizeVer100;
      data.nDataSize   := 0;
    End
    Else
    Begin
      (*
       * Calculates the HeaderSize used by protocol versions equals or higher
       * than 1.50;
       * Copy just the 16Bit part of VGMDataOffset because the library won't
       * handle large files containing 32Bit amount of data.
       *)
      Move( data.header.nVGMDataOffset,
            data.nHeaderSize,
            SizeOf( data.nHeaderSize ) );

      If( data.nHeaderSize > 0 )  Then
        data.nHeaderSize := data.nHeaderSize + ctVGMDataOffset;
    End;

    (* Calculates the DataSize *)
    Move( data.header.nEOFOffset,
          data.nDataSize,
          SizeOf( data.nDataSize ) );
    data.nDataSize := ( data.nDataSize - data.nHeaderSize - ctEOFOffset );
  End;

  (**
    * Check the file status looking for some errors or features that
    * the library still can't handle.
    *)
  Function __CheckFileStatus : Boolean;
  Var
        status : TVGMStatus;

  Begin
    status := data.status;

    If( data.nHeaderSize = 0 )  Then     { Invalid header data }
      data.status := StateInvalidHeaderData;

    __CheckFileStatus := ( status = data.status ); { No changed status }
  End;

  (**
    * Alloc and move data chunks to the allocated memory.
    *)
  Procedure __AllocAndMoveChunks;
  Var
          bAlloc  : Boolean;
          nSlotId : TSlotNumber;

  Begin
    If( nSegmentId = nMaxMapperSegsChunks )  Then
    Begin
      With data Do
      Begin
        nSlotId := nActiveSlotId;
        bAlloc  := AllocMapperSegment( handle,
                                       UseAnotherSlotIfFailCurrentSlot,
                                       nActiveSlotId,
                                       UserSegment,
                                       nSegmentId );

        If( bAlloc )  Then
        Begin
          (*
           * Enable slot/page if mapper slot changed
           *)
          If( nSlotId <> nActiveSlotId )  Then
            ENASLT( nActiveSlotId, ctVGMSelectedPage );

          PutMapperPage( handle, nSegmentId, ctVGMSelectedPage );

          mapper.aSegments[mapper.nSegCounter].nSlotId    := nActiveSlotId;
          mapper.aSegments[mapper.nSegCounter].nSegmentId := nSegmentId;
          mapper.nSegCounter := Succ( mapper.nSegCounter );
          pCurrentPosPtr := Ptr( ctVGMDataPageAddress );
          nSegmentId     := 1;
        End
        Else
          status := StateNotEnoughMemory;
      End;
    End
    Else
    Begin
      bAlloc     := True;
      nSegmentId := Succ( nSegmentId );
    End;

    If( bAlloc )  Then
    Begin
      Move( aDiskBuffer, pCurrentPosPtr^, SizeOf( aDiskBuffer ) );
      pCurrentPosPtr := Ptr( Ord( pCurrentPosPtr ) + SizeOf( aDiskBuffer ) );
    End;
  End;


(*
 * Main entry point for OpenVGM procedure.
 *)
Begin
  FillChar( data.mapper, SizeOf( data.mapper ), 0 );
  nMaxMapperSegsChunks := ( ctMapperPageSize Div SizeOf( aDiskBuffer ) );

  If( InitMapper( handle ) )  Then
  Begin
    nActiveSlotId := handle.nPriMapperSlotId;
    nSegmentId    := nMaxMapperSegsChunks;
    data.mapper.nPriMapperSlotId := handle.nPriMapperSlotId;

    hFile := FileOpen( strFileName, 'r' );

    If( hFile <> ctInvalidFileHandle )  Then
    Begin
      data.status := StateUninitialized;  { The first processing state }

      Repeat
        (*
         * Process the VGM file.
         *)
        bEndOfFile := FileBlockRead( hFile,
                                     aDiskBuffer,
                                     SizeOf( aDiskBuffer ) ) = ctReadWriteError;
        If( Not bEndOfFile )  Then
        Begin
          case( data.status ) Of
            StateUninitialized :
            Begin
              (*
               * Check the file identification in header.
               *)
              If( ( aDiskBuffer[0] = Byte( 'V' ) ) And
                  ( aDiskBuffer[1] = Byte( 'g' ) ) And
                  ( aDiskBuffer[2] = Byte( 'm' ) ) And
                  ( aDiskBuffer[3] = Byte( ' ' ) ) )  Then
              Begin
                (*
                 * Get all mandatory fields and ajust the Header and
                 * Data sizes.
                 *)
                __GetMandatoryFields;

                (*
                 * Check the file status looking by errors and unimplemented
                 * features.
                 *)
                If( __CheckFileStatus )  Then
                Begin
                  (* Point the VGM starting buffer to the Page 2 *)
                  data.pVGMSongBuffer := Ptr( ctVGMDataPageAddress );

                  __AllocAndMoveChunks;

                  If( data.status <> StateNotEnoughMemory )  Then
                    data.status := StateSuccessfullyLoaded;
                End;
              End
              Else
                data.status := StateInvalidFileFormat;
            End;

            StateSuccessfullyLoaded : __AllocAndMoveChunks;
          End;
        End;

        bError := data.status In [StateInvalidHeaderData,
                                  StateUninitialized,
                                  StateInvalidFileFormat,
                                  StateNotEnoughMemory];
      Until( bEndOfFile Or bError );

      (* Close the previously opened file *)
      bEndOfFile := FileClose( hFile );

      (*
       * If everything goes fine, select the first
       * allocated mapper segment.
       *)
      If( Not bError )  Then
      Begin
        (*
         * Enable slot/page if mapper slot changed
         *)
        If( handle.nPriMapperSlotId <> nActiveSlotId ) Then
        Begin
          ENASLT( handle.nPriMapperSlotId, ctVGMSelectedPage );
        End;

        PutMapperPage( handle,
                       data.mapper.aSegments[0].nSegmentId,
                       ctVGMSelectedPage );
      End;
    End;
  End
  Else
    data.status := StateNoMemoryMapper;
End;
