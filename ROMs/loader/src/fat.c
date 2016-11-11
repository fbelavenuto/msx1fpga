/*
Copyright 2005, 2006, 2007 Dennis van Weeren
Copyright 2008, 2009 Jakub Bednarski

This file is part of Minimig

Minimig is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 3 of the License, or
(at your option) any later version.

Minimig is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.

This is a simple FAT16 handler. It works on a sector basis to allow fastest acces on disk
images.

11-12-2005 - first version, ported from FAT1618.C

JB:
2008-10-11  - added SeekFile() and cluster_mask
            - limited file create and write support added
2009-05-01  - modified LoadDirectory() and GetDirEntry() to support sub-directories (with limitation of 511 files/subdirs per directory)
            - added GetFATLink() function
            - code cleanup
2009-05-03  - modified sorting algorithm in LoadDirectory() to display sub-directories above files
2009-08-23  - modified ScanDirectory() to support page scrolling and parent dir selection
2009-11-22  - modified FileSeek()
            - added FileReadEx()
2009-12-15  - all entries are now sorted by name with extension
            - directory short names are displayed with extensions

2012-07-24  - Major changes to fit the MiniSOC project - AMR

2016-09		- Minor changes to adapt the project
*/

#include <stdio.h>
#include "fat.h"
#include "mmc.h"

// internal global variables
unsigned long fat_start;                // start LBA of first FAT table
unsigned long data_start;               // start LBA of data field
unsigned long root_directory_start;     // start LBA of directory table
unsigned long root_directory_size;      // size of directory region in sectors
unsigned int fat_number;               // number of FAT tables
unsigned long cluster_size;             // size of a cluster in sectors
unsigned long cluster_mask;             // binary mask of cluster number
unsigned long dir_entries;             // number of entry's in directory table
unsigned long fat_size;                 // size of fat

unsigned char sector_buffer[512];       // sector buffer

int partitioncount;

#define fat_buffer (*(FATBUFFER*)&sector_buffer) // Don't need a separate buffer for this.
unsigned long buffered_fat_index;       // index of buffered FAT sector

/*******************************************************************************/
static unsigned long GetCluster(unsigned long cluster)
{
	unsigned long i;
	unsigned long sb;
	sb = cluster >> 8; // calculate sector number containing FAT-link
	i = cluster & 0xFF; // calculate link offsset within sector

	// read sector of FAT if not already in the buffer
	if (sb != buffered_fat_index) {
		if (!MMC_Read(fat_start + sb, (unsigned char*)&fat_buffer)) {
			return 0;
		}
		// remember current buffer index
		buffered_fat_index = sb;
	}
	i = fat_buffer.fat16[i];
	return i;
}

/*******************************************************************************/
int compare(const char *s1, const char *s2, int b) {
	int i;

	for(i = 0; i < b; ++i) {
		if(*s1++ != *s2++)
			return 1;
	}
	return 0;
}

/*******************************************************************************/
// FindDrive() checks if a card is present and contains FAT formatted primary partition
unsigned char FindDrive(void)
{
	unsigned long boot_sector;              // partition boot sector
    buffered_fat_index = 0xFFFFFFFF;

    if (!MMC_Read(0, sector_buffer)) // read MBR
        return(0);

	boot_sector=0;
	partitioncount=1;

	// If we can identify a filesystem on block 0 we don't look for partitions
    if (compare((const char*)&sector_buffer[0x36], "FAT16   ",8)==0) // check for FAT16
		partitioncount=0;

	if(partitioncount) {
		// We have at least one partition, parse the MBR.
		struct MasterBootRecord *mbr=(struct MasterBootRecord *)sector_buffer;

		boot_sector = mbr->Partition[0].startlba;
		if(mbr->Signature == 0x55aa)
				boot_sector = mbr->Partition[0].startlba;
		else if(mbr->Signature != 0xaa55) {
				return(0);							// No partition signature found
		}
		if (!MMC_Read(boot_sector, sector_buffer)) // read discriptor
		    return(0);
		//Read boot sector from first partition
	}

	if (compare(sector_buffer+0x36, "FAT16   ",8) != 0) {		// check for FAT16
		// Unsupported partition type!
		return(0);
	}

	if (sector_buffer[510] != 0x55 || sector_buffer[511] != 0xaa) {		// check signature
		return(0);
	}

	// check for near-jump or short-jump opcode
	if (sector_buffer[0] != 0xe9 && sector_buffer[0] != 0xeb)
		return(0);

	// check if blocksize is really 512 bytes
	if (sector_buffer[11] != 0x00 || sector_buffer[12] != 0x02)
		return(0);

	// get cluster_size
	cluster_size = sector_buffer[13];

	// calculate cluster mask
	cluster_mask = cluster_size - 1;

	fat_start = boot_sector + sector_buffer[0x0E] + (sector_buffer[0x0F] << 8); // reserved sector count before FAT table (usually 32 for FAT32)
	fat_number = sector_buffer[0x10];

	// calculate drive's parameters from bootsector, first up is size of directory
	dir_entries = sector_buffer[17] + (sector_buffer[18] << 8);
	root_directory_size = ((dir_entries << 5) + 511) >> 9;

	// calculate start of FAT,size of FAT and number of FAT's
	fat_size = sector_buffer[22] + (sector_buffer[23] << 8);

	// calculate start of directory
	root_directory_start = fat_start + (fat_number * fat_size);

	// calculate start of data
	data_start = root_directory_start + root_directory_size;

	return(1);
}

/*******************************************************************************/
unsigned char FileOpen(fileTYPE *file, const char *name)
{
	unsigned long  iDirectory = 0;       // only root directory is supported
	DIRENTRY       *pEntry = 0;          // pointer to current entry in sector buffer
	unsigned long  iDirectorySector;     // current sector of directory entries table
	unsigned long  iEntry;               // entry index in directory cluster or FAT16 root directory
	unsigned long  nEntries;             // number of entries per cluster or FAT16 root directory size

	buffered_fat_index = 0xFFFFFFFF;

	iDirectorySector = root_directory_start;
	nEntries = root_directory_size << 4;												// 16 entries per sector

	for (iEntry = 0; iEntry < nEntries; iEntry++) {
		if ((iEntry & 0x0F) == 0) {														// first entry in sector, load the sector
			MMC_Read(iDirectorySector++, sector_buffer);								// root directory is linear
			pEntry = (DIRENTRY*)sector_buffer;
		} else {
			pEntry++;
		}
		if (pEntry->Name[0] != SLOT_EMPTY && pEntry->Name[0] != SLOT_DELETED) {			// valid entry??
			if (!(pEntry->Attributes & (ATTR_VOLUME | ATTR_DIRECTORY))) {				// not a volume nor directory
				if (compare((const char*)pEntry->Name, name, 11) == 0) {
					file->size = pEntry->FileSize;
					file->cluster = pEntry->StartCluster;
					file->sector = 0;
					return(1);															// File found
				}
			}
		}
	}
	return(0);
}

/*******************************************************************************/
unsigned char FileRead(fileTYPE *file, unsigned char *pBuffer)
{
	unsigned long sb;

	sb = data_start;							// start of data in partition
	sb += cluster_size * (file->cluster-2);		// cluster offset
	sb += file->sector & cluster_mask;			// sector offset in cluster

	if (!MMC_Read(sb, pBuffer)) {				// read sector from drive
		return 0;
	} else {
		// increment sector index
		file->sector++;

		// cluster's boundary crossed?
		if ((file->sector & cluster_mask) == 0) {
			file->cluster = GetCluster(file->cluster);
		}
	}
	return 1;
}
