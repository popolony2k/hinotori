(*<vgmmem.pas>
 * Library for VGM music handling.
 * Check for newer VGM format definition at following URL address below
 * http://www.smspower.org/Music/VGMFileFormat?from=Development.VGMFormat
 * CopyLeft (c) since 1995 by PopolonY2k.
 *)

(**
  *
  * $Id: vgmmem.pas 128 2020-07-08 17:51:23Z popolony2k $
  * $Author: popolony2k $
  * $Date: 2020-07-08 14:51:23 -0300 (Wed, 08 Jul 2020) $
  * $Revision: 128 $
  * $HeadURL: https://svn.code.sf.net/p/oldskooltech/code/msx/trunk/msxdos/pascal/vgmmem.pas $
  *)

(*
 * This module depends on folowing include files (respect the order):
 * - types.pas;
 * - vgmtypes.pas;
 *)


(**
  * Releases the VGM loaded by @see OpenVGM function. Call this method
  * is mandatory when the user won't use the VGM data content anymore.
  * This releases all allocated memory for the VGM data.
  * @param data Reference to the @see TVGMData with the data
  * to be released;
  *)
Procedure ReleaseVGM( Var data : TVGMData );
Begin
  data.pVGMSongBuffer := Nil;
End;
