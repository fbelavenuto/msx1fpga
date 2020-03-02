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

Some keys and their functions:

 - Print Screen: Toggle VGA mode;
 - Scroll Lock: Toggle Scanlines mode;
 - Pause/Break: Toggle 50/60 Hz Vertical frequency
 - F11: Toggle Turbo mode;
 - CTRL+ALT+DEL: Soft Reset;
 - CTRL+ALT+F12: Hard Reset;
 - CTRL+ALT+BACKSPACE: For ZX-Uno based boards only: reload FPGA;
 - Left ALT: MSX GRAPH key;
 - Right ALT: MSX CODE key;
 - Page Up: MSX SELECT key;
 - END: MSX STOP key.
 
The joystick port for Multicore Boards are mapped as JoyMega, and configured to use a SEGA Genesis/Megadrive joypad. Other boards are mapped as single joystick/joypad with 2 buttons.

To go to the BASIC from the MSX-DOS you must execute the BASIC command.

To go to MSX-DOS from BASIC, CALL SYSTEM must be executed.


NOTES:

- In BASIC use the "CTRL + STOP" keys to stop the execution of a program. The MSX STOP key is mapped to the END key of the PC.
- To change the video mode by switching between 50HZ and 60HZ, and thus play at correct speed to PAL games, such as "Invasion of the Zombie Monsters", through the VGA output, you can use the program "DISPLAY.COM", which is to download in this thread (https://www.msx.org/forum/msx-talk/software/dos-tool-to-switch-from-50-to-60hz).


## SOFTWARE LOADING:

### A.- .ROM files

They are dumps of programs in cartridges.

Uses the SROM.COM utility to load the ROMs file. Ex: SROM NEMESIS1.ROM

### B.- .DSK files

They are dumps of programs in disketes.

Uses the SRI.COM utility to emulate a disk. Ex: SRI GAME.DSK

### C.- .CAS files

They are images with the content of the audio tapes. The way to use them is very well explained in the article Load CAS files with MegaFlashROM and an MSX-2 (hhttps://programbytes48k.wordpress.com/2015/11/19/cargar-archivos-cas-con-megaflashrom-y-un-msx-2/).

The **LOADCAX** and **LOADCAXX** files are located in the BIN folder on the diskette http://www.msxcartridgeshop.com/bin/ROMDISK.DSK of the MegaFlashROM SCC+ SD.

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

Do not forget to disable TURBO to load a real K7 audio.

It is perfectly explained in the article How to load programs in MSX (https://programbytes48k.wordpress.com/2012/01/04/como-cargar-programas-en-msx/).

In the (http://www.vintagenarios.com/hilo-oficial-wavs-msx-t1997.html) forum of **Vintagenarios** you can find many MSX programs in WAV format that can be loaded by audio.
