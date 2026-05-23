; <funcptr2.asm>
; Function pointer implementation to Turbo Pascal 3.
; Unfortunately this feature is missing in the core language
; of TP3 compiler.
; CopyLeft (c) 1995-2024 by PopolonY2k.
; CopyLeft (c) since 2024 by Hinotori Team.
;

.z80
external nProcAddr    ; The Pascal variable containing the function pointer

         ; This function simulates a CALL function by using JP
         ; (with no extra parm)

         ld   hl, endf
         push hl
         ld   hl, (nProcAddr)
         jp   (hl)

endf:    end
