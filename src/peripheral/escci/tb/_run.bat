vlib work
IF ERRORLEVEL 1 GOTO error
vcom dpram.vhd
IF ERRORLEVEL 1 GOTO error
vcom ..\scc_wave.vhd
IF ERRORLEVEL 1 GOTO error
vcom ..\escci.vhd
IF ERRORLEVEL 1 GOTO error
vcom tb_escci.vht
IF ERRORLEVEL 1 GOTO error
vsim -t ns tb -do all.do
IF ERRORLEVEL 1 GOTO error

goto ok

:error
echo Error!
pause

:ok
