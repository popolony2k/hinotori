; <YM2413.asm>
; Library for the YM2413 soundchip handling.
; CopyLeft (c) 1995-2024 by PopolonY2k.
; CopyLeft (c) since 2024 by Hinotori Team.
;

.z80
external __pSndChipArrayParms  ; The YM2413 params byte array (INDEX|DATA)

YM2413INDEX      equ    007Ch  ; YM2413 index

         ; Main routine

         ld   hl,(__pSndChipArrayParms)
         ld   c,YM2413INDEX
         outi
         push ix    ; Wait some cycles because this routine is too
         pop  ix    ; fast when executed in a Turbo R machine.
         inc  c
         outi
endf:    end
