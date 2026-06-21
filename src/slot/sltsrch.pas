(*<sltsrch.pas>
 * Library for slot searching handling.
 * CopyLeft (c) 1995-2024 by PopolonY2k.
 * CopyLeft (c) since 2024 by Hinotori Team.
 *)

(*
 * This module depends on folowing include files (respect the order):
 * - /system/types.pas
 * - /bios/msxbios.pas
 *)

(**
  * Find a signature specified by parameter, return the slot where the
  * signature was found.
  * @param nSlotNumber The @see TSlotNumber to receive the slot information
  * where the signature was found;
  * @param strSignature The string containing the signature to found;
  * @param nAddress The starting address where the signature will be
  * searched;
  *)
function FindSignature( var strSignature : TTinyString;
                        nAddress : integer ) : TSlotNumber;
var
        nSlotNumber     : TSlotNumber;
        bResult         : boolean;
        strTmp          : TTinyString;
        nCount,
        nPrimarySlot,
        nSecondarySlot,
        nSignatureSize  : byte;

begin
  nPrimarySlot   := 0;
  nSignatureSize := byte( strSignature[0] ) - 1;
  strTmp[0]      := strSignature[0];
  bResult        := false;

  (* Search by the signature's  slot *)
  repeat
    nSecondarySlot := 0;

    repeat
      nSlotNumber := MakeSlotNumber( nPrimarySlot, nSecondarySlot );

      for nCount := 0 to nSignatureSize do
        strTmp[nCount+1] := char( RDSLT( nSlotNumber,
                                         ( nAddress + nCount ) ) );
      bResult := ( strTmp = strSignature );

      if( not bResult )  then
        nSecondarySlot := nSecondarySlot + 1;
    until( bResult or ( nSecondarySlot = ctMaxSecSlots ) );

    if( not bResult )  then
      nPrimarySlot := nPrimarySlot + 1;
  until( bResult or ( nPrimarySlot = ctMaxSlots ) );

  if( not bResult )  then
    FindSignature := ctUnitializedSlot
  else
    FindSignature := nSlotNumber;
end;
