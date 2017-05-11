/*

MSX1 FPGA project

Copyright (c) 2016 Fabio Belavenuto

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.

*/

#ifndef _VDP_H
#define _VDP_H

#define uint8 unsigned char
#define uint16 unsigned int
#define int8 char
#define int16 int

#define peek(A) (*(volatile unsigned int*)(A))
#define poke(A,V) *(volatile unsigned int*)(A)=(V)

enum {
	COLOR_TRANSP = 0,
	COLOR_BLACK,
	COLOR_MGREEN,
	COLOR_LGREEN,
	COLOR_BLUE,
	COLOR_LBLUE,
	COLOR_RED,
	COLOR_CYAN,
	COLOR_MRED,
	COLOR_LRED,
	COLOR_YELLOW,
	COLOR_LYELLOW,
	COLOR_GREEN,
	COLOR_MAGENTA,
	COLOR_GRAY,
	COLOR_WHITE	
};

void vdp_writereg(uint8 reg, uint8 val);
void vdp_setaddr(uint16 addr, uint8 rw);
void vdp_writedata(uint8 *source, uint16 addr, uint16 count);
void vdp_init();
void vdp_setcolor(uint8 border, uint8 background, uint8 foreground);
void vdp_cls();
void vdp_gotoxy(uint8 x, uint8 y);
void vdp_putcharxy(uint8 x, uint8 y, uint8 c);
void vdp_putchar(uint8 c);
void vdp_putcharcolor(uint8 c, uint8 color);
void vdp_putstring(char *s);
void puthex8(uint8 v);
void puthex16(uint16 v);
void putdec8(uint8 v);
void putdec16(uint8 v);

#endif	/* _VDP_H */