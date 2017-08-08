goto pula

vlib work
IF ERRORLEVEL 1 GOTO error
vcom ..\vdp18\vdp18_pack-p.vhd
IF ERRORLEVEL 1 GOTO error
vcom ..\vdp18\vdp18_addr_mux.vhd
IF ERRORLEVEL 1 GOTO error
vcom ..\vdp18\vdp18_clk_gen.vhd
IF ERRORLEVEL 1 GOTO error
vcom ..\vdp18\vdp18_palette.vhd
IF ERRORLEVEL 1 GOTO error
vcom ..\vdp18\vdp18_col_mux.vhd
IF ERRORLEVEL 1 GOTO error

:pula

vcom ..\vdp18\vdp18_cpuio.vhd
IF ERRORLEVEL 1 GOTO error
vcom ..\vdp18\vdp18_ctrl.vhd
IF ERRORLEVEL 1 GOTO error
vcom ..\vdp18\vdp18_hor_vert.vhd
IF ERRORLEVEL 1 GOTO error
vcom ..\vdp18\vdp18_pattern.vhd
IF ERRORLEVEL 1 GOTO error
vcom ..\vdp18\vdp18_sprite.vhd
IF ERRORLEVEL 1 GOTO error
vcom ..\..\ram\dpram.vhd
IF ERRORLEVEL 1 GOTO error
vcom ..\dblscan.vhd
IF ERRORLEVEL 1 GOTO error
vcom ..\vdp18\vdp18_core.vhd
IF ERRORLEVEL 1 GOTO error

vcom tb_vdp18.vht
IF ERRORLEVEL 1 GOTO error
vsim -t ns tb -do all.do
IF ERRORLEVEL 1 GOTO error

goto ok

:error
echo Error!
pause

:ok
