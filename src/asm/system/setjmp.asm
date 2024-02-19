;<setjmp.asm>
; Long jump implementation for Turbo Pascal 3.
; Unfortunately this feature doesn't exist in TP3 core language.
; CopyLeft (c) 1995-2024 by PopolonY2k.
; CopyLeft (c) since 2024 by Hinotori Team.
;

.z80
external nAddr           ; The long jump return address

         ; Main routine
         pop  hl
         pop  de
         ld   (nAddr), hl
         push de
         push hl
         end
