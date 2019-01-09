onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb/wait_n_s
add wave -noupdate /tb/reset_n_s
add wave -noupdate /tb/clock_cpu_s
add wave -noupdate /tb/addr_s
add wave -noupdate /tb/cs_n_s
add wave -noupdate /tb/rd_n_s
add wave -noupdate /tb/wr_n_s
add wave -noupdate -radix hexadecimal /tb/data_s
add wave -noupdate -radix hexadecimal /tb/data_o_s
add wave -noupdate /tb/clock_s
add wave -noupdate /tb/out0_s
add wave -noupdate /tb/out2_s
add wave -noupdate -divider Internal
add wave -noupdate /tb/u_target/access_s
add wave -noupdate /tb/u_target/port_a0_s
add wave -noupdate /tb/u_target/port_a2_s
add wave -noupdate /tb/u_target/port_a3_s
add wave -noupdate /tb/u_target/write_s
add wave -noupdate /tb/u_target/cmd0_s
add wave -noupdate /tb/u_target/cmd2_s
add wave -noupdate /tb/u_target/cnt0_cs_s
add wave -noupdate -radix hexadecimal /tb/u_target/cnt0_data_from_s
add wave -noupdate /tb/u_target/cnt2_cs_s
add wave -noupdate -radix hexadecimal /tb/u_target/cnt2_data_from_s
add wave -noupdate -divider CNT0
add wave -noupdate /tb/u_target/cnt0/clr_ce_s
add wave -noupdate /tb/u_target/cnt0/clr_ncmd_s
add wave -noupdate /tb/u_target/cnt0/ce_q
add wave -noupdate /tb/u_target/cnt0/cnt1_s
add wave -noupdate /tb/u_target/cnt0/cnt2_s
add wave -noupdate -radix unsigned /tb/u_target/cnt0/initial_q
add wave -noupdate /tb/u_target/cnt0/latched_q
add wave -noupdate /tb/u_target/cnt0/mode_q
add wave -noupdate /tb/u_target/cnt0/newcmd_q
add wave -noupdate /tb/u_target/cnt0/rd_q
add wave -noupdate /tb/u_target/cnt0/state_q
add wave -noupdate /tb/u_target/cnt0/strobe_q
add wave -noupdate -radix unsigned /tb/u_target/cnt0/value_q
add wave -noupdate /tb/u_target/cnt0/out_q
add wave -noupdate -divider CNT2
add wave -noupdate /tb/u_target/cnt2/clr_ce_s
add wave -noupdate /tb/u_target/cnt2/clr_ncmd_s
add wave -noupdate /tb/u_target/cnt2/ce_q
add wave -noupdate /tb/u_target/cnt2/cnt1_s
add wave -noupdate /tb/u_target/cnt2/cnt2_s
add wave -noupdate -radix unsigned /tb/u_target/cnt2/initial_q
add wave -noupdate /tb/u_target/cnt2/latched_q
add wave -noupdate /tb/u_target/cnt2/mode_q
add wave -noupdate /tb/u_target/cnt2/newcmd_q
add wave -noupdate /tb/u_target/cnt2/rd_q
add wave -noupdate /tb/u_target/cnt2/state_q
add wave -noupdate /tb/u_target/cnt2/strobe_q
add wave -noupdate -radix unsigned /tb/u_target/cnt2/value_q
add wave -noupdate /tb/u_target/cnt2/out_q
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {12088 ns} 0}
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
