;<math2.asm>
; Implement extende math functions present in new
; Turbo Pascal releases and other languages;
; CopyLeft (c) 1995-2024 by PopolonY2k.
; CopyLeft (c) since 2024 by Hinotori Team.
;

.z80
;
; Thanks to MSX Assembly pages for hosting this routine and Flyguille (MNBIOS)
; for writting this routine;
; The rouding part of this routine was written by PopolonY2k
; The original routine can be found at:
; http://map.grauw.nl/articles/mult=div=shitfs.php#div
;
external nDividend     ; The dividend
external nDivisor      ; The divisor
external nResult       ; The returning result
external nRest         ; The rest of the operation


         ; Main routine
div16:   ld   bc, (nDividend)
         ld   de, (nDivisor)

         ld   hl, 0
         ld   a, b
         ld   b, 8
loop1:   rla
         adc  hl, hl
         sbc  hl, de
         jr   nc, noadd1
         add  hl, de
noadd1:  djnz loop1
         ld   b, a
         ld   a, c
         ld   c, b
         ld   b, 8
loop2:   rla
         adc  hl, hl
         sbc  hl, de
         jr   nc, noadd2
         add  hl, de
noadd2:  djnz loop2
         rla
         cpl
         ld   b, a
         ld   a, c
         ld   c, b
         rla
         cpl
         ld   b, a
         ld   (nRest), hl
         ld   (nResult), bc
         end
