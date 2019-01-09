onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb/reset_n_s
add wave -noupdate /tb/clock_s
add wave -noupdate /tb/clock_cpu_s
add wave -noupdate -radix unsigned /tb/addr_s
add wave -noupdate -radix hexadecimal /tb/data_i_s
add wave -noupdate -radix hexadecimal /tb/data_o_s
add wave -noupdate /tb/cs_n_s
add wave -noupdate /tb/rd_n_s
add wave -noupdate /tb/wr_n_s
add wave -noupdate /tb/int_n_s
add wave -noupdate /tb/tx_s
add wave -noupdate -divider Internal
add wave -noupdate /tb/u_target/clock_4m_s
add wave -noupdate /tb/u_target/dtr_s
add wave -noupdate /tb/u_target/rts_s
add wave -noupdate /tb/u_target/ffint_cs_n_s
add wave -noupdate /tb/u_target/ffint_n_s
add wave -noupdate /tb/u_target/ffint_q
add wave -noupdate /tb/u_target/ffint_wr_s
add wave -noupdate /tb/u_target/i8251_cs_n_s
add wave -noupdate /tb/u_target/i8253_cs_n_s
add wave -noupdate /tb/u_target/out0_s
add wave -noupdate /tb/u_target/out2_s
add wave -noupdate -divider i8251
add wave -noupdate /tb/u_target/serial/RxReady_s
add wave -noupdate /tb/u_target/serial/baud_sel_q
add wave -noupdate /tb/u_target/serial/baudclk_s
add wave -noupdate /tb/u_target/serial/char_len_q
add wave -noupdate /tb/u_target/serial/clrRxR_s
add wave -noupdate /tb/u_target/serial/dtr_q
add wave -noupdate /tb/u_target/serial/err_reset_q
add wave -noupdate /tb/u_target/serial/frame_err_q
add wave -noupdate /tb/u_target/serial/isread_s
add wave -noupdate /tb/u_target/serial/iswrite_s
add wave -noupdate /tb/u_target/serial/loadTxD_s
add wave -noupdate /tb/u_target/serial/load_ctrl_s
add wave -noupdate /tb/u_target/serial/load_mode_s
add wave -noupdate /tb/u_target/serial/load_s
add wave -noupdate /tb/u_target/serial/modectrl_q
add wave -noupdate /tb/u_target/serial/overrun_err_q
add wave -noupdate /tb/u_target/serial/parity_err_q
add wave -noupdate /tb/u_target/serial/parity_q
add wave -noupdate /tb/u_target/serial/rts_q
add wave -noupdate /tb/u_target/serial/rx_data_q
add wave -noupdate /tb/u_target/serial/rx_en_q
add wave -noupdate /tb/u_target/serial/setFE_s
add wave -noupdate /tb/u_target/serial/setOE_s
add wave -noupdate /tb/u_target/serial/setPE_s
add wave -noupdate /tb/u_target/serial/setRxR_s
add wave -noupdate /tb/u_target/serial/setTxE_s
add wave -noupdate /tb/u_target/serial/softreset_q
add wave -noupdate /tb/u_target/serial/status_s
add wave -noupdate /tb/u_target/serial/stop_bits_q
add wave -noupdate /tb/u_target/serial/tx_en_q
add wave -noupdate /tb/u_target/serial/txd_empty_s
add wave -noupdate /tb/u_target/serial/txd_ready_s
add wave -noupdate -divider i8253
add wave -noupdate /tb/u_target/tmr/port_a0_s
add wave -noupdate /tb/u_target/tmr/port_a2_s
add wave -noupdate /tb/u_target/tmr/port_a3_s
add wave -noupdate /tb/u_target/tmr/wr_s
add wave -noupdate /tb/u_target/tmr/cclk0_s
add wave -noupdate /tb/u_target/tmr/cclk2_s
add wave -noupdate /tb/u_target/tmr/cmd0_s
add wave -noupdate /tb/u_target/tmr/cmd2_s
add wave -noupdate /tb/u_target/tmr/cnt0_cs_s
add wave -noupdate -radix hexadecimal /tb/u_target/tmr/cnt0_data_from_s
add wave -noupdate /tb/u_target/tmr/cnt2_cs_s
add wave -noupdate -radix hexadecimal /tb/u_target/tmr/cnt2_data_from_s
add wave -noupdate -divider Count0
add wave -noupdate /tb/u_target/tmr/cnt0/clken_s
add wave -noupdate /tb/u_target/tmr/cnt0/cnt1_s
add wave -noupdate /tb/u_target/tmr/cnt0/cnt2_s
add wave -noupdate -radix hexadecimal /tb/u_target/tmr/cnt0/initial_q
add wave -noupdate /tb/u_target/tmr/cnt0/latched_q
add wave -noupdate /tb/u_target/tmr/cnt0/mode_q
add wave -noupdate /tb/u_target/tmr/cnt0/newcmd_q
add wave -noupdate /tb/u_target/tmr/cnt0/rd_q
add wave -noupdate /tb/u_target/tmr/cnt0/state_q
add wave -noupdate /tb/u_target/tmr/cnt0/strobe_q
add wave -noupdate -radix hexadecimal /tb/u_target/tmr/cnt0/value_q
add wave -noupdate -divider Count2
add wave -noupdate /tb/u_target/tmr/cnt2/clken_s
add wave -noupdate /tb/u_target/tmr/cnt2/cnt1_s
add wave -noupdate /tb/u_target/tmr/cnt2/cnt2_s
add wave -noupdate -radix hexadecimal /tb/u_target/tmr/cnt2/initial_q
add wave -noupdate /tb/u_target/tmr/cnt2/latched_q
add wave -noupdate /tb/u_target/tmr/cnt2/mode_q
add wave -noupdate /tb/u_target/tmr/cnt2/newcmd_q
add wave -noupdate /tb/u_target/tmr/cnt2/rd_q
add wave -noupdate /tb/u_target/tmr/cnt2/state_q
add wave -noupdate /tb/u_target/tmr/cnt2/strobe_q
add wave -noupdate -radix hexadecimal /tb/u_target/tmr/cnt2/value_q
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {49045 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 205
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
WaveRestoreZoom {0 ns} {1180416 ns}
