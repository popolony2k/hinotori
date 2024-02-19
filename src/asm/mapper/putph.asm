; <putph.asm>
; Mapper functions implementation for Turbo Pascal 3.
; CopyLeft (c) 1995-2024 by PopolonY2k.
; CopyLeft (c) since 2024 by Hinotori Team.
;

.z80
external nJmpTblAddr  ; The pointer to the PUT_PH routine in the jump table
external nSegmentId   ; The segment id that will be passed to the routine
external nAddress     ; The address passed to the PUT_PH routine

         ; This function simulate a CALL the PUT_PH routine by using JP

         ld hl, retj
         push hl
         ld   a, (nSegmentId)
         ld   hl,(nAddress)
         ld   ix,(nJmpTblAddr)
         jp   (ix)
retj:    end
