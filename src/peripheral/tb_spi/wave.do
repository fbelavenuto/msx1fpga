onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb/reset_s
add wave -noupdate /tb/clock_s
add wave -noupdate -divider Interface
add wave -noupdate /tb/addr_s
add wave -noupdate -radix hexadecimal /tb/data_i_s
add wave -noupdate -radix hexadecimal /tb/data_o_s
add wave -noupdate /tb/req_s
add wave -noupdate /tb/cs_n_s
add wave -noupdate /tb/rd_n_s
add wave -noupdate /tb/wr_n_s
add wave -noupdate -divider SD
add wave -noupdate /tb/sd_pres_n_s
add wave -noupdate /tb/sd_wp_s
add wave -noupdate /tb/spi_cs_n_s
add wave -noupdate /tb/spi_miso_s
add wave -noupdate /tb/spi_mosi_s
add wave -noupdate /tb/spi_sclk_s
add wave -noupdate -divider Internal
add wave -noupdate -radix unsigned /tb/u_target/counter_s
add wave -noupdate /tb/u_target/shift_r
add wave -noupdate /tb/u_target/port0_s
add wave -noupdate /tb/u_target/port1_r
add wave -noupdate /tb/u_target/read_ctrl_s
add wave -noupdate /tb/u_target/sck_delayed_s
add wave -noupdate /tb/u_target/sd_chg_q
add wave -noupdate /tb/u_target/sd_chg_s
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1875 ns} 0}
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
WaveRestoreZoom {0 ns} {6648 ns}
