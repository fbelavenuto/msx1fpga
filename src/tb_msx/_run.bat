rem goto pula

vlib work
IF ERRORLEVEL 1 GOTO error

vcom ..\msx_pack.vhd
IF ERRORLEVEL 1 GOTO error

vcom ..\clocks.vhd
IF ERRORLEVEL 1 GOTO error

vcom ..\ram\dpram.vhd
IF ERRORLEVEL 1 GOTO error
vcom ..\ram\spram.vhd
IF ERRORLEVEL 1 GOTO error

vcom ..\shared\fifo.vhd
IF ERRORLEVEL 1 GOTO error

vcom ..\audio\YM2149.vhd
IF ERRORLEVEL 1 GOTO error

vcom ..\cpu\t80_pack.vhd
IF ERRORLEVEL 1 GOTO error
vcom ..\cpu\t80_alu.vhd
IF ERRORLEVEL 1 GOTO error
vcom ..\cpu\t80_mcode.vhd
IF ERRORLEVEL 1 GOTO error
vcom ..\cpu\t80_reg.vhd
IF ERRORLEVEL 1 GOTO error
vcom ..\cpu\t80.vhd
IF ERRORLEVEL 1 GOTO error
vcom ..\cpu\t80a.vhd
IF ERRORLEVEL 1 GOTO error

vcom ..\peripheral\exp_slot.vhd
IF ERRORLEVEL 1 GOTO error
vcom ..\peripheral\pio.vhd
IF ERRORLEVEL 1 GOTO error
vcom ..\peripheral\romnextor.vhd
IF ERRORLEVEL 1 GOTO error
vcom ..\peripheral\spi.vhd
IF ERRORLEVEL 1 GOTO error
vcom ..\peripheral\swioports.vhd
IF ERRORLEVEL 1 GOTO error
vcom ..\peripheral\escci\scc_wave.vhd
IF ERRORLEVEL 1 GOTO error
vcom ..\peripheral\escci\escci.vhd
IF ERRORLEVEL 1 GOTO error
vcom ..\peripheral\memoryctl.vhd
IF ERRORLEVEL 1 GOTO error

vcom ..\video\vdp18\vdp18_pack-p.vhd
IF ERRORLEVEL 1 GOTO error
vcom ..\video\vdp18\vdp18_addr_mux.vhd
IF ERRORLEVEL 1 GOTO error
vcom ..\video\vdp18\vdp18_clk_gen.vhd
IF ERRORLEVEL 1 GOTO error
vcom ..\video\vdp18\vdp18_palette.vhd
IF ERRORLEVEL 1 GOTO error
vcom ..\video\vdp18\vdp18_col_mux.vhd
IF ERRORLEVEL 1 GOTO error
vcom ..\video\vdp18\vdp18_cpuio.vhd
IF ERRORLEVEL 1 GOTO error
vcom ..\video\vdp18\vdp18_ctrl.vhd
IF ERRORLEVEL 1 GOTO error
vcom ..\video\vdp18\vdp18_hor_vert.vhd
IF ERRORLEVEL 1 GOTO error
vcom ..\video\vdp18\vdp18_pattern.vhd
IF ERRORLEVEL 1 GOTO error
vcom ..\video\vdp18\vdp18_sprite.vhd
IF ERRORLEVEL 1 GOTO error
vcom ..\video\dblscan.vhd
IF ERRORLEVEL 1 GOTO error
vcom ..\video\vdp18\vdp18_core.vhd
IF ERRORLEVEL 1 GOTO error

:pula

vcom ipl_rom.vhd
IF ERRORLEVEL 1 GOTO error

vcom ..\msx.vhd
IF ERRORLEVEL 1 GOTO error

vcom tb_msx.vht
IF ERRORLEVEL 1 GOTO error
vsim -t ns tb -do all.do
IF ERRORLEVEL 1 GOTO error

goto ok

:error
echo Error!
pause

:ok
del /q wlft*
