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

//                              12345678...
static const char * msxdir   = "MSX1FPGA   ";
static const char * cfgfile  = "CONFIG  TXT";
static const char * nxtfile  = "NEXTOR  ROM";
static const char * nxtfileh = "NEXTORH ROM";
static const char * romsfile = "MSXROMS ROM";

static char *km_files[5] = {
//   12345678...
	"EN      KMP",
	"PTBR    KMP",
	"FR      KMP",
	"SPA     KMP",
	"JP      KMP",
};

//                             11111111112222222222333
//                    12345678901234567890123456789012
const char TITLE[] = "        MSX1FPGA LOADER         ";

unsigned int  romKeymapOffset = 0x0DA5;
unsigned int  *prampage = (unsigned int *)0x3FFE;
unsigned char *pramrom;
unsigned char i;
unsigned int  page;
file_t        file;


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
void zeroram(unsigned int ps, unsigned int pe)
{
	for (page = ps; page < pe; page++) {
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
}

/*******************************************************************************/
void loadrom(unsigned int ps, unsigned int pe)
{
	for (page = ps; page < pe; page++) {
		*prampage = page;
		pramrom  = (unsigned char *)0x8000;
		for (i = 0; i < 32; i++) {
			if (!fat_bread(&file, pramrom)) {
				//              11111111112222222222333
				//     12345678901234567890123456789012
				error("Error reading file!");
			}
			pramrom += 512;
		}
		vdp_putchar('.');
	}
}

/*******************************************************************************/
void main()
{
	unsigned char hwid, hwversion, hwtxt[20], hwmemcfg, hwds;
	unsigned int pn_ram_start = 0, pn_ram_end = 0, pn_ram_ipl = 0;
	unsigned int pn_mr2_start = 0, pn_mr2_end = 0;
	unsigned int pn_rom = 0, pn_nextor = 0, pn_romsize = 2;
	unsigned char buffer[512];
	unsigned char *ppl       = (unsigned char *)0xFF00;
//	unsigned char c;
	unsigned int  k;
	unsigned char cfgnxt, cfgvga, cfgkm, cfgcor, cfgturbo, cfgsln;
	char *kmpfile = NULL, *nxtfn = NULL;

	// Init SWIO
	SWIOP_MKID = mymkid;
	SWIOP_REGNUM = REG_TURBO;
	SWIOP_REGVAL = TURBO_ON;			// Turbo ON

	vdp_init();
	vdp_setcolor(COLOR_BLUE, COLOR_BLACK, COLOR_WHITE);
	vdp_putstring(TITLE);

	// Read Hardware ID
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
	SWIOP_REGNUM = REG_HWMEMCFG;
	hwmemcfg = SWIOP_REGVAL;
	SWIOP_REGNUM = REG_HWFLAGS;
	hwds = SWIOP_REGVAL & 0x01;

	vdp_gotoxy(0, 3);
	vdp_putstring("HW ID = ");
	putdec8(hwid);
	vdp_putstring(" - ");
	vdp_putstring(hwtxt);
	vdp_putstring("\n\nVersion ");
	putdec8(hwversion >> 4);
	vdp_putchar('.');
	putdec8(hwversion & 0x0F);
	vdp_putstring("\n\n");

	if (!MMC_IsPresent()) {
		//              11111111112222222222333
		//     12345678901234567890123456789012
		error("No SD card in the slot!");
	}

	vdp_putstring("Initializing SD Card: ");

	if (!MMC_Init()) {
		//              11111111112222222222333
		//     12345678901234567890123456789012
		error("Error on SD card initialization!");
	}
	if (!fat_init()) {
		//              11111111112222222222333
		//     12345678901234567890123456789012
		error("FAT FS not found!");
	}
	vdp_putstring("OK\n\nLoading config file: ");
	if (!fat_chdir(msxdir)) {
		//              11111111112222222222333
		//     12345678901234567890123456789012
		error("'MSX1FPGA' directory not found!");
	}
	if (!fat_fopen(&file, cfgfile)) {
		//              11111111112222222222333
		//     12345678901234567890123456789012
		error("Config file not found!");
	}
/*
	if (file.size < 6) {
		//              11111111112222222222333
		//     12345678901234567890123456789012
		error("Config file error!");
	}
*/
	if (!fat_bread(&file, buffer)) {
		//              11111111112222222222333
		//     12345678901234567890123456789012
		error("Error reading Config file!");
	}
	cfgnxt = (buffer[0] == '1') ? CFG_NEXTOR		: 0;	// Options
	cfgvga = (buffer[1] == '1') ? CFG_SCANDBL		: 0;	// Options
	cfgkm  = buffer[2];
	if (cfgkm != 'E' && cfgkm != 'B' && cfgkm != 'F' && cfgkm != 'S' && cfgkm != 'J') {
		//              11111111112222222222333
		//     12345678901234567890123456789012
		error("Invalid keymap!");
	}
	cfgcor   = (buffer[3] == 'P') ? CFG_NTSC_PAL 	: 0;	// Options
	cfgturbo = (buffer[4] == '1') ? TURBO_ON		: 0;
	cfgsln   = (buffer[5] == '1') ? CFG_SCANLINES	: 0;	// Options

	SWIOP_REGNUM = REG_OPTIONS;
	SWIOP_REGVAL = cfgcor | cfgsln | cfgvga | cfgnxt;
	//putdec8(cfgcor | cfgsln | cfgvga | cfgnxt);

	// IPL pages config
	if ((hwmemcfg & 0x07) == 0) {			// 512K
		pn_ram_start = 8;
		pn_ram_end   = 14;
		pn_ram_ipl   = 15;
		pn_rom       = 30;
		pn_romsize   = 2;
//		pn_nextor    = 0;
		pn_mr2_start = 16;
		pn_mr2_end   = 28;
	} else if ((hwmemcfg & 0x07) == 2) {	// 2MB
		pn_ram_start = 64;
		pn_ram_end   = 96;
		pn_ram_ipl   = 127;
//		pn_rom       = 0;
		pn_romsize   = 4;
		pn_nextor    = 8;
		pn_mr2_start = 32;
		pn_mr2_end   = 64;
	} else if ((hwmemcfg & 0x07) == 4) {	// 8MB
		pn_ram_start = 256;
		pn_ram_end   = 287;
		pn_ram_ipl   = 511;
//		pn_rom       = 0;
		pn_romsize   = 4;
		pn_nextor    = 8;
		pn_mr2_start = 64;
		pn_mr2_end   = 96;
	} else {
		//              11111111112222222222333
		//     12345678901234567890123456789012
		error("Memory size error!");
	}

	vdp_putstring("OK\n\nZeroing RAM: ");

	if (cfgnxt != CFG_NEXTOR) {
		zeroram(pn_nextor, pn_nextor+8);
	}
	zeroram(pn_ram_start, pn_ram_end);
	zeroram(pn_mr2_start, pn_mr2_end);
	vdp_putstring(" OK\n");

	if ((hwmemcfg & 0x80) == 0x80) {
		vdp_putstring("\nLoading MSXROMS.ROM: ");
		if (!fat_fopen(&file, romsfile)) {
			//              11111111112222222222333
			//     12345678901234567890123456789012
			error("MSXROMS file not found!");
		}

		if (file.size != 65536L) {
			//              11111111112222222222333
			//     12345678901234567890123456789012
			error("MSXROMS file size wrong!");
		}

		loadrom(pn_rom, pn_rom+pn_romsize);
		vdp_putstring(" OK\n");
	}

	if (cfgnxt == CFG_NEXTOR) {
		if (hwds == 0) {
			nxtfn = (char *)nxtfile;
		} else {
			nxtfn = (char *)nxtfileh;
		}
		vdp_putstring("\nLoading NEXTOR: ");
		if (!fat_fopen(&file, nxtfn)) {
			//              11111111112222222222333
			//     12345678901234567890123456789012
			error("NEXTOR file not found!");
		}
		if (file.size != 131072) {
			//              11111111112222222222333
			//     12345678901234567890123456789012
			error("NEXTOR file size must be 131072!");
		}
		loadrom(pn_nextor, pn_nextor+8);
		vdp_putstring(" OK\n");
	}

	switch(cfgkm) {
		case 'E':
			kmpfile = (char *)km_files[0];
			break;
		case 'B':
			kmpfile = (char *)km_files[1];
			break;
		case 'F':
			kmpfile = (char *)km_files[2];
			break;
		case 'S':
			kmpfile = (char *)km_files[3];
			break;
		case 'J':
			kmpfile = (char *)km_files[4];
			break;
	};
	vdp_putstring("\nLoading Keymap ");
	if (!fat_fopen(&file, kmpfile)) {
		//              11111111112222222222333
		//     12345678901234567890123456789012
		error("Keymap file not found!");
	}
	if (file.size != 932) {
		//              11111111112222222222333
		//     12345678901234567890123456789012
		error("Keymap file size must be 932B!");
	}
	SWIOP_REGNUM = REG_KMLOWADDR;
	SWIOP_REGVAL = 0;
	SWIOP_REGNUM = REG_KMHIGHADDR;
	SWIOP_REGVAL = 0;
	SWIOP_REGNUM = REG_KMBYTE;
	if (!fat_bread(&file, buffer)) {
		//              11111111112222222222333
		//     12345678901234567890123456789012
		error("Error reading Keymap file!");
	}
	for (k = 0; k < 512; k++) {
		SWIOP_REGVAL = buffer[k];
	}
	vdp_putchar('.');
	if (!fat_bread(&file, buffer)) {
		//              11111111112222222222333
		//     12345678901234567890123456789012
		error("Error reading Keymap file!");
	}
	vdp_putchar('.');
	*prampage = pn_rom;
	pramrom  = (unsigned char *)(0x8000 + romKeymapOffset);
	for (k = 0; k < 420; k++) {
		*pramrom++ = buffer[k];
	}
	vdp_putstring(" OK\n");
	SPI_CTRL = 0xFF;

	vdp_setcolor(COLOR_GREEN, COLOR_BLACK, COLOR_WHITE);
	vdp_putstring("\nBooting...");

	*prampage = pn_ram_ipl;

	SWIOP_REGNUM = REG_TURBO;
	SWIOP_REGVAL = cfgturbo;

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
