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

#ifndef  __MAPPER_H__
#define  __MAPPER_H__

/*
mpvSlot			= 0		; Slot address of the mapper slot.
mpvNumSegs		= 1		; Total number of 16k RAM segments. 1...255 (8...255 for the primary)
mpvNumFree		= 2		; Number of free 16k RAM segments.
mpvNumSysAlloc	= 3		; Number of 16k RAM segments allocated to the system (at least 6 for the primay)
mpvNumUserAlloc	= 4		; Number of 16k RAM segments allocated to the user.
*/

typedef struct {
	unsigned char slotAddr;
	unsigned char numSegs;
	unsigned char numFree;
	unsigned char numSysAlloc;
	unsigned char numUserAlloc;
} TMapperVars;

extern TMapperVars *mpVars;
extern unsigned char mpSlotAddr;
extern unsigned char mpSlotNum;


/* mpInit: Initializes mapper variables and functions
 * Input: none
 * Output: 1 if error
 */
unsigned char mpInit(void);

/* numMapperPages: Test mapper size, for MSX without EXTBIOS
 * Input: none
 * Output: number of pages
 */
unsigned char numMapperPages(void);

/* allocUserSegment: Alloc a mapper user segment
 * Input: none
 * Output: segment number, 0 if error
 */
unsigned char allocUserSegment(void);

/* allocSysSegment: Alloc a mapper system segment
 * Input: none
 * Output: segment number, 0 if error
 */
unsigned char allocSysSegment(void);

/* freeSegment: Free a mapper segment
 * Input: segment number
 * Output: 1 if OK, 0 if error
 */
unsigned char freeSegment(unsigned char segm);

/* getCurSegFrame1: Get current segment in Frame 1
 * Input: none
 * Output: segment number
 */
unsigned char getCurSegFrame1(void);

/* getCurSegFrame2: Get current segment in Frame 2
 * Input: none
 * Output: segment number
 */
unsigned char getCurSegFrame2(void);

/* putSegFrame1: Put a mapper segment in Frame 1
 * Input: segment number
 * Output: none
 */
void putSegFrame1(unsigned char segm);

/* putSegFrame2: Put a mapper segment in Frame 2
 * Input: segment number
 * Output: none
 */
void putSegFrame2(unsigned char segm);

#endif /* __MAPPER_H__ */
