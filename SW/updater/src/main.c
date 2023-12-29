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

#include "spi.h"
#include "conio.h"
#include "msxdos.h"
#include "hardware.h"

/* Constants */

const char ce[5] = "\\|/-";

/* Global vars */
unsigned char buffer[1024], c;
unsigned int  i, l;
unsigned long	fsize, dsize;

/******************************************************************************/
int main(char** argv, int argc)
{
	int fhandle, r;

	if (argc != 1) {
		puts("Parameters error!\r\nUse: msx1upd file.pld\r\n");
		return 1;
	}

	// Try open file
	fhandle = open(argv[0], O_RDONLY);
	if (fhandle == -1) {
		puts("Error opening file!\r\n");
		return 2;
	}

	puts("Testing file: ");
	c = 0;
	// Test file
	for (i = 0; i < 336; i++) {
		putchar(ce[c]);
		putchar(8);
		c = (c + 1) & 0x03;
		r = read(fhandle, buffer, 1024);
		if (r == -1) {
			if (last_error == EEOF) {
				puts("End of file! File size must be 344064 bytes.\r\n");
				goto exit;
			} else {
				puts("Reading error: ");
				puthex8(last_error);
				puts("!\r\n");
				goto exit;
			}
		}
	}
	puts("OK\r\n");

	if (-1 == lseek(fhandle, 0, SEEK_SET)) {
		puts("Error in lseek!\r\n");
		goto exit;
	}

	// Read flash ID
	// W25Q32BV = 0x15
	buffer[0] = cmd_read_id;
	c = SPI_send4bytes_recv(buffer);
	if (c != 0x15) {
		puts("Flash not detected, ID received: ");
		puthex8(c);
		puts("!\r\n");
		goto exit;
	}

	puts("Erasing flash: ");
	SPI_sendcmd(cmd_write_enable);
	SPI_sendcmd(cmd_erase_bulk);
	c = 0;
	while ((SPI_sendcmd_recv(cmd_read_status) & 0x01) == 1) {
		putchar(ce[c]);
		putchar(8);
		c = (c + 1) & 0x03;
		for (i = 0; i < 4000; i++) ;
	}
	puts("OK\r\n");

	puts("Writing: ");
	dsize = 0; // Flash address
	c = 0;
	for (i = 0; i < (344064 / 256); i++) {
		buffer[0] = cmd_write_bytes;
		buffer[1] = (dsize >> 16) & 0xFF;
		buffer[2] = (dsize >> 8) & 0xFF;
		buffer[3] = dsize & 0xFF;
		r = read(fhandle, buffer+4, 256);
		if (r == -1) {
			puts("Reading error: ");
			puthex8(last_error);
			puts("!\r\n");
			goto exit;
		}
		SPI_sendcmd(cmd_write_enable);
		SPI_writebytes(buffer);
		putchar(ce[c]);
		putchar(8);
		c = (c + 1) & 0x03;
		while ((SPI_sendcmd_recv(cmd_read_status) & 0x01) == 1) ;
		dsize += 256;
//		putchar('.');
	}
	puts("OK\r\n");
	SPI_sendcmd(cmd_write_disable);

	puts("Flash updated, turn power off and on.\r\n");
	SWIOP_MKID = mymkid;
	SWIOP_REGNUM = REG_RESET;
	SWIOP_REGVAL = RES_RELOAD;


exit:
	close(fhandle);

	return 0;
}
