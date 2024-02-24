(*<vgmgd3.pas>
 * Library for VGM music handling.
 * Check for newer VGM format definition at following URL address below
 * http://www.smspower.org/Music/VGMFileFormat?from=Development.VGMFormat
 * CopyLeft (c) since 1995 by PopolonY2k.
 *)

(**
  *
  * $Id: vgmgd3.pas 128 2020-07-08 17:51:23Z popolony2k $
  * $Author: popolony2k $
  * $Date: 2020-07-08 14:51:23 -0300 (Wed, 08 Jul 2020) $
  * $Revision: 128 $
  * $HeadURL: https://svn.code.sf.net/p/oldskooltech/code/msx/trunk/msxdos/pascal/vgmgd3.pas $
  *)

(*
 * This module depends on folowing include files (respect the order):
 * - databufr.pas;
 * - types.pas;
 * - vgmtypes.pas;
 *)


(**
  * GD3 v1.00 Specification according the following URL below.
  * http://www.smspower.org/uploads/Music/gd3spec100.txt
  *)
Type TGD3Tags = Record
  aIdentification   : Array[0..3] Of Char;
  nVersionNumber    : TInt32;
  nDataSize         : TInt32;
  pData             : Pointer;
End;


(**
  * Retrieve the GD3 Tags present at the end of file, if is available.
  * @param data The @see TVGMData structure containing the VGM data
  * where the GD3 tags will be retrieved;
  * @param gd3Tags The @see TGD3Tags that will receive the GD3 tags loaded
  * from @see TGVMData;
  *)
Procedure GetGD3Tags( Var data : TVGMData; Var gd3Tags : TGD3Tags );
Var
        nStep,
        nGD3Position : Integer;

Begin
  (*
   * Copy just the 16Bit part of GD3Offset because the library won't
   * handle large files containing 32Bit amount of data.
   *)
  Move( data.header.nGD3Offset, nGD3Position, SizeOf( nGD3Position ) );

  If( nGD3Position > 0 )  Then
  Begin
    nGD3Position := nGD3Position + ctGD3Offset;

    (* GD3 Identification *)
    GetData( Ord( data.pVGMSongBuffer ),
             Addr( gd3Tags.aIdentification ),
             nGD3Position,
             SizeOf( gd3Tags.aIdentification ) );
    nStep := SizeOf( gd3Tags.aIdentification );

    (* GD3 Version Number *)
    GetData( Ord( data.pVGMSongBuffer ),
             Addr( gd3Tags.nVersionNumber ),
             nGD3Position + nStep,
             SizeOf( gd3Tags.nVersionNumber ) );
    nStep := nStep + SizeOf( gd3Tags.nVersionNumber );

    (* GD3 Data size *)
    GetData( Ord( data.pVGMSongBuffer ),
             Addr( gd3Tags.nDataSize ),
             nGD3Position + nStep,
             SizeOf( gd3Tags.nDataSize ) );
    nStep := nStep + SizeOf( gd3Tags.nDataSize );

    (* GD3 pointer to data area *)
    gd3Tags.pData := Ptr( Ord( data.pVGMSongBuffer ) + nStep );
  End;
End;

(**
  * Return a GD3 Tag string based on specified index.
  * @param nIndex The index of string that will be retrieved;
  *)
Function GetGD3TagIndex( gd3Tags : TGD3Tags; nIndex : Byte ) : TString;
Begin
  { TODO: FINISH HIM !!!! }
  GetGD3TagIndex := '';
End;
