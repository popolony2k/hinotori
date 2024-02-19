; <allseg.asm>
; Mapper functions implementation for Turbo Pascal 3.
; CopyLeft (c) 1995-2024 by PopolonY2k.
; CopyLeft (c) since 2024 by Hinotori Team.
;

.z80
external nSegType     ; The segment type parameter
external nSlotId      ; The slot parameter
external nJmpTblAddr  ; The pointer to the ALL_SEG routine in the jump table
external nRetCode     ; The return code from ALL_SEG routine
external nSegId       ; The allocated segment id

         ; This function simulate a CALL the ALL_SEG routine by using JP

         ld hl, retj
         push hl
         ld   a, (nSlotId)
         ld   b, a
         ld   a, (nSegType)
         ld   hl,(nJmpTblAddr)
         jp   (hl)
retj:    ld   (nSegId), a
         ld   h, 0
         jr   c, endf
         ld   h, 1
endf:    ld   a, h
         ld   (nRetCode), a
         end
