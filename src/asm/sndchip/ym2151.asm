; <ym2151.asm>
; Library for YM2151 (SFG-05/SFG-01) soundchip handling.
; CopyLeft (c) 1995-2024 by PopolonY2k.
; CopyLeft (c) since 2024 by Hinotori Team.
;

.z80
external __nYM2151PrimarySlot     ; YM2151 primary slot number
external __nYM2151SecondarySlot   ; YM2151 secondary slot number
external __pSndChipArrayParms     ; YM2151 parms byte array (REGISTER|DATA)

SEC_SLOT         equ    0FFFFh    ; Secondary slot page selection
PPI_SSEL         equ    0A8h      ; PPI slot selection I/O port
YM2151_ADDR_REG  equ    3FF0h     ; YM2151 address register
YM2151_DATA_REG  equ    3FF1h     ; YM2151 data register
CT_REG           equ    001Bh     ; CT register
IRQEN_REG        equ    0014h     ; IRQ EN register
CT_DATA_MSK      equ    00111111b ; CT reset data mask
IRQEN_DATA_MSK   equ    11110011b ; IRQEN reset data mask

          ; Main routine

          ld  hl,(__pSndChipArrayParms)

          ; Get all needed parameters
          ld  d, (hl)                     ; Get register parameter
          inc hl
          ld  e, (hl)                     ; Get data parameter

          ;
          ; Save current slot/sub-slot before
          ; switching to YM2151 slot/sub-slot
          ;

SavSlt:   ld  hl, (SEC_SLOT)              ; L contains current sub-slot number
          ld  c,  PPI_SSEL
          di
          in  h,  (c)                     ; H contains current slot number
          ld  a, (__nYM2151SecondarySlot)
          ld  c, a
          ld  a, (__nYM2151PrimarySlot)
          out (PPI_SSEL), a               ; Select YM2151 Slot using PPI
          ld  a, c
          ld  (SEC_SLOT), a               ; Select YM2151 sub slot

          ;
          ; Mask CT and IRQEN register if necessary
          ; Check YM2151 datasheet for more details
          ;
          ld  a, CT_REG
          cp  d
          jr  z, MskCT
          ld  a, IRQEN_REG
          cp  d
          jr  z, MskIRQEN

          ;
          ; Register writing
          ;
WrtReg:   ld  a, d
          ld  (YM2151_ADDR_REG), a
          cp  (hl)                       ; Wait before data writing

          ; Data write
          ld  a, e
          ld  (YM2151_DATA_REG), a

          ;
          ; Restore the main slot page
          ; HL contains sub-slot and slot repectively
          ;
ResSlt:   ld   a, l                      ; Select main sub-slot
          cpl                            ; Must be inverted
          ld   (SEC_SLOT), a
          ld   a, h                      ; Select main slot
          ei
          out  (PPI_SSEL), a
          ret

MskCT:    ld   a, e
          and  CT_DATA_MSK
          ld   e, a
          jr   WrtReg

MskIRQEN: ld   a, e
          and  IRQEN_DATA_MSK
          ld   e, a
          jr   WrtReg

          end
