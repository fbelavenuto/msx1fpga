/*

Original source code: https://github.com/ben0109/Papilio-Master-System
All credits go to Ben.
Ben's Blog: http://fpga-hacks.blogspot.com.es/

11/2016 - Modified by Fabio Belavenuto to MSX1FPGA project.

*/

#ifndef __FAT_H
#define __FAT_H

#define FAT_EOF	0xffff
#define FALSE 0
#define TRUE 1

#define USE_FAT32 0

typedef struct {
	unsigned char type;
	unsigned long size;
	unsigned long cluster;
	unsigned long sector;
} file_t;

int fat_init();
int fat_fopen(file_t *file, const char *name);
int fat_bread(file_t *file, unsigned char *buffer);
int fat_chdir(const char *name);

#endif // __FAT_H



