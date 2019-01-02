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
	ld	a, #28
	out	(#40), a
	ld	a, #12		; Turbo register
	out	(#48), a
	ld	a, 1		; Turn on turbo
	out	(#49), a
	ld	c, #49		; Port #49
	ld	a, #0B		; PS/2 FIFO status
	out	(#48), a
	in	a, (c)		; Read status
	ld	a, #0C		; PS/2 FIFO data
	out	(#48), a
	in	a, (c)		; Read data
	
	xor	a
	out	(#99), a
	ld	a, #40
	out	(#99), a
	nop
	xor	a
loop:
	out	(#98), a
	inc	a
	jr	loop
