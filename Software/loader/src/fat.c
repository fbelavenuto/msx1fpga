/*

Original source code: https://github.com/ben0109/Papilio-Master-System
All credits go to Ben.
Ben's Blog: http://fpga-hacks.blogspot.com.es/

11/2016 - Modified by Fabio Belavenuto to MSX1FPGA project.

*/

#include "fat.h"
#include "mmc.h"

typedef struct {
#if USE_FAT32 == 1
	unsigned char fat32;
#endif
	unsigned char sectors_per_cluster;
	unsigned long first_fat_sector;
	unsigned long first_data_sector;
	unsigned long current_data_sector;
	unsigned long current_fat_sector;
	unsigned long root_directory_cluster;
	unsigned long root_directory_sector;
	unsigned short root_directory_size;
	unsigned long current_directory_cluster;
	unsigned long current_directory_sector;
} fat_t;

fat_t          fat;
unsigned char  fat_buffer[512];
unsigned char  data_buffer[512];


/******************************************************************************/
static unsigned long load_dword(unsigned char *ptr)
{
	unsigned long *p = (unsigned long *)ptr;
	return *p;
}

/******************************************************************************/
static unsigned short load_word(unsigned char *ptr)
{
	unsigned short *p = (unsigned short *)ptr;
	return *p;
}

/*******************************************************************************/
static int compare(const char *s1, const char *s2, int b) {
	int i;

	for(i = 0; i < b; ++i) {
		if(*s1++ != *s2++)
			return FALSE;
	}
	return TRUE;
}

/******************************************************************************/
static int load_fat_sector(unsigned long sector)
{
	sector += fat.first_fat_sector;
	if (fat.current_fat_sector == sector) {
		return TRUE;
	}

	if (MMC_Read(sector, fat_buffer)) {
		fat.current_fat_sector = sector;
		return TRUE;
	}
	return FALSE;
}

/******************************************************************************/
static unsigned long first_sector_of_cluster(unsigned long cluster)
{
	return fat.first_data_sector + (cluster-2)*fat.sectors_per_cluster;
}

/******************************************************************************/
static unsigned long fat_next_cluster(unsigned long current)
{
	unsigned long fat_sector;

#if USE_FAT32 == 1
	fat_sector = (fat.fat32) ? (current >> 7) : (current >> 8);
#else
	fat_sector = (current >> 8);
#endif
	if (!load_fat_sector(fat_sector)) {
		return 0;
	}

#if USE_FAT32 == 1
	if (fat.fat32) {
		return load_dword(&fat_buffer[(current & 0x7F) << 2]);
	} else {
		return load_word(&fat_buffer[(current & 0xFF) << 1]);
	}
#else
	return load_word(&fat_buffer[(current & 0xFF) << 1]);
#endif
}

/******************************************************************************/
static int fat_is_last_cluster(unsigned long cluster)
{
#if USE_FAT32 == 1
	if (fat.fat32) {
		return ((cluster & 0xFFFFFFF8) == 0xFFFFFFF8);
	} else {
		return ((cluster & 0xFFF8) == 0xFFF8);
	}
#else
	return ((cluster & 0xFFF8) == 0xFFF8);
#endif
}

#if USE_FAT32 == 1
/******************************************************************************/
static void fat_init32()
{
	unsigned char nb_fats;
	unsigned long fat_size;

	nb_fats  = data_buffer[0x10];
	fat_size = load_dword(&data_buffer[0x24]);

	fat.first_data_sector = fat.first_fat_sector;
	for (; nb_fats > 0; --nb_fats) {
		fat.first_data_sector += fat_size;
	}
	fat.root_directory_cluster = load_dword(&data_buffer[0x2C]);
	fat.root_directory_sector  = first_sector_of_cluster(fat.root_directory_cluster);
	fat.root_directory_size = 8;
	fat.current_directory_cluster = fat.root_directory_cluster;
	fat.current_directory_sector  = fat.root_directory_sector;
}
#endif

/******************************************************************************/
static void fat_init16()
{
	unsigned char nb_fats;
	unsigned short fat_size;

	// root directory first sector
	nb_fats = data_buffer[0x10];
	fat_size = load_word(&data_buffer[0x16]);
	fat.root_directory_cluster = 0;
	fat.root_directory_sector  = fat.first_fat_sector;
	for (; nb_fats > 0; --nb_fats) {
		fat.root_directory_sector += fat_size;
	}

	// root directory size (in sectors)
	fat.root_directory_size = load_word(&data_buffer[0x11])>>4;

	// first data sector = first sector after root directory
	fat.first_data_sector = fat.root_directory_sector + fat.root_directory_size;
	fat.current_directory_cluster = 0;
	fat.current_directory_sector  = fat.root_directory_sector;
}

/******************************************************************************/
int fat_init()
{
	unsigned long sector;
	unsigned char hasMBR;

	sector = 0;
	if (!MMC_Read(sector, data_buffer)) {
		return FALSE;
	}
	if ((data_buffer[0x1FE] != 0x55) || (data_buffer[0x1FF] != 0xAA)) {
		return FALSE;
	}
	switch (data_buffer[0x1C2]) {
	case 0x06:
	case 0x04:
#if USE_FAT32 == 1
		fat.fat32 = FALSE;
#endif
		hasMBR = TRUE;
		break;
#if USE_FAT32 == 1
	case 0x0B:
	case 0x0C:	
		fat.fat32 = TRUE;
		hasMBR = TRUE;
		break;
#endif
	default:
#if USE_FAT32 == 1
		if (data_buffer[0x55] == 0x33) {		//check possible FAT type when NO MBR found (32)
			fat.fat32 = TRUE;
			hasMBR = FALSE;
		} else
#endif
		if (data_buffer[0x39] == 0x31) {	//check possible FAT type when NO MBR found (16)
#if USE_FAT32 == 1
			fat.fat32 = FALSE;
#endif
			hasMBR = FALSE;
		} else {
			return FALSE;
		}
	}
	if (hasMBR) {
		sector = load_dword(&data_buffer[0x1C6]); 
	} else {
		sector = 0; 
	}

	if (!MMC_Read(sector, data_buffer)) {
		return FALSE;
	}
/*
	if ((data_buffer[0x1FE] != 0x55) || (data_buffer[0x1FF] != 0xAA)) {
		return FALSE;
	}
*/
	if ((data_buffer[0x0B] != 0) || (data_buffer[0x0C] != 2)) {
		return FALSE;
	}

	fat.sectors_per_cluster = data_buffer[0x0D];

	// reserved sectors
	fat.first_fat_sector = sector + load_word(&data_buffer[0x0E]);

#if USE_FAT32 == 1
	if (fat.fat32) {
		fat_init32();
	} else {
		fat_init16();
	}
#else
	fat_init16();
#endif

	return TRUE;
}

/******************************************************************************/
static int fat_findentry(file_t *file, const char *name)
{
	unsigned long sector;
	unsigned long cluster;
	unsigned char i, n;
	unsigned char* buffer_ptr;

	cluster = fat.current_directory_cluster;
	sector  = fat.current_directory_sector;
#if USE_FAT32 == 1
	while(1) {
#endif
		for(i = fat.root_directory_size; i > 0; --i) {
			if (!MMC_Read(sector, data_buffer)) {
				return 0;
			}
			buffer_ptr = data_buffer;
			for(n = 0; n < 16; n++) {
				if (buffer_ptr[0] != 0xE5 && buffer_ptr[0] != 0x00) {
					if (compare((const char*)buffer_ptr, name, 11)) {
						file->type = buffer_ptr[0x0B];
						file->size = load_dword(&buffer_ptr[0x1C]);
						file->cluster = load_word(&buffer_ptr[0x1A]);
#if USE_FAT32 == 1
						if (fat.fat32) {
							file->cluster |= ((unsigned long)load_word(&buffer_ptr[0x15])) << 16;
						}
#endif
						return TRUE;
					}
				}
				buffer_ptr += 32;
			}
			sector++;
		}
#if USE_FAT32 == 1
		if (fat.fat32) {
			cluster = fat_next_cluster(cluster);
			if (cluster == 0) {
				return FALSE;
			}
			if (fat_is_last_cluster(cluster)) {
				break;
			}
			sector = first_sector_of_cluster(cluster);
		} else {
			break;
		}
	};
#endif
	return FALSE;
}

/******************************************************************************/
int fat_fopen(file_t *file, const char *name)
{
	if (fat_findentry(file, name) == FALSE) {
		return FALSE;
	}
	if ((file->type & 0x18) != 0) {				// If Vol or Dir, return error
		return FALSE;
	}
	file->sector = first_sector_of_cluster(file->cluster);
	return TRUE;
}

/******************************************************************************/
int fat_bread(file_t *file, unsigned char *buffer)
{
	if (file->sector == first_sector_of_cluster(file->cluster + 1)) {
		file->cluster = fat_next_cluster(file->cluster);
		if (fat_is_last_cluster(file->cluster)) {
			return FAT_EOF;
		} else {
			file->sector = first_sector_of_cluster(file->cluster);
		}
	}
	return MMC_Read(file->sector++, buffer);
}

/******************************************************************************/
int fat_chdir(const char *name)
{
	file_t f;

	if (fat_findentry(&f, name) == FALSE) {
		return FALSE;
	}
	if ((f.type & 0x10) == 0) {				// If not Dir, return error
		return FALSE;
	}
	fat.current_directory_cluster = f.cluster;
	fat.current_directory_sector  = first_sector_of_cluster(f.cluster);
	return TRUE;
}