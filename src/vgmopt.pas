(*<vgmopt.pas>
 * Library for VGM music handling.
 * Check for newer VGM format definition at following URL address below
 * http://www.smspower.org/Music/VGMFileFormat?from=Development.VGMFormat
 * CopyLeft (c) since 1995 by PopolonY2k.
 *)

(**
  *
  * $Id: vgmopt.pas 128 2020-07-08 17:51:23Z popolony2k $
  * $Author: popolony2k $
  * $Date: 2020-07-08 14:51:23 -0300 (Wed, 08 Jul 2020) $
  * $Revision: 128 $
  * $HeadURL: https://svn.code.sf.net/p/oldskooltech/code/msx/trunk/msxdos/pascal/vgmopt.pas $
  *)

(*
 * This module depends on folowing include files (respect the order):
 * - memory.pas;
 * - types.pas;
 * - vgmtypes.pas;
 * - databufr.pas;
 *)


(**
  * Header position index (Version 1.70). All fields are 32Bit, except when
  * the comments shows the field's real size.
  *)
Const
        ctVolumeModifier        = $7C; { Volume Modifier - 8Bit }
        ctLoopBase              = $7E; { Loop Base - 8Bit }
        ctLoopModifier          = $7F; { Loop modifier - 8Bit }


(**
  * VGM Header with optional fields used by the VGM Format.
  *)
Type TVGMOptionalHeader = Record
  nLoopModifier     : Byte;                { 1.51 Version  }
  nVolumeModifier   : Byte;                { 1.60 Version  }
  nLoopBase         : Byte;                { 1.60 Version  }
End;



(**
  * Refresh all optional fields from the pointer buffer to the structure
  * data according the protocol version.
  * Add newer optional fields here always when needed;
  * @param data The @see TVGMData structure containing the VGM data to
  * copy the Optional header information;
  * @param header The @see TVGMOptionalHeader that will receive the data;
  *)
Procedure RefreshOptionalFields( Var data   : TVGMData;
                                 Var header : TVGMOptionalHeader );
Begin
  With header Do
  Begin
    (* Since protocol 1.60 *)
    If( ( data.header.nVersionNumber[0] >= $60 ) And
        ( data.header.nVersionNumber[1] >= $1 ) )  Then
    Begin
      (* Volume modifier *)
      GetData( Ord( data.pVGMSongBuffer ),
               Addr( nVolumeModifier ),
               ctVolumeModifier,
               SizeOf( nVolumeModifier ) );

      (* Loop modifier *)
      GetData( Ord( data.pVGMSongBuffer ),
               Addr( nLoopModifier ),
               ctLoopModifier,
               SizeOf( nLoopModifier ) );

      (* Loop Base *)
      GetData( Ord( data.pVGMSongBuffer ),
               Addr( nLoopBase ),
               ctLoopBase,
               SizeOf( nLoopBase ) );
    End;
  End;
End;
