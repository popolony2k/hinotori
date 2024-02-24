(*<ftdefs.pas>
 * File transfer definitions used by send and recv file transfer tools.
 * CopyLeft (c) since 1995 by PopolonY2k.
 *)

(**
  *
  * $Id: ftdefs.pas 128 2020-07-08 17:51:23Z popolony2k $
  * $Author: popolony2k $
  * $Date: 2020-07-08 14:51:23 -0300 (Wed, 08 Jul 2020) $
  * $Revision: 128 $
  * $HeadURL: https://svn.code.sf.net/p/oldskooltech/code/msx/trunk/msxdos/pascal/ftdefs.pas $
  *)

(*
 * This module depends on folowing include files (respect the order):
 * -
 *)

(*
 * Module definitions.
 *)
Const           ctFileNameChunk        = 0;     { File name chunk }
                ctNextChunk            = 1;     { Has next chunk }
                ctLastChunk            = 2;     { Last chunk }
                ctAckChunk             = 3;     { Acknowledgement chunk }
                ctUninitChunk          = 255;   { Uninitalized chunk }
                ctMaxPacketCount       = 255;   { Max packet count }
                ctSendTimeout          = 500;   { I/O Timeout for send }
                ctRecvTimeout          = 2000;  { I/O Timeout for recv }
                ctRetries              = 5;     { I/O retries }

Type TTransferBuffer = Array[0..127] Of Byte;   { Internal transfer buffer }
Type TTransferData = Record                     { I/O transfer Buffer }
  nType,
  nSize,
  nCount   : Byte;
  data     : TTransferBuffer;
End;

Type TAckData = Record                          { Acknowledgement packet }
  nType    : Byte;
  nCount   : Byte;
End;

Type TIOParms = Record                          { Commmunication I/O control }
  nTimeout : Integer;
  nRetries : Byte;
End;
