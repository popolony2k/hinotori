; <AY8910.asm>
; Library for the AY8910 soundchip handling.
; CopyLeft (c) 1995-2024 by PopolonY2k.
; CopyLeft (c) since 2024 by Hinotori Team.
;

.z80
external __pSndChipArrayParms  ; The AY8910 params byte array (REGISTER|DATA)

AY8910REGWRITE   equ    00A0h  ; AY8910 write register address

         ; Main routine

         ld  hl,(__pSndChipArrayParms)
         ld  c,AY8910REGWRITE
         outi
         inc c
         outi
endf:    end
