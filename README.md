# msx1fpga
MSX1 cloned in FPGA

This project is an MSX1 cloned in FPGA, with some parts of the OCM project.

Specifications:

- MSX1 50Hz or 60Hz;
- 128K RAM Mapper;
- 128K Nextor (MSX-DOS2 evolution) ROM with SD driver;
- 256K of RAM to Megaram SCC/SCC+ from OCM project;
- Keyboard map reconfigurable;
- Simple switched I/O ports (no software yet);
- Multiple boards;
- 15/31KHz configurable.
- Scanlines configurable.
- HDMI output in some boards.

In the project there is a loader to boot and load ROMs and configuration from SD card.

The "CONFIG.TXT" configuration file is self-explanatory.

## Use

Format an SD Card in FAT16 (max 4GB), put the NEXTOR.SYS and COMMAND2.COM files, create a directory called 'MSX1FGPA', put the CONFIG.TXT and KEYMAPs in this directory. Put ROMs and Utilities in the SD Card for MSX use.
PS: Due to a Nextor bug, FAT16 partitions with ID 0x0E are not recognized, only with ID 0x06.

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

Uses the ROMLOAD utility for ROM loading and executing (simple, megaroms or SCC).
