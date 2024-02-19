; <calseg.asm>
; Mapper functions implementation for Turbo Pascal 3.
; CopyLeft (c) 1995-2024 by PopolonY2k.
; CopyLeft (c) since 2024 by Hinotori Team.
;

.z80
external nJmpTblAddr  ; The pointer to the CAL_SEG routine in the jump table
external nSegmentId   ; The segment id that will be passed to the routine
external nAddress     ; The address passed to the CAL_SEG routine

         ; This function simulate a CALL the CAL_SEG routine by using JP

         ld hl, retj
         push hl
         ld   iy,(nSegmentId)
         ld   ix,(nAddress)
         ld   hl,(nJmpTblAddr)
         jp   (hl)
retj:    end
