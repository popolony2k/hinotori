;<system2.asm>
; Z80 and MSX related system routines.
; CopyLeft (c) 1995-2024 by PopolonY2k.
; CopyLeft (c) since 2024 by Hinotori Team.
;

.z80
external nMode    ; The current TR running mode

GETCPU   equ    00183h     ; GETCPU TurboR BIOS call
CALSLT   equ    0001Ch     ; CALSLT BIOS call

         ; Main routine

         ld ix, GETCPU
         ld iy, 0
         call CALSLT
         ld (nMode), a
         end
