vlib work
IF ERRORLEVEL 1 GOTO error

vcom ..\counter.vhd
IF ERRORLEVEL 1 GOTO error
vcom ..\timer.vhd
IF ERRORLEVEL 1 GOTO error

vcom tb_timer.vht
IF ERRORLEVEL 1 GOTO error

vsim -t ns tb -do all.do
IF ERRORLEVEL 1 GOTO error

goto ok

:error
echo Error!
pause

:ok
