(**<databufr.pas>
  * Generic buffer management helper functions.
  * CopyLeft (c) since 1995 by PopolonY2k.
  *)

 (**
  *
  * $Id: databufr.pas 128 2020-07-08 17:51:23Z popolony2k $
  * $Author: popolony2k $
  * $Date: 2020-07-08 14:51:23 -0300 (Wed, 08 Jul 2020) $
  * $Revision: 128 $
  * $HeadURL: https://svn.code.sf.net/p/oldskooltech/code/msx/trunk/msxdos/pascal/databufr.pas $
  *)

(*
 * This module depends on folowing include files (respect the order):
 * -
 *)

(**
  * Get a data specified by position for a given buffer.
  * @param pBufferAddr The buffer address containing the data to be
  * retrieved;
  * @param nReturnValueAddr The value's address of the data that will be
  * retrieved (Must have the same size as specified by nCount);
  * @param nBufferIndex The starting index inside the buffer to be retrieved;
  * @param nCount The number of bytes to copy into the return pointer;
  *)
Procedure GetData( nBufferAddr,
                   nReturnValueAddr,
                   nBufferIndex, nCount : Integer );
Begin
  Move( Mem[nBufferAddr + nBufferIndex],
        Mem[nReturnValueAddr], nCount );
End;
