; <getpn.sou>
; Mapper functions implementation for Turbo Pascal 3.
; CopyLeft (c) 1995-2024 by PopolonY2k.
; CopyLeft (c) since 2024 by Hinotori Team.
;

.z80
external nJmpTblAddr  ; The pointer to the GET_Pn routine in the jump table
external nSegmentId   ; The segment id that will be received

         ; This function simulate a CALL the GET_Pn routine by using JP

         ld hl, retj
         push hl
         ld   hl,(nJmpTblAddr)
         jp   (hl)
retj:    ld   (nSegmentId), a
         end
