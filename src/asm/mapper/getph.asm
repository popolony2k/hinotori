; <getph.asm>
; Mapper functions implementation for Turbo Pascal 3.
; CopyLeft (c) 1995-2024 by PopolonY2k.
; CopyLeft (c) since 2024 by Hinotori Team.
;

.z80
external nJmpTblAddr  ; The pointer to the GET_PH routine in the jump table
external nSegmentId   ; The segment id that will be received
external nAddress     ; The address passed to the GET_PH routine

         ; This function simulate a CALL the GET_PH routine by using JP

         ld hl, retj
         push hl
         ld   hl,(nAddress)
         ld   ix,(nJmpTblAddr)
         jp   (ix)
retj:    ld   (nSegmentId), a
         end
