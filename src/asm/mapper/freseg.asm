; <freseg.asm>
; Mapper functions implementation for Turbo Pascal 3.
; CopyLeft (c) 1995-2024 by PopolonY2k.
; CopyLeft (c) since 2024 by Hinotori Team.
;

.z80
external nSlotId      ; The slot parameter
external nJmpTblAddr  ; The pointer to the FRE_SEG routine in the jump table
external nRetCode     ; The return code from FRE_SEG routine
external nSegmentId   ; The segment id that will be released

         ; This function simulate a CALL the FRE_SEG routine by using JP

         ld hl, retj
         push hl
         ld   a, (nSlotId)
         ld   b, a
         ld   a, (nSegmentId)
         ld   hl,(nJmpTblAddr)
         jp   (hl)
retj:    ld   h, 0
         jr   c, endf
         ld   h, 1
endf:    ld   a, h
         ld   (nRetCode), a
         end
