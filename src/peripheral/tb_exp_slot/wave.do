onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb/reset_s
add wave -noupdate /tb/clock_s
add wave -noupdate -divider Interface
add wave -noupdate -radix hexadecimal /tb/addr_s
add wave -noupdate -radix hexadecimal /tb/data_i_s
add wave -noupdate -radix hexadecimal /tb/data_o_s
add wave -noupdate /tb/has_data_s
add wave -noupdate /tb/req_s
add wave -noupdate /tb/sltsl_n_s
add wave -noupdate /tb/rd_n_s
add wave -noupdate /tb/wr_n_s
add wave -noupdate -divider Out
add wave -noupdate /tb/expsltsl_n_s
add wave -noupdate -divider Internal
add wave -noupdate /tb/u_target/ffff_s
add wave -noupdate /tb/u_target/exp_reg_s
add wave -noupdate /tb/u_target/exp_sel_s
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {325 ns} 0}
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
WaveRestoreZoom {0 ns} {7259 ns}
