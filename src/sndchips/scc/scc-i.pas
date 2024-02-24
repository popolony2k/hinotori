(*<scc-i.pas>
 * Library for SCC soundchip handling.
 * Thanks to BIFI's website at http://bifi.msxnet.org/msxnet/tech/scc
 * CopyLeft (c) 1995-2024 by PopolonY2k.
 * CopyLeft (c) since 2024 by Hinotori Team.
 *)

(*
 * This module depends on folowing include files (respect the order):
 * - /system/types.pas;
 * - /system/sysvars.pas;
 * - msxbios.pas;
 *)


(**
  * Find the slot that SCC lives in.
  * @param nPrimarySlot The primary slot number returned;
  * @param nSecondarySlot The secondary slot number returned;
  *)
Procedure FindSCC( Var nPrimarySlot, nSecondarySlot : Byte );
Const
        ctPPISlotSel    : Byte = $A8;       { PPI slot selection }
Var
        bResult         : Boolean;
        nCount          : Integer;
        nSlotPages      : Byte;
        nSlotNumber     : TSlotNumber;

Begin
  nPrimarySlot := 0;

  (* Search for SCC slot *)
  Repeat
    nSecondarySlot := 0;

    Repeat
      bResult := True;
      nSlotNumber := MakeSlotNumber( nPrimarySlot, nSecondarySlot );

      (*
       * Following the http://bifi.msxnet.org/msxnet/tech/scc we can find
       * that to activate the SCC on MSX is needed just to write $3F to
       * bank select register 3 (some place between memory address to $9000
       * to $97FF) to activate it.
       * After this, you can read and write at $9800 to $9FFF.
       *)
      WRSLT( nSlotNumber, $9000, $3F );

      (*
       * Check for a memory behavior specific of SCC soundchip.
       * The memory area from $9800 to $987F behaves as RAM, so we can write
       * something there and try to read the same content.
       *)
      For nCount := $9800 To $987F Do
      Begin
        WRSLT( nSlotNumber, nCount, $7F );
        bResult := bResult And ( RDSLT( nSlotNumber, nCount ) = $7F );
      End;

      If( bResult )  Then
      Begin
        (*
         * The memory area between $9880 to $98FF is write only, so if you
         * try to read it, it'll always return $FF.
         * WARNING: To the test below the range considered is just between
         * $9880 to $988E, because the $988F is a on/off switch to channels
         * 1 to 5, so if we test it they would be reseted and the SCC
         * channels won't play anymore.
         *)
        For nCount := $9880 To $988E Do
        Begin
          WRSLT( nSlotNumber, nCount, 1 );
          bResult := bResult And ( RDSLT( nSlotNumber, nCount ) = $FF );
        End;
      End;

      If( Not bResult )  Then
        nSecondarySlot := nSecondarySlot + 1;
    Until( bResult Or
           ( nSecondarySlot = ctMaxSecSlots ) Or
           ( EXPTBL[nPrimarySlot] = 0 ) );

    If( Not bResult )  Then
      nPrimarySlot := nPrimarySlot + 1;
  Until( bResult Or ( nPrimarySlot = ctMaxSlots ) );

  If( Not bResult )  Then
  Begin
    nPrimarySlot   := ctUnitializedSlot;
    nSecondarySlot := ctUnitializedSlot;
  End
  Else
  Begin
    (*
     * Get the active sub-slots for all selected pages based on the primary
     * slot where SCC is connected.
     * For more information about memory slot selection, please check:
     * http://www.angelfire.com/art2/unicorndreams/msx/RR-PPI.html
     *)
    nSlotPages     := ( Not SLTTBL[nPrimarySlot] ) And $CF;
    nSecondarySlot := ( ( ( nSecondarySlot ShL 4 ) Or $CF ) Or nSlotPages );

    (*
     * The SCC primary slot and the secondary slot must be positioned on the
     * 2nd page.
     * Activates page 3 on selected Slot for accessing the SubSlot selection
     * register and respectively activates page 2 for SCC accessing.
     *)
    nSlotPages   := ( nPrimarySlot ShL 6 );
    nPrimarySlot := ( ( ( nPrimarySlot ShL 4 ) Or $0F ) Or nSlotPages );

    (* Get the active slots for all other pages *)
    nSlotPages   := Port[ctPPISlotSel] Or $F0;
    nPrimarySlot := nPrimarySlot And nSlotPages;
  End;
End;
