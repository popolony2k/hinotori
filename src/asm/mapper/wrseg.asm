; <wrseg.asm>
; Mapper functions implementation for Turbo Pascal 3.
; CopyLeft (c) 1995-2024 by PopolonY2k.
; CopyLeft (c) since 2024 by Hinotori Team.
;

.z80
external nJmpTblAddr  ; The pointer to the WR_SEG routine in the jump table
external nValue       ; The returned data from WR_SEG routine
external nSegmentId   ; The segment id that will be passed to the routine
external nAddress     ; The address to read within the specified segment
external nRetCode     ; The return code from WR_SEG function

         ; This function simulate a CALL the WR_SEG routine by using JP

         ld hl, retj
         push hl
         ld   a, (nValue)
         ld   e, a
         ld   a, (nSegmentId)
         ld   hl,(nAddress)
         ld   ix,(nJmpTblAddr)
         jp   (ix)
retj:    ld   (nRetCode), a
         end
