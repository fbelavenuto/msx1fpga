;
;Copyright (c) 2017 FBLabs
;
;This program is free software: you can redistribute it and/or modify
;it under the terms of the GNU General Public License as published by
;the Free Software Foundation, either version 3 of the License, or
;(at your option) any later version.
;
;This program is distributed in the hope that it will be useful,
;but WITHOUT ANY WARRANTY; without even the implied warranty of
;MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;GNU General Public License for more details.
;
;You should have received a copy of the GNU General Public License
;along with this program.  If not, see <http://www.gnu.org/licenses/>.
;

	.module mapper
	.optsdcc -mz80

	.area	_CODE

EXTBIO	= 0xFFCA
HOKVLD	= 0xFB20

;-------------------------------------------------------------------------------
; unsigned char mpInit(void)
;-------------------------------------------------------------------------------
_mpInit::
	ld		a, (HOKVLD)
	bit		0, a
	jp z,	.error1
	ld		a, #0
	ld		de, #0x0401
	call	EXTBIO
	and		a
	jp z,	.error1
	ld		(_mpSlotAddr), a
	ld		(_mpVars), hl
	ld		a, #0
	ld		de, #0x0402
	call	EXTBIO
	and		a
	jp z,	.error1
	ld		a, b
	ld		(_mpSlotNum), a
	ld		(mpFuncs), hl
	ld		de, #mpfAllocSeg		; copy jumptable
	ld		bc, #16 * 3
	ldir
	ld		l, #0
.exit1:
	ret
.error1:
	ld		l, #1
	ret

;-------------------------------------------------------------------------------
; unsigned char numMapperPages(void)
;-------------------------------------------------------------------------------
_numMapperPages::
	ld		c, #0xFE
	in		a, (c)
	push	af
	ld		de, #0x0005					; D = number of pages, E = start page
	ld		hl, #0x8000					; Address os frame 2
	ld		a, #4
	out		(c), a						; Set page 4
	ld		b, (hl)						; Read actual byte and save it
	ld		a, #0xAA
	ld		(hl), a						; Put 0xAA
nmp_loop:
	out		(c), e
	ld		a, (hl)						; Read byte from another page
	cp		#0xAA						; Is the same?
	jr z, 	nmp_same					; Yes, test if it is the #4 page
	inc		d							; No, is a valid page, increment
nmp_next:
	inc		e							; Test next page
	jr nz,	nmp_loop
	jr		nmp_exit
nmp_same:
	cpl									; Invert all bits
	ld		(hl), a
	push	af
	ld		a, #4
	out		(c), a						; Set page 4
	pop		af
	cp		(hl)						; Is the same
	jr z,	nmp_exit2					; Yes, the pages overlapped
	out		(c), e
	cpl
	ld		(hl), a						; No, restore RAM byte
	jr		nmp_next					; Next
nmp_exit:
	ld		a, #4
	out		(c), a						; Set page 4
nmp_exit2:
	ld		(hl), b						; Restore original value
	pop		af
	out		(c), a
	ld		a, d
	ld		b, #3						; Exclude initial 64K (last page-3)
	sub		b
	ld		l, a
	ret

;-------------------------------------------------------------------------------
; unsigned char allocUserSegment(void)
;-------------------------------------------------------------------------------
_allocUserSegment::
	xor		a
	ld		b, a
	call	mpfAllocSeg
	ld		l, #0
	jr c,	.exit2
	ld		l, a
.exit2:
	ret

;-------------------------------------------------------------------------------
; unsigned char allocSysSegment(void)
;-------------------------------------------------------------------------------
_allocSysSegment::
	xor		a
	ld		b, a
	inc		a
	call	mpfAllocSeg
	ld		l, #0
	jr c,	.exit3
	ld		l, a
.exit3:
	ret

;-------------------------------------------------------------------------------
; unsigned char freeSegment(unsigned char segm)
;-------------------------------------------------------------------------------
_freeSegment::
	xor		a
	ld		b, a
	ld		iy, #0
	add		iy, sp
	ld		a, 2(iy)
	call	mpfFreeSeg
	ld		l, #0
	jr c,	.exit4
	ld		l, #1
.exit4:
	ret

;-------------------------------------------------------------------------------
; unsigned char getCurSegFrame1(void)
;-------------------------------------------------------------------------------
_getCurSegFrame1::
	call	mpfGetP1
	ld		l, a
	ret

;-------------------------------------------------------------------------------
; unsigned char getCurSegFrame2(void)
;-------------------------------------------------------------------------------
_getCurSegFrame2::
	call	mpfGetP2
	ld		l, a
	ret

;-------------------------------------------------------------------------------
; void putSegFrame1(unsigned char segm)
;-------------------------------------------------------------------------------
_putSegFrame1::
	ld		iy, #0
	add		iy, sp
	ld		a, 2(iy)
	call	mpfPutP1
	ret

;-------------------------------------------------------------------------------
; void putSegFrame2(unsigned char segm)
;-------------------------------------------------------------------------------
_putSegFrame2::
	ld		iy, #0
	add		iy, sp
	ld		a, 2(iy)
	call	mpfPutP2
	ret

;-------------------------------------------------------------------------------
myAlloc:
	ld		hl, #initSeg
	ld		a, (hl)
	inc		(hl)
	ld		l, a
	ret

;-------------------------------------------------------------------------------
; Jumptables
mpfAllocSeg:
	call	myAlloc
mpfFreeSeg:
	.db		0xC9,0xC9,0xC9
mpfReadSeg:
	.db		0xC9,0xC9,0xC9
mpfWriteSeg:
	.db		0xC9,0xC9,0xC9
mpfCallSeg:
	.db		0xC9,0xC9,0xC9
mpfCallS:
	.db		0xC9,0xC9,0xC9
mpfPutPh:
	.db		0xC9,0xC9,0xC9
mpfGetPh:
	.db		0xC9,0xC9,0xC9
mpfPutP0:
	out		(#0xFC), a
	ret
mpfGetP0:
	in		a, (#0xFC)
	ret
mpfPutP1:
	out		(#0xFD), a
	ret
mpfGetP1:
	in		a, (#0xFD)
	ret
mpfPutP2:
	out		(#0xFE), a
	ret
mpfGetP2:
	in		a, (#0xFE)
	ret
empty:
	.db		0xC9,0xC9,0xC9
mpfGetP3:
	in		a, (#0xFF)
	ret

;mpfAllocSeg	= 0x00	; Allocate a 16k segment.
;mpfFreeSeg		= 0x03	; Free a 16k segment.
;mpfReadSeg		= 0x06	; Read byte from address A:HL to A.
;mpfWriteSeg	= 0x09	; Write byte from E to address A:HL.
;mpfCallSeg		= 0x0C	; Inter-segment call.  Address in IYh:IX
;mpfCallS		= 0x0F	; Inter-segment call.  Address in line after the call instruction.
;mpfPutPh		= 0x12	; Put segment into page (HL).
;mpfGetPh		= 0x15	; Get current segment for page (HL)
;mpfPutP0		= 0x18	; Put segment into page 0.
;mpfGetP0		= 0x1B	; Get current segment for page 0.
;mpfPutP1		= 0x1E	; Put segment into page 1.
;mpfGetP1		= 0x21	; Get current segment for page 1.
;mpfPutP2		= 0x24	; Put segment into page 2.
;mpfGetP2		= 0x27	; Get current segment for page 2.
;;
;mpfGetP3		= 0x2D	; Get current segment for page 3.

;ALL_SEG - Parameters:   A=0 => allocate user segment
;                        A=1 => allocate system segment
;                        B=0 => allocate primary mapper
;                        B!=0 => allocate
;                        FxxxSSPP slot address (primary mapper, if 0)
;                        xxx=000 allocate specified slot only
;                        xxx=001 allocate other slots than specified
;                        xxx=010 try to allocate specified slot and, if it failed, try another slot (if any)
;                        xxx=011 try to allocate other slots than specified and, if it failed, try specified slot
;          Results:      Carry set => no free segments
;                        Carry clear => segment allocated
;                                       A=new segment number
;                                       B=slot address of mapper slot (0 if called as B=0)
;
;
;FRE_SEG - Parameters:   A=segment number to free
;                        B=0 primary mapper
;                        B!=0 mapper other than primary
;          Returns:      Carry set => error
;                        Carry clear => segment freed OK
;
;RD_SEG -  Parameters:   A = segment number to read from
;                       HL = address within this segment
;          Results:      A = value of byte at that address
;                        All other registers preserved
;
;
;WR_SEG -  Parameters:   A = segment number to write to
;                       HL = address within this segment
;                        E = value to write
;          Returns:      A = corrupted
;                        All other registers preserved
;CAL_SEG - Parameters: IY = segment number to be called
;                       IX = address to call
;                       AF, BC, DE, HL passed to called routine
;                       Other registers corrupted
;          Results:     AF, BC, DE, HL, IX and IY returned from called routine.  All others corrupted.
;
;
;CALLS -   Parameters:  AF, BC, DE, HL passed to called routine
;                       Other registers corrupted
;          Calling sequence:   CALL  CALLS
;                              DB    SEGMENT
;                              DW    ADDRESS
;          Results:     AF, BC, DE, HL, IX and IY returned from called routine.  All others corrupted.

;PUT_Pn -  Parameters:   n = 0,1,2 or 3 to select page
;                        A = segment number
;          Results:      None
;                        All registers preserved
;
;
;GET_Pn -  Parameters:   n = 0,1,2 or 3 to select page
;          Results:      A = segment number
;                        All other registers preserved
;
;
;PUT_PH -  Parameters:   H = high byte of address
;                        A = segment number
;          Results:      None
;                        All registers preserved
;
;
;GET_PH -  Parameters:   H = high byte of address
;          Results:      A = segment number
;                        All other registers preserved
;
;

	.area	_DATA

_mpSlotAddr::
	.ds		1
_mpSlotNum::
	.ds		1
_mpVars::
	.ds		2
mpFuncs:
	.ds		2
initSeg:
	.db		4

