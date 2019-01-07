vlib work
IF ERRORLEVEL 1 GOTO error

vcom ..\clk_divider.vhd
IF ERRORLEVEL 1 GOTO error
vcom ..\UART_Receiver.vhd
IF ERRORLEVEL 1 GOTO error
vcom ..\UART_transmitter.vhd
IF ERRORLEVEL 1 GOTO error
vcom ..\UART.vhd
IF ERRORLEVEL 1 GOTO error

vcom tb_uart.vht
IF ERRORLEVEL 1 GOTO error

vsim -t ns tb -do all.do
IF ERRORLEVEL 1 GOTO error

goto ok

:error
echo Error!
pause

:ok
