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

const
       { YM2413 related constants }
       ctFMPACIdentAddr      : integer   = $401C; { FMPAC ident. address     }
       ctMSXMusicIdentAddr   : integer   = $4018; { MSX-Music ident. address }
       ctActivateFMPACIOPort : integer   = $7FF6; { FMPAC activate I/O port  }
       ctFMPACSignature      : string[4] = 'OPLL';{ FMPAC signature          }
       ctMSXMusicSignature   : string[8] = 'APRLOPLL';{ MSX-Music signature  }


(**
  * Find the slot that YM2413 lives in.
  * Thanks to BIFI's website at http://bifi.msxnet.org/blog/index.php?m=08&y=11
  *)
function FindYM2413 : TSlotNumber;
var
        nSlotNumber : TSlotNumber;

begin
  {$v-}
  nSlotNumber := FindSignature( ctMSXMusicSignature, ctMSXMusicIdentAddr );

  if( nSlotNumber = ctUnitializedSlot )  then
  begin
    nSlotNumber := FindSignature( ctFMPACSignature, ctFMPACIdentAddr );

    (* Activate FMPAC I/O port mode instead default memory mode *)
    if( nSlotNumber <> ctUnitializedSlot )  then
      WRSLT( nSlotNumber, ctActivateFMPACIOPort, 1 );
  end;
  {$v+}

  FindYM2413 := nSlotNumber;
end;
