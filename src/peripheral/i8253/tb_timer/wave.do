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
add wave -noupdate -divider Internal
add wave -noupdate /tb/u_target/isread_s
add wave -noupdate /tb/u_target/iswrite_s
add wave -noupdate /tb/u_target/cnt0_read_s
add wave -noupdate /tb/u_target/cnt0_write_s
add wave -noupdate /tb/u_target/cnt1_read_s
add wave -noupdate /tb/u_target/cnt1_write_s
add wave -noupdate /tb/u_target/cnt2_read_s
add wave -noupdate /tb/u_target/cnt2_write_s
add wave -noupdate /tb/out0_s
add wave -noupdate /tb/out2_s
add wave -noupdate -divider CNT0
add wave -noupdate /tb/u_target/cnt0/cnt_out_q
add wave -noupdate -radix hexadecimal /tb/u_target/cnt0/cnt_initial_q
add wave -noupdate -radix unsigned /tb/u_target/cnt0/cnt_value_q
add wave -noupdate -radix hexadecimal /tb/u_target/cnt0/cnt_latch_q
add wave -noupdate /tb/u_target/cnt0/cnt_latched_q
add wave -noupdate /tb/u_target/cnt0/cnt_lmr_q
add wave -noupdate /tb/u_target/cnt0/cnt_lmw_q
add wave -noupdate /tb/u_target/cnt0/cnt_mode_q
add wave -noupdate /tb/u_target/cnt0/cnt_rw_q
add wave -noupdate /tb/u_target/cnt0/cnt_read_q
add wave -noupdate -divider CNT2
add wave -noupdate /tb/u_target/cnt2/cnt_out_q
add wave -noupdate -radix hexadecimal /tb/u_target/cnt2/cnt_initial_q
add wave -noupdate -radix unsigned /tb/u_target/cnt2/cnt_value_q
add wave -noupdate -radix hexadecimal /tb/u_target/cnt2/cnt_latch_q
add wave -noupdate /tb/u_target/cnt2/cnt_latched_q
add wave -noupdate /tb/u_target/cnt2/cnt_lmr_q
add wave -noupdate /tb/u_target/cnt2/cnt_lmw_q
add wave -noupdate /tb/u_target/cnt2/cnt_mode_q
add wave -noupdate /tb/u_target/cnt2/cnt_rw_q
add wave -noupdate /tb/u_target/cnt2/cnt_read_q
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {8479 ns} 0}
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
WaveRestoreZoom {0 ns} {37134 ns}
