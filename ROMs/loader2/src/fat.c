/*

Original source code: https://github.com/ben0109/Papilio-Master-System
All credits go to Ben.
Ben's Blog: http://fpga-hacks.blogspot.com.es/

11/2016 - Modified by Fabio Belavenuto to MSX1FPGA project.

*/

#include "fat.h"
#include "mmc.h"
#include "hardware.h"

typedef struct {
#if USE_FAT32 == 1
	unsigned char fat32;
#endif
	unsigned char sectors_per_cluster;
	unsigned long first_fat_sector;
	unsigned long first_data_sector;
	unsigned long current_data_sector;
	unsigned long current_fat_sector;
	unsigned long root_directory;
	unsigned short root_directory_size;
} fat_t;


fat_t          fat;
unsigned char  fat_buffer[512];
unsigned char  data_buffer[512];
//file_descr_t   directory_buffer[256];


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
	if (fat.current_fat_sector==sector) {
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
	fat.root_directory = load_dword(&data_buffer[0x2C]);
	fat.root_directory_size = 8;
}
#endif

/******************************************************************************/
static void fat_init16()
{
	unsigned char nb_fats;
	unsigned short fat_size;

	// root directory first sector
	nb_fats = data_buffer[0x10];
	fat_size = load_word(&data_buffer[22]);
	fat.root_directory = fat.first_fat_sector;
	for (; nb_fats > 0; --nb_fats) {
		fat.root_directory += fat_size;
	}

	// root directory size (in sectors)
	fat.root_directory_size = load_word(&data_buffer[17])>>4;

	// first data sector = first sector after root directory
	fat.first_data_sector = fat.root_directory + fat.root_directory_size;
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

	if ((data_buffer[0x1FE] != 0x55) || (data_buffer[0x1FF] != 0xAA)) {
		return FALSE;
	}

	if ((data_buffer[11] != 0) || (data_buffer[12] != 2)) {
		return FALSE;
	}

	fat.sectors_per_cluster = data_buffer[13];

	// reserved sectors
	fat.first_fat_sector = sector + load_word(&data_buffer[14]);

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
/*int fat_open_file(file_t *file, unsigned long cluster)
{
	file->cluster = cluster;
	file->sector  = first_sector_of_cluster(cluster);
	return TRUE;
}*/

/******************************************************************************/
/*int fat_load_file_sector(file_t *file, unsigned char *buffer)
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
}*/

/******************************************************************************/
/*static void clear_directory_buffer()
{
	int i;
	for (i = 0; i < 256; i++) {
		directory_buffer[i].type = 0;
	}
}*/

/******************************************************************************/
/*static int fat_process_directory_entry(file_descr_t *file_descr, unsigned char* data)
{
	unsigned char i;

	if ((*data) == 0xE5) {		// deleted
		return FALSE;
	} 
	if ((data[11] & 13) != 0) {	// fancy attributes
		return FALSE;
	}

	// first byte : directories are 0x01", files are 0x11
	file_descr->type = ((data[11] & 0x10) ^ 0x10) | 0x01;

	// copy file name (11 bytes)
	for(i=0; i<11; i++) {
		file_descr->name[i] = *data++;
	}

	// copy cluster # (4 bytes)
	file_descr->cluster = load_word(&data[15]);
	if (fat.fat32) {
		file_descr->cluster |= ((unsigned long)load_word(&data[9])) << 16;
	}

	return TRUE;
}*/

/******************************************************************************/
/*static int process_directory_sector(file_descr_t** directory_ptr, unsigned char* buffer_ptr)
{
	unsigned char i;
	for (i = 0x10; i > 0; --i) {
		if ((*buffer_ptr) == 0) {
			(*directory_ptr)->type = 0; // marks last entry
			return TRUE;
		}
		if (fat_process_directory_entry(*directory_ptr, buffer_ptr)) {
			(*directory_ptr)++;
		}
		buffer_ptr += 0x20;
	}
	return FALSE;
}*/

/******************************************************************************/
/*static file_descr_t* fat_load_root_directory16()
{
	unsigned long sector;
	file_descr_t* directory_ptr;
	unsigned char i;

	clear_directory_buffer();

	sector = fat.root_directory;
	directory_ptr = directory_buffer;
	for (i = fat.root_directory_size; i > 0; --i) {
		if (!MMC_Read(sector, data_buffer)) {
			return 0;
		}
		if (process_directory_sector(&directory_ptr, data_buffer)) {
			goto fat_load_root_directory16;
		}
		sector++;
	}

fat_load_root_directory16:
	directory_ptr->type = 0; // marks last entry
	return directory_buffer;
}*/

/******************************************************************************/
/*file_descr_t* fat_load_directory(unsigned long first_cluster)
{
	unsigned long cluster;
	unsigned long sector;
	file_descr_t* directory_ptr;

	if (!fat.fat32) {
		if (first_cluster == 0) {
			return fat_load_root_directory16();
		}
	}

	clear_directory_buffer();

	cluster = first_cluster;
	directory_ptr = directory_buffer;
	do {
		unsigned char i;
		sector = first_sector_of_cluster(cluster);
		for(i = 8; i > 0; --i) {
			if (!MMC_Read(sector, data_buffer)) {
				return 0;
			}
			if (process_directory_sector(&directory_ptr, data_buffer)) {
				goto fat_open_directory_end;
			}
			sector++;
		}
		cluster = fat_next_cluster(cluster);
		if (cluster == 0) {
			return 0;
		}
	} while (!fat_is_last_cluster(cluster));

fat_open_directory_end:
	directory_ptr->type = 0; // marks last entry
	return directory_buffer;
}*/

/******************************************************************************/
/*file_descr_t* fat_load_root_directory()
{
	if (fat.fat32) {
		return fat_load_directory(fat.root_directory);
	} else {
		return fat_load_root_directory16();
	}
}
*/

/******************************************************************************/
int fat_fopen(file_t *file, const char *name)
{
	unsigned long sector;
	unsigned long cluster = 0;
	unsigned char i, n;
	unsigned char* buffer_ptr;

#if USE_FAT32 == 1
	if (fat.fat32) {
		cluster = fat.root_directory;
		sector = first_sector_of_cluster(cluster);
	} else {
		sector = fat.root_directory;
	}
	do {
#else
	sector = fat.root_directory;
#endif
		for(i = fat.root_directory_size; i > 0; --i) {
			if (!MMC_Read(sector, data_buffer)) {
				return 0;
			}
			buffer_ptr = data_buffer;
			for(n = 0; n < 16; n++) {
				if (buffer_ptr[0] != 0xE5 && buffer_ptr[0] != 0x00) {
					if ((buffer_ptr[11] & 0x18) == 0) {
						if (compare((const char*)buffer_ptr, name, 11)) {
							file->size = load_dword(&buffer_ptr[28]);
							file->cluster = load_word(&buffer_ptr[26]);
#if USE_FAT32 == 1
							if (fat.fat32) {
								file->cluster |= ((unsigned long)load_word(&buffer_ptr[21])) << 16;
							}
#endif
							file->sector = first_sector_of_cluster(file->cluster);
							return TRUE;
						}
					}
				}
				buffer_ptr += 32;
			}
			sector++;
		}
#if USE_FAT32 == 1
		if (!fat.fat32) {
			break;
		}
		cluster = fat_next_cluster(cluster);
		if (cluster == 0) {
			return FALSE;
		}
		sector = first_sector_of_cluster(fat.root_directory);
	} while (!fat_is_last_cluster(cluster));
#endif

	return FALSE;
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
