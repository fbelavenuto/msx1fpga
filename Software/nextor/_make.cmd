@echo off
sjasmplus --lst=Driver.lst Driver.asm
IF ERRORLEVEL 1 GOTO error

mknexrom Nextor-2.1-alpha2.base.dat NEXTOR.ROM /d:driver.bin /m:Mapper.ASCII16.bin
rem mknexrom Nextor-2.0.4.base.dat NEXTOR.ROM /d:driver.bin /m:Mapper.ASCII16.bin
IF ERRORLEVEL 1 GOTO error
copy NEXTOR.ROM F:\MSX1FPGA
goto ok

:error
echo Error!

:ok
echo.
pause