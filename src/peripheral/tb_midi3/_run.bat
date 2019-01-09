vlib work
IF ERRORLEVEL 1 GOTO error

vcom ..\i8253\counter.vhd
IF ERRORLEVEL 1 GOTO error
vcom ..\i8253\timer.vhd
IF ERRORLEVEL 1 GOTO error
vcom ..\i8251\clk_divider.vhd
IF ERRORLEVEL 1 GOTO error
vcom ..\i8251\UART_Receiver.vhd
IF ERRORLEVEL 1 GOTO error
vcom ..\i8251\UART_transmitter.vhd
IF ERRORLEVEL 1 GOTO error
vcom ..\i8251\UART.vhd
IF ERRORLEVEL 1 GOTO error
vcom ..\Midi3.vhd
IF ERRORLEVEL 1 GOTO error

vcom tb_midi.vht
IF ERRORLEVEL 1 GOTO error

vsim -t ns tb -do all.do
IF ERRORLEVEL 1 GOTO error

goto ok

:error
echo Error!
pause

:ok
