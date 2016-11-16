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

	org		0
	
	di
	ld		a, $28
	out		($40), a
	ld		a, $0D
	out		($48), a
	ld		a, 0
	out		($49), a
	ld		a, $0E
	out		($48), a
	ld		a, 0
	out		($49), a
	ld		a, $0F
	out		($48), a
	ld		a, 1
loop:
	out		($49), a
	inc		a
	jr		loop
