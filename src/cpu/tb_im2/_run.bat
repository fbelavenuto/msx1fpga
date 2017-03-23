vlib work
vcom ..\t80_pack.vhd
vcom ..\t80_alu.vhd
vcom ..\t80_mcode.vhd
vcom ..\t80_reg.vhd
vcom ..\T80.vhd
vcom ..\T80a.vhd
vcom tb_T80.vht
vsim -t ns tb -do all.do
