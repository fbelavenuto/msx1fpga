@echo off
sjasmplus --lst=Driver.lst Driver.asm
IF ERRORLEVEL 1 GOTO error

rem mknexrom Nextor-2.1-alpha2.base.dat NEXTOR.ROM /d:driver.bin /m:Mapper.ASCII16.bin
mknexrom Nextor-2.0.5-beta1.base.dat NEXTOR.ROM /d:driver.bin /m:Mapper.ASCII16.bin
IF ERRORLEVEL 1 GOTO error
copy NEXTOR.ROM ..\..\SD\MSX1FPGA
goto ok

:error
echo Error!

:ok
echo.
pause