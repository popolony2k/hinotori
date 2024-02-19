; <rdseg.asm>
; Mapper functions implementation for Turbo Pascal 3.
; CopyLeft (c) 1995-2024 by PopolonY2k.
; CopyLeft (c) since 2024 by Hinotori Team.
;

.z80
external nJmpTblAddr  ; The pointer to the RD_SEG routine in the jump table
external nValue       ; The returned data from RD_SEG routine
external nSegmentId   ; The segment id that will be passed to the routine
external nAddress     ; The address to read within the specified segment

         ; This function simulate a CALL the RD_SEG routine by using JP

         ld hl, retj
         push hl
         ld   a, (nSegmentId)
         ld   hl,(nAddress)
         ld   ix,(nJmpTblAddr)
         jp   (ix)
retj:    ld   (nValue), a
         end
