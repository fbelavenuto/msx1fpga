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

#ifndef _HARDWARE
#define _HARDWARE

// Switched I/O ports
__sfr __at 0x40 SWIOP_MKID;
__sfr __at 0x48 SWIOP_REGNUM;
__sfr __at 0x49 SWIOP_REGVAL;

// My Maker ID
static const unsigned char mymkid = 40;

// Register numbers
#define REG_HWID		0x00
#define REG_HWTXT		0x01
#define REG_HWVER		0x02
#define REG_HWMEMCFG	0x03
#define REG_HWFLAGS		0x04
#define REG_RESET		0x0A
#define REG_FIFOSTAT	0x0B
#define REG_FIFODATA	0x0C
#define REG_KMLOWADDR	0x0D
#define REG_KMHIGHADDR	0x0E
#define REG_KMBYTE		0x0F
#define REG_OPTIONS		0x10
#define REG_MAPPER		0x11
#define REG_TURBO		0x12
#define REG_VOLBEEP		0x20
#define REG_VOLEAR		0x21
#define REG_VOLPSG		0x22
#define REG_VOLSCC		0x23
#define REG_VOLOPLL		0x24
#define REG_VOLAUX1		0x25

// Reg Reset
#define RES_RELOAD		0x80
#define RES_SOFTRES		0x01

// PS/2 FIFO status
#define FIFO_FULL		0x01
#define FIFO_EMPTY		0x02

// Reg config
#define CFG_NEXTOR		0x01
#define CFG_SCANDBL		0x02
#define CFG_SCANLINES	0x04
#define CFG_NTSC_PAL	0x08

// Reg turbo
#define TURBO_ON		0x01

// SPI
__sfr __at 0x9E SPI_CTRL;
__sfr __at 0x9F SPI_DATA;


#endif
