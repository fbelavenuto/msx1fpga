@echo off
sjasmplus --lst=Driver.lst Driver.asm
IF ERRORLEVEL 1 GOTO error

mknexrom Nextor-2.0.5-beta1.base.dat NEXTORH.ROM /d:driver.bin /m:Mapper.ASCII16.bin
IF ERRORLEVEL 1 GOTO error
copy NEXTORH.ROM ..\..\SD\MSX1FPGA
goto ok

:error
echo Error!

:ok
echo.
pause