(*<ym2413-i.pas>
 * Library for the YM2413 soundchip handling.
 * CopyLeft (c) 1995-2024 by PopolonY2k.
 * CopyLeft (c) since 2024 by Hinotori Team.
 *)

(*
 * This module depends on folowing include files (respect the order):
 * - /system/types.pas;
 * - msxbios.pas;
 * - sltsrch.pas;
 *)

Const
       { YM2413 related constants }
       ctFMPACIdentAddr      : Integer   = $401C; { FMPAC ident. address     }
       ctMSXMusicIdentAddr   : Integer   = $4018; { MSX-Music ident. address }
       ctActivateFMPACIOPort : Integer   = $7FF6; { FMPAC activate I/O port  }
       ctFMPACSignature      : String[4] = 'OPLL';{ FMPAC signature          }
       ctMSXMusicSignature   : String[8] = 'APRLOPLL';{ MSX-Music signature  }


(**
  * Find the slot that YM2413 lives in.
  * Thanks to BIFI's website at http://bifi.msxnet.org/blog/index.php?m=08&y=11
  *)
Function FindYM2413 : TSlotNumber;
Var
        nSlotNumber : TSlotNumber;

Begin
  {$v-}
  nSlotNumber := FindSignature( ctMSXMusicSignature, ctMSXMusicIdentAddr );

  If( nSlotNumber = ctUnitializedSlot )  Then
  Begin
    nSlotNumber := FindSignature( ctFMPACSignature, ctFMPACIdentAddr );

    (* Activate FMPAC I/O port mode instead default memory mode *)
    If( nSlotNumber <> ctUnitializedSlot )  Then
      WRSLT( nSlotNumber, ctActivateFMPACIOPort, 1 );
  End;
  {$v+}

  FindYM2413 := nSlotNumber;
End;
