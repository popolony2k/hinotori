; <y8950.asm>
; Library for the Y8950 soundchip handling.
; CopyLeft (c) 1995-2024 by PopolonY2k.
; CopyLeft (c) since 2024 by Hinotori Team.
;

.z80
external __pSndChipArrayParms ; The Y8950 params byte array (REGISTER|DATA)

Y8950REGWRITE   equ    00C0h  ; Y8950 write register address
Y8950STATUSREG  equ    00C4h  ; Y8950 status port

         ; Main routine

         ld  hl,(__pSndChipArrayParms)

         ld  c,Y8950REGWRITE          ; Write register
         outi
         in  a,(Y8950STATUSREG)       ; Wait for Y8950 to be ready (TR only)
         inc c
         outi
endf:    end
