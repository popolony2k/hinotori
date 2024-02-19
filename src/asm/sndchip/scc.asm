; <scc.asm>
; Library for SCC soundchip handling.
; Thanks to BIFI's website at http://bifi.msxnet.org/msxnet/tech/scc
; CopyLeft (c) 1995-2024 by PopolonY2k.
; CopyLeft (c) since 2024 by Hinotori Team.
;
.z80
external __nSCCPrimarySlot    ; SCC primary slot number
external __nSCCSecondarySlot  ; SCC secondary slot number
external __pSCCBaseAddresses  ; SCC base addresses array
external __pSndChipArrayParms ; SCC params byte array (PORT|REGISTER|DATA)

SEC_SLOT       equ    0FFFFh  ; Secondary slot page selection
PPI_SSEL       equ    0A8h    ; PPI slot selection I/O port


         ; Main routine

         ld  de, (__pSndChipArrayParms) ; Get SCC array pointer parms
         ld  a, (de)                    ; Get port Number

         ;
         ; Get SCC register base address based on current
         ; selected port
         ;
BasAdr:  ld  l, a
         ld  h, 00h
         add hl, hl
         ld  bc, (__pSCCBaseAddresses)
         add hl, bc
         ld  a, (hl)
         inc hl
         ld  h, (hl)
         ld  l, a

         ;
         ; Select SCC register to use based on previous
         ; SCC base
         ;
SelReg:  inc  de
         ld   a, (de)
         ld   c, a                      ; Get SCC register
         ld   b, 0
         add  hl, bc                    ; Calculates SCC register address
         inc  de
         ld   a, (de)
         ld   b, a                      ; Get SCC data
         ex   de, hl                    ; Get SCC register address

         ;
         ; Save current slot/sub-slot before
         ; switching to YM2151 slot/sub-slot
         ;
SavSlt:  ld   hl, (SEC_SLOT)            ; L contains current sub-slot number
         ld   c,  PPI_SSEL
         di
         in   h,  (c)                   ; H contains current slot number
         ld   a,  (__nSCCSecondarySlot)
         ld   c,  a                     ; Get SCC secondary slot
         ld   a,  (__nSCCPrimarySlot)   ; Get SCC primary slot
         out  (PPI_SSEL), a             ; Select SCC Slot using PPI I/O
         ld   a, c
         ld   (SEC_SLOT), a             ; Select SCC sub-slot

         ;
         ; Register writing
         ;
WrtReg:  ld   a, b
         ld   (de), a                   ; Write the data SCC address

         ;
         ; Restore main slot page
         ; HL contains sub-slot and slot repectively
         ;
ResSlt:  ld   a, l                      ; Select main sub-slot
         cpl                            ; Must be inverted
         ld   (SEC_SLOT), a
         ld   a, h                      ; Select main slot
         ei
         out  (PPI_SSEL), a

         end
