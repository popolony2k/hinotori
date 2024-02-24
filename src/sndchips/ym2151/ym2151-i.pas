(*<ym2151-i.pas>
 * Library for YM2151 (SFG-05/SFG-01) soundchip handling.
 * CopyLeft (c) 1995-2024 by PopolonY2k.
 * CopyLeft (c) since 2024 by Hinotori Team.
 *)

(*
 * This module depends on folowing include files (respect the order):
 * - /system/types.pas;
 * - /system/sysvars.pas;
 * - msxbios.pas;
 * - sltsrch.pas;
 *)

Const
       { YM2151 related constants }
       ctYM2151Identification            = $80;   { YM2151 string ident. }


(**
  * Find the slot that YM2151 lives in.
  * @param nPrimarySlot The primary slot number returned;
  * @param nSecondarySlot The secondary slot number returned;
  *)
Procedure FindYM2151( Var nPrimarySlot, nSecondarySlot : Byte );
Const
        ctPPISlotSel    : Byte    = $A8;       { PPI slot selection }
        ctSubSlotSel    : Integer = $FFFF;     { Sub slot selection }
Var
        strSignature : String[6];
        nSlotNumber  : TSlotNumber;
        nSlotPages   : Byte;

Begin
  strSignature := 'MCHFM0';
  {$v-}
  nSlotNumber := FindSignature( strSignature, ctYM2151Identification );
  {$v+}

  If( nSlotNumber = ctUnitializedSlot )  Then
  Begin
    nPrimarySlot   := ctUnitializedSlot;
    nSecondarySlot := ctUnitializedSlot;
  End
  Else
  Begin
    SplitSlotNumber( nSlotNumber, nPrimarySlot, nSecondarySlot );

    (*
     * Get the active sub-slots for all selected pages based on the primary
     * slot where YM2151 is connected.
     * For more information about memory slot selection, please check:
     * http://www.angelfire.com/art2/unicorndreams/msx/RR-PPI.html
     *)
    nSlotPages     := ( ( Not SLTTBL[nPrimarySlot] ) And $FC );
    nSecondarySlot := ( nSecondarySlot Or nSlotPages );

    (*
     * The YM2151 primary slot and the secondary slot must be positioned on
     * page 0.
     * Activates page 3 on selected Slot for accessing the SubSlot selection
     * register and respectively activates page 0 for YM2151 access.
     *)
    nSlotPages   := ( nPrimarySlot ShL 6 );
    nPrimarySlot := ( ( nPrimarySlot Or $3C ) Or nSlotPages );

    (* Get the active slots for all other pages *)
    nSlotPages   := Port[ctPPISlotSel] Or $C3;
    nPrimarySlot := nPrimarySlot And nSlotPages;
  End;
End;
