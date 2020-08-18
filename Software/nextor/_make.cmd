@echo off
echo Making no HWDS
sjasmplus --nologo -DHWDS=0 --lst=Driver.lst Driver.asm
IF ERRORLEVEL 1 GOTO error

mknexrom Nextor-2.1.0.base.dat NEXTOR.ROM /d:driver.bin /m:Mapper.ASCII16.bin
IF ERRORLEVEL 1 GOTO error
copy NEXTOR.ROM ..\..\Support\SD\MSX1FPGA

echo Making HWDS
sjasmplus --nologo -DHWDS=1 --lst=Driver.lst Driver.asm
IF ERRORLEVEL 1 GOTO error

mknexrom Nextor-2.1.0.base.dat NEXTORH.ROM /d:driver.bin /m:Mapper.ASCII16.bin
IF ERRORLEVEL 1 GOTO error
copy NEXTORH.ROM ..\..\Support\SD\MSX1FPGA
goto ok

:error
echo Error!

:ok
echo.
pause
