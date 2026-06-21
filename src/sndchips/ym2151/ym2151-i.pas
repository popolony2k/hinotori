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

const
       { YM2151 related constants }
       ctYM2151Identification            = $80;   { YM2151 string ident. }


(**
  * Find the slot that YM2151 lives in.
  * @param nPrimarySlot The primary slot number returned;
  * @param nSecondarySlot The secondary slot number returned;
  *)
procedure FindYM2151( var nPrimarySlot, nSecondarySlot : byte );
const
        ctPPISlotSel    : byte    = $A8;       { PPI slot selection }
        ctSubSlotSel    : integer = $FFFF;     { Sub slot selection }
var
        strSignature : string[6];
        nSlotNumber  : TSlotNumber;
        nSlotPages   : byte;

begin
  strSignature := 'MCHFM0';
  {$v-}
  nSlotNumber := FindSignature( strSignature, ctYM2151Identification );
  {$v+}

  if( nSlotNumber = ctUnitializedSlot )  then
  begin
    nPrimarySlot   := ctUnitializedSlot;
    nSecondarySlot := ctUnitializedSlot;
  end
  else
  begin
    SplitSlotNumber( nSlotNumber, nPrimarySlot, nSecondarySlot );

    (*
     * Get the active sub-slots for all selected pages based on the primary
     * slot where YM2151 is connected.
     * For more information about memory slot selection, please check:
     * http://www.angelfire.com/art2/unicorndreams/msx/RR-PPI.html
     *)
    nSlotPages     := ( ( not SLTTBL[nPrimarySlot] ) and $FC );
    nSecondarySlot := ( nSecondarySlot or nSlotPages );

    (*
     * The YM2151 primary slot and the secondary slot must be positioned on
     * page 0.
     * Activates page 3 on selected Slot for accessing the SubSlot selection
     * register and respectively activates page 0 for YM2151 access.
     *)
    nSlotPages   := ( nPrimarySlot shl 6 );
    nPrimarySlot := ( ( nPrimarySlot or $3C ) or nSlotPages );

    (* Get the active slots for all other pages *)
    nSlotPages   := Port[ctPPISlotSel] or $C3;
    nPrimarySlot := nPrimarySlot and nSlotPages;
  end;
end;
