;<opl4.asm>
; Library for OPL4 (YMF278B) soundchip handling.
; CopyLeft (c) 1995-2024 by PopolonY2k.
; CopyLeft (c) since 2024 by Hinotori Team.
;

.z80
external __pSndChipArrayParms ; The OPL4 params byte array (PORT|REGISTER|DATA)

OPL4STS     equ     00C4h     ;  OPL4 status port
OPL4FMR1    equ     00C4h     ;  OPL4 FM register 1
OPL4FMD1    equ     00C5h     ;  OPL4 FM data 1
OPL4FMR2    equ     00C6h     ;  OPL4 FM register 2
OPL4FMD2    equ     00C7h     ;  OPL4 FM data 2
OPL4WAVR    equ     007Eh     ;  OPL4 WAVE register
OPL4WAVD    equ     007Fh     ;  OPL4 WAVE data
OPL4PCMR    equ     0008h     ;  OPL4 PCM register
OPL4_BSY    equ     00000001b ;  OPL4 Status Busy
OPL4_FM     equ     01h       ;  OPL4 FM Port
OPL4_WAV    equ     02h       ;  OPL4 Wave port


;
; Write data to OPL4
;
wrt_opl4  MACRO k, v
          inc  hl
          ld   a, (hl)
          ld   c, v
          out  (c), a
wait&k:   in   a, (OPL4STS)
          and  OPL4_BSY
          jr   nz, wait&k
          ENDM

;
; Main routine
;
          ld   hl, (__pSndChipArrayParms)
          ld   a, (hl)                   ; Get OPL4 PORT parameter
          cp   OPL4_WAV
          jr   z, wrtwave
          wrt_opl4 1, OPL4FMR2
          wrt_opl4 2, OPL4FMD2
          ret

wrtwave:  wrt_opl4 3, OPL4WAVR
          wrt_opl4 4, OPL4WAVD
          end
