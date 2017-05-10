
#ifndef  __DOS2_H__
#define  __DOS2_H__

#ifdef  __DOS_H__
#error You cannot use both dos and dos2 file functions
#endif

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


extern uint8_t last_error;

extern int8_t open(char *, uint8_t);
extern int8_t creat(char *, uint8_t, uint8_t);
extern int8_t close(int8_t);
extern int8_t dup(int8_t);
extern int16_t read(int8_t, void *, int16_t);
extern int16_t write(int8_t, void *, int16_t);
extern uint32_t lseek(int8_t, uint32_t, uint8_t);
extern void exit(int8_t);


#endif
