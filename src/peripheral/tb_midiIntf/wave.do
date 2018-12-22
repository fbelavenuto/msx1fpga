onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb/reset_s
add wave -noupdate /tb/clock_s
add wave -noupdate /tb/clock_cpu_s
add wave -noupdate /tb/addr_s
add wave -noupdate -radix hexadecimal /tb/data_i_s
add wave -noupdate -radix hexadecimal /tb/data_o_s
add wave -noupdate /tb/cs_n_s
add wave -noupdate /tb/rd_n_s
add wave -noupdate /tb/wr_n_s
add wave -noupdate /tb/int_n_s
add wave -noupdate /tb/wait_n_s
add wave -noupdate /tb/tx_s
add wave -noupdate -divider Internal
add wave -noupdate /tb/u_target/int_en_q
add wave -noupdate /tb/u_target/int_n_s
add wave -noupdate -radix unsigned /tb/u_target/baudr_cnt_q
add wave -noupdate /tb/u_target/enable_s
add wave -noupdate /tb/u_target/port0_r_s
add wave -noupdate -radix hexadecimal /tb/u_target/shift_q
add wave -noupdate -radix hexadecimal /tb/u_target/status_s
add wave -noupdate /tb/u_target/state_s
add wave -noupdate /tb/u_target/bit_cnt_q
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {5390 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 180
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
WaveRestoreZoom {0 ns} {18880 ns}
