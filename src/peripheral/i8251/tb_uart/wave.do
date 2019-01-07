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
add wave -noupdate /tb/dtr_n_s
add wave -noupdate /tb/rts_n_s
add wave -noupdate /tb/rxd_s
add wave -noupdate /tb/txd_s
add wave -noupdate -divider Internal
add wave -noupdate -radix hexadecimal /tb/u_target/status_s
add wave -noupdate /tb/u_target/isread_s
add wave -noupdate /tb/u_target/iswrite_s
add wave -noupdate /tb/u_target/load_mode_s
add wave -noupdate /tb/u_target/load_ctrl_s
add wave -noupdate /tb/u_target/modectrl_q
add wave -noupdate /tb/u_target/softreset_q
add wave -noupdate /tb/u_target/tx_en_q
add wave -noupdate /tb/u_target/rx_en_q
add wave -noupdate /tb/u_target/baud_sel_q
add wave -noupdate /tb/u_target/char_len_q
add wave -noupdate /tb/u_target/stop_bits_q
add wave -noupdate /tb/u_target/err_reset_q
add wave -noupdate /tb/u_target/rts_q
add wave -noupdate /tb/u_target/dtr_q
add wave -noupdate -divider TX
add wave -noupdate /tb/u_target/baudclk_s
add wave -noupdate /tb/u_target/txd_empty_s
add wave -noupdate /tb/u_target/setTxE_s
add wave -noupdate /tb/u_target/loadTxD_s
add wave -noupdate /tb/u_target/txd_ready_s
add wave -noupdate /tb/u_target/XMIT/state_s
add wave -noupdate /tb/u_target/XMIT/nextstate_s
add wave -noupdate /tb/u_target/XMIT/Bclk_dlayed
add wave -noupdate /tb/u_target/XMIT/Bclk_rising
add wave -noupdate /tb/u_target/XMIT/bitcount_q
add wave -noupdate -radix unsigned /tb/u_target/XMIT/bitmax_s
add wave -noupdate /tb/u_target/XMIT/inc_s
add wave -noupdate /tb/u_target/XMIT/loadTSR
add wave -noupdate /tb/u_target/XMIT/shftTSR
add wave -noupdate /tb/u_target/XMIT/start_s
add wave -noupdate -radix hexadecimal /tb/u_target/XMIT/tdr_q
add wave -noupdate -radix hexadecimal /tb/u_target/XMIT/tsr_q
add wave -noupdate -divider RX
add wave -noupdate /tb/u_target/rx_data_q
add wave -noupdate /tb/u_target/clrRxR_s
add wave -noupdate /tb/u_target/frame_err_q
add wave -noupdate /tb/u_target/overrun_err_q
add wave -noupdate /tb/u_target/parity_err_q
add wave -noupdate /tb/u_target/parity_q
add wave -noupdate /tb/u_target/setFE_s
add wave -noupdate /tb/u_target/setOE_s
add wave -noupdate /tb/u_target/RxReady_s
add wave -noupdate /tb/u_target/setPE_s
add wave -noupdate /tb/u_target/setRxR_s
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {339021 ns} 0}
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
WaveRestoreZoom {0 ns} {1188256 ns}
