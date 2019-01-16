onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb/reset_s
add wave -noupdate /tb/wait_n_s
add wave -noupdate /tb/clock_s
add wave -noupdate /tb/clock_cpu_s
add wave -noupdate /tb/addr_s
add wave -noupdate -radix hexadecimal /tb/data_i_s
add wave -noupdate -radix hexadecimal -childformat {{/tb/data_o_s(7) -radix hexadecimal} {/tb/data_o_s(6) -radix hexadecimal} {/tb/data_o_s(5) -radix hexadecimal} {/tb/data_o_s(4) -radix hexadecimal} {/tb/data_o_s(3) -radix hexadecimal} {/tb/data_o_s(2) -radix hexadecimal} {/tb/data_o_s(1) -radix hexadecimal} {/tb/data_o_s(0) -radix hexadecimal}} -subitemconfig {/tb/data_o_s(7) {-height 15 -radix hexadecimal} /tb/data_o_s(6) {-height 15 -radix hexadecimal} /tb/data_o_s(5) {-height 15 -radix hexadecimal} /tb/data_o_s(4) {-height 15 -radix hexadecimal} /tb/data_o_s(3) {-height 15 -radix hexadecimal} /tb/data_o_s(2) {-height 15 -radix hexadecimal} /tb/data_o_s(1) {-height 15 -radix hexadecimal} /tb/data_o_s(0) {-height 15 -radix hexadecimal}} /tb/data_o_s
add wave -noupdate /tb/cs_s
add wave -noupdate /tb/rd_s
add wave -noupdate /tb/wr_s
add wave -noupdate /tb/dtr_n_s
add wave -noupdate /tb/rts_n_s
add wave -noupdate /tb/rxd_s
add wave -noupdate /tb/txd_s
add wave -noupdate -divider Internal
add wave -noupdate /tb/u_target/access_s
add wave -noupdate /tb/u_target/last_read_s
add wave -noupdate /tb/u_target/aread_s
add wave -noupdate /tb/u_target/last_write_s
add wave -noupdate /tb/u_target/awrite_s
add wave -noupdate -radix hexadecimal /tb/u_target/mode_r
add wave -noupdate -radix hexadecimal /tb/u_target/ctrl_r
add wave -noupdate -radix hexadecimal /tb/u_target/baud_r
add wave -noupdate -radix hexadecimal /tb/u_target/status_s
add wave -noupdate -divider TX
add wave -noupdate -radix hexadecimal /tb/u_target/txfifo_data_s
add wave -noupdate /tb/u_target/txfifo_empty_s
add wave -noupdate /tb/u_target/txfifo_full_s
add wave -noupdate /tb/u_target/txfifo_rd_s
add wave -noupdate /tb/u_target/txfifo_wr_s
add wave -noupdate -divider RX
add wave -noupdate -radix hexadecimal /tb/u_target/rxfifo_data_s
add wave -noupdate /tb/u_target/rxfifo_empty_s
add wave -noupdate /tb/u_target/rxfifo_full_s
add wave -noupdate /tb/u_target/rxfifo_rd_s
add wave -noupdate /tb/u_target/rxfifo_wr_s
add wave -noupdate -divider uart_tx
add wave -noupdate /tb/u_target/tx/reset_i
add wave -noupdate /tb/u_target/tx/clock_i
add wave -noupdate /tb/u_target/tx/char_len_i
add wave -noupdate /tb/u_target/tx/parity_i
add wave -noupdate /tb/u_target/tx/stop_bits_i
add wave -noupdate -radix unsigned /tb/u_target/tx/baud_i
add wave -noupdate /tb/u_target/tx/baudr_cnt_q
add wave -noupdate /tb/u_target/tx/bit_cnt_q
add wave -noupdate /tb/u_target/tx/bitmax_s
add wave -noupdate /tb/u_target/tx/tx_empty_i
add wave -noupdate -radix hexadecimal /tb/u_target/tx/data_i
add wave -noupdate /tb/u_target/tx/state_s
add wave -noupdate /tb/u_target/tx/max_cnt_s
add wave -noupdate /tb/u_target/tx/fifo_rd_o
add wave -noupdate -radix hexadecimal /tb/u_target/tx/shift_q
add wave -noupdate /tb/u_target/tx/txd_o
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {4030 ns} 0}
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
WaveRestoreZoom {0 ns} {37152 ns}
