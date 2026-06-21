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
function GetSlotNumberByAddress( nAddress : integer ) : byte;
var
       nRAMAD0 : byte absolute $f341; { Slot address of RAM in page 0 }
       nRAMAD1 : byte absolute $f342; { Slot address of RAM in page 1 }
       nRAMAD2 : byte absolute $f343; { Slot address of RAM in page 2 }
       nRAMAD3 : byte absolute $f344; { Slot address of RAM in page 3 }
       nRet    : byte;
begin
  nRet := -1; { Something is wrong }

  if( ( nAddress >= $0000 ) and ( nAddress <= $4000 ) ) then
    nRet := nRAMAD0
  else
  if( ( nAddress > $4000 ) and ( nAddress <= $8000 ) ) then
    nRet := nRAMAD1
  else
  if( ( nAddress > $8000 ) and ( nAddress <= $C000 ) ) then
    nRet := nRAMAD2
  else
  if( ( nAddress > $C000 ) and ( nAddress <= $FFFF ) ) then
    nRet := nRAMAD3;

  GetSlotNumberByAddress := nRet;
end;
