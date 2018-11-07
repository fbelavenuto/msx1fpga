# MSX1FPGA
MSX1 cloned in FPGA

This project is an MSX1 cloned in FPGA, with some parts of the OCM project.

Specifications:

- Multiple boards;
- MSX1 50Hz or 60Hz;
- RAM Mapper size configurable, depends on the board;
- 128K Nextor (MSX-DOS2 evolution) ROM with SD driver;
- Megaram SCC/SCC+ from OCM project (size configurable, depends on the board);
- Keyboard map reconfigurable;
- Simple switched I/O ports (no software yet);
- 15/31KHz configurable.
- Scanlines configurable.
- HDMI output on some boards.

In the project there is a loader (IPL) to boot and load ROMs and configuration from SD card.

The "CONFIG.TXT" configuration file is self-explanatory.

## Use instructions

Format an SD Card in FAT16 (max 4GB), unzip the file 'msx1_sd_files.zip' in the root directory from SD Card.

PS: Due to a Nextor bug, FAT16 partitions with ID 0x0E are not recognized, only with ID 0x06.

### IMPORTANT NOTE 2018.05.12: When you unzip the file 'msx1_sd_files.zip' the folder MSX1FPGA is created, and inside it is the file SPA.KMP with the definition of the keys for the Spanish keyboard. This definition contains numerous errors, for example, the quotes are not in place or it is impossible to get the closing parenthesis. You can get an alternative definition of the Spanish keyboard without those errors from this post (http://www.zxuno.com/forum/viewtopic.php?f=53&t=2087).

Some keys and their functions:

 - Print Screen: Toggle VGA mode;
 - Scroll Lock: Toggle Scanlines mode;
 - F11: Toggle Turbo mode;
 - CTRL+ALT+DEL = Soft Reset;
 - CTRL+ALT+F12 = Hard Reset;
 - CTRL+ALT+BACKSPACE = For ZX-Uno based boards only: reload FPGA;
 - Page Down = MSX CODE key;
 - Page Up = MSX SELECT key;
 - ALT = MSX GRAPH key;
 - END = MSX STOP key.
 
The joystick port is mapped as JoyMega, and configured to use a SEGA Genesis/Megadrive joypad.

To go to the BASIC from the MSX-DOS you must execute the BASIC command.

To go to MSX-DOS from BASIC, CALL SYSTEM must be executed.


NOTES:

- In BASIC use the "CTRL + STOP" keys to stop the execution of a program. The MSX STOP key is mapped to the END key of the PC.
- To change the video mode by switching between 50HZ and 60HZ, and thus play at correct speed to PAL games, such as "Invasion of the Zombie Monsters", through the VGA output, you can use the program "DISPLAY.COM", which is to download in this thread (https://www.msx.org/forum/msx-talk/software/dos-tool-to-switch-from-50-to-60hz).


## SOFTWARE LOADING:

### A.- .ROM files

They are dumps of programs in cartridges. For files of 48K or less, use the ODO.COM program (hOndonadas De hOstias).

#### ODO is a ROM loader for MSX1 and up, running MSX-DOS (supports MSX-DOS2 too). It can load and play ROM files up to 48K in RAM. ROMs that execute from page 0 are supported as well. 

You can download version 0.4 from here (http://msxbanzai.tni.nl/dev/software.html), and then place the file "ODO.COM" in the "\util" folder of the SD card.

For .ROM files larger than 48K, use the command **ROMLOAD**. It can be used in two ways:

 *1st*: "ROMLOAD file.ROM /S"  ("/S" force to the execution of the program),

 *2nd*: "file /S"  (the name of the .ROM file without the extension)

If the /S is not set it is necessary to carry out a Soft Reset (CTRL + ALT + DEL) in order to execute the program.

By default, the memory mapping system used is that of Konami5(SCC). In the case of non-Konami games, such as "Golvellius" or "el Abu Simbel Profanation", add a "/A" or "/1" switch - mapper ASCII8 and ASCII16 respectively - (one or the other is tested until finding the one that works). For example: ROMLOAD ascii8.rom /A /S

Anyway, in the folder "\util" of the SD there are 2 files: ROMLOAD.TXT with instructions on how to use this command, and ROMLOAD.LST with a list of games and the options that have to be used to load them.

### B.- .DSK files

There are two ways to do this, using the **EMUFILE** command or the **MAPDRV** command. Suppose that the disk of the program *Human Body: Circulatory System* is called "CH-CIRCU.DSK", we can load it in these two ways:

#### 1st - EMUFILE

```
EMUFILE CH-CIRCU.DSK -r
```

This command creates a file **NEXT_DSK.DAT** in the root directory of the SD card with the contents of the floppy disk, and the "-r" option forces a Soft Reset that will automatically restart the Nextor-DOS when it starts up again. the floppy disk.

Every time we start the computer, the floppy disk will be executed, unless we delete it. To avoid this, when starting up the computer we must press the "0" (zero) key, and that will not load the floppy disk. At that time we can delete the file with an ERASE NEXT_DSK.DAT or DEL NEXT_DSK.DAT.

To see all the options that the EMUFILE command has, execute it simply by typing its name. The command allows several diskettes to be mounted at the same time, useful, for example, for a multi-diskette game.

#### 2nd - MAPDRV

This command mounts the contents of the image of a floppy disk to a new disk drive. For example:

```
MAPDRV B: CH-CIRCU.DSK
```

Now we can go to unit B: and see the files. We see that there is an AUTOEXEC.BAS file, which we can simply run with AUTOEXEC, and the program already starts.


#### Important note 2018.05.13: There are diskette images that sometimes do not work, and it is possible that the same game has several versions. For example, in (http://www.planetemu.net/roms/msx-various-dsk?page=A) you will see up to 4 versions in .dsk of the game "La Abadía del Crimen". Only the one labeled "Abadia del Crimen, La (1988)(Opera Soft)(es)[a3]" has worked for me. A simple way to check if the .dsk image has any problem is to use the online MSX emulator WebMSX (http://webmsx.org), set it up as MSX 1, European or American, depending on what you want, and drag the .dsk file to test it. In the previous case, none of the other 3 versions of "La Abadía" worked for me, and only the one that worked on the WebMSX also worked on the ZX-Uno.

### C.- .CAS files

They are images with the content of the audio tapes. The way to use them is very well explained in the article Load CAS files with MegaFlashROM and an MSX-2 (hhttps://programbytes48k.wordpress.com/2015/11/19/cargar-archivos-cas-con-megaflashrom-y-un-msx-2/).

The **LOADCAX** and **LOADCAXX** files are located in the BIN folder on the diskette http://www.msxcartridgeshop.com/bin/ROMDISK.DSK of the MegaFlashROM SCC+ SD. As we have seen before, with MAPDRV we can access its content and extract them.

### D.- .BAS files

They are programs in BASIC that we can record in the SD, and also load them to execute them. From inside the BASIC we can type:

```
SAVE "A:HOLA.BAS"
```

to save the program, and with

```
LOAD "A:HOLA.BAS"
```

we recover it.

To know the differences between CSAVE, BSAVE and SAVE, or other commands to store and retrieve the information, you can consult this section (https://www.msx.org/wiki/Category:Disk_BASIC) with the Disk BASIC commands of the wiki from msx.org (https://www.msx.org/wiki/).

To load a .BAS file from Nextor-DOS, simply write its name with or without extension and press ENTER.


### E.- AUDIO IN

The core allows the loading of programs by audio. The way to do it is from BASIC with the commands:

```
RUN”CAS:”
```
or well:
```
BLOAD”CAS:”,R
```
or well:
```
LOAD”CAS:”,R
```

It is perfectly explained in the article How to load programs in MSX (https://programbytes48k.wordpress.com/2012/01/04/como-cargar-programas-en-msx/).

In the (http://www.vintagenarios.com/hilo-oficial-wavs-msx-t1997.html) forum of **Vintagenarios** you can find many MSX programs in WAV format that can be loaded by audio.
