### Found on:  http://bifi.msxnet.org/msxnet/tech/megaroms


Quick access:

 - [Konami without SCC](#KonamiWithoutSCC)
 - [Konami with SCC](#KonamiWithSCC)
 - [ASCII 8Kb](#A08)
 - [ASCII 16Kb](#A16)
 - [R-Type](#RTYPE)
 - [The Game Master 2 (Konami RC 755)](#RC755)
 - [ASCII 8Kb with 8Kb SRAM](#A08S8)
 - [Hai no Majutsushi (Mah Jong 2) RC 765](#RC765)
 - [MSX DOS 2 cartridge](#DOS2)
 - [Hydlide 2](#HYDLIDE)
 - [Konami without SCC 16Kb](#KonamiWithoutSCC16K)
 - [FM PAC](#FMPAC)
 - [Konami's Synthesizer](#SYNTH)
 - [Cross Blaim](#CROSS)
 - [Super Lode Runner](#SLR)
 - [Playball](#PLAY)
 - [64-in-1 and 80-in-1](#M6480G)
 - [90-in-1](#M90G)
 - [126-in-1](#M126G)


To fit ROMs larger than 64Kb in one slot (thus one cartridge) software producers made ROM mappers. There are several different types around.

These mappers divide the memory area 4000h - BFFFh in two or four memory areas (banks), depending on whether it is a 8Kb or a 16Kb mapper.

You can write to a certain address or address area (if it is a memory area, any address in the area will do the same thing). 0 selects the first 8Kb or 16Kb of the real ROM into a memory bank, 1 the second, etc..

By default, bank 1 has the value 0 and bank 2 the value 1, etc, etc. In this way the first 32Kb of the ROM is selected into 4000h - BFFFh.

<a id="KonamiWithoutSCC"></a>
# Konami without SCC

This type is used Konami cartridges that do not have a SCC such as: Nemesis, Penguin Adventure, Usas, Metal Gear, Shalom and The Maze of Galious.

Since the size of the mapper is 8Kb, the memory banks are:

	Bank 1: 4000h - 5FFFh
	Bank 2: 6000h - 7FFFh
	Bank 3: 8000h - 9FFFh
	Bank 4: A000h - BFFFh

And the address to change banks:

	Bank 1: <none>
	Bank 2: 6000h - 7FFFh (6000h used)
	Bank 3: 8000h - 9FFFh (8000h used)
	Bank 4: A000h - BFFFh (A000h used)

This has been verified on several Konami cartridges. Although the ROM can be smaller than 256Kb the mapper will remain that size all the time. The empty area will always be entirely filled with FFh. At number 20h the ROM start of the ROM is returned again.

Note that in order for The Game Master 2 to work with a cartridge of this type, bank 1 must be fixed at 0. This is the reason The Game Master 2 doesn't work with these cartridges on fMSX. While The Game Master 2 searches for memory in page 1 and 2 it overwrites 4000h. If bank 1 is changed, it won't find the AB code and the cartridge won't be detected.

<a id="KonamiWithSCC"></a>
# Konami with SCC

This type is used Konami cartridges that do have a SCC and some cartridges not made by Konami: Nemesis 2, King's Valley 2, Nemesis 3, Space Manbow, Solid Snake, Quarth, Ashguine 1, Animal, Arkanoid 2, and more.

Since the size of the mapper is 8Kb, the memory banks are:

	Bank 1: 4000h - 5FFFh
	Bank 2: 6000h - 7FFFh
	Bank 3: 8000h - 9FFFh
	Bank 4: A000h - BFFFh

And the address to change banks:

	Bank 1: 5000h - 57FFh (5000h used)
	Bank 2: 7000h - 77FFh (7000h used)
	Bank 3: 9000h - 97FFh (9000h used)
	Bank 4: B000h - B7FFh (B000h used)

If it is a Konami cartridge, you can use the SCC by writing a value with bits 0 - 5 set (3Fh, bits 6 and 7 do not matter) to 9000h - 97FFh, you can read and write to the SCC in the memory area 9800h - 9FFFh. See SCC Sound Chip for more information.

This has been verified on Konami cartridges. Unlike the Konami without SCC (konami4/8Kb) one this mapper does repeat the ROM just after the last ROM page.

<a id="A08"></a>
# ASCII 8Kb

This type is used in many Japanese-only cartridges. You can find it in Valis, Dragon Slayer, Outrun, Ashguine 2, and many more.

Since the size of the mapper is 8Kb, the memory banks are:

	Bank 1: 4000h - 5FFFh
	Bank 2: 6000h - 7FFFh
	Bank 3: 8000h - 9FFFh
	Bank 4: A000h - BFFFh

And the address to change banks:

	Bank 1: 6000h - 67FFh (6000h used)
	Bank 2: 6800h - 6FFFh (6800h used)
	Bank 3: 7000h - 77FFh (7000h used)
	Bank 4: 7800h - 7FFFh (7800h used)

This has been verified on Valis (Fantasm Soldier).

<a id="A16"></a>
# ASCII 16Kb

This type is used in a few cartridges: Xevious, Fantasy Zone 2, Return of Ishitar, Andorogynus and probably some more.

Since the size of the mapper is 16Kb, the memory banks are:

	Bank 1: 4000h - 7FFFh
	Bank 2: 8000h - BFFFh

And the address to change banks:

	Bank 1: 6000h - 67FFh (6000h used)
	Bank 2: 7000h - 77FFh (7000h and 77FFh used)

This has been verified on Xevious.

Gallforce is a special case. It is the same as Xevious, but bank 2 has to start with the first 16kB after a reset.

<a id="RTYPE"></a>
# R-Type

This is a 3 megabit ROM cartridge. It's pretty weird actually, as all the data would easily fit into 2 megabit. A lot of pages are identical. I'm not sure the top 1 megabit is ever used...

Anyway, it's a 16Kb type mapper:

	Bank 1: 4000h - 7FFFh
	Bank 2: 8000h - BFFFh

And the address to change banks:

	Bank 1: Fixed at 0Fh or 17h
	Bank 2: 7000h - 7FFFh (7000h and 7800h used)

Addresses 6000h and 6800h are used somewhere in the code of the game, but this perticulair bit of code is never executed. These addresses don't seem to have effect on anything.

So the value you write selects a 16Kb page. Bit 4 selects the ROM chip. If bit 4 is low, bits 0 - 3 select a page. If bit 4 is high, bits 0 - 2 select a page from the other ROM chip.

But that's not all: page 0 of both ROM chips do not contain the entry code (with AB 'n stuff) of the game. Only the last page of both ROM chips contain the AB code (0Fh and 17h). These pages are identical. So there's a problem: what is the beginning of the ROM and what is the end? Which one of the two ROM chips comes first?

<a id="RC755"></a>
# The Game Master 2 (Konami RC 755)

This is a 1 megabit ROM cartridge with 8 Kb SRAM. Because of the SRAM, the mappers have special features.

Since the size of the mapper is 8Kb, the memory banks are:

	Bank 1: 4000h - 5FFFh
	Bank 2: 6000h - 7FFFh
	Bank 3: 8000h - 9FFFh
	Bank 4: A000h - BFFFh

And the addresses to change banks:

	Bank 1: <none>
	Bank 2: 6000h - 6FFFh (6000h used)
	Bank 3: 8000h - 8FFFh (8000h used)
	Bank 4:	A000h - AFFFh (A000h used)
	SRAM write: B000h - BFFFh

If SRAM is selected in bank 4, you can write to it in the memory area B000h - BFFFh.

The value you write to change banks also determines whether you select ROM or SRAM. SRAM can be in any memory bank (except bank 1 which can't be modified) but it can only be written too in bank 4.

	bit      |  0 |  1 |  2 |  3 |      4       |  5 | 6 | 7 |
	----------------------------------------------------------
	function | R0 | R1 | R2 | R3 | 1=SRAM/0=ROM | S0 | X | X |

If bit 4 is reset, bits 0 - 3 select the ROM page as you would expect them to do. Bits 5 - 7 are ignored now. If bit 4 is set, bit 5 selects the SRAM page (first or second 4Kb of the 8Kb). Bits 6 - 7 and bits 0 - 3 are ignored now.

Since you can only select 4Kb of the SRAM at once in a memory bank and a memory bank is 8Kb in size, the first and second 4Kb of the memory bank read the same 4Kb of SRAM if SRAM is selected.

I have verified all of this on the real cartridge, many thanks to Klaas de Wind.

<a id="A08S8"></a>
# ASCII 8Kb with 8 Kb SRAM

It is much like the normal ASCII 8Kb. This type is used in Xanadu and Royal Blood (maybe some others). Since the size of the mapper is 8Kb, the memory banks are:

	Bank 1: 4000h - 5FFFh
	Bank 2: 6000h - 7FFFh
	Bank 3: 8000h - 9FFFh
	Bank 4: A000h - BFFFh

And the address to change banks:

	Bank 1: 6000h - 67FFh (6000h used)
	Bank 2: 6800h - 6FFFh (6800h used)
	Bank 3: 7000h - 77FFh (7000h used)
	Bank 4: 7800h - 7FFFh (7800h used)

The SRAM behaves just like a page of the ROM. The SRAM can be written too only if is selected in bank 3 or 4. To select it, write value with bit 5 set (20h) to the address to change banks (for Xanadu, 80h for Royal Blood).

<a id="RC765"></a>
# Hai no Majutsushi (Mah Jong 2) RC 765

This game is special because there is a 8 Bit D/A converter for playing samples installed on it. It is a really simple setup. The ROM is one megabit (128kB) and uses the Konami without SCC (konami4/8Kb) mapper.

Since the size of the mapper is 8Kb, the memory banks are:

	Bank 1: 4000h - 5FFFh
	Bank 2: 6000h - 7FFFh
	Bank 3: 8000h - 9FFFh
	Bank 4: A000h - BFFFh

And the address to change banks:

	Bank 1: <none>
	Bank 2: 6000h - 7FFFh (6000h used)
	Bank 3: 8000h - 9FFFh (8000h used)
	Bank 4: A000h - BFFFh (A000h and B000h used)

Bank 1 is always fixed to the first block (0). The others can be changed by writing to any address in their memory area. This is important for emulators because the game uses A000h and B000h to switch the last bank.

The D/A converter is really simple. To write data to it, simply write to any address between 5000h and 5FFFh. This is interpreted als 8 bit unsigned wave data, which is directly sent to the D/A (no buffering of any kind). Value 80h is centre (no amplitude), FFh max positive and 00h max negative.

The ROM file at ftp.komkon.org has been modified to make it run as konami5 type. The real one would not do this, since it writes data to 5000h (which switches bank 1 in the konami5 setup), and it expects A000h to do the same as B000h.

<a id="DOS2"></a>
# MSX DOS 2 cartridge

The MSX DOS 2 cartridge contains 64Kb which is mapped. It can only be used in page 1. The mapper is 16Kb and can be modified through address 6000h which is the unofficial address. The official uses 7FFEh in stead of 6000h.

I've only been able to check this on an unofficial DOS2 cartridge.

<a id="HYDLIDE"></a>
# Hydlide 2

Hydlide has 2kB of SRAM, and 128kB ROM. The mapping is much like the Ascii/16Kb type. Use value 10h to select the SRAM area; if it selected in page 1, it can't be modified. If it is selected in page 2, it is possible. The whole 16Kb of the page is a repetition if the 2 kB SRAM (=800h bytes).

<a id="KonamiWithoutSCC16K"></a>
# Konami without SCC 16Kb

Does not exist. Games using it are hacked from the ASCII 16Kb mapper.

<a id="FMPAC"></a>
# FM PAC

This about the original FM PAC, the Panasonic. This cartridge has 64kB ROM and 8kB SRAM. The ROM is in memory area 4000h-7FFFh. By writing to address 7FF7h, you can switch 16kB blocks (switches the whole ROM area). This address is read/write but since there are only 4 pages, bits 2-7 are always zero.

Special address (always active):

	7FF4h: write YM-2413 register port (write only)
	7FF5h: write YM-2413 data port (write only)
	7FF6h: activate OPLL (read/write)
	7FF7h: ROM page (read/write)

Address 7FF6h also has a special function, but for the sound chip. You have to set bit 0 to active the OPLL. Only bit 4 and 0 can be set or reset, the other bits are always 0. I don't know what bit 4 is for.

The SRAM can be actived in only this way: write 4Dh to 5FFEh and 69h to 5FFFh. Now 8kB SRAM is active in 4000h - 5FFFh, and the last two bytes are the two values you have just written. If you write any other value than the two above, the SRAM will disappear, and the usual ROM will appear. When the SRAM is active 6000h - 7FFFh is FFh except for 7FF7h and 7FF6h.

The .pac data files have the following format: first a header ("PAC2 BACKUP DATA") and then the 1FFEh bytes data.

<a id="SYNTH"></a>
# Konami's Synthesizer

This cartridge has no special mapper; it's a standard 32kB ROM (4000h - BFFFh). The special feature is the DAC; it is unbuffered 8 bit unsigned PCM like Matjusushi. You can write to it by writing to any address in the ranges 4000h - 400Fh, 4020h - 402Fh, 4040h - 404Fh, repeated up to 7FE0h - 7FEFh. It's verified on the real cartridge.

<a id="CROSS"></a>
# Cross Blaim

This is a 64Kb ROM, in 16Kb pages. I haven't ever seen/tested the real cartridge, so maybe my dump is bad; however, from the code I found that the 16Kb in 8000h - BFFFh can be changed by writing to 4045h. This is implemented in MESS and it works fine.

<a id="SLR"></a>
# Super Lode Runner

Super Lode Runner is a rather weird cartridge. Again, never seen or tested the real cartridge so the ROM dump may be bad. However the ROM is writing to address 0000h (yes 0) without selecting it's own ROM in that page. So if this is correct, it's ignoring the slot-select signal. This game only seem to use the ROM in page 2 (8000h - BFFFh). By writing to address 0, the memory is changed in 16Kb blocks.

<a id="PLAY"></a>
# Playball

This is a 32Kb ROM cartridge from Sony. Supposedly it has a DAC. All I could find in the source was a few writes to address BFFFh, in it's own address space. It's also reading it. Since it's just a few bytes, seemingly ranging from 0-7, it's not a normal DAC. What this address actually does is a mystery to me, any help here would be most appreciated.

<a id="M6480G"></a>
# 64-in-1 and 80-in-1

This Korean ROM cartridge is a 512Kb ROM with a lot of games on it.

Since the size of the mapper is 8Kb, the memory banks are:

	Bank 1: 4000h - 5FFFh
	Bank 2: 6000h - 7FFFh
	Bank 3: 8000h - 9FFFh
	Bank 4: A000h - BFFFh

And the address to change banks:

	Bank 1: 4000h
	Bank 2: 4001h
	Bank 3: 4002h
	Bank 4: 4003h

This information comes from the emulator sources which already have the mapper emulated and the contents of the ROM image. It hasn't been verified with any original version.

<a id="M90G"></a>
# 90-in-1

This Korean ROM cartridge is a 1024Kb ROM with a lot of games on it. It's not a standard mapper, as it uses an I/O port to control it: 77h

Since the size of the mapper is 16Kb, the memory banks are:

	Bank 1: 4000h - 7FFFh
	Bank 2: 8000h - BFFFh

The value to write to the I/O port is formatted like this:

	bit      |  0 |  1 |  2 |  3 |  4 |  5 |    6   |      7     |
	--------------------------------------------------------------
	function | R0 | R1 | R2 | R3 | R4 | R5 | Mirror | Sequential |

If bit 7 is reset, bits 0 - 5 select the ROM page which will be mirrored in both bank 1 and 2. Bit 6 is ignored in this case. If bit 7 is set, bits 0 - 5 select the ROM page which will select the ROM page which will be set in bank 1. The next ROM page is selected in bank 2. When bit 6 is set bank 2 will select the same ROM page as bank 0, though the two 8Kb area's of that ROM page will be swapped.

This information comes from the emulator sources which already have the mapper emulated and the contents of the ROM image. It hasn't been verified with any original version.

<a id="M126G"></a>
# 126-in-1

This Korean ROM cartridge is a 2048Kb ROM with a lot of games on it.

Since the size of the mapper is 16Kb, the memory banks are:

	Bank 1: 4000h - 7FFFh
	Bank 2: 8000h - BFFFh

And the address to change banks:

	Bank 1: 4000h
	Bank 2: 4001h

This information comes from the emulator sources which already have the mapper emulated and the contents of the ROM image. It hasn't been verified with any original version.
