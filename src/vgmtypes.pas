(*<vgmtypes.pas>
 * Library for VGM music handling.
 * Check for newer VGM format definition at following URL address below
 * http://www.smspower.org/Music/VGMFileFormat?from=Development.VGMFormat
 * CopyLeft (c) since 1995 by PopolonY2k.
 *)

(**
  *
  * $Id: vgmtypes.pas 128 2020-07-08 17:51:23Z popolony2k $
  * $Author: popolony2k $
  * $Date: 2020-07-08 14:51:23 -0300 (Wed, 08 Jul 2020) $
  * $Revision: 128 $
  * $HeadURL: https://svn.code.sf.net/p/oldskooltech/code/msx/trunk/msxdos/pascal/vgmtypes.pas $
  *)

(*
 * This module depends on folowing include files (respect the order):
 * - types.pas;
 *)


(**
  * Header size of each specification version.
  * Versions prior to 1.50 are 64 bytes size and the header cannot be
  * calculated by VGMdata offset field.
  *)
Const   ctHeaderSizeVer100      = 64;    { 64 bytes prior 1.50 versions }
        ctHeaderSizeVer160      = 128;
        ctHeaderSizeVer170      = 256;

(**
  * Header position index (Version 1.70). All fields are 32Bit, except when
  * the comments shows the field's real size.
  *)
        ctGD3Offset             = $14;   { GD3 Offset    }

(**
  * Common VGM commands.
  *)
        ctLoopOffset            = $1C;   { Loop offset   }

(**
  * Memory management based constants.
  *)
        ctVGMMaxMapperSegs      = $FF;   { Maximum mapper segments }

(**
  * VGM memory data reserved address (MSX specific)
  *)
        ctVGMSelectedPage       = $02;   { Selected page for VGM data }
        ctVGMDataPageAddress    = $8000; { VGM data in page ctVGMSelectedPage }

(**
  * VGM Buffer status definition.
  *)
Type     TVGMStatus = ( StateProcessingHeader,
                        StateSuccessfullyLoaded,
                        StateUninitialized,
                        StateInvalidFileFormat,
                        StateInvalidHeaderData,
                        StateNoMemoryMapper,
                        StateNotEnoughMemory );

(**
  * VGM Header with specific header data with full support to header and
  * information of VGM format.
  *)
Type TVGMHeader = Record
  nEOFOffset        : TInt32;                 { 1.00 Version  }
  nVersionNumber    : TInt32;                 { 1.00 Version  }
  nGD3Offset        : TInt32;                 { 1.00 Version  }
  nTotalSamples     : TInt32;                 { 1.00 Version  }
  nLoopOffset       : TInt32;                 { 1.00 Version  }
  nLoopSamples      : TInt32;                 { 1.00 Version  }
  nRate             : TInt32;                 { 1.01 Version  }
  nVGMDataOffset    : TInt32;                 { 1.50 Version  }
End;

(**
  * Mapper segment slot addressing.
  *)
Type TVGMMapperSegmentSlot = Record
  nSlotId           : TSlotNumber;            { Mapper allocated slot number }
  nSegmentId        : Byte;                   { Mapper allocated Segment Id  }
End;

(**
  * Memory management structure used for mapper handling.
  *)
Type TVGMMapper = Record
  aSegments         : Array[0..ctVGMMaxMapperSegs] Of TVGMMapperSegmentSlot;
  nSegCounter       : Byte;                  { Segment counter              }
  nPriMapperSlotId  : TSlotNumber;           { Primary mapper slot id       }
End;

(**
  * VGM data structure containing the chip's stored raw data commands.
  *)
Type PVGMData = ^TVGMData;
     TVGMData = Record
  header            : TVGMHeader;             { Some mandatory header data   }
  mapper            : TVGMMapper;             { Mapper handler               }
  pVGMSongBuffer    : PDynByteArray;          { Header + Pre-processed VGM   }
  nHeaderSize       : Integer;
  nDataSize         : Integer;
  status            : TVGMStatus;
End;
