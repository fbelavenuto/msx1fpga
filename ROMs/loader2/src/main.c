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

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "hardware.h"
#include "vdp.h"
#include "mmc.h"
#include "fat.h"


static const char * nxtfile  = "NEXTOR  ROM";
static const char * biosfile = "MSX1BIOSROM";

//                             11111111112222222222333
//                    12345678901234567890123456789012
const char TITLE[] = "        MSX1 FPGA LOADER        ";

/*******************************************************************************/
void printCenter(unsigned char y, unsigned char *msg)
{
	unsigned char x;

	x = 16 - strlen(msg)/2;
	vdp_gotoxy(x, y);
	vdp_putstring(msg);
}

/*******************************************************************************/
void error(unsigned char *error)
{
	DisableCard();
	vdp_setcolor(COLOR_RED, COLOR_BLACK, COLOR_WHITE);
	printCenter(12, error);
	for(;;);
}

/*******************************************************************************/
void main()
{
	unsigned char hwid, hwversion, hwtxt[20];
	unsigned char *prampage = (unsigned char *)0x3FFF;
	unsigned char *pramrom  = (unsigned char *)0x8000;
	unsigned char *ppl      = (unsigned char *)0xFF00;
	unsigned char c, i, page;
	file_t        file;

	vdp_init();
	vdp_setcolor(COLOR_BLUE, COLOR_BLACK, COLOR_WHITE);
	vdp_putstring(TITLE);

	// Read Hardware ID
	SWIOP_MKID = mymkid;
	if (SWIOP_MKID != (mymkid ^ 255)) {
		//              11111111112222222222333
		//     12345678901234567890123456789012
		error("Error setting MakerID!");
	}
	SWIOP_REGNUM = REG_TURBO;
	SWIOP_REGVAL = 1;
	SWIOP_REGNUM = REG_HWID;
	hwid = SWIOP_REGVAL;
	SWIOP_REGNUM = REG_HWTXT;
	for (i = 0; i < 20; i++) {
		hwtxt[i] = SWIOP_REGVAL;
		if (hwtxt[i] == 0) {
			break;
		}
	}
	SWIOP_REGNUM = REG_HWVER;
	hwversion = SWIOP_REGVAL;

	vdp_gotoxy(0, 3);
	vdp_putstring("HW ID = ");
	c = '0' + hwid;
	vdp_putchar(c);
	vdp_putstring(" - ");
	vdp_putstring(hwtxt);
	vdp_putstring("\n\nVersion ");
	c = '0' + (hwversion >> 4);
	vdp_putchar(c);
	vdp_putchar('.');
	c = '0' + (hwversion & 0x0F);
	vdp_putchar(c);
	vdp_putstring("\n\n");

	vdp_putstring("Initializing SD Card: ");

	if (!MMC_Init()) {
		vdp_putstring("Error");
		//              11111111112222222222333
		//     12345678901234567890123456789012
		error("Error on SD card initialization!");
	}
	if (!fat_init()) {
		vdp_putstring("Error");
		//              11111111112222222222333
		//     12345678901234567890123456789012
		error("FAT FS not found!");
	}
	vdp_putstring("OK\n\nZeroing RAM: ");

	for (page = 0; page < 32; page++) {
		if (page == 15) {
			continue;
		}
		*prampage = page;
		__asm__("push hl");
		__asm__("push de");
		__asm__("push bc");
		__asm__("ld hl, #0x8000");
		__asm__("ld de, #0x8001");
		__asm__("ld bc, #0x3FFF");
		__asm__("ld a, #0");
		__asm__("ld (hl), a");
		__asm__("ldir");
		__asm__("pop bc");
		__asm__("pop de");
		__asm__("pop hl");
	}

	vdp_putstring(" OK\n");

	if (hwid == 5 || hwid == 6) {
		vdp_putstring("\nLoading MSX1BIOS.ROM ");
		if (!fat_fopen(&file, biosfile)) {
			//              11111111112222222222333
			//     12345678901234567890123456789012
			error("MSX1BIOS file not found!");
		}
		if (file.size != 32768) {
			//              11111111112222222222333
			//     12345678901234567890123456789012
			error("MSXBIOS file size must be 32768!");
		}
		for (page = 30; page < 32; page++) {
			*prampage = page;
			pramrom  = (unsigned char *)0x8000;
			for (i = 0; i < 32; i++) {
				if (!fat_bread(&file, pramrom)) {
					//              11111111112222222222333
					//     12345678901234567890123456789012
					error("Error reading NEXTOR file!");
				}
				pramrom += 512;
			}
			vdp_putchar('.');
		}
		vdp_putstring(" OK\n");
	}

	vdp_putstring("\nLoading NEXTOR.ROM ");
	if (!fat_fopen(&file, nxtfile)) {
		//              11111111112222222222333
		//     12345678901234567890123456789012
		error("NEXTOR file not found!");
	}
	if (file.size != 131072) {
		//              11111111112222222222333
		//     12345678901234567890123456789012
		error("NEXTOR file size must be 131072!");
	}
	for (page = 0; page < 8; page++) {
		*prampage = page;
		pramrom  = (unsigned char *)0x8000;
		for (i = 0; i < 32; i++) {
			if (!fat_bread(&file, pramrom)) {
				//              11111111112222222222333
				//     12345678901234567890123456789012
				error("Error reading NEXTOR file!");
			}
			pramrom += 512;
		}
		vdp_putchar('.');
	}
	vdp_putstring(" OK\n");
	vdp_setcolor(COLOR_GREEN, COLOR_BLACK, COLOR_WHITE);
	vdp_putstring("\nBooting...");
	SWIOP_REGNUM = REG_TURBO;
	SWIOP_REGVAL = 0;
	*prampage = 15;	// Main RAM
	// start ROM
	*ppl++=0x3E;		// LD A, $F0
	*ppl++=0xF0;
	*ppl++=0xD3;		// OUT ($A8), A
	*ppl++=0xA8;
	*ppl++=0xC3;		// JP $0000
	*ppl++=0x00;
	*ppl++=0x00;
	__asm__("jp 0xFF00");
}
