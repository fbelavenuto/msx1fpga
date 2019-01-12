onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb/wait_n_s
add wave -noupdate /tb/reset_n_s
add wave -noupdate /tb/clock_s
add wave -noupdate /tb/clock_cpu_s
add wave -noupdate /tb/addr_s
add wave -noupdate /tb/cs_n_s
add wave -noupdate /tb/rd_n_s
add wave -noupdate /tb/wr_n_s
add wave -noupdate -radix hexadecimal /tb/data_s
add wave -noupdate -radix hexadecimal -childformat {{/tb/data_o_s(7) -radix hexadecimal} {/tb/data_o_s(6) -radix hexadecimal} {/tb/data_o_s(5) -radix hexadecimal} {/tb/data_o_s(4) -radix hexadecimal} {/tb/data_o_s(3) -radix hexadecimal} {/tb/data_o_s(2) -radix hexadecimal} {/tb/data_o_s(1) -radix hexadecimal} {/tb/data_o_s(0) -radix hexadecimal}} -subitemconfig {/tb/data_o_s(7) {-height 15 -radix hexadecimal} /tb/data_o_s(6) {-height 15 -radix hexadecimal} /tb/data_o_s(5) {-height 15 -radix hexadecimal} /tb/data_o_s(4) {-height 15 -radix hexadecimal} /tb/data_o_s(3) {-height 15 -radix hexadecimal} /tb/data_o_s(2) {-height 15 -radix hexadecimal} /tb/data_o_s(1) {-height 15 -radix hexadecimal} /tb/data_o_s(0) {-height 15 -radix hexadecimal}} /tb/data_o_s
add wave -noupdate /tb/dtr_n_s
add wave -noupdate /tb/rts_n_s
add wave -noupdate /tb/rxd_s
add wave -noupdate /tb/txd_s
add wave -noupdate /tb/clock_c_s
add wave -noupdate -divider Internal
add wave -noupdate /tb/u_target/access_s
add wave -noupdate /tb/u_target/datawrite_s
add wave -noupdate /tb/u_target/ctrlwrite_s
add wave -noupdate /tb/u_target/last_cs1_s
add wave -noupdate /tb/u_target/last_cs2_s
add wave -noupdate /tb/u_target/regidx_q
add wave -noupdate -radix hexadecimal /tb/u_target/ctrl_r
add wave -noupdate -radix hexadecimal /tb/u_target/mode_r
add wave -noupdate -radix hexadecimal /tb/u_target/status_s
add wave -noupdate /tb/u_target/baud_sel_a
add wave -noupdate /tb/u_target/char_len_a
add wave -noupdate /tb/u_target/dtr_a
add wave -noupdate /tb/u_target/rts_a
add wave -noupdate /tb/u_target/baudclk_s
add wave -noupdate -radix hexadecimal /tb/u_target/tx_data_s
add wave -noupdate /tb/u_target/clr_txe_s
add wave -noupdate /tb/u_target/tx_empty_s
add wave -noupdate /tb/u_target/tx_en_a
add wave -noupdate -divider TX
add wave -noupdate /tb/u_target/XMIT/bclk_dlayed_s
add wave -noupdate /tb/u_target/XMIT/bclk_rising_s
add wave -noupdate /tb/u_target/XMIT/bitcount_q
add wave -noupdate /tb/u_target/XMIT/bitmax_s
add wave -noupdate /tb/u_target/XMIT/clr_s
add wave -noupdate /tb/u_target/XMIT/inc_s
add wave -noupdate /tb/u_target/XMIT/shift_tsr_s
add wave -noupdate /tb/u_target/XMIT/load_tsr_s
add wave -noupdate /tb/u_target/XMIT/start_s
add wave -noupdate /tb/u_target/XMIT/state_s
add wave -noupdate /tb/u_target/XMIT/nextstate_s
add wave -noupdate -radix hexadecimal /tb/u_target/XMIT/tsr_q
add wave -noupdate -divider RX
add wave -noupdate /tb/u_target/rx_data_q
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {19321 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 198
configure wave -valuecolwidth 41
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
WaveRestoreZoom {0 ns} {74304 ns}
