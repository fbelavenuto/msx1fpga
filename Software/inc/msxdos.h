/*
Copyright (c) 2017 FBLabs

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

#ifndef  __MSXDOS_H__
#define  __MSXDOS_H__


/* Structures */
typedef struct {
	unsigned char slotNum;				// Driver slot number
	unsigned char segNum;				// Driver segment number, FFh if the driver is embedded within a Nextor or MSX-DOS kernel ROM
	unsigned char numDriveLetter;		// Number of drive letters assigned to this driver at boot time
	unsigned char firstDriveLetter;		// First drive letter assigned to this driver at boot time (A:=0, etc), unused if no drives are assigned at boot time
	unsigned char flags;				// Driver flags:
										// bit 7: 1 => the driver is a Nextor driver, 0 => the driver is a MSX-DOS driver (embedded within a MSX-DOS kernel ROM)
										// bits 6-1: Unused, always zero
										// bit 0: 1 => the driver is a device-based driver, 0 => the driver is a drive-based driver
	unsigned char mainVersion;			// Driver main version number
	unsigned char secVersion;			// Driver secondary version number
	unsigned char revVersion;			// Driver revision number
	unsigned char name[32];				// Driver name, left justified, padded with spaces (32 bytes)
	unsigned char reserved[14];			// Reserved (currently always zero)
} TDevInfo;

/* standard descriptors */
#define  STDIN   0
#define  STDOUT  1
#define  STDERR  2
#define  AUX     3
#define  PRN     4

/* open/creat flags */
#define  O_RDONLY   0x01
#define  O_WRONLY   0x02
#define  O_RDWR     0x00
#define  O_INHERIT  0x04

/* creat attributes */
#define  ATTR_NONE    0x00
#define  ATTR_RDONLY  0x01
#define  ATTR_HIDDEN  0x02
#define  ATTR_SYSTEM  0x04
#define  ATTR_VOLUME  0x08
#define  ATTR_FOLDER  0x10
#define  ATTR_ARCHIV  0x20
#define  ATTR_DEVICE  0x80

/* seek whence */
#define  SEEK_SET  0
#define  SEEK_CUR  1
#define  SEEK_END  2

/* Errors */
#define EINTER	0xDF		// Internal Error
#define ENORAM	0xDE		// Not enough memory
#define EIBDOS	0xDC		// Invalid MSX-DOS call
#define EIDRV	0xDB		// Invalid drive
#define EIFNM	0xDA		// Invalid filename
#define EIPATH	0xD9		// Invalid pathname
#define EPLONG	0xD8		// Pathname too long
#define ENOFIL	0xD7		// File not found
#define ENODIR	0xD6		// Directory not found
#define EDRFUL	0xD5		// Root directory full
#define EDKFUL	0xD4		// Disk full
#define EDUPF	0xD3		// Duplicate filename
#define EDIRE	0xD2		// Invalid directory move
#define EFILRO	0xD1		// Read only file
#define EDIRNE	0xD0		// Directory not empty
#define EIATTR	0xCF		// Invalid attributes
#define EDOT	0xCE		// Invalid . or .. operation
#define ESYSX	0xCD		// System file exists
#define EFILEX	0xCB		// File exists
#define EFOPEN	0xCA		// File already in use
#define EOV64K	0xC9		// Cannot transfer above 64K
#define EFILE	0xC8		// File allocation error
#define EEOF	0xC7		// End of file
#define EACCV	0xC6		// File access violation
#define EIPROC	0xC5		// Invalid process id
#define ENHAND	0xC4		// No spare file handles
#define EIHAND	0xC3		// Invalid file handle
#define ENOPEN	0xC2		// File handle not open
#define EIDEV	0xC1		// Invalid device operation
#define EIENV	0xC0		// Invalid environment string


extern uint8_t dosversion;
extern uint8_t last_error;

extern void msxdos_init(void);
extern int8_t open(char *filepath, uint8_t flags);
extern int8_t creat(char *filepath, uint8_t flags, uint8_t attrib);
extern int8_t close(int8_t handle);
extern int8_t dup(int8_t handle);
extern int16_t read(int8_t handle, void *buffer, int16_t bytesToRead);
extern int16_t write(int8_t handle, void *buffer, int16_t bytesToWrite);
extern uint32_t lseek(int8_t fhandle, uint32_t offset, uint8_t method);
extern uint32_t dos1GetFilesize(void);
extern void exit(int8_t error);
extern unsigned char getDeviceInfo(unsigned char index, void *buffer);

#endif
