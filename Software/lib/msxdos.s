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
; Based on Avelino Herreras Morales C library
; http://msx.atlantes.org/index_en.html#sdccmsxdos
;

	.module msxdos
	.optsdcc -mz80

; Constants
BDOS		= 0x0005				; BDOS entry point

_FOPEN		= 0x0F					; Open file
_FCLOSE		= 0x10					; Close file
;_RDSEQ		= 0x14					; Sequencial read
;_WRSEQ		= 0x15					; Sequencial write
_FMAKE		= 0x16					; Create file
_SETDTA		= 0x1A					; Set disk transfer address
_WRBLK		= 0x26					; Random block write
_RDBLK		= 0x27					; Random block read
_OPEN		= 0x43					; Open file handle
_CREATE		= 0x44					; Create file handle
_CLOSE		= 0x45					; Close file handle
_DUP		= 0x47					; Duplicate file handle
_READ		= 0x48					; Read from file handle
_WRITE		= 0x49					; Write to file handle
_SEEK		= 0x4A					; Move file handle pointer
_TERM		= 0x62					; Terminate with error code
_DOSVER		= 0x6F					; Get MSX DOS version number

;
	.area _CODE

; Private functions

callBDOS:
	call	BDOS					; Call BDOS
	ld		(_last_error), a		; Saves the last error
	or		a						; Test it
	ret


; -------------
; prepareFCB
; DOS1: Make FCB
; DE = Filepath pointer
; -------------
prepareFCB:
	push	de
	ld		hl, #FCB					; Zero FCB
	ld		de, #FCB+1
	ld		(hl), #0
	ld		bc, #37
	ldir
	pop		de
	push	de
	ld		b, #0
prepareFCB_calcsize_loop:
	inc		b
	ld		a, (de)
	inc		de
	cp		#0
	jr nz,	prepareFCB_calcsize_loop
	pop		de
	ld		hl, #fileNameDOS1			; DOS1. Extract filename
prepareFCB_loop0:
	ld		a, (de)
	cp		#'.'
	jr z,	prepareFCB_loop2
	ld		(hl), a
	inc		hl
prepareFCB_loop1:
	inc		de
	djnz	prepareFCB_loop0
	jr		prepareFCB_exit
prepareFCB_loop2:
	ld		hl, #filenDOS1Ext
	ld		b, #4
	jr		prepareFCB_loop1
prepareFCB_exit:
	ld		hl, #fileNameDOS1			; Copy DOS1 filename to FCB
	ld		de, #fileName
	ld		bc, #11
	ldir
	ld		de, #FCB
	ret

; ----------------
; cmpHLwithDE
; Compares HL and DE
; BIOS RST 020H clone
; -----------------
cmpHLwithDE:
	ld		a, h
	sub		d
	ret nz
	ld		a, l
	sub		e
	ret

; -------------------------
; READ MAX
; HL : Size to read
; Returns HL max size
; this code is for DOS1 Compatibility
; -------------------------
readMax:
	push	af
	push	de
	push	hl
	xor		a
	ld		hl, (sizefile+2)
	ld		de, (sizeread+2)
	sbc		hl, de
	ld		(sizefiletmp+2), hl
	ld		hl, (sizefile)
	ld		de, (sizeread)
	sbc		hl, de
	ld		(sizefiletmp), hl
	pop		hl
	push	hl
	ld		de, (sizefiletmp)
	call	cmpHLwithDE
	jr nc,	.readmax0
	pop		hl
.readmaxend:
	pop		de
	pop		af
	ret
.readmax0:
	ld		de, (sizefiletmp+2)
	ld		hl, #0
	call	cmpHLwithDE
	pop		hl
	jr nz,	.readmaxend
.readmax1:
	ld		hl, (sizefiletmp)
	jr		.readmaxend


; Public functions
;-------------------------------------------------------------------------------
; void msxdos_init(void)
;-------------------------------------------------------------------------------
_msxdos_init::
	ld		bc, #0x5A00 + _DOSVER		; B=5Ah, C=6Fh
	ld		hl, #0x1234
	ld		de, #0xABCD
	ld		ix, #0
	call	callBDOS					; Send DOSVER command to dos
	jr nz, _msxdos_init_error
	ld		a, b
	ld		(_dosversion), a			; Save MSXDOS version
	cp		#2
	ret nz
	push	ix							; Test Nextor
	pop		de
	ld		a, d
	cp		#0
	ret z
	ld		a, #0x82					; Flag Nextor
_msxdos_init_exit:
	ld		(_dosversion), a
	ret
_msxdos_init_error:
	ld		a, #1
	jr		_msxdos_init_exit

;-------------------------------------------------------------------------------
; int8_t open(char *filepath, uint8_t flags);
;-------------------------------------------------------------------------------
_open::
	ld		iy, #0
	add		iy, sp
	ld		e, 2(iy)					; path
	ld		d, 3(iy)
	ld		a, (_dosversion)
	cp		#2
	jr c,	_open_dos1
	ld		a, 4(iy)					; flags
	; call
	ld		c, #_OPEN
	call	callBDOS
	jp z,	_open_ok
_open_error:
	ld		l, #-1						; Error
	ret
_open_ok:
	ld		l, b						; OK
	ret
_open_dos1:
	call	prepareFCB					; DE = FCB pointer
	ld		c, #_FOPEN
	call	callBDOS
	jr nz,	_open_error
	ld		iy, #FCB
	ld		a, #1
	ld		14(iy), a
	xor		a
	ld		15(iy), a
	ld		33(iy), a
	ld		34(iy), a
	ld		35(iy), a
	ld		36(iy), a
	ld		l, a						; No error
	ret

;-------------------------------------------------------------------------------
; int8_t creat(char *filepath, uint8_tflags, uint8_t attrib)
;-------------------------------------------------------------------------------
_creat::
	ld		iy, #0
	add		iy, sp
	ld		e, 2(iy)					; path
	ld		d, 3(iy)
	ld		a, (_dosversion)
	cp		#2
	jr c,	_creat_dos1
	ld		a, 4(iy)					; flags
	ld		b, 5(iy)					; attrib
	ld		c, #_CREATE
	call	callBDOS
	jp z,	_creat_ok
_creat_error:
	ld		l, #-1						; Error
	ret
_creat_ok:
	ld		l, b
	ret
_creat_dos1:
	call	prepareFCB					; DE = FCB pointer
	ld		c, #_FMAKE
	call	callBDOS
	jr nz,	_creat_error
	ld		l, a
	ret

;-------------------------------------------------------------------------------
; int8_t close(int8_t handle)
;-------------------------------------------------------------------------------
_close::
	ld		a, (_dosversion)
	cp		#2
	jr c,	_close_dos1
	ld		iy, #0
	add		iy, sp
	ld		b, 2(iy)					; handle
	ld		c, #_CLOSE
_close_call:
	call	callBDOS
	ld		l, a
	ret
_close_dos1:
	ld		de, #FCB
	ld		c, #_FCLOSE
	jr		_close_call

;-------------------------------------------------------------------------------
; int8_t dup(int8_t handle)
;-------------------------------------------------------------------------------
_dup::
	ld		a, (_dosversion)
	cp		#2
	jr nc,	_dup_dos2
_dup_error:
	ld		l, #-1						; Error
	ret
_dup_dos2:
	ld		iy, #0
	add		iy, sp
	ld		b, 2(iy)					; handle
	ld		c, #_DUP
	call	callBDOS
	jr nz,	_dup_error
	ld		l, b
	ret	

;-------------------------------------------------------------------------------
; int16_t read(int8_t handle, void *buffer, int16_t bytesToRead)
;-------------------------------------------------------------------------------
_read::
	ld		iy, #0
	add		iy, sp
	ld		b, 2(iy)					; handle
	ld		e, 3(iy)					; buffer
	ld		d, 4(iy)
	ld		l, 5(iy)					; bytesToRead
	ld		h, 6(iy)
	ld		a, (_dosversion)
	cp		#2
	jr c,	_read_dos1
	ld		c, #_READ
	call	callBDOS
	ret z
_read_error:
	ld		h, #-1
	ld		l, #-1
	ret
_read_dos1:
	push	hl
	push	de
	ld		c, #_SETDTA
	call	callBDOS
	pop		de							; Buffer
	pop		hl							; bytesToRead
	jr nz,	_read_error
	call	readMax						; HL = max size
	ld		de, #FCB
	ld		c, #_RDBLK
	jp		callBDOS
	jr nz,	_read_error
	ret

;-------------------------------------------------------------------------------
; write(int8_t handle, void *buffer, int16_t bytesToWrite)
;-------------------------------------------------------------------------------
_write::
	ld		iy, #0
	add		iy, sp
	ld		b, 2(iy)					; handle
	ld		e, 3(iy)					; buffer
	ld		d, 4(iy)
	ld		l, 5(iy)					; bytesToWrite
	ld		h, 6(iy)
	ld		a, (_dosversion)
	cp		#2
	jr c,	_write_dos1
	ld		c, #_WRITE
	call	callBDOS
	ret z
_write_error:
	ld		h, #-1
	ld		l, #-1
	ret
_write_dos1:
	push	hl
	push	de
	ld		c, #_SETDTA
	call	callBDOS
	pop		de							; Buffer
	pop		hl							; bytesToWrite
	jr nz,	_write_error
	call	readMax						; HL = max size
	ld		de, #FCB
	ld		c, #_RDBLK
	jp		callBDOS
	jr nz,	_read_error
	ret

;-------------------------------------------------------------------------------
; uint32_t lseek(int8_t fhandle, uint32_t offset, uint8_t method)
;-------------------------------------------------------------------------------
_lseek::
	ld		a, (_dosversion)
	cp		#2
	jr c,	_lseek_error
	ld		iy, #0
	add		iy, sp
	ld		b, 2(iy)					; handle
	ld		l, 3(iy)					; offset (32 bits)
	ld		h, 4(iy)
	ld		e, 5(iy)
	ld		d, 6(iy)
	ld		a, 7(iy)					; method
	ld		c, #_SEEK
	call	callBDOS
	ret z
_lseek_error:
	ld		a, #-1
	ld		h, a
	ld		l, a
	ld		d, a
	ld		e, a
	ret

;-------------------------------------------------------------------------------
; uint32_t dos1GetFilesize(void)
;-------------------------------------------------------------------------------
_dos1GetFilesize::
	ld		hl, (sizefile)
	ld		de, (sizefile+2)
	ret

;-------------------------------------------------------------------------------
; exit(int8_t error)
;-------------------------------------------------------------------------------
_exit::
	ld		iy, #0
	add		iy, sp
	ld		b, 2(iy)					; error
	ld		c, #_TERM
	jp		callBDOS

;-------------------------------------------------------------------------------
; unsigned char getDeviceInfo(unsigned char index, void *buffer)
;-------------------------------------------------------------------------------
_getDeviceInfo::
	ld		iy, #0
	add		iy, sp
	ld		a, 2(iy)
	or		a
	jr z,	_getDeviceInfo_error
	ld		l, 3(iy)
	ld		h, 4(iy)
	ld		c, #0x78
	call	5
	ld		(_last_error),a
	ld		l, a
	ret		
_getDeviceInfo_error:
	ld		l, #1
	ret

;-------------------------------------------------------------------------------

	.area _DATA

_dosversion::
	.ds		1

_last_error::
	.ds		1

sizefiletmp:
	.ds		4					; tmp variable for READMAX Code

; *** FCB DOS 1 ***
FCB:
unidad:		.db	0
fileName:	.ds	8
extname:	.ds	3
			.dw	0
registro:	.dw	0
sizefile:	.ds	4
			.ds	13
sizeread:
			.ds	4
			.db	0

fileNameDOS1:	.ASCII "        "			; DOS1 fileName for DOS1 Code
filenDOS1Ext:	.ASCII "   "
				.ds	4
