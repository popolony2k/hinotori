(*<slotutil.pas>
 * Slot utilities management function library.
 * CopyLeft (c) 1995-2024 by PopolonY2k.
 * CopyLeft (c) since 2024 by Hinotori Team.
 *)

(*
 * This module depends on folowing include files (respect the order):
 * -
 *)


(**
  * Get the slot number of a given memory address passed by
  * parameter.
  * This function works only when the machine has a disk drive or hard
  * disk interface connected;
  * @param nAddress The address to check the slot number;
  *)
Function GetSlotNumberByAddress( nAddress : Integer ) : Byte;
Var
       nRAMAD0 : Byte Absolute $f341; { Slot address of RAM in page 0 }
       nRAMAD1 : Byte Absolute $f342; { Slot address of RAM in page 1 }
       nRAMAD2 : Byte Absolute $f343; { Slot address of RAM in page 2 }
       nRAMAD3 : Byte Absolute $f344; { Slot address of RAM in page 3 }
       nRet    : Byte;
Begin
  nRet := -1; { Something is wrong }

  If( ( nAddress >= $0000 ) And ( nAddress <= $4000 ) ) Then
    nRet := nRAMAD0
  Else
  If( ( nAddress > $4000 ) And ( nAddress <= $8000 ) ) Then
    nRet := nRAMAD1
  Else
  If( ( nAddress > $8000 ) And ( nAddress <= $C000 ) ) Then
    nRet := nRAMAD2
  Else
  If( ( nAddress > $C000 ) And ( nAddress <= $FFFF ) ) Then
    nRet := nRAMAD3;

  GetSlotNumberByAddress := nRet;
End;
