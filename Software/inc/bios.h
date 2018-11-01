
#ifndef  __BIOS_H__
#define  __BIOS_H__

/* clearKeyBuf: Clear the keyboard buffer
 * Input: none
 * Output: none
 */
void clearKeyBuf(void);

/* putRamFrame1: Put RAM in Frame 1
 * Input: none
 * Output: none
 */
void putRamFrame1(void);

/* putRamFrame2: Put RAM in Frame 2
 * Input: none
 * Output: none
 */
void putRamFrame2(void);

/* putRamFrame1: Put Slot in Frame 1
 * Input: slot number in format E...SSPP
 * Output: none
 */
void putSlotFrame1(unsigned char slot);

/* putRamFrame1: Put Slot in Frame 2
 * Input: slot number in format E...SSPP
 * Output: none
 */
void putSlotFrame2(unsigned char slot);

/* resetSystem: Reset the MSX
 * Input: none
 * Output: none
 */
void resetSystem(void);

#endif	/* __BIOS_H__ */
