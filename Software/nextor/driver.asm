; MSX1 FPGA project
;
;Copyright (c) 2017 FBLabs and FRS
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

; Technical info:
; I/O port 0x9E: Interface status and card select register (read/write)
;	<read>
;	b0	: 1=SD disk was changed
;	b1	: 0=SD card present
;	b2	: 1=Write protecton enabled for SD card
;	b3-7: Reserved for future use. Must be masked out from readings.
;	<write>
;	b0	: SD card chip-select (0=selected)
; I/O port 0x9F: SPI data transfer (read/write)

; Comments in Brazilian Portuguese, sorry :(

	output	"driver.bin"

; Uses HW (1) or SW (0) disk-change:
HWDS = 0

;-----------------------------------------------------------------------------
;
; Driver configuration constants
;

;Driver type:
;   0 for drive-based
;   1 for device-based

DRV_TYPE	equ	1

;Hot-plug devices support (device-based drivers only):
;   0 for no hot-plug support
;   1 for hot-plug support

DRV_HOTPLUG	equ	1

DEBUG	equ	0	;Set to 1 for debugging, 0 to normal operation

;Driver version

VER_MAIN	equ	1
VER_SEC		equ	0
VER_REV		equ	0

;-----------------------------------------------------------------------------
; SPI addresses. Check the Technical info above for the bit contents

PORTCTL		= $9E
PORTDATA	= $9F

; SPI commands:
CMD0	= 0  | $40
CMD1	= 1  | $40
CMD8	= 8  | $40
CMD9	= 9  | $40
CMD10	= 10 | $40
CMD12	= 12 | $40
CMD16	= 16 | $40
CMD17	= 17 | $40
CMD18	= 18 | $40
CMD24	= 24 | $40
CMD25	= 25 | $40
CMD55	= 55 | $40
CMD58	= 58 | $40
ACMD23	= 23 | $40
ACMD41	= 41 | $40


;-----------------------------------------------------------------------------
;
; Standard BIOS and work area entries
INITXT	= $006C		; Initialize SCREEN0
CHSNS	= $009C		; Sense keyboard buffer for character
CHGET	= $009F		; Get character from keyboard buffer
CHPUT	= $00A2		; A=char
SNSMAT	= $0141		; Read row of keyboard matrix
KILBUF	= $0156		; Clear keyboard buffer
EXTROM	= $015F

; subROM functions
SDFSCR	= $0185
REDCLK	= $01F5

; System variables
MSXVER	= $002D
LINLEN	= $F3B0
INTFLG	= $FC9B
SCRMOD	= $FCAF

;-----------------------------------------------------------------------------

	org		$4000

	ds		256, $FF		; 256 dummy bytes

DRV_START:

;-----------------------------------------------------------------------------
;
; Miscellaneous constants
;

;This is a 2 byte buffer to store the address of code to be executed.
;It is used by some of the kernel page 0 routines.

CODE_ADD:	equ	0F84Ch


;-----------------------------------------------------------------------------
;
; Error codes for DEV_RW
;

ENCOMP	equ	0FFh
EWRERR	equ	0FEh
EDISK	equ	0FDh
ENRDY	equ	0FCh
EDATA	equ	0FAh
ERNF	equ	0F9h
EWPROT	equ	0F8h
EUFORM	equ	0F7h
ESEEK	equ	0F3h
EIFORM	equ	0F0h
EIDEVL	equ	0B5h
EIPARM	equ	08Bh

;-----------------------------------------------------------------------------
;
; Routines and information available on kernel page 0
;

;* Get in A the current slot for page 1. Corrupts F.
;  Must be called by using CALBNK to bank 0:
;    xor a
;    ld ix,GSLOT1
;    call CALBNK

GSLOT1	equ	402Dh


;* This routine reads a byte from another bank.
;  Must be called by using CALBNK to the desired bank,
;  passing the address to be read in HL:
;    ld a,<bank number>
;    ld hl,<byte address>
;    ld ix,RDBANK
;    call CALBNK

RDBANK	equ	403Ch


;* This routine temporarily switches kernel main bank
;  (usually bank 0, but will be 3 when running in MSX-DOS 1 mode),
;  then invokes the routine whose address is at (CODE_ADD).
;  It is necessary to use this routine to invoke CALBAS
;  (so that kernel bank is correct in case of BASIC error)
;  and to invoke DOS functions via F37Dh hook.
;
;  Input:  Address of code to invoke in (CODE_ADD).
;          AF, BC, DE, HL, IX, IY passed to the called routine.
;  Output: AF, BC, DE, HL, IX, IY returned from the called routine.

CALLB0	equ	403Fh


;* Call a routine in another bank.
;  Must be used if the driver spawns across more than one bank.
;
;  Input:  A = bank number
;          IX = routine address
;          AF' = AF for the routine
;          HL' = Ix for the routine
;          BC, DE, HL, IY = input for the routine
;  Output: AF, BC, DE, HL, IX, IY returned from the called routine.

CALBNK	equ	4042h


;* Get in IX the address of the SLTWRK entry for the slot passed in A,
;  which will in turn contain a pointer to the allocated page 3
;  work area for that slot (0 if no work area was allocated).
;  If A=0, then it uses the slot currently switched in page 1.
;  Returns A=current slot for page 1, if A=0 was passed.
;  Corrupts F.
;  Must be called by using CALBNK to bank 0:
;    ld a,<slot number> (xor a for current page 1 slot)
;    ex af,af'
;    xor a
;    ld ix,GWORK
;    call CALBNK

GWORK	equ	4045h


;* This address contains one byte that tells how many banks
;  form the Nextor kernel (or alternatively, the first bank
;  number of the driver).

K_SIZE	equ	40FEh


;* This address contains one byte with the current bank number.

CUR_BANK	equ	40FFh


;-----------------------------------------------------------------------------
;
; Built-in format choice strings
;

NULL_MSG  equ     781Fh	;Null string (disk can't be formatted)
SING_DBL  equ     7820h ;"1-Single side / 2-Double side"


;-----------------------------------------------------------------------------
;
; Driver signature
;
	db	"NEXTOR_DRIVER",0


;-----------------------------------------------------------------------------
;
; Driver flags:
;    bit 0: 0 for drive-based, 1 for device-based
;    bit 1: 1 for hot-plug devices supported (device-based drivers only)

	db 1+(2*DRV_HOTPLUG)

;-----------------------------------------------------------------------------
;
; Reserved byte
;
	db	0

;-----------------------------------------------------------------------------
;
; Driver name
;

DRV_NAME:
	db	"MSX1FPGA SD Driver"
	ds	32-($-DRV_NAME)," "


;-----------------------------------------------------------------------------
;
; Jump table for the driver public routines
;

	; These routines are mandatory for all drivers
        ; (but probably you need to implement only DRV_INIT)

	jp	DRV_TIMI
	jp	DRV_VERSION
	jp	DRV_INIT
	jp	DRV_BASSTAT
	jp	DRV_BASDEV
	jp	DRV_EXTBIO
	jp	DRV_DIRECT0
	jp	DRV_DIRECT1
	jp	DRV_DIRECT2
	jp	DRV_DIRECT3
	jp	DRV_DIRECT4

	ds	15

	; These routines are mandatory for device-based drivers

	jp	DEV_RW
	jp	DEV_INFO
	jp	DEV_STATUS
	jp	LUN_INFO


;=====
;=====  END of data that must be at fixed addresses
;=====


;-----------------------------------------------------------------------------
;
; Timer interrupt routine, it will be called on each timer interrupt
; (at 50 or 60Hz), but only if DRV_INIT returns Cy=1 on its first execution.

DRV_TIMI:
	ret

;-----------------------------------------------------------------------------
;
; Driver initialization routine, it is called twice:
;
; 1) First execution, for information gathering.
;    Input:
;      A = 0
;      B = number of available drives
;      HL = maximum size of allocatable work area in page 3
;    Output:
;      A = number of required drives (for drive-based driver only)
;      HL = size of required work area in page 3
;      Cy = 1 if DRV_TIMI must be hooked to the timer interrupt, 0 otherwise
;
; 2) Second execution, for work area and hardware initialization.
;    Input:
;      A = 1
;      B = number of allocated drives for this controller
;
;    The work area address can be obtained by using GWORK.
;
;    If first execution requests more work area than available,
;    second execution will not be done and DRV_TIMI will not be hooked
;    to the timer interrupt.
;
;    If first execution requests more drives than available,
;    as many drives as possible will be allocated, and the initialization
;    procedure will continue the normal way
;    (for drive-based drivers only. Device-based drivers always
;     get two allocated drives.)

DRV_INIT:
	or		a							; Is this the 1st call?
	jp nz,	.call2
; 1st call:
	ld		hl, 0						; No RAM needed
	or		a							; Clear Cy
	ret

.call2:
; 2nd call:
	call	MYSETSCR					; Set the screen mode

	ld		de,strTitle					; prints the title
	call	printString

 IF HWDS = 0
	xor		a
	ld		(WRKAREA.FLAGS), a
 ENDIF

	ld		a, 1						; Detect SD card #1 (only 1 SD for now)
	call	.detect
	ld		bc, 0
	ld		e, 5

	call	INICHKSTOP					; Check if the STOP key was pressed

	ld		de, strCrLf
	jp		printString

.detect:
	ld		(WRKAREA.NUMSD), a			; SD card detection process
	push	af
	ld		de, strSDSlot
	call	printString
	pop		af
	add		'0'
	call	CHPUT
	ld		a, ':'
	call	CHPUT
	ld		a, ' '
	call	CHPUT
	in		a, (PORTCTL)				; Is there an SD Card in the slot?
	and		$2
	jr z,	.naoVazio
	ld		de, strVazio				; nop
	call	printString
	ret
.naoVazio:
	call	detectCard					; Yep, initialize it and detect it
	jr nc,	.detectou
	call	disableCards
	ld		de, strNaoIdentificado
 IF HWDS = 1
 	jp		printString
 ELSE
	call	printString
.marcaErro:
	jp		marcaErroCartao				; slot vazio ou erro de deteccao, marcar nas flags
 ENDIF
.detectou:
	call	getCIDaddr
	ld		a, (ix+15)					; SDV1 or SDV2
	ld		de, strSDV1
	or		a
	jr z,	.pula1
	ld		de, strSDV2
.pula1:
	call	printString
	ld		a, '('
	call	CHPUT
	ld		a, (ix)						; Manufacturer ID
	call	printDecToAscii
	ld		a, ')'
	call	CHPUT
	ld		a, ' '
	call	CHPUT
	ld		a, (ix)						; Manufacturer ID
	call	findManStr
	ex		de, hl
	call	printString
	ld		de, strCrLf
	jp		printString


;-----------------------------------------------------------------------------
;
; Obtain driver version
;
; Input:  -
; Output: A = Main version number
;         B = Secondary version number
;         C = Revision number

DRV_VERSION:
	ld	a,VER_MAIN
	ld	b,VER_SEC
	ld	c,VER_REV
	ret


;-----------------------------------------------------------------------------
;
; BASIC expanded statement ("CALL") handler.
; Works the expected way, except that if invoking CALBAS is needed,
; it must be done via the CALLB0 routine in kernel page 0.

DRV_BASSTAT:
	scf
	ret

;-----------------------------------------------------------------------------
;
; BASIC expanded device handler.
; Works the expected way, except that if invoking CALBAS is needed,
; it must be done via the CALLB0 routine in kernel page 0.

DRV_BASDEV:
	scf
	ret


;-----------------------------------------------------------------------------
;
; Extended BIOS hook.
; Works the expected way, except that it must return
; D'=1 if the old hook must be called, D'=0 otherwise.
; It is entered with D'=1.

DRV_EXTBIO:
	ret


;-----------------------------------------------------------------------------
;
; Direct calls entry points.
; Calls to addresses 7850h, 7853h, 7856h, 7859h and 785Ch
; in kernel banks 0 and 3 will be redirected
; to DIRECT0/1/2/3/4 respectively.
; Receives all register data from the caller except IX and AF'.

DRV_DIRECT0:
DRV_DIRECT1:
DRV_DIRECT2:
DRV_DIRECT3:
DRV_DIRECT4:
	ret


;=====
;=====  BEGIN of DEVICE-BASED specific routines
;=====

;-----------------------------------------------------------------------------
;
; Read or write logical sectors from/to a logical unit
;
;Input:    Cy=0 to read, 1 to write
;          A = Device number, 1 to 7
;          B = Number of sectors to read or write
;          C = Logical unit number, 1 to 7
;          HL = Source or destination memory address for the transfer
;          DE = Address where the 4 byte sector number is stored.
;Output:   A = Error code (the same codes of MSX-DOS are used):
;              0: Ok
;              .IDEVL: Invalid device or LUN
;              .NRDY: Not ready
;              .DISK: General unknown disk error
;              .DATA: CRC error when reading
;              .RNF: Sector not found
;              .UFORM: Unformatted disk
;              .WPROT: Write protected media, or read-only logical unit
;              .WRERR: Write error
;              .NCOMP: Incompatible disk.
;              .SEEK: Seek error.
;          B = Number of sectors actually read (in case of error only)

DEV_RW:
	push	af
	cp		a, 2						; only 1 device
	jr nc,	.error
	dec		c							; only 1 logical unit
	jr z,	.ok
.error:
	pop		af
	ld		a, EIDEVL					; error
	ld		b, 0
	ret
.ok:
 IF HWDS = 0
	call	checkSWDS
	jr c,	.error
 ENDIF
	ld		a, b
	ld		(WRKAREA.NUMBLOCKS), a		; save the number of blocks to transfer
	exx
	call	getCIDaddr					; ix=CID offset
	ld		a, (ix+15)					; SDV1 or SDV2
	ld		ixl, a						; ixl=SDcard version
	exx									; hl=Source/dest Address, de=Pointer to sect#
	ld		ixh, b 						; ixh=Number of blocks to transfer
	pop		af							; a=Device number, f=read/write flag
	jr c,	isWrite						; Skip if it's a write operation
isRead:
	ld		a, (de)						; block #1
	push	af
	inc		de
	ld		a, (de)						; block #2
	push	af
	inc		de
	ld		a, (de)						; block #3
	ld		c, a
	inc		de
	ld		a, (de)						; block #4
	ld		b, a
	pop		af
	ld		d, a
	pop		af							; HL=dest address
	ld		e, a						; BC DE = 32 bits block number
	call	readBlock
	jr nc,	DEV_RW_OK
 IF HWDS = 0
	call	marcaErroCartao				; ocorreu erro na leitura, marcar erro
 ENDIF
	ld		a, (WRKAREA.NUMBLOCKS)		; Get the number of requested blocks
	sub		ixh							; subtract the number of remaining blocks
	ld		b, a						; b=number of blocks read
	ld		a, ENRDY					; Not ready
;	ld		a, EDISK					; General unknown disk error
DEV_RW_OK:
	xor		a							; exit with no error
	ret

isWrite:
	in		a, (PORTCTL)				; destructive read
	and		$4							; test if the card is write protected
	jr z,	.ok
	ld		a, EWPROT					; write protect
	ld		b, 0						; 0 blocks were written
	ret
.ok:
	ld		a, (de)						; block #1
	push	af
	inc		de
	ld		a, (de)						; block #2
	push	af
	inc		de
	ld		a, (de)						; block #3
	ld		c, a
	inc		de
	ld		a, (de)						; block #4
	ld		b, a
	pop		af
	ld		d, a
	pop		af							; HL=dest address
	ld		e, a						; BC DE = 32 bits block number
	call	writeBlock
	jr nc,	DEV_RW_OK
 IF HWDS = 0
	call	marcaErroCartao				; ocorreu erro na leitura, marcar erro
 ENDIF
	ld		a, (WRKAREA.NUMBLOCKS)		; Get the number of requested blocks
	sub		ixh							; subtract the number of remaining blocks
	ld		b, a						; b=number of blocks read
	ld		a, EWRERR					; write error
	ret

;-----------------------------------------------------------------------------
;
; Device information gathering
;
;Input:   A = Device index, 1 to 7
;         B = Information to return:
;             0: Basic information
;             1: Manufacturer name string
;             2: Device name string
;             3: Serial number string
;         HL = Pointer to a buffer in RAM
;Output:  A = Error code:
;             0: Ok
;             1: Device not available or invalid device index
;             2: Information not available, or invalid information index
;         When basic information is requested,
;         buffer filled with the following information:
;
;+0 (1): Numer of logical units, from 1 to 7. 1 if the device has no logical
;        units (which is functionally equivalent to having only one).
;+1 (1): Device flags, always zero in Beta 2.
;
; The strings must be printable ASCII string (ASCII codes 32 to 126),
; left justified and padded with spaces. All the strings are optional,
; if not available, an error must be returned.
; If a string is provided by the device in binary format, it must be reported
; as an hexadecimal, upper-cased string, preceded by the prefix "0x".
; The maximum length for a string is 64 characters;
; if the string is actually longer, the leftmost 64 characters
; should be provided.
;
; In the case of the serial number string, the same rules for the strings
; apply, except that it must be provided right-justified,
; and if it is too long, the rightmost characters must be
; provided, not the leftmost.

DEV_INFO:
	inc		b
	cp		a, 2						; only 1 device
	jr c,	.ok
.error:
	ld		a, 1						; error
	ret
.ok:
 IF HWDS = 0
	call	checkSWDS
	jr c,	.error
 ENDIF
	djnz	.noBasic

; Basic information:
	ld		(hl), 1						; only 1 logical unit
	xor		a							; reserved, must be 0
	inc		hl
	ld		(hl), a
	ret									; return with A=0 (OK)

.noBasic:
	push	hl
	call	getCIDaddr
	pop		hl

	djnz	.noManuf
; Manufacturer Name:
	push	hl							; save buffer pointer
	ld		b, 64						; fill with SPACE char
	ld		a, ' '
.loop1:
	ld		(hl), a
	inc		hl
	djnz	.loop1
	pop		de							; restore buffer pointer in DE
	ld		a, '('						; put brackets
	ld		(de), a
	inc		de
	ld		a, (ix)						; manufacturer ID
	call	DecToAscii
	ld		a, ')'
	ld		(de), a
	inc		de
	ld		a, ' '
	ld		(de), a
	inc		de
	ld		a, (ix)						; manufacturer ID
	call	findManStr
	ldir								; copy manufacturer name
	ret

.noManuf:
	djnz	.noProduct
; Product Name:
	push	hl							; save buffer pointer
	push	ix
	pop		hl							; HL <- IX
	ld		d, 0
	ld		e, 3						; add productname offset
	add		hl, de
	pop		de							; restore buffer pointer in DE
	ld		bc, 5						; 5 chars
	ldir								; copy product name
	ex		de, hl
	ld		b, 59						; space padding
	ld		a, ' '
.loop2:
	ld		(hl), a
	inc		hl
	djnz	.loop2
	xor		a							; no errors
	ret

.noProduct:
; Serial Number:
	ld		(hl), '0'					; put prefix "0x"
	inc		hl
	ld		(hl), 'x'
	inc		hl
	push	hl							; save buffer pointer
	push	ix
	pop		hl							; HL <- IX
	ld		d, 0
	ld		e, 9						; add serial offset
	add		hl, de
	pop		de							; restore buffer pointer in DE
	ld		b, 4						; 4 bytes size
.loop3:
	ld		a, (hl)
	call	HexToAscii
	inc		hl
	djnz	.loop3
	ld		b, 54						; space padding
	ld		a, ' '
.loop4:
	ld		(de), a
	inc		de
	djnz	.loop4
	xor		a							; no errors
	ret

;-----------------------------------------------------------------------------
;
; Obtain device status
;
;Input:   A = Device index, 1 to 7
;         B = Logical unit number, 1 to 7
;             0 to return the status of the device itself.
;Output:  A = Status for the specified logical unit,
;             or for the whole device if 0 was specified:
;                0: The device or logical unit is not available, or the
;                   device or logical unit number supplied is invalid.
;                1: The device or logical unit is available and has not
;                   changed since the last status request.
;                2: The device or logical unit is available and has changed
;                   since the last status request
;                   (for devices, the device has been unplugged and a
;                    different device has been plugged which has been
;                    assigned the same device index; for logical units,
;                    the media has been changed).
;                3: The device or logical unit is available, but it is not
;                   possible to determine whether it has been changed
;                   or not since the last status request.
;
; Devices not supporting hot-plugging must always return status value 1.
; Non removable logical units may return values 0 and 1.
;
; The returned status is always relative to the previous invokation of
; DEV_STATUS itself. Please read the Driver Developer Guide for more info.

DEV_STATUS:
	cp		a, 2						; only 1 device
	jr nc,	.error
	dec		b							; only 1 logical unit
	jr nz,	.error
	ld		(WRKAREA.NUMSD),a
 IF HWDS = 0
	ld		a, (WRKAREA.FLAGS)
	and		1
	jr z,	.nochange
	call	detectCard					; try redetect
	jr c,	.withError
	ld		a, (WRKAREA.FLAGS)
	and		$FE
	ld		(WRKAREA.FLAGS), a
	jr		.changed
 ELSE
	in		a, (PORTCTL)				; destructive read
	ld		b, a
	and		$02							; SD card present?
	jr nz,	.error						; no
	ld		a, b
	and		$01							; changed?
	jr nz,	.changed					; yes
 ENDIF

.nochange:
	ld		a, 1						; SD card is ok and has not changed
	ret
.changed:
	call	detectCard					; Try redetect
	jr c,	.error
.changed2:
	ld		a, 2						; SD card is ok and has changed
	ret

 IF HWDS = 0
.withError:
	call	marcaErroCartao				; marcar erro do cartao nas flags
 ENDIF

.error:
	xor		a							; error
	ret

;-----------------------------------------------------------------------------
;
; Obtain logical unit information
;
;Input:   A  = Device index, 1 to 7
;         B  = Logical unit number, 1 to 7
;         HL = Pointer to buffer in RAM.
;Output:  A = 0: Ok, buffer filled with information.
;             1: Error, device or logical unit not available,
;                or device index or logical unit number invalid.
;         On success, buffer filled with the following information:
;
;+0 (1): Medium type:
;        0: Block device
;        1: CD or DVD reader or recorder
;        2-254: Unused. Additional codes may be defined in the future.
;        255: Other
;+1 (2): Sector size, 0 if this information does not apply or is
;        not available.
;+3 (4): Total number of available sectors.
;        0 if this information does not apply or is not available.
;+7 (1): Flags:
;        bit 0: 1 if the medium is removable.
;        bit 1: 1 if the medium is read only. A medium that can dinamically
;               be write protected or write enabled is not considered
;               to be read-only.
;        bit 2: 1 if the LUN is a floppy disk drive.
;+8 (2): Number of cylinders
;+10 (1): Number of heads
;+11 (1): Number of sectors per track
;
; Number of cylinders, heads and sectors apply to hard disks only.
; For other types of device, these fields must be zero.

LUN_INFO:
	cp		a, 2						; only 1 device
	jr nc,	.error
	dec		b							; only 1 logical unit
	jr z,	.ok
.error:
	ld		a, 1						; error
	ret
.ok:
 IF HWDS = 0
	call	checkSWDS
	jr c,	.error
 ENDIF
	exx
	call	getBlockAddr				; IX=# blocks address
	exx
	xor		a
	ld		(hl), a						; report as block device (00h)
	inc		hl
	ld		(hl), a						; block size: 512 bytes (0200h)
	inc		hl
	ld		(hl), 2
	inc		hl
	ld		a, (ix)						; copy # blocks
	ld		(hl), a
	inc		hl
	ld		a, (ix+1)
	ld		(hl), a
	inc		hl
	ld		a, (ix+2)
	ld		(hl), a
	inc		hl
	ld		(hl), 0						; The highest byte must be set to 0, as SDcards
										; have 24bit total block numbers, and Nextor
										; requires 32bits.
	inc		hl
	ld		(hl),1						; flags: R/W, removable device
	inc		hl
	xor		a							; CHS = 0
	ld		(hl), a
	inc		hl
	ld		(hl), a
	inc		hl
	ld		(hl), a
	ret									; exit with A=0 (no errors)

;=====
;=====  END of DEVICE-BASED specific routines
;=====

;------------------------------------------------
; Auxiliary routines
;------------------------------------------------

 IF HWDS = 0
;------------------------------------------------
; Testa se cartao esta inserido e/ou houve erro
; na ultima vez que foi acessado. Carry indica
; erro
; Destroys AF
;------------------------------------------------
checkSWDS:
	ld		a, (WRKAREA.FLAGS)			; testar bit de erro do cartao nas flags
	and		1
	jr z,	.ok
	scf									; indica erro
	ret
.ok:
	xor		a							; Cy = 0 indicates no error
	ret

;------------------------------------------------
; Marcar bit de erro nas flags
; Destroi AF
;------------------------------------------------
marcaErroCartao:
	ld		a, (WRKAREA.FLAGS)			; marcar erro
	or		1
	ld		(WRKAREA.FLAGS), a
	ret

 ENDIF

;------------------------------------------------
; Get correct CID address in the IX and HL
; registers depending on current SD card
; Destroys AF, HL, IX
;------------------------------------------------
getCIDaddr:
	ld		hl, WRKAREA.BCID1
	ld		a, (WRKAREA.NUMSD)
	dec		a
	jr z,	.c1
	ld		hl, WRKAREA.BCID2
.c1:
	push	hl
	pop		ix							; IX <- HL
	ret

;------------------------------------------------
; Get correct Blocks address in the IX and HL
; registers depending on current SD card
; Destroys AF, HL, IX
;------------------------------------------------
getBlockAddr:
	ld		hl, WRKAREA.BLOCKS1
	ld		a, (WRKAREA.NUMSD)
	dec		a
	jr z,	.c1
	ld		hl, WRKAREA.BLOCKS2
.c1:
	push	hl
	pop		ix							; IX <- HL
	ret


;------------------------------------------------
; SD card initialization and detection process.
;
; Detects whether SD card responds, which version
; (SDV1 or SDV2), reads the CSD and CID and
; calculates the number of blocks of the SD card,
; placing the CID and total blocks in the correct
; buffer depending on current SD card.
; Cy indicates error (0=OK)
; Destroys all regs
;------------------------------------------------
detectCard:
	call	initializeSD						; send clock pulses and CMD0
	ret	c									; exit if error
	call	trySDV2							; try SDV2 initialization process
	ret	c
	ld		hl, WRKAREA.BCSD
	ld		a, CMD9							; read CSD
	call	readBlockCxD
	ret	c
	call	getCIDaddr
	ld		a, CMD10						; read CID
	call	readBlockCxD
	ret	c
	ld		a, CMD58						; read OCR
	ld		de, 0
	call	SD_SEND_CMD_2_ARGS_GET_R3
	ret	c
	ld		a, b							; CCS bit of OCR register reports SDV1 or SDV2
	and		$40
	ld		(ix+15), a						; put SD card version (V1 ou V2) in the byte 15 of CID
	call z,	set512bytesBlocks		; if is not SDV2 (Block address - SDHC ou SDXD) changes
	ret c									; block size to 512 bytes
	call	disableCards
	call	getBlockAddr
	ld		hl, WRKAREA.BCSD+5
	ld		a, (WRKAREA.BCSD)
	and		$C0								; checks CSD register version
	jr z,	.CSD1calc
	cp		$40
	jr z,	.CSD2calc
	scf										; CSD register version was not recognized, report error
	ret

; -----------------------------------
; Calculates CSD version 1
; -----------------------------------
.CSD1calc:
	ld		a, (hl)
	and		$0F								; mask READ_BL_LEN
	push	af								; save READ_BL_LEN
	inc		hl
	ld		a, (hl)							; mask 2 LSB bits of C_SIZE
	and		3
	ld		d, a
	inc		hl
	ld		e, (hl)							; next 8 bits of C_SIZE
	inc		hl
	ld		a, (hl)
	and		$C0								; mask 2 MSB bits of C_SIZE
	add		a, a							; rotate left
	rl		e								; rotate to DE
	rl		d
	add		a, a
	rl		e
	rl		d
	inc		de								; now DE contains all 12 bits of C_SIZE. Increment it
	inc		hl
	ld		a, (hl)							; next byte
	and		3								; mask 2 LSB bits of C_SIZE_MUL
	ld		b, a
	inc		hl
	ld		a, (hl)							; next byte
	and		$80								; mask 1 MSB bit of C_SIZE_MUL
	add		a, a
	rl		b
	inc		b								; now B contains all 3 bits of C_SIZE_MUL
	inc		b								; B <= C_SIZE_MUL + 2
	pop		af								; restore READ_BL_LEN
	add		a, b							; A <= READ_BL_LEN + (C_SIZE_MUL+2)
	ld		bc, 0
	call	.eleva2
	ld		e, d							; (BC DE) contains bytes size of SD card
	ld		d, c							; divide (BC DE) by 256
	ld		c, b
	ld		b, 0
	srl		c
	rr		d
	rr		e								; (BC DE) <= (BC DE) / 2 (converts total bytes to 512-byte blocks)
.saveBlocks:
	ld		(ix+2), c
	ld		(ix+1), d
	ld		(ix), e
	xor		a								; Cy = 0
	ret

.eleva2:									; in: A = (READ_BL_LEN + (C_SIZE_MUL+2))
											; BC = 0
											; DE = C_SIZE
	sla		e								; rotate C_SIZE by 'A' times
	rl		d
	rl		c
	rl		b
	dec		a								; decrement
	jr nz,	.eleva2
	ret

; -----------------------------------
; Calculates CSD version 2
; -----------------------------------
.CSD2calc:
	inc		hl								; HL pointer to BCSD+5, increment plus 2
	inc		hl
	ld		a, (hl)
	and		$3F
	ld		c, a
	inc		hl
	ld		d, (hl)
	inc		hl
	ld		e, (hl)
	call	.inc32							; 32 bits increment
	call	.desloca32						; * 512
	call	.rotaciona24					; * 2
	jp		.saveBlocks

.inc32:
	inc		e
	ret	nz
	inc		d
	ret	nz
	inc		c
	ret	nz
	inc		b
	ret

.desloca32:
	ld		b, c
	ld		c, d
	ld		d, e
	ld		e, 0
.rotaciona24:
	sla		d
	rl		c
	rl		b
	ret

; ------------------------------------------------
; for SDV1: sets 512-byte blocks
; ------------------------------------------------
set512bytesBlocks:
	ld		a, CMD16
	ld		bc, 0
	ld		de, 512
	jp		SD_SEND_CMD_GET_ERROR

; ------------------------------------------------
; Try to initialize an SDV2 card, if there is an
; error the card should be SDV1
; ------------------------------------------------
trySDV2:
	ld		a, CMD8
	ld		de, $1AA
	call	SD_SEND_CMD_2_ARGS_GET_R3
	ld		hl, SD_SEND_CMD1
	jr c,	.pula						; SD card declined CMD8, send CMD1 command
	ld		hl, SD_SEND_ACMD41			; SD card accepted CMD8, send ACMD41 command
.pula:
	ld		bc, 120						; B <= 0, C <= 120: 30720 tries
.loop:
	push	bc
	call	.jumpHL
	pop		bc
	ret		nc
	djnz	.loop
	dec		c
	jr nz,	.loop
	scf
	ret
.jumpHL:
	jp	(hl)

; ------------------------------------------------
; Read CID or CSD register, A contains command
; ------------------------------------------------
readBlockCxD:
	call	SD_SEND_CMD_NO_ARGS
	ret	c
	call	WAIT_RESP_FE
	ret	c
	ld		c, PORTDATA
	.16	ini					; INI x16
	in		a, (PORTDATA)
	nop
	in		a, (PORTDATA)						; answer
	or		a
	jr		disableCards

; ------------------------------------------------
; Algorithm to initialize an SD card
; Destroys AF, B, DE
; ------------------------------------------------
initializeSD:
	ld		a, $FF
	out		(PORTCTL), a				; disable SD card
	ld		b, 10						; send 80 clock pulses with SD card not selected
.loop:
	out		(PORTDATA), a
	djnz	.loop
	call	enableSD					; enable actual SD card
	ld		b, 8						; 8 tries for CMD0
SD_SEND_CMD0:
	ld		a, CMD0						; first command: CMD0
	ld		de, 0
	push	bc
	call	SD_SEND_CMD_2_ARGS_TEST_BUSY
	pop		bc
	ret	nc								; SD card accepts CMD0, return
	djnz	SD_SEND_CMD0
	scf									; SD card not accepts CMD0, error
	; fall throw

; ------------------------------------------------
; Deselect all SD cards
; Do not destroy registers
; ------------------------------------------------
disableCards:
	push	af
	ld		a, $FF
	out		(PORTCTL), a
	pop		af
	ret

; ------------------------------------------------
; Send ACMD41 command
; ------------------------------------------------
SD_SEND_ACMD41:
	ld		a, CMD55
	call	SD_SEND_CMD_NO_ARGS
	ld		a, ACMD41
	ld		bc, $4000
	ld		d, c
	ld		e, c
	jr		SD_SEND_CMD_GET_ERROR

; ------------------------------------------------
; Send CMD1 command. Carry flag indicates error
; Destroys AF, BC, DE
; ------------------------------------------------
SD_SEND_CMD1:
	ld		a, CMD1
SD_SEND_CMD_NO_ARGS:
	ld		bc, 0
	ld		d, b
	ld		e, c
SD_SEND_CMD_GET_ERROR:
	call	SD_SEND_CMD
	or		a
	ret	z								; if A=0 is OK, return
	; fall throw

; ------------------------------------------------
; Report error
; Do not destroy registers
; ------------------------------------------------
setError:
	scf
	jr		disableCards

; ------------------------------------------------
; Enviar comando em A com 2 bytes de parametros
; em DE e testar retorno BUSY
; Retorna em A a resposta do cartao
; Destroi AF, BC
; ------------------------------------------------
SD_SEND_CMD_2_ARGS_TEST_BUSY:
	ld		bc, 0
	call	SD_SEND_CMD
	ld		b, a
	and		$FE							; testar bit 0 (flag BUSY)
	ld		a, b
	jr		nz, setError				; BUSY em 1, informar erro
	ret									; sem erros

; ------------------------------------------------
; Enviar comando em A com 2 bytes de parametros
; em DE e ler resposta do tipo R3 em BC DE
; Retorna em A a resposta do cartao
; Destroi AF, BC, DE, HL
; ------------------------------------------------
SD_SEND_CMD_2_ARGS_GET_R3:
	call	SD_SEND_CMD_2_ARGS_TEST_BUSY
	ret	c
	push	af
	call	WAIT_RESP_NO_FF
	ld		h, a
	call	WAIT_RESP_NO_FF
	ld		l, a
	call	WAIT_RESP_NO_FF
	ld		d, a
	call	WAIT_RESP_NO_FF
	ld		e, a
	ld		b, h
	ld		c, l
	pop		af
	ret

; ------------------------------------------------
; Enviar comando em A com 4 bytes de parametros
; em BC DE e enviar CRC correto se for CMD0 ou
; CMD8 e aguardar processamento do cartao
; Output  : A=0 if there was no error
; Destroi AF, BC
; ------------------------------------------------
SD_SEND_CMD:
	ex		af,af'
	call	enableSD
	ex		af,af'
	out		(PORTDATA), a
	push	af
	ld		a, b
	out		(PORTDATA), a
	ld		a, c
	nop
	out		(PORTDATA), a
	ld		a, d
	nop
	out		(PORTDATA), a
	ld		a, e
	nop
	out		(PORTDATA), a
	pop		af
	cp		CMD0
	ld		b, $95						; CRC para CMD0
	jr		z, enviaCRC
	cp		CMD8
	ld		b, $87						; CRC para CMD8
	jr		z, enviaCRC
	ld		b, $FF						; CRC dummy
enviaCRC:
	ld		a, b
	out		(PORTDATA), a
;	jr		WAIT_RESP_NO_FF

; ------------------------------------------------
; Esperar que resposta do cartao seja diferente
; de $FF
; Destroi AF, BC
; ------------------------------------------------
WAIT_RESP_NO_FF:
	ld		bc, 100						; 25600 tentativas
.loop:
	in		a, (PORTDATA)
	cp		$FF							; testa $FF
	ret	nz								; sai se nao for $FF
	djnz	.loop
	dec		c
	jr		nz, .loop
	ret

; ------------------------------------------------
; Esperar que resposta do cartao seja $FE
; Destroi AF, B
; ------------------------------------------------
WAIT_RESP_FE:
	ld		b, 10						; 10 tentativas
.loop:
	push	bc
	call	WAIT_RESP_NO_FF				; esperar resposta diferente de $FF
	pop		bc
	cp		$FE							; resposta é $FE ?
	ret	z								; sim, retornamos com carry=0
	djnz	.loop
	scf									; erro, carry=1
	ret

; ------------------------------------------------
; Esperar que resposta do cartao seja diferente
; de $00
; Destroi A, BC
; ------------------------------------------------
WAIT_RESP_NO_00:
	ld		bc, 128					; 32768 tentativas
.loop:
	in		a, (PORTDATA)
	or		a
	ret	nz								; se resposta for <> $00, sai
	djnz	.loop
	dec		c
	jr		nz, .loop
	scf									; erro
	ret

; ------------------------------------------------
; Ativa (seleciona) cartao atual baixando seu /CS
; Nao destroi registradores
; ------------------------------------------------
enableSD:
	in		a, (PORTDATA)				; dummy read
	ld		a, (WRKAREA.NUMSD)
	cpl
	out		(PORTCTL), a
	ret


; ------------------------------------------------
; Grava um bloco de 512 bytes no cartao
; HL aponta para o inicio dos dados
; BC e DE contem o numero do bloco (BCDE = 32 bits)
; Destroi AF, BC, DE, HL
; ------------------------------------------------
writeBlock:
	dec	ixl		; SDcard V1?
	call	m,blocoParaByte	; Yes, convert blocks to bytes
	call	enableSD	; selecionar cartao atual
	ld	a,ixh		; get Number of blocks to write
	dec	a
	jp	z,.umBloco	; somente um bloco, gravar usando CMD24

; multiplos blocos
	exx
	ld	a, CMD55	; Multiplos blocos, mandar ACMD23 com total de blocos
	call	SD_SEND_CMD_NO_ARGS
	ld	a, ACMD23
	ld	bc, 0
	ld	d, c
	ld	e,ixh		; e=Number of blocks to write
	call	SD_SEND_CMD
	or	a
	jr	nz,.erroEscritaBlocoR	; erro no ACMD23
	exx
	ld	a, CMD25	; CMD25 = write multiple blocks
	call	SD_SEND_CMD
	or	a
	jr	z, .loop
.erroEscritaBlocoR: ; Trick to save some cycles inside the block transfer loop
	scf
	jp	terminaLeituraEscritaBloco

.loop:
	ld	c, PORTDATA
	ld	a, $FC		; mandar $FC para indicar que os proximos dados
	out	(c),a		; sao para gravacao
	nop
	.512	outi		; OUTI x512
	out	(c),a	; Send a dummy 16bit CRC
	nop
	out	(c),a
	call	WAIT_RESP_NO_FF	; esperar cartao
	and	$1F		; testa bits erro
	cp	5
	jr	nz,.erroEscritaBlocoZ	; resposta errada, informar erro
	call	WAIT_RESP_NO_00	; esperar cartao
	jr	c,.erroEscritaBlocoZ
	dec	ixh		; nblocks=nblocks-1
	jp	nz,.loop
.loopend:
	in	a, (c)	; dummy reads
	nop
	in	a, (c)
	ld	a, $FD		; enviar $FD para informar ao cartao que acabou os dados
	out	(c),a
	nop
	in	a, (c)	; dummy reads
	nop
	in	a, (c)
	call	WAIT_RESP_NO_00	; esperar cartao
	jp	.fim		; CMD25 concluido, sair informando nenhum erro

.erroEscritaBlocoZ: ; Trick to save some cycles inside the block transfer loop
	scf
	jp	terminaLeituraEscritaBloco

.umBloco:
	ld	a, CMD24	; CMD24 = Write Single Block
	call	SD_SEND_CMD_GET_ERROR
	jp	c,terminaLeituraEscritaBloco	; erro

	ld	c, PORTDATA
	ld	a, $FE		; mandar $FE para indicar que vamos mandar dados para gravacao
	out	(c),a
	nop
	.512	outi		; OUTI x512
.part2s:
	ld	a, $FF		; envia dummy CRC
	out	(c),a
	nop
	out	(c),a
	call	WAIT_RESP_NO_FF	; esperar cartao
	and	$1F		; testa bits erro
	cp	5
	scf
	jp	nz,terminaLeituraEscritaBloco	; resposta errada, informar erro
.esp:
	call	WAIT_RESP_NO_FF	; esperar cartao
	or	a
	jr	z,.esp
.fim:
	xor	a		; zera carry e informa nenhum erro
terminaLeituraEscritaBloco:
	push	af
	call	disableCards	; desabilitar todos os cartoes
	pop	af
	ret


; ------------------------------------------------
; Ler um bloco de 512 bytes do cartao
; HL aponta para o inicio dos dados
; BC e DE contem o numero do bloco (BCDE = 32 bits)
; Destroi AF, BC, DE, HL, IXL
; ------------------------------------------------
readBlock:
	dec	ixl		; SDcard V1?
	call	m,blocoParaByte	; Yes, convert blocks to bytes
	call	enableSD
	ld	a,ixh		; get Number of blocks to read
	dec	a
	jp	z,.umBloco	; somente um bloco, pular

; multiplos blocos
	ld	a, CMD18	; CMD18 = Read Multiple Blocks
	call	SD_SEND_CMD_GET_ERROR
	jr	c,terminaLeituraEscritaBloco

.loop:
	ld	bc,0
.zwaitFE:
	in	a,(PORTDATA)
	cp	$FE
	jr	z,.zFEok
	djnz	.zwaitFE	; fast card wait
	ex	(sp),hl
	ex	(sp),hl
	dec	c
	jr	nz,.zwaitFE	; slow card wait
	scf
	jr	terminaLeituraEscritaBloco
.zFEok:
	ld	c,PORTDATA
	.512	ini
	in	a, (c)	; discard 16bit CRC
	nop
	in	a, (c)
	dec	ixh		; nblocks=nblocks-1
	jp	nz,.loop
.loopend:
	ld	a, CMD12	; acabou os blocos, mandar CMD12 para cancelar leitura
	call	SD_SEND_CMD_NO_ARGS
	jp	.fim

.umBloco:
	ld	a, CMD17	; CMD17 = Read Single Block
	call	SD_SEND_CMD_GET_ERROR
	jp	c,terminaLeituraEscritaBloco

	call	WAIT_RESP_FE
	jp	c,terminaLeituraEscritaBloco

	ld	c,PORTDATA
	.512	ini
.part2s:
	in	a, (c)	; discard 16bit CRC
	nop
	in	a, (c)
.fim:
	xor	a		; zera carry para informar leitura sem erros
	jp	terminaLeituraEscritaBloco

; ------------------------------------------------
; Converte blocos para bytes. Na pratica faz
; BC DE = (BC DE) * 512
; ------------------------------------------------
blocoParaByte:
	ld		b, c
	ld		c, d
	ld		d, e
	ld		e, 0
	sla		d
	rl		c
	rl		b
	ret

; ==========================================================================
; Funcoes utilitarias
; ==========================================================================

; ------------------------------------------------
; Imprime string na tela apontada por DE
; Destroi todos os registradores
; ------------------------------------------------
printString:
	ld		a, (de)
	or		a
	ret z
	call	CHPUT
	inc		de
	jr		printString


; ------------------------------------------------
; Converte o byte em A para string em decimal no
; buffer apontado por DE
; Destroi AF, BC, HL, DE
; ------------------------------------------------
DecToAscii:
	ld		iy, WRKAREA.TEMP
	ld		h, 0
	ld		l, a						; copiar A para HL
	ld		(iy+0), 1					; flag para indicar que devemos cortar os zeros a esquerda
	ld		bc, -100					; centenas
	call	.num1
	ld		c, -10						; dezenas
	call	.num1
	ld		(iy+0), 2					; unidade deve exibir 0 se for zero e nao corta-lo
	ld		c, -1						; unidades
.num1:
	ld		a, '0'-1
.num2:
	inc		a							; contar o valor em ascii de '0' a '9'
	add		hl, bc						; somar com negativo
	jr c,	.num2						; ainda nao zeramos
	sbc		hl, bc						; retoma valor original
	dec		(iy+0)						; se flag do corte do zero indicar para nao cortar, pula
	jr nz,	.naozero
	cp		'0'							; devemos cortar os zeros a esquerda. Eh zero?
	jr nz,	.naozero
	inc		(iy+0)						; se for zero, nao salvamos e voltamos a flag
	ret
.naozero:
	ld		(de), a						; eh zero ou eh outro numero, salvar
	inc		de							; incrementa ponteiro de destino
	ret

; ------------------------------------------------
; Converte o byte em A para string em hexa no
; buffer apontado por DE
; Destroi AF, C, DE
; ------------------------------------------------
HexToAscii:
	ld		c, a
	rra
	rra
	rra
	rra
	call	.conv
	ld  	a, c
.conv:
	and		$0F
	add		a, $90
	daa
	adc		a, $40
	daa
	ld		(de), a
	inc		de
	ret

; ------------------------------------------------
; Converte o byte em A para string em decimal e
; imprime na tela
; Destroi AF, BC, HL, DE
; ------------------------------------------------
printDecToAscii:
	ld		h, 0
	ld		l, a						; copiar A para HL
	ld		b, 1						; flag para indicar que devemos cortar os zeros a esquerda
	ld		de, -100					; centenas
	call	.num1
	ld		e, -10						; dezenas
	call	.num1
	ld		b, 2						; unidade deve exibir 0 se for zero e nao corta-lo
	ld		e, -1						; unidades
.num1:
	ld		a, '0'-1
.num2:
	inc		a							; contar o valor em ascii de '0' a '9'
	add		hl, de						; somar com negativo
	jr c,	.num2						; ainda nao zeramos
	sbc		hl, de						; retoma valor original
	djnz	.naozero					; se flag do corte do zero indicar para nao cortar, pula
	cp		'0'							; devemos cortar os zeros a esquerda. Eh zero?
	jr nz,	.naozero
	inc		b							; se for zero, nao imprimimos e voltamos a flag
	ret
.naozero:
	push	hl							; nao eh zero ou eh outro numero, imprimir
	push	bc
	call	CHPUT
	pop		bc
	pop		hl
	ret

; ------------------------------------------------
; Procura pelo nome do fabricante em uma tabela.
; A contem o manufacturer ID
; Devolve HL apontando para o buffer do fabricante
; e BC com o comprimento do texto
; Destroi AF, BC, HL
; ------------------------------------------------
findManStr:
	ld		c, a
	ld		hl, tblFabricantes

.loop:
	ld		a, (hl)
	inc		hl
	cp		c
	jr z,	.achado
	or		a
	jr z,	.achado
	push	bc
	call	.achado
	add		hl, bc
	inc		hl
	pop		bc
	jr		.loop

.achado:
	ld		c, 0
	push	hl
	xor		a
.loop2:
	inc		c
	inc		hl
	cp		(hl)
	jr nz,	.loop2
	pop		hl
	ld		b, 0
	ret

; ------------------------------------------------
; Restore screen parameters on MSX>=2 if they're
; not set yet
; ------------------------------------------------
MYSETSCR:
	ld	a,(MSXVER)
	or	a			; MSX1?
	jp	z,INITXT		; Yes, change do screen-0

	ld	c,$23			; Block-2, R#3
	ld 	ix,REDCLK
	call	EXTROM
	and	1
	ld	b,a
	ld	a,(SCRMOD)
	cp	b
	jr	nz,.restore
	inc	c
	ld 	ix,REDCLK
	call	EXTROM
	ld	b,a
	inc	c
	ld 	ix,REDCLK
	call	EXTROM
	add	a,a
	add	a,a
	add	a,a
	add	a,a
	or	b
	ld	b,a
	ld	a,(LINLEN)
	cp	b
	ret	z
.restore:
	xor	a		; Don't displat the function keys
	ld	ix,SDFSCR
	jp	EXTROM

; ------------------------------------------------
; Check if the STOP key was signaled on DRV_INIT
; ------------------------------------------------
INICHKSTOP:
	ld	a,(INTFLG)
	cp	4			; Was STOP pressed?
	ret	nz			; No, quit as fast as possible

	; Handle STOP to pause and read messages, and ask for the copyright info
	ld	de,strBootpaused
	call	printString
.wait1:
	ld	a,7
	call	SNSMAT
	and	$10			; Is STOP still pressed?
	jr	z,.wait1		; Wait for STOP to be released
	xor	a
	ld	(INTFLG),a		; Clear STOP flag
	ld	b,0			; b=inhibit 'i' key flag
.wait2:
	call	CHSNS
	call	nz,.chkikey		; Wait until a key is pressed
	ld	a,(INTFLG)
	cp	4			; Was STOP pressed?
	jr	nz,.wait2		; No, return
	xor	a
	ld	(INTFLG),a		; Clear STOP flag
	call	KILBUF
	ld	b,30			; Since the user is trying pause the
.wait3:	halt				; boot messages, this gives him enough
					; time to react and pause the next
					; driver
	ld	a,(INTFLG)
	cp	4			; Was STOP pressed?
	ret	z			; quit so the next driver can process it
	djnz	.wait3			; The user will have the impression
					; that he has a perfect timing.   ;)
	ret

.chkikey:
	bit	0,b			; Was the copyright message shown?
	ret	nz			; Yes, return
	call	CHGET
	cp	'i'
	jr	z,.showcopyright
	cp	'I'
	ret	nz
.showcopyright:
	inc	b			; Inhibit further presses of the i key
	ld	de,strCopyright
	jp	printString

; ==========================================================================
tblFabricantes:
	db	1
	db	"Panasonic",0
	db	2
	db	"Toshiba",0
	db	3
	db	"SanDisk",0
	db	4
	db	"SMI-S",0
	db	6
	db	"Renesas",0
	db	17
	db	"Dane-Elec",0
	db	19
	db	"KingMax",0
	db	21
	db	"Samsung",0
	db	24
	db	"Infineon",0
	db	26
	db	"PQI",0
	db	27
	db	"Sony",0
	db	28
	db	"Transcend",0
	db	29
	db	"A-DATA",0
	db	31
	db	"SiliconPower",0
	db	39
	db	"Verbatim",0
	db	65
	db	"OKI",0
	db	115
	db	"SilverHT",0
	db	137
	db	"L.Data",0
	db	0
	db	"Generico",0

strTitle:
	db	"MSX1FPGA SDHC driver "
	db	"v",VER_MAIN+$30,'.',VER_SEC+$30,'.',VER_REV+$30
	db	13,10,0

strBootpaused:
	db	"Paused. Press <i> to show the copyright info.",13,10,0

strCopyright:
	db	"(c) 2016 Fabio Belavenuto",13,10
	db	"(c) 2016 FRS",13,10
	db	"Licenced under CERN OHL v1.1",13,10
	db	"http://ohwr.org/cernohl",13,10
	; fall throw
strCrLf:
	db	13,10,0
strSDSlot:
	db	"Slot ",0
strVazio:
	db	"Empty",13,10,0
strNaoIdentificado:
	db	"Unknown!",13,10,0
			;----------------------------------------
strSDV1:
	db	"SDV1 - ",0
strSDV2:
	db	"SDV2 - ",0

; RAM area
	org		$7000

; Work area variables
WRKAREA.BCSD 		ds 16	; Card Specific Data
WRKAREA.BCID1		ds 16	; Card-ID of card1
WRKAREA.BCID2		ds 16	; Card-ID of card2
WRKAREA.NUMSD		ds 1	; Currently selected card: 1 or 2
WRKAREA.NUMBLOCKS	ds 1	; Number of blocks in multi-block operations
WRKAREA.BLOCKS1		ds 3	; 3 bytes. Size of card1, in blocks.
WRKAREA.BLOCKS2		ds 3	; 3 bytes. Size of card2, in blocks.
WRKAREA.TEMP		ds 1	; Temporary data

 IF HWDS = 0
WRKAREA.FLAGS		ds 1	; Flags for soft-diskchange
 ENDIF

;-----------------------------------------------------------------------------
;
; End of the driver code

DRV_END:

	ds	3ED0h-(DRV_END-DRV_START), $FF

