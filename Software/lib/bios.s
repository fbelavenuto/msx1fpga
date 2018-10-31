
	.module bios
	.optsdcc -mz80

CALSLT	= 0x001C
ENASLT	= 0x0024
RESET	= 0x0000
KILBUF	= 0x0156
RAMAD0	= 0xF341				; slotid DOS ram page 0
RAMAD1	= 0xF342				; slotid DOS ram page 1
RAMAD2	= 0xF343				; slotid DOS ram page 2
RAMAD3	= 0xF344				; slotid DOS ram page 3
EXPTBL	= 0xFCC1				; slotids
DSKSLT	= 0xF348				; slotid DOS diskrom

	.area	_CODE


;-------------------------------------------------------------------------------
; void clearKeyBuf(void)
;-------------------------------------------------------------------------------
_clearKeyBuf::
	ld		ix, #KILBUF
	ld		iy, (EXPTBL-1)
	jp		CALSLT

;-------------------------------------------------------------------------------
; void putRamFrame1(void)
;-------------------------------------------------------------------------------
_putRamFrame1::
	ld		a, (RAMAD1)
	ld		h, #0x40
	jp		ENASLT

;-------------------------------------------------------------------------------
; void putRamFrame2(void)
;-------------------------------------------------------------------------------
_putRamFrame2::
	ld		a, (RAMAD2)
	ld		h, #0x80
	jp		ENASLT

;-------------------------------------------------------------------------------
; void putSlotFrame1(unsigned char slot)
;-------------------------------------------------------------------------------
_putSlotFrame1::
	ld		iy, #0
	add		iy, sp
	ld		a, 2(iy)
	ld		h, #0x40
	jp		ENASLT

;-------------------------------------------------------------------------------
; void putSlotFrame2(unsigned char slot)
;-------------------------------------------------------------------------------
_putSlotFrame2::
	ld		iy, #0
	add		iy, sp
	ld		a, 2(iy)
	ld		h, #0x80
	jp		ENASLT

;-------------------------------------------------------------------------------
; void resetSystem(void)
;-------------------------------------------------------------------------------
_resetSystem::
	ld		ix, #RESET
	ld		iy, (EXPTBL-1)
	jp		CALSLT
