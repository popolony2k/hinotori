(*<databufr.pas>
 * Generic buffer management helper functions.
 * CopyLeft (c) 1995-2024 by PopolonY2k.
 * CopyLeft (c) since 2024 by Hinotori Team.
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
