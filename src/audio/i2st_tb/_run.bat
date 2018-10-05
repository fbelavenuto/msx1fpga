vlib work
IF ERRORLEVEL 1 GOTO error
vcom ..\i2s_transmitter.vhd
IF ERRORLEVEL 1 GOTO error
vcom tb_i2s_transmitter.vht
IF ERRORLEVEL 1 GOTO error
vsim -t ns tb -do all.do
IF ERRORLEVEL 1 GOTO error

goto ok

:error
echo Error!
pause

:ok
