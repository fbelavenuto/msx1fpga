onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb/reset_s
add wave -noupdate /tb/clock_s
add wave -noupdate /tb/clock_en_s
add wave -noupdate -radix unsigned /tb/clk_en/cnt_v
add wave -noupdate -divider Interface
add wave -noupdate -radix hexadecimal /tb/addr_s
add wave -noupdate -radix hexadecimal /tb/data_i_s
add wave -noupdate -radix hexadecimal /tb/data_o_s
add wave -noupdate /tb/sltsl_n_s
add wave -noupdate /tb/rd_n_s
add wave -noupdate /tb/wr_n_s
add wave -noupdate /tb/wait_n_s
add wave -noupdate -divider ROM
add wave -noupdate /tb/rom_cs_n_s
add wave -noupdate -radix hexadecimal /tb/rom_page_s
add wave -noupdate /tb/rom_wr_n_s
add wave -noupdate -divider SD
add wave -noupdate /tb/sd_pres_n_s
add wave -noupdate /tb/sd_wp_s
add wave -noupdate /tb/spi_cs_n_s
add wave -noupdate /tb/spi_miso_s
add wave -noupdate /tb/spi_mosi_s
add wave -noupdate /tb/spi_sclk_s
add wave -noupdate /tb/spi_has_data_s
add wave -noupdate -divider Internal
add wave -noupdate -radix unsigned /tb/u_target/counter_s
add wave -noupdate -radix hexadecimal /tb/u_target/shift_r
add wave -noupdate -radix hexadecimal /tb/u_target/status_s
add wave -noupdate -radix hexadecimal /tb/u_target/spidata_r
add wave -noupdate /tb/u_target/sck_delayed_s
add wave -noupdate /tb/u_target/sd_chg_q
add wave -noupdate /tb/u_target/sd_chg_s
add wave -noupdate /tb/u_target/ram_wr_n_s
add wave -noupdate /tb/u_target/spi_ctrl_cs_n_s
add wave -noupdate /tb/u_target/spi_data_cs_n_s
add wave -noupdate -radix hexadecimal /tb/u_target/wait_cnt_q
add wave -noupdate /tb/u_target/wait_n_s
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {20615 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 189
configure wave -valuecolwidth 48
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
WaveRestoreZoom {0 ns} {60864 ns}
