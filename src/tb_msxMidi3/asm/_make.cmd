sjasmplus test1.asm
fillfile test1.bin 8192
romgen test1.bin ipl_rom a r > ..\ipl_rom.vhd
pause