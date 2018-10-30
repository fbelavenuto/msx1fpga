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

Using Avelino Herreras Morales C library
http://msx.atlantes.org/index_en.html#sdccmsxdos

*/

#include "hardware.h"
#include "conio.h"
#include "dos2.h"

/* Constants */
const char CONFFILE[] = "MSX1FPGA.REG";
const unsigned char REGS[] = {REG_VOLBEEP, REG_VOLEAR, REG_VOLPSG,
							REG_VOLSCC, REG_VOLOPLL, REG_VOLAUX1};

/* Structures */
struct tRegValPair {
	unsigned char reg;
	unsigned char value;
};

/* Global vars */
unsigned char hwid, hwversion, hwtxt[20], hwmemcfg, hwds;
unsigned char c;
unsigned int  i;
int fhandle;
struct tRegValPair rvp;

/******************************************************************************/
void use()
{
	puts("MSXCTRL.COM - Utility to manipulate MSX1FPGA core.\r\n");
	puts("Use:\r\n");
	puts("\r\n");
	puts("MSXCTRL <options>\r\n");
	
	return 1;

}

/******************************************************************************/
int main(char** argv, int argc)
{

	// Init SWIO
	SWIOP_MKID = mymkid;
	if ((unsigned char)SWIOP_MKID != (unsigned char)~mymkid) {
		puts("MSX1FPGA core needed!\r\n");
		return 1;
	}
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
	puts("HW ID = ");
	puthex8(hwid);
	puts(" - ");
	puts(hwtxt);
	puts("\r\nVersion ");
	putdec8(hwversion >> 4);
	putchar('.');
	putdec8(hwversion & 0x0F);
	puts("\r\nMem config = ");
	puthex8(hwmemcfg);
	puts("\r\nHas HWDS = ");
	puthex8(hwds);
	puts("\r\n\r\n");

	if (argc != 1) {
		use();
	}
	c = argv[0][0] | 0x20;
	if (c != 'r' && c != 'w') {
		use();
	}
	if (c == 'r') {
		// Try open file
		fhandle = open(CONFFILE, O_RDONLY);
		if (fhandle == -1) {
			puts("Error opening file '");
			puts(CONFFILE);
			puts("'.\r\n");
			return 2;
		}
		close(fhandle);
		puts("Not implemented yet!\r\n");
		return 3;
/*
		r = read(fhandle, &reg, 1);
		if (r == -1) {
			if (last_error == EEOF) {
				puts("End of file!\r\n");
				goto exit;
			} else {
				puts("Reading error: ");
				puthex8(last_error);
				puts("!\r\n");
				goto exit;
			}
		}
		goto exit;
*/
	}
	// write
	// Try open file
	fhandle = creat(CONFFILE, O_WRONLY, ATTR_NONE);
	if (fhandle == -1) {
		puts("Error opening file '");
		puts(CONFFILE);
		puts("'.\r\n");
		return 2;
	}
	for (i = 0; i < sizeof(REGS); i++) {
		rvp.reg = REGS[i];
		SWIOP_REGNUM = rvp.reg;
		rvp.value = SWIOP_REGVAL;
		if (-1 == write(fhandle, &rvp, sizeof(rvp))) {
			puts("Error writing file.\r\n");
			close(fhandle);
			return 4;
		}
	}
	puts("Regs write sucessful!\r\n");

exit:
	close(fhandle);

	return 0;
}
