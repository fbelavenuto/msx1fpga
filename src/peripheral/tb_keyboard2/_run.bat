vlib work
IF ERRORLEVEL 1 GOTO error

vcom ..\ps2_iobase.vhd
IF ERRORLEVEL 1 GOTO error

vcom ..\keymap.vhd
IF ERRORLEVEL 1 GOTO error

vcom ..\keyboard.vhd
IF ERRORLEVEL 1 GOTO error

vcom tb_keyboard.vht
IF ERRORLEVEL 1 GOTO error

vsim -t ns tb -do all.do
IF ERRORLEVEL 1 GOTO error

goto ok

:error
echo Error!
pause

:ok
