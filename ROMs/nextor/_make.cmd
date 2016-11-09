@echo off
sjasmplus --lst=Driver.lst Driver.asm
mknexrom Nextor-2.1-alpha2.base.dat NEXTOR.ROM /d:driver.bin /m:Mapper.ASCII16.bin
echo.
pause