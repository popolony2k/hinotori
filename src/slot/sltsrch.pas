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
Function FindSignature( Var strSignature : TTinyString;
                        nAddress : Integer ) : TSlotNumber;
Var
        nSlotNumber     : TSlotNumber;
        bResult         : Boolean;
        strTmp          : TTinyString;
        nCount,
        nPrimarySlot,
        nSecondarySlot,
        nSignatureSize  : Byte;

Begin
  nPrimarySlot   := 0;
  nSignatureSize := Byte( strSignature[0] ) - 1;
  strTmp[0]      := strSignature[0];
  bResult        := False;

  (* Search by the signature's  slot *)
  Repeat
    nSecondarySlot := 0;

    Repeat
      nSlotNumber := MakeSlotNumber( nPrimarySlot, nSecondarySlot );

      For nCount := 0 To nSignatureSize Do
        strTmp[nCount+1] := Char( RDSLT( nSlotNumber,
                                         ( nAddress + nCount ) ) );
      bResult := ( strTmp = strSignature );

      If( Not bResult )  Then
        nSecondarySlot := nSecondarySlot + 1;
    Until( bResult Or ( nSecondarySlot = ctMaxSecSlots ) );

    If( Not bResult )  Then
      nPrimarySlot := nPrimarySlot + 1;
  Until( bResult Or ( nPrimarySlot = ctMaxSlots ) );

  If( Not bResult )  Then
    FindSignature := ctUnitializedSlot
  Else
    FindSignature := nSlotNumber;
End;
