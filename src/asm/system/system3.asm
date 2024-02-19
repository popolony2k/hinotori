;<system3.asm>
; Z80 and MSX related system routines.
; CopyLeft (c) 1995-2024 by PopolonY2k.
; CopyLeft (c) since 2024 by Hinotori Team.
;

.z80
external nRet              ; Several system information

EXPTBL   equ    0FCC1h     ; EXPTBL for slot 0 id
RDSLT    equ    0000Ch     ; RDSLT BIOS call
SYSINFO  equ    0002Bh     ; MSX system information (Not official name)

         ; Retrieve the MSX system information

         ld a, (EXPTBL)
         ld hl, SYSINFO
         call RDSLT
         ld (nRet), a

         end
