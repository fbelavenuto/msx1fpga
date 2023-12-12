@echo off

echo Updating docker image
docker pull fbelavenuto/8bitcompilers
docker pull fbelavenuto/xilinxise

echo Building software
docker run --rm -it -e TZ=America/Sao_Paulo -v %cd%:/src fbelavenuto/8bitcompilers make -f Makefile-software
IF ERRORLEVEL 1 GOTO error

echo Building FPGA bitstreams
docker run --rm -it --mac-address 08:00:27:68:c9:35 -e TZ=America/Sao_Paulo -v %cd%:/workdir fbelavenuto/xilinxise make -f Makefile-fpga
IF ERRORLEVEL 1 GOTO error

goto ok

:error
echo Ocorreu algum erro!
:ok
echo.
pause
