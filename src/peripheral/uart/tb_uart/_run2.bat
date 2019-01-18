vlib work
IF ERRORLEVEL 1 GOTO error

vcom ..\..\..\shared\fifo.vhd
IF ERRORLEVEL 1 GOTO error
vcom ..\uart_rx.vhd
IF ERRORLEVEL 1 GOTO error
vcom ..\uart_tx.vhd
IF ERRORLEVEL 1 GOTO error
vcom ..\uart.vhd
IF ERRORLEVEL 1 GOTO error

vcom tb_uart2.vht
IF ERRORLEVEL 1 GOTO error

vsim -t ns tb -do all.do
IF ERRORLEVEL 1 GOTO error

goto ok

:error
echo Error!
pause

:ok
