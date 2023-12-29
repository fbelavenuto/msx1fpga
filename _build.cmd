@echo off

echo Building software
docker run --rm -it -e TZ=America/Sao_Paulo -v %cd%:/src fbelavenuto/8bitcompilers make -f Makefile-software
IF ERRORLEVEL 1 GOTO error

mkdir _BINs

echo Building Xilinx FPGA bitstreams
docker run --rm -it --mac-address 08:00:27:68:c9:35 -e TZ=America/Sao_Paulo -v %cd%:/workdir fbelavenuto/xilinxise make -f Makefile-xilinx
IF ERRORLEVEL 1 GOTO error

echo Building Altera FPGA bitstreams
docker run --rm -it --mac-address 00:01:02:03:04:05 -e TZ=America/Sao_Paulo -v %cd%:/workdir fbelavenuto/alteraquartus make -f Makefile-altera
IF ERRORLEVEL 1 GOTO error

goto ok

:error
echo Ocorreu algum erro!
:ok
echo.
pause
