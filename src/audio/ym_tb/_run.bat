vlib work
IF ERRORLEVEL 1 GOTO error

vcom ..\YM2149.vhd
IF ERRORLEVEL 1 GOTO error

vcom tb_ym2149.vht
IF ERRORLEVEL 1 GOTO error

vsim -t ns tb -do all.do
IF ERRORLEVEL 1 GOTO error

goto ok

:error
echo Error!
pause

:ok
