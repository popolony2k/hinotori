;<wait.asm>
; Implements an accurate wait routine, splitting time into a specific
; divisor, useful for high frequency music player routines.
; This module implements a Sleep routine based on VBLANK ticks.
;
; CopyLeft (c) 1995-2024 by PopolonY2k.
; CopyLeft (c) since 2024 by Hinotori Team.
;

.z80
external  __nWaitInterval         ; The sleep interval to wait
external  __nLastWaitInterval     ; The wait interval from previous iteration
external  __nFreqDivisor          ; Frequency divisor for waiting process
external  __nRemaining            ; Remaining samples from last wait operation

JIFFY     equ    0FC9Eh           ; JIFFY system variable

;
; Main routine
;

          ld   hl, (__nWaitInterval)
          ld   bc, (__nLastWaitInterval)
          add  hl, bc
          ld   (__nLastWaitInterval), hl
          ld   bc, (__nRemaining)
          sbc  hl, bc
          jr   c,  endfn
          ld   de, (__nFreqDivisor)
loop:     ld   a,  (JIFFY)
          ld   b,  a
wait:     cp   b
          ld   a,  (JIFFY)
          jr   z,  wait
          sbc  hl, de
          jr   z,  endlop
          jr   nc, loop
endlop:   ld   a, h
          cpl
          ld   h, a
          ld   a, l
          cpl
          ld   l, a
          inc  hl
          ld   (__nRemaining), hl
          ld   hl, 0000h
          ld   (__nLastWaitInterval), hl
endfn:    end
