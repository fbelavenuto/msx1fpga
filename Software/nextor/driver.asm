; MSX1 FPGA project
;
;Copyright (c) 2016 Fabio Belavenuto
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
;	b0	: 1=SD disk was changed (If Hardware Disk Change is available)
;	b1	: 0=SD card present
;	b2	: 1=Write protecton enabled for SD card
;	b3-7: Reserved for future use. Must be masked out from readings.
;	<write>
;	b0	: SD card chip-select (0=selected)
; I/O port 0x9F: SPI data transfer (read/write)

; Comments in Brazilian Portuguese, sorry :(

	output	"driver.bin"

; Uses HW (1) or SW (0) disk-change:
HWDS = 1


;-----------------------------------------------------------------------------
;
; Miscellaneous constants
;

;This is a 2 byte buffer to store the address of code to be executed.
;It is used by some of the kernel page 0 routines.

CODE_ADD:	equ	0F84Ch


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

;Driver version

VER_MAIN	equ	1
VER_SEC		equ	0
VER_REV		equ	0


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

NULL_MSG  equ     781Fh		;Null string (disk can't be formatted)
SING_DBL  equ     7820h 	;"1-Single side / 2-Double side"


; Enderecos ROM

BIOS_INITXT	= $6C		; Inicializa SCREEN0
BIOS_CHPUT	= $A2		; A=char
BIOS_CLS	= $C3		; Chamar com A=0
LINL40		= $F3AE		; Width
LINLEN		= $F3B0

; Enderecos SPI

PORTCFG		= $9E
PORTSTATUS	= $9E
PORTSPI		= $9F

; Comandos SPI:
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

	org	$4000

	ds	256, $FF	; 256 dummy bytes

DRV_START:

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
;    bit 2: 1 if the driver provides configuration
;             (implements the DRV_CONFIG routine)


	db	DRV_TYPE+(2*DRV_HOTPLUG)+4

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
	db	"SD Driver"
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
	jp      DRV_CONFIG

    ds      12


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
	or	a		; primeira chamada do Nextor
	;ld	hl,WRKAREA
	ld	hl, 41		; informar que nao precisamos de RAM
	ret z


; 2. chamada:
	call	BIOS_INITXT	; inicializar tela
	xor	a
	call	BIOS_CLS	; limpar tela
	ld	de, strTitulo	; imprimir titulo
	call	printString
 IF HWDS = 0
	xor	a
	ld	(WRKAREA.FLAGS), a
 ENDIF
	ld	de, strCartao
	call	printString
	in	a, (PORTSTATUS)	; Is there an SD Card in the slot?
	and	$2
	jr	z, .naoVazio
	ld	de, strVazio
	call	printString
 IF HWDS = 0
 	call	marcaErroCartao
 ENDIF
	jr	.wait
.naoVazio:
	call	detectaCartao	; tem cartao no slot, inicializar e detectar
	jr	nc, .detectou ; RAMPA
	call	desabilitaSDs
	ld	de, strNaoIdentificado
	call	printString
 IF HWDS = 1
	ret
 ELSE
	jp	marcaErroCartao	; slot vazio ou erro de deteccao, marcar nas flags
 ENDIF
.detectou:
	call	calculaCIDoffset
	ld	a, (ix+15)	; pegar byte SDV1 ou SDV2
	ld	de, strSDV1	; e imprimir
	or	a
	jr	z, .pula1
	ld	de, strSDV2
.pula1:
	call	printString
	ld	a, '('
	call	BIOS_CHPUT
	ld	a, (ix)		; pegar byte do fabricante
	call	printDecToAscii	; Imprimir Manufacturer ID
	ld	a, ')'
	call	BIOS_CHPUT
	ld	a, ' '
	call	BIOS_CHPUT
	ld	a, (ix)		; pegar byte do fabricante
	call	pegaFabricante	; achar nome do fabricante
	ex	de, hl
	call	printString	; e imprimir
	ld	de, strCrLf
	call	printString
	ld	bc, 0
	ld	e, 2
.wait:				; esperar um pouco para dar tempo
	nop			; de ler mensagens
	dec	bc
	ld	a, c
	or	b
	jr	nz, .wait
	dec	e
	jr	nz, .wait
	ret


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

;-----------------------------------------------------------------------------
;
; Get driver configuration 
; (bit 2 of driver flags must be set if this routine is implemented)
;
; Input:
;   A = Configuration index
;   BC, DE, HL = Depends on the configuration
;
; Output:
;   A = 0: Ok
;       1: Configuration not available for the supplied index
;   BC, DE, HL = Depends on the configuration
;
; * Get number of drives at boot time (for device-based drivers only):
;   Input:
;     A = 1
;     B = 0 for DOS 2 mode, 1 for DOS 1 mode
;     C: bit 5 set if user is requesting reduced drive count
;        (by pressing the 5 key)
;   Output:
;     B = number of drives
;
; * Get default configuration for drive
;   Input:
;     A = 2
;     B = 0 for DOS 2 mode, 1 for DOS 1 mode
;     C = Relative drive number at boot time
;   Output:
;     B = Device index
;     C = LUN index


DRV_CONFIG:
        ;ld a,1
        ;ret

        dec a
        jr z,DRV_CONFIG_1
        dec a
        jr z,DRV_CONFIG_2
        ld a,1
        ret

DRV_CONFIG_1:
        ld b,2
        or a
        ret

DRV_CONFIG_2:
        ld b,1
        ld c,1
        xor a
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
	cp	2		; somente 1 dispositivo
	jr	nc, .saicomerroidl
	dec	c		; somente 1 logical unit
	jr	z, .ok
.saicomerroidl:
	pop	af		; retira AF guardado no inicio
	ld	a, EIDEVL	; informar erro
	ld	b, 0
	ret
 IF HWDS = 0
.errornr:
	pop	af		; retira AF guardado no inicio
	ld	a, ENRDY	; Not ready
;	ld	a, EDISK	; General unknown disk error
	ld	b, 0
	ret
 ENDIF
.ok:
 IF HWDS = 0
	call	checkSWDS
	jr	c, .errornr
 ENDIF
 	ld	a, b
	ld	(WRKAREA.NUMBLOCKS), a	; guarda numero de blocos para ler/gravar
	push	hl
	call	calculaCIDoffset	; calculamos em IX a posicao correta do offset CID dependendo do cartao atual
	pop	hl
	pop	af		; retira AF guardado no inicio, para saber se eh leitura ou escrita
	jr	c, escrita	; se for escrita pulamos
leitura:
	ld	a, (de)		; 1. n. bloco
	push	af
	inc	de
	ld	a, (de)		; 2. n. bloco
	push	af
	inc	de
	ld	a, (de)		; 3. n. bloco
	ld	c, a
	inc	de
	ld	a, (de)		; 4. n. bloco
	inc	de
	ld	b, a
	pop	af
	ld	d, a
	pop	af		; HL = ponteiro destino
	ld	e, a		; BC DE = 32 bits numero do bloco
	call	LerBloco	; chamar rotina de leitura de dados
	jr	nc, .ok
 IF HWDS = 0
	call	marcaErroCartao	; ocorreu erro na leitura, marcar erro
 ENDIF
;	ld	a, ENRDY	; Not ready
	ld	a, EDISK	; General unknown disk error
	ld	b, 0		; informar que lemos 0 blocos
	ret
.ok:
	xor	a		; tudo OK, informar ao Nextor
	ret

escrita:
	in	a, (PORTSTATUS)	; destructive read
	and	$4		; test if the card is write protected
	jr	z, .ok
	ld	a, EWPROT	; write protect
	ld	b, 0		; 0 blocks were written
	ret
.ok:
	ld	a, (de)		; 1. n. bloco
	push	af
	inc	de
	ld	a, (de)		; 2. n. bloco
	push	af
	inc	de
	ld	a, (de)		; 3. n. bloco
	inc	de
	ld	c, a
	ld	a, (de)		; 4. n. bloco
	inc	de
	ld	b, a
	pop	af
	ld	d, a
	pop	af		; HL = ponteiro destino
	ld	e, a		; BC DE = 32 bits numero do bloco
	call	GravarBloco	; chamar rotina de gravacao de dados
	jr	nc, .ok2
 IF HWDS = 0
	call	marcaErroCartao	; ocorreu erro, marcar nas flags
 ENDIF
	ld	a, EWRERR	; Write error
	ld	b, 0
	ret
.ok2:
	xor	a		; gravacao sem erros!
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
	inc	b
	cp	2		; somente 1 dispositivo
	jr	c, .ok
.saicomerro:
	ld	a, 1		; informar erro
	ret
.ok:
 IF HWDS = 0
	call	checkSWDS
	jr	c, .saicomerro
 ENDIF
	djnz	.naoBasic
; Basic information:
	ld	a, 1		; 1 logical unit somente
	ld	(hl), a
	xor	a		; reservado, deve ser 0
	inc	hl
	ld	(hl), a
	ret			; retorna com A=0 (OK)

.naoBasic:
	push	hl
	call	calculaCIDoffset	; calculamos em IX a posicao correta do offset CID dependendo do cartao atual
	pop	hl
	djnz	.naoManuf
; Manufacturer Name:
	push	hl		; salva ponteiro do buffer
	ld	b, 64		; preenche buffer com espaco
	ld	a, ' '
.loop1:
	ld	(hl), a
	inc	hl
	djnz	.loop1
	pop	de		; recuperamos ponteiro do buffer em DE
	ld	a, '('		; colocamos (xx) xxx no buffer
	ld	(de), a
	inc	de
	ld	a, (ix)		; byte do fabricante
	call	DecToAscii
	ld	a, ')'
	ld	(de), a
	inc	de
	ld	a, ' '
	ld	(de), a
	inc	de
	ld	a, (ix)		; byte do fabricante
	call	pegaFabricante	; pegar nome do fabricante em HL
	ldir			; e colocar no buffer
	ret

.naoManuf:
	djnz	.naoProduct
; Product Name:
	push	hl		; guarda HL que aponta para buffer do Nextor
	push	ix
	pop	hl		; joga IX para HL
	ld	d, 0
	ld	e, 3		; adiciona offset do productname em HL
	add	hl, de
	pop	de		; recupera buffer do Nextor em DE
	ld	bc, 5		; 5 caracteres
	ldir			; copia nome do produto
	ex	de, hl		; troca DE com HL, agora HL aponta para Buffer do nextor atualizado
	ld	b, 59		; Coloca espaco no restante do buffer
	ld	a, ' '
.loop2:
	ld	(hl), a
	inc	hl
	djnz	.loop2
	xor	a		; informar sem erros
	ret

.naoProduct:
; Serial:
	ld	a, '0'		; Coloca prefixo "0x"
	ld	(hl), a
	inc	hl
	ld	a, 'x'
	ld	(hl), a
	inc	hl
	push	hl		; guarda HL que aponta para buffer do Nextor
	push	ix
	pop	hl		; joga IX para HL
	ld	d, 0
	ld	e, 9		; adiciona offset do productname em HL
	add	hl, de
	pop	de		; recupera buffer do nextor em DE
	ld	b, 4		; 4 bytes do serial
.loop3:
	ld	a, (hl)
	call	HexToAscii	; converter HEXA para ASCII
	inc	hl
	djnz	.loop3
	ld	b, 54		; Coloca espaco no restante
	ld	a, ' '
.loop4:
	ld	(de), a
	inc	de
	djnz	.loop4
	xor	a		; informar sem erros
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
	cp	2		; 1 dispositivo somente
	jr	nc, .saicomerro
	dec	b		; 1 logical unit somente
	jr	nz, .saicomerro
	ld	(WRKAREA.NUMSD), a
 IF HWDS = 0
	ld	a, (WRKAREA.FLAGS)
	and	1
	jr	z, .semMudanca
	call	detectaCartao	; try redetect
	jr	c, .cartaoComErro
	ld	a, (WRKAREA.FLAGS)
	and	$FE
	ld	(WRKAREA.FLAGS), a
	jr	.comMudanca2
 ELSE
	in	a, (PORTSTATUS)	; destructive read
	bit	1, a
	jr	nz, .saicomerro	; no
	bit	0, a		; changed?
	jr	nz, .comMudanca	; no
 ENDIF
.semMudanca:
	ld	a, 1		; informa ao Nextor que cartao esta OK e nao mudou
	ret
.comMudanca:
	call	detectaCartao	; try redetect
.comMudanca2
	ld	a, 2		; informa ao Nextor que cartao esta OK e mudou
	ret
 IF HWDS = 0
.cartaoComErro:
	call	marcaErroCartao	; marcar erro do cartao nas flags
 ENDIF
.saicomerro:
	xor	a		; informa erro
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
	cp	2		; somente 1 dispositivo
	jr	nc, .saicomerro
	dec	b		; somente 1 logical unit
	jr	z, .ok
.saicomerro:
	ld	a, 1		; informar erro
	ret
.ok:
 IF HWDS = 0
	call	checkSWDS
	jr	c, .saicomerro
 ENDIF
	push	hl
	call	calculaBLOCOSoffset	; calcular em IX e HL o offset correto do buffer que armazena total de blocos
	pop	hl		; do cartao dependendo do cartao atual solicitado
	xor	a
	ld	(hl), a		; Informar que o dispositivo eh do tipo block device
	inc	hl
	ld	(hl), a		; tamanho de um bloco = 512 bytes (coloca $00, $02 que � $200 = 512)
	inc	hl
	ld	a, 2
	ld	(hl), a
	inc	hl
	ld	a, (ix)		; copia numero de blocos total
	ld	(hl), a
	inc	hl
	ld	a, (ix+1)
	ld	(hl), a
	inc	hl
	ld	a, (ix+2)
	ld	(hl), a
	inc	hl
	xor	a		; cartoes SD tem total de blocos em 24 bits, mas o Nextor pede numero de
	ld	(hl), a 	; 32 bits, entao coloca 0 no MSB
	inc	hl
	ld	a, 1		; flags: dispositivo R/W removivel
	ld	(hl), a
	inc	hl
	xor	a		; CHS = 0
	ld	(hl), a
	inc	hl
	ld	(hl), a
	inc	hl
	ld	(hl), a
	inc	hl
	xor	a		; informar que dados foram preenchidos
	ret

;=====
;=====  END of DEVICE-BASED specific routines
;=====

;------------------------------------------------
; Rotinas auxiliares
;------------------------------------------------

;------------------------------------------------
; Testa se cartao esta inserido e/ou houve erro
; na ultima vez que foi acessado. Carry indica
; erro
; Destroi AF
;------------------------------------------------

 IF HWDS = 0
checkSWDS:
	ld	a, (WRKAREA.FLAGS)	; testar bit de erro do cartao nas flags
	and	1
	jr	z, .ok
	scf			; indica erro
	ret
.ok:
	xor	a		; zera carry indicando sem erro
	ret

;------------------------------------------------
; Marcar bit de erro nas flags
; Destroi AF, C
;------------------------------------------------
marcaErroCartao:
	ld	a, (WRKAREA.FLAGS)	; marcar erro
	or	1
	ld	(WRKAREA.FLAGS), a
	ret

 ENDIF

;------------------------------------------------
; Calcula offset do buffer na RAM em HL e IX para
; os dados do CID dependendo do cartao atual
; Destroi AF, DE, HL e IX
;------------------------------------------------
calculaCIDoffset:
	ld	hl, WRKAREA.BCID1
	ld	a, (WRKAREA.NUMSD)
	dec	a
	jr	z, .c1
.c1:
	push	hl		
	pop	ix		; vamos colocar HL em IX
	ret

;------------------------------------------------
; Calcula offset do buffer na RAM para os dados
; do total de blocos dependendo do cartao atual
; Offset fica em HL e IX
; Destroi AF, DE, HL e IX
;------------------------------------------------
calculaBLOCOSoffset:
	ld	hl, WRKAREA.BLOCKS1
	ld	a, (WRKAREA.NUMSD)
	dec	a
	jr	z, .c1
	ld	hl, WRKAREA.BLOCKS2
.c1:
	push	hl		
	pop	ix		; Vamos colocar HL em IX
	ret


;------------------------------------------------
; Minhas funcoes para cartao SD
;------------------------------------------------

;------------------------------------------------
; Processo de inicializacao e deteccao do cartao.
; Detecta se cartao responde, qual versao (SDV1
; ou SDV2), faz a leitura do CSD e CID e calcula
; o numero de blocos do cartao, colocando o CID
; e total de blocos no buffer correto dependendo
; do cartao 1 ou 2.
; Retorna erro no carry. Se for 0 indica deteccao
; com sucesso.
; Destroi todos os registradores
;------------------------------------------------
detectaCartao:
	call	iniciaSD	; manda pulsos de clock e comandos iniciais
	ret	c		; retorna se erro
	call	testaSDCV2	; tenta inicializar um cartao SDV2
	ret	c
	ld	hl, WRKAREA.BCSD
	ld	a, CMD9		; ler CSD
	call	lerBlocoCxD
	ret	c
	call	calculaCIDoffset	; calculamos em IX e HL a posicao correta do offset CID dependendo do cartao atual
	ld	a, CMD10	; ler CID
	call	lerBlocoCxD
	ret	c
	ld	a, CMD58	; ler OCR
	ld	de, 0
	call	SD_SEND_CMD_2_ARGS_GET_R3	; enviar comando e receber resposta tipo R3
	ret	c
	ld	a, b		; testa bit CCS do OCR que informa se cartao eh SDV1 ou SDV2
	and	$40
	ld	(ix+15), a	; salva informacao da versao do SD (V1 ou V2) no byte 15 do CID
	call	z, mudarTamanhoBlocoPara512		; se bit CCS do OCR for 1, eh cartao SDV2 (Block address - SDHC ou SDXD)
	ret	c		; e nao precisamos mudar tamanho do bloco para 512
	call	desabilitaSDs
				; agora vamos calcular o total de blocos dependendo dos dados do CSD
	call	calculaBLOCOSoffset	; calcular em IX e HL o offset correto do buffer que armazena total de blocos
	ld	hl, WRKAREA.BCSD+5
	ld	a, (WRKAREA.BCSD)
	and	$C0		; testa versao do registro CSD
	jr	z, .calculaCSD1
	cp	$40
	;jr	z, .calculaCSD2
	jr .calculaCSD2
	scf			; versao do registro CSD nao reconhecida, informa erro na deteccao
	ret

; -----------------------------------
; Registro CSD versao 1, calcular da
; maneira correta para a versao 1
; -----------------------------------
.calculaCSD1:
	ld	a, (hl)
	and	$0F		; isola READ_BL_LEN
	push	af
	inc	hl
	ld	a, (hl)		; 2 primeiros bits de C_SIZE
	and	3
	ld	d, a
	inc	hl
	ld	e, (hl)		; 8 bits de C_SIZE (DE contem os primeiros 10 bits de C_SIZE)
	inc	hl
	ld	a, (hl)
	and	$C0		; 2 ultimos bits de C_SIZE
	add	a, a		; rotaciona a esquerda
	rl	e		; rotaciona para DE
	rl	d
	add	a, a		; mais uma rotacao
	rl	e		; rotaciona para DE
	rl	d
	inc	de		; agora DE contem todos os 12 bits de C_SIZE, incrementa 1
	inc	hl
	ld	a, (hl)		; proximo byte
	and	3		; 2 bits de C_SIZE_MUL
	ld	b, a		; B contem os 2 bits de C_SIZE_MUL
	inc	hl
	ld	a, (hl)		; proximo byte
	and	$80		; 1 bit de C_SIZE_MUL
	add	a, a		; rotaciona para esquerda jogando no carry
	rl	b		; rotaciona para B
	inc	b		; agora B contem os 3 bits de C_SIZE_MUL
	inc	b		; faz B = C_SIZE_MUL + 2
	pop	af		; volta em A o READ_BL_LEN
	add	a, b		; A = READ_BL_LEN + (C_SIZE_MUL+2)
	ld	bc, 0
	call	.eleva2
	ld	e, d		; aqui temos 32 bits (BC DE) com o tamanho do cartao
	ld	d, c		; ignoramos os 8 ultimos bits em E, fazemos BC DE => 0B CD (divide por 256)
	ld	c, b
	ld	b, 0
	srl	c		; rotacionamos a direita o C, carry = LSB (divide por 2)
	rr	d		; rotacionamos D e E
	rr	e		; no final BC DE contem tamanho do cartao / 512 = numero de blocos
.salvaBlocos:
	ld	(ix+2), c	; colocar no buffer BLOCOS correto a quantidade de blocos
	ld	(ix+1), d	; que o cartao (1 ou 2) tem
	ld	(ix), e
	xor	a		; limpa carry
	ret

.eleva2:			; aqui temos: A = (READ_BL_LEN + (C_SIZE_MUL+2))
				; BC = 0
				; DE = C_SIZE
	sla	e		; rotacionamos C_SIZE por 'A' vezes
	rl	d
	rl	c
	rl	b
	dec	a		; subtraimos 1
	jr	nz, .eleva2
	ret			; em BC DE temos o tamanho do cartao (bytes) em 32 bits

; -----------------------------------
; Registro CSD versao 2, calcular da
; maneira correta para a versao 2
; -----------------------------------
.calculaCSD2:
	inc	hl		; HL ja aponta para BCSD+5, fazer HL apontar para BCSD+7
	inc	hl
	ld	a, (hl)
	and	$3F
	ld	c, a
	inc	hl
	ld	d, (hl)
	inc	hl
	ld	e, (hl)
	call	.inc32		; soma 1
	call	.desloca32	; multiplica por 512
	call	.rotaciona24	; multiplica por 2
	jp	.salvaBlocos

.inc32:
	inc	e
	ret	nz
	inc	d
	ret	nz
	inc	c
	ret	nz
	inc	b
	ret

.desloca32:
	ld	b, c
	ld	c, d
	ld	d, e
	ld	e, 0
.rotaciona24:
	sla	d
	rl	c
	rl	b
	ret

; ------------------------------------------------
; Setar o tamanho do bloco para 512 se o cartao
; for SDV1
; ------------------------------------------------
mudarTamanhoBlocoPara512:
	ld	a, CMD16
	ld	bc, 0
	ld	de, 512
	jp	SD_SEND_CMD_GET_ERROR

; ------------------------------------------------
; Tenta inicializar um cartao SDV2, se houver erro
; o cartao deve ser SDV1
; ------------------------------------------------
testaSDCV2:
	ld	a, CMD8
	ld	de, $1AA
	call	SD_SEND_CMD_2_ARGS_GET_R3
	ld	hl, SD_SEND_CMD1	; HL aponta para rotina correta
	jr	c, .pula	; cartao recusou CMD8, enviar comando CMD1
	ld	hl, SD_SEND_ACMD41	; cartao aceitou CMD8, enviar comando ACMD41
.pula:
	ld	bc, 120		; 120 tentativas
.loop:
	push	bc
	call	.jumpHL		; chamar rotina correta em HL
	pop	bc
	ret	nc
	djnz	.loop
	dec	c
	jr	nz, .loop
	scf
	ret
.jumpHL:
	jp	(hl)		; chamar rotina correta em HL

; ------------------------------------------------
; Enviar comando ACMD41
; ------------------------------------------------
SD_SEND_ACMD41:
	ld	a, CMD55
	call	SD_SEND_CMD_NO_ARGS
	ld	a, ACMD41
	ld	bc, $4000
	ld	d, c
	ld	e, c
	jr	SD_SEND_CMD_GET_ERROR

; ------------------------------------------------
; Ler registro CID ou CSD, o comando vem em A
; ------------------------------------------------
lerBlocoCxD:
	call	SD_SEND_CMD_NO_ARGS
	ret	c
	call	WAIT_RESP_FE
	ret	c
	ld	c, PORTSPI
	ld	b, 16
	inir
	nop
	in	a, (PORTSPI)
	nop
	in	a, (PORTSPI)	; byte de resposta
	or	a
	jr	desabilitaSDs


; ------------------------------------------------
; Algoritmo para inicializar um cartao SD
; Destroi AF, B, DE
; ------------------------------------------------

iniciaSD:
        ld              a, $FF
        out             (PORTCFG), a                            ; disable SD card
        ld              b, 10                                           ; send 80 clock pulses with SD card not selected
.loop:
        out             (PORTSPI), a
        djnz    .loop
        call    enableSD                                        ; enable actual SD card
        ld              b, 8                                            ; 8 tries for CMD0
SD_SEND_CMD0:
        ld              a, CMD0                                         ; first command: CMD0
        ld              de, 0
        push    bc
        call    SD_SEND_CMD_2_ARGS_TEST_BUSY
        pop             bc
        ret     nc                                                              ; SD card accepts CMD0, return
        djnz    SD_SEND_CMD0
        scf                                                                     ; SD card not accepts CMD0, error
        ; fall throw

; ------------------------------------------------
; Desabilitar (de-selecionar) todos os cartoes
; Nao destroi registradores
; ------------------------------------------------
desabilitaSDs:
	push	af
	ld	a, $FF
	out	(PORTCFG), a
	pop	af
	ret

; ------------------------------------------------
; Enviar CMD1 para cartao. Carry indica erro
; Destroi AF, BC, DE
; ------------------------------------------------
SD_SEND_CMD1:
	ld	a, CMD1
SD_SEND_CMD_NO_ARGS:
	ld	bc, 0
	ld	d, b
	ld	e, c
SD_SEND_CMD_GET_ERROR:
	call	SD_SEND_CMD
	or	a
	ret	z		; se A=0 nao houve erro, retornar
	; fall throw

; ------------------------------------------------
; Informar erro
; Nao destroi registradores
; ------------------------------------------------
setaErro:
	scf
	jr		desabilitaSDs

; ------------------------------------------------
; Enviar comando em A com 2 bytes de parametros
; em DE e testar retorno BUSY
; Retorna em A a resposta do cartao
; Destroi AF, BC
; ------------------------------------------------
SD_SEND_CMD_2_ARGS_TEST_BUSY:
	ld	bc, 0
	call	SD_SEND_CMD
	ld	b, a
	and	$FE		; testar bit 0 (flag BUSY)
	ld	a, b
	jr	nz, setaErro	; BUSY em 1, informar erro
	ret			; sem erros

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
	ld	h, a
	call	WAIT_RESP_NO_FF
	ld	l, a
	call	WAIT_RESP_NO_FF
	ld	d, a
	call	WAIT_RESP_NO_FF
	ld	e, a
	ld	b, h
	ld	c, l
	pop	af
	ret

; ------------------------------------------------
; Enviar comando em A com 4 bytes de parametros
; em BC DE e enviar CRC correto se for CMD0 ou 
; CMD8 e aguardar processamento do cartao
; Destroi AF, BC
; ------------------------------------------------
SD_SEND_CMD:
	call	enableSD
	out	(PORTSPI), a
	push	af
	ld	a, b
	nop
	out	(PORTSPI), a
	ld	a, c
	nop
	out	(PORTSPI), a
	ld	a, d
	nop
	out	(PORTSPI), a
	ld	a, e
	nop
	out	(PORTSPI), a
	pop	af
	cp	CMD0
	ld	b, $95		; CRC para CMD0
	jr	z, enviaCRC
	cp	CMD8
	ld	b, $87		; CRC para CMD8
	jr	z, enviaCRC
	ld	b, $FF		; CRC dummy
enviaCRC:
	ld	a, b
	out	(PORTSPI), a
	jr	WAIT_RESP_NO_FF

; ------------------------------------------------
; Esperar que resposta do cartao seja $FE
; Destroi AF, B
; ------------------------------------------------
WAIT_RESP_FE:
	ld	b, 10		; 10 tentativas
.loop:
	push	bc
	call	WAIT_RESP_NO_FF	; esperar resposta diferente de $FF
	pop	bc
	cp	$FE		; resposta � $FE ?
	ret	z		; sim, retornamos com carry=0
	djnz	.loop
	scf			; erro, carry=1
	ret

; ------------------------------------------------
; Esperar que resposta do cartao seja diferente
; de $FF
; Destroi AF, BC
; ------------------------------------------------
WAIT_RESP_NO_FF:
	ld	bc, 100		; 25600 tentativas
.loop:
	in	a, (PORTSPI)
	cp	$FF		; testa $FF
	ret	nz		; sai se nao for $FF
	djnz	.loop
	dec	c
	jr	nz, .loop
	ret

; ------------------------------------------------
; Esperar que resposta do cartao seja diferente
; de $00
; Destroi A, BC
; ------------------------------------------------
WAIT_RESP_NO_00:
	ld	bc, 32768	; 32768 tentativas
.loop:
	in	a, (PORTSPI)
	or	a
	ret	nz		; se resposta for <> $00, sai
	djnz	.loop
	dec	c
	jr	nz, .loop
	scf			; erro
	ret

; ------------------------------------------------
; Ativa (seleciona) cartao atual baixando seu /CS
; Nao destroi registradores
; ------------------------------------------------
enableSD:
	push	af
	in	a, (PORTSPI)	; dummy read
	ld	a, $FE
	out	(PORTCFG), a
	pop	af
	ret


; ------------------------------------------------
; Grava um bloco de 512 bytes no cartao
; HL aponta para o inicio dos dados
; BC e DE contem o numero do bloco (BCDE = 32 bits)
; Destroi AF, BC, DE, HL
; ------------------------------------------------
GravarBloco:
	ld	a, (ix+15)	; verificar se eh SDV1 ou SDV2
	or	a
	call	z, blocoParaByte	; se for SDV1 coverter blocos para bytes
	call	enableSD
	ld	a, (WRKAREA.NUMBLOCKS)	; testar se Nextor quer gravar 1 ou mais blocos
	dec	a
	jp	z, .umBloco	; somente um bloco, gravar usando CMD24

; multiplos blocos
	push	bc
	push	de
	ld	a, CMD55	; Multiplos blocos, mandar ACMD23 com total de blocos
	call	SD_SEND_CMD_NO_ARGS
	ld	bc, 0
	ld	d, c
	ld	a, (WRKAREA.NUMBLOCKS)	; parametro = total de blocos a gravar
	ld	e, a
	ld	a, ACMD23
	call	SD_SEND_CMD_GET_ERROR
	pop	de
	pop	bc
	jp	c, .erro	; erro no ACMD23
	ld	a, CMD25	; comando CMD25 = write multiple blocks
	call	SD_SEND_CMD_GET_ERROR
	jp	c, .erro	; erro
.loop:
	ld	a, $FC		; mandar $FC para indicar que os proximos dados sao
	out	(PORTSPI), a	; dados para gravacao
	ld	bc, PORTSPI
	otir
	otir
	ld	a, $FF		; envia dummy CRC
	out	(PORTSPI), a
	nop
	out	(PORTSPI), a
	call	WAIT_RESP_NO_FF	; esperar cartao
	and	$1F		; testa bits erro
	cp	5
	jr	nz, .erro	; resposta errada, informar erro
	call	WAIT_RESP_NO_00	; esperar cartao
	jr	c, .erro
	ld	a, (WRKAREA.NUMBLOCKS)	; testar se tem mais blocos para gravar
	dec	a
	ld	(WRKAREA.NUMBLOCKS), a
	jp	nz, .loop
	in	a, (PORTSPI)	; acabou os blocos, fazer 2 dummy reads
	nop
	in	a, (PORTSPI)
	ld	a, $FD		; enviar $FD para informar ao cartao que acabou os dados
	out	(PORTSPI), a
	nop
	nop
	in	a, (PORTSPI)	; dummy reads
	nop
	in	a, (PORTSPI)
	call	WAIT_RESP_NO_00	; esperar cartao
	jp	.fim		; CMD25 concluido, sair informando nenhum erro

.umBloco:
	ld	a, CMD24	; gravar somente um bloco com comando CMD24 = Write Single Block
	call	SD_SEND_CMD_GET_ERROR
	jr	nc, .ok
.erro:
	scf			; informar erro
	jp	terminaLeituraEscritaBloco
.ok:
	ld	a, $FE		; mandar $FE para indicar que vamos mandar dados para gravacao
	out	(PORTSPI), a
	ld	bc, PORTSPI
	otir
	otir
	ld	a, $FF		; envia dummy CRC
	out	(PORTSPI), a
	nop
	out	(PORTSPI), a
	call	WAIT_RESP_NO_FF	; esperar cartao
	and	$1F		; testa bits erro
	cp	5
	jp	nz, .erro	; resposta errada, informar erro
.esp:
	call	WAIT_RESP_NO_FF	; esperar cartao
	or	a
	jr	z, .esp
.fim:
	xor	a		; zera carry e informa nenhum erro
terminaLeituraEscritaBloco:
	push	af
	call	desabilitaSDs	; desabilitar todos os cartoes
	pop	af
	ret

; ------------------------------------------------
; Ler um bloco de 512 bytes do cartao
; HL aponta para o inicio dos dados
; BC e DE contem o numero do bloco (BCDE = 32 bits)
; Destroi AF, BC, DE, HL
; ------------------------------------------------
LerBloco:
	ld	a, (ix+15)	; verificar se eh SDV1 ou SDV2
	or	a
	call	z, blocoParaByte	; se for SDV1 coverter blocos para bytes
	call	enableSD
	ld	a, (WRKAREA.NUMBLOCKS)	; testar se Nextor quer ler um ou mais blocos
	dec	a
	jp	z, .umBloco	; somente um bloco, pular

; multiplos blocos
	ld	a, CMD18	; ler multiplos blocos com CMD18 = Read Multiple Blocks
	call	SD_SEND_CMD_GET_ERROR
	jr	c, .erro
.loop:
	call	WAIT_RESP_FE
	jr	c, .erro
	ld	bc, PORTSPI
	inir
	inir
	nop
	in	a, (PORTSPI)	; descarta CRC
	nop
	in	a, (PORTSPI)
	ld	a, (WRKAREA.NUMBLOCKS)	; testar se tem mais blocos para ler
	dec	a
	ld	(WRKAREA.NUMBLOCKS), a
	jp	nz, .loop
	ld	a, CMD12	; acabou os blocos, mandar CMD12 para cancelar leitura
	call	SD_SEND_CMD_NO_ARGS
	jr	.fim

.umBloco:
	ld	a, CMD17	; ler somente um bloco com CMD17 = Read Single Block
	call	SD_SEND_CMD_GET_ERROR
	jr	nc, .ok
.erro:
	scf
	jp	terminaLeituraEscritaBloco
.ok:
	call	WAIT_RESP_FE
	jr	c, .erro
	ld	bc, PORTSPI
	inir
	inir
	nop
	in	a, (PORTSPI)	; descarta CRC
	nop
	in	a, (PORTSPI)
.fim:
	xor	a		; zera carry para informar leitura sem erros
	jp	terminaLeituraEscritaBloco

; ------------------------------------------------
; Converte blocos para bytes. Na pratica faz
; BC DE = (BC DE) * 512
; ------------------------------------------------
blocoParaByte:
	ld	b, c
	ld	c, d
	ld	d, e
	ld	e, 0
	sla	d
	rl	c
	rl	b
	ret

; ------------------------------------------------
; Funcoes utilitarias
; ------------------------------------------------

; ------------------------------------------------
; Imprime string na tela apontada por DE
; Destroi todos os registradores
; ------------------------------------------------
printString:
	ld	a, (de)
	or	a
	ret	z
	call	BIOS_CHPUT
	inc	de
	jr	printString


; ------------------------------------------------
; Converte o byte em A para string em decimal no
; buffer apontado por DE
; Destroi AF, BC, HL, DE
; ------------------------------------------------
DecToAscii:
	ld	iy, WRKAREA.TEMP
	ld	h, 0
	ld	l, a		; copiar A para HL
	ld	(iy+0), 1	; flag para indicar que devemos cortar os zeros a esquerda
	ld	bc, -100	; centenas
	call	.num1
	ld	c, -10		; dezenas
	call	.num1
	ld	(iy+0), 2	; unidade deve exibir 0 se for zero e nao corta-lo
	ld	c, -1		; unidades
.num1:
	ld	a, '0'-1
.num2:
	inc	a		; contar o valor em ascii de '0' a '9'
	add	hl, bc		; somar com negativo
	jr	c, .num2	; ainda nao zeramos
	sbc	hl, bc		; retoma valor original
	dec	(iy+0)		; se flag do corte do zero indicar para nao cortar, pula
	jr	nz, .naozero
	cp	'0'		; devemos cortar os zeros a esquerda. Eh zero?
	jr	nz, .naozero
	inc	(iy+0)		; se for zero, nao salvamos e voltamos a flag
	ret
.naozero:
	ld	(de), a		; eh zero ou eh outro numero, salvar
	inc	de		; incrementa ponteiro de destino
	ret

; ------------------------------------------------
; Converte o byte em A para string em hexa no
; buffer apontado por DE
; Destroi AF, C, DE
; ------------------------------------------------
HexToAscii:
	ld	c, a
	rra
	rra
	rra
	rra
	call	.conv
	ld  	a, c
.conv:
	and	$0F
	add	a, $90
	daa
	adc	a, $40
	daa
	ld	(de), a
	inc	de
	ret

; ------------------------------------------------
; Converte o byte em A para string em decimal e
; imprime na tela
; Destroi AF, BC, HL, DE
; ------------------------------------------------
printDecToAscii:
	ld	h, 0
	ld	l, a		; copiar A para HL
	ld	b, 1		; flag para indicar que devemos cortar os zeros a esquerda
	ld	de, -100	; centenas
	call	.num1
	ld	e, -10		; dezenas
	call	.num1
	ld	b, 2		; unidade deve exibir 0 se for zero e nao corta-lo
	ld	e, -1		; unidades
.num1:
	ld	a, '0'-1
.num2:
	inc	a		; contar o valor em ascii de '0' a '9'
	add	hl, de		; somar com negativo
	jr	c, .num2	; ainda nao zeramos
	sbc	hl, de		; retoma valor original
	djnz	.naozero	; se flag do corte do zero indicar para nao cortar, pula
	cp	'0'		; devemos cortar os zeros a esquerda. Eh zero?
	jr	nz, .naozero
	inc	b		; se for zero, nao imprimimos e voltamos a flag
	ret
.naozero:
	push	hl		; nao eh zero ou eh outro numero, imprimir
	push	bc
	call	BIOS_CHPUT
	pop	bc
	pop	hl
	ret

; ------------------------------------------------
; Procura pelo nome do fabricante em uma tabela.
; A contem o byte do fabricante
; Devolve HL apontando para o buffer do fabricante
; e BC com o comprimento do texto
; Destroi AF, BC, HL
; ------------------------------------------------
pegaFabricante:
	ld	c, a
	ld	hl, tblFabricantes

.loop:
	ld	a, (hl)
	inc	hl
	cp	c
	jr	z, .achado
	or	a
	jr	z, .achado
	push	bc
	call	.achado
	add	hl, bc
	inc	hl
	pop	bc
	jr	.loop

.achado:
	ld	c, 0
	push	hl
	xor	a
.loop2:
	inc	c
	inc	hl
	cp	(hl)
	jr	nz, .loop2
	pop	hl
	ld	b, 0
	ret

; ---------------------------------------------------------------------------
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
	db  62
	db "RetroWiki VHD MiSTer",0
	db	65
	db	"OKI",0
	db	115
	db	"SilverHT",0
	db  116
	db  "RetroWiki VHD MiST",0
	db	137
	db	"L.Data",0
	db	0
	db	"Generico",0

; ------------------------------------------------
strTitulo:
	db	"MSX1 FPGA",13,10
	db	"SD Nextor Driver",13,10
	db	"Version "
	db	VER_MAIN + $30, '.', VER_SEC + $30, '.', VER_REV + $30
	db	13, 10
	db	"Copyright (c) 2016",13,10
	db	"Fabio Belavenuto",13,10
;	db	"Licenced under",13,10
;	db	"CERN OHL v1.1",13,10
;	db	"http://ohwr.org/cernohl",13,10
	; fall throw
strCrLf:
	db	13,10,0
strCartao:
	db	"Card: ",0
strVazio:
	db	"No card!",13,10,0
strNaoIdentificado:
	db	"No identification!",13,10,0
strSDV1:
	db	"SDV1 - ",0
strSDV2:
	db	"SDV2 - ",0

; RAM area
	org		$7000


;-----------------------------------------------------------------------------
;
; End of the driver code
; Work area variables
WRKAREA:
WRKAREA.BCSD 		ds 16	; Card Specific Data
WRKAREA.BCID1		ds 16	; Card-ID of card1
WRKAREA.NUMSD		ds 1	; Currently selected card: 1 or 2
WRKAREA.NUMBLOCKS	ds 1	; Number of blocks in multi-block operations
WRKAREA.BLOCKS1	    ds 3	; 3 bytes. Size of card1, in blocks.
WRKAREA.BLOCKS2	    ds 3	; 3 bytes. Size of card2, in blocks.
WRKAREA.TEMP		ds 1	; Temporary data

 IF HWDS = 0
FLAGS		ds 1	; Flags for soft-diskchange
 ENDIF
; ENDS



DRV_END:

	ds	3ED0h-(DRV_END-DRV_START)
	end

