;<pointer.asm>
; Pointer functions to turn Turbo Pascal 3 more flexible with
; modern pointer operations, present in newer Delphi releases.
; CopyLeft (c) 1995-2024 by PopolonY2k.
; CopyLeft (c) since 2024 by Hinotori Team.
;

.z80
external pPointer     ; The user pointer
external nIncrement   ; The pointer increment

         ; Main routine
         ld  hl, (pPointer)
         ld  de, (nIncrement)
         add hl, de
         ld  (pPointer), hl
         end
