onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb/por_s
add wave -noupdate /tb/reset_s
add wave -noupdate /tb/clock_s
add wave -noupdate /tb/clock_psg_en_s
add wave -noupdate /tb/clock_vdp_s
add wave -noupdate -radix hexadecimal /tb/ram_addr_s
add wave -noupdate /tb/ram_ce_s
add wave -noupdate -radix hexadecimal /tb/bus_addr_s
add wave -noupdate -radix hexadecimal /tb/bus_data_i_s
add wave -noupdate -radix hexadecimal /tb/bus_data_o_s
add wave -noupdate /tb/bus_int_n_s
add wave -noupdate /tb/bus_iorq_n_s
add wave -noupdate /tb/bus_m1_n_s
add wave -noupdate /tb/bus_mreq_n_s
add wave -noupdate /tb/bus_nmi_n_s
add wave -noupdate /tb/bus_rd_n_s
add wave -noupdate /tb/bus_sltsl1_n_s
add wave -noupdate /tb/bus_sltsl2_n_s
add wave -noupdate /tb/bus_wait_n_s
add wave -noupdate /tb/bus_wr_n_s
add wave -noupdate -radix decimal /tb/audio_psg_s
add wave -noupdate -radix decimal /tb/audio_scc_s
add wave -noupdate /tb/beep_s
add wave -noupdate /tb/spi_cs_n_s
add wave -noupdate /tb/spi_sclk_s
add wave -noupdate /tb/spi_miso_s
add wave -noupdate /tb/spi_mosi_s
add wave -noupdate /tb/u_target/escci/SccWave/clock_i
add wave -noupdate /tb/u_target/escci/SccWave/clock_en_i
add wave -noupdate /tb/u_target/escci/SccWave/cs_i
add wave -noupdate /tb/u_target/escci/SccWave/wr_i
add wave -noupdate -radix hexadecimal /tb/u_target/escci/SccWave/addr_i
add wave -noupdate -radix hexadecimal /tb/u_target/escci/SccWave/data_i
add wave -noupdate -radix hexadecimal /tb/u_target/escci/SccWave/data_o
add wave -noupdate -radix hexadecimal /tb/u_target/escci/SccWave/w_wave_adr
add wave -noupdate -radix hexadecimal /tb/u_target/escci/SccWave/w_wave_data_s
add wave -noupdate /tb/u_target/escci/SccWave/w_wave_we
add wave -noupdate /tb/clock_cpu_s
add wave -noupdate /tb/clock_3m_s
add wave -noupdate /tb/turbo_on_k_s
add wave -noupdate /tb/turbo_on_s
add wave -noupdate -radix hexadecimal /tb/u_target/cpu_addr_s
add wave -noupdate -radix hexadecimal /tb/u_target/d_from_cpu_s
add wave -noupdate /tb/u_target/rfsh_n_s
add wave -noupdate /tb/u_target/iorq_n_s
add wave -noupdate /tb/u_target/rd_n_s
add wave -noupdate /tb/u_target/wr_n_s
add wave -noupdate /tb/u_target/mreq_n_s
add wave -noupdate /tb/u_target/m1_n_s
add wave -noupdate /tb/u_target/m1_wait_n_s
add wave -noupdate /tb/u_target/m1_wait_qn_s
add wave -noupdate /tb/u_target/wait_n_s
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {99040 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 264
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {93348 ns} {100596 ns}
