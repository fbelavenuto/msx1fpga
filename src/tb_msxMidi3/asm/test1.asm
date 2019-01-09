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

	output	"test1.bin"

	org	0

	di
	jr	init

	ds	#38-$, 0

	nop
	in	a, (#E9)
	and	#80		; Read DSR pin
	jr	nz, jmp1
	reti
jmp1:
	xor	a
	out	(#EA), a	; reset timer interrupt
	reti

	ds	#80-$, 0
init:
	im	1
	xor	a
	out	(#EA), a
	ld	a, #16
	out	(#EF), a		; counter 0, LSB, mode 3, binary
	ld	a, 8
	out	(#EC), a		; initialize counter 0 on 500 KHz (4MHz / 8 = 500KHz)
	ld	a, #B4
	out	(#EF), a		; counter 2, WORD, mode 2, binary
	ld	hl, 20000
	ld	a, l
	out	(#EE), a
	ld	a, h
	out	(#EE), a		; initialize counter 2 (4MHz / 20000 = 200Hz) (MIDI timer interrupts every 5 ms)
	xor	a
	out	(#E9), a		; 8251 RESET SEQUENCE = 0,0,0,#40
	nop
	nop
	out	(#E9), a
	nop
	out	(#E9), a
	nop
	ld	a, #40
	out	(#E9), a		; initialize 8251
	nop
	ld	a, #4E
	out	(#E9), a		; 1 stopbit, no	parity,	8 bit, 16x
	nop
	ld	a, #03
	out	(#E9), a		; no reset, MIDI IN interrupt off, MIDI in off, MIDI timer interrupt on, MIDI out on
	nop
	nop
loop1:
	in	a, (#E9)
	and	1		; transmitter ready ?
	jr	z, loop1	; nope,	wait
	ld	a, #AA
	out	(#E8), a
	ei
sf:
	jr	sf
