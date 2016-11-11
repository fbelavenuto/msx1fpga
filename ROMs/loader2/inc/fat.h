
#ifndef __FAT_H
#define __FAT_H

#define FAT_EOF	0xffff
#define FALSE 0
#define TRUE 1

/*
typedef struct {
	unsigned char type;		// first byte : directories are 0x01, files are 0x11
	char          name[11];
	unsigned long cluster;
} file_descr_t;
*/

typedef struct {
	unsigned long size;
	unsigned long cluster;
	unsigned long sector;
} file_t;

int fat_init();
//file_descr_t* fat_load_root_directory();
//file_descr_t* fat_load_directory(unsigned long first_cluster);
//int fat_open_file(file_t *file, unsigned long cluster);
//int fat_load_file_sector(file_t *file, unsigned char *buffer);
int fat_fopen(file_t *file, const char *name);
int fat_bread(file_t *file, unsigned char *buffer);

#endif // __FAT_H



