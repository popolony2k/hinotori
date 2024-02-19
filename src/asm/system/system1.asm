;<system1.asm>
; Z80 and MSX related system routines.
; CopyLeft (c) 1995-2024 by PopolonY2k.
; CopyLeft (c) since 2024 by Hinotori Team.
;

.z80
external nModel            ; The MSX model to be returned
external nMIDI             ; If MIDI is present (TR GT model only)

EXPTBL   equ    0FCC1h     ; EXPTBL for slot 0 id
RDSLT    equ    0000Ch     ; RDSLT BIOS call
MSXMODEL equ    0002Dh     ; MSX model
MSXMIDI  equ    0002Eh     ; MSX MIDI present internally

         ; Retrieve the MSX model

         ld a, (EXPTBL)
         ld hl, MSXMODEL
         call RDSLT
         ld (nModel), a

         ; Retrieve if MIDI is present

         ld a, (EXPTBL)
         ld hl, MSXMIDI
         call RDSLT
         ld (nMidi), a

         end
