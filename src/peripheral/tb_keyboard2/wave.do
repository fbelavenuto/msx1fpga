onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb/reset_s
add wave -noupdate /tb/clock_s
add wave -noupdate -radix hexadecimal /tb/rows_coded_s
add wave -noupdate -radix hexadecimal /tb/cols_s
add wave -noupdate -radix hexadecimal /tb/u_target/keyb_data_s
add wave -noupdate /tb/u_target/keyb_valid_s
add wave -noupdate -radix hexadecimal /tb/u_target/matrix_s
add wave -noupdate /tb/u_target/break_s
add wave -noupdate /tb/u_target/extended_s
add wave -noupdate /tb/u_target/shift_s
add wave -noupdate /tb/u_target/has_keycode_s
add wave -noupdate -radix hexadecimal /tb/u_target/keymap_addr_s
add wave -noupdate -radix hexadecimal /tb/u_target/keymap_data_s
add wave -noupdate /tb/u_target/keymap_seq_s
add wave -noupdate /tb/led_caps_s
add wave -noupdate -radix hexadecimal /tb/u_target/d_to_send_s
add wave -noupdate /tb/u_target/data_load_s
add wave -noupdate /tb/ps2_clk_s
add wave -noupdate /tb/ps2_data_s
add wave -noupdate /tb/u_target/ps2_port/clk_syn_s
add wave -noupdate /tb/u_target/ps2_port/dat_syn_s
add wave -noupdate /tb/u_target/ps2_port/clk_nedge_s
add wave -noupdate /tb/u_target/ps2_port/parchecked_s
add wave -noupdate /tb/u_target/ps2_port/data_rdy_o
add wave -noupdate /tb/u_target/ps2_port/sigclkheld
add wave -noupdate /tb/u_target/ps2_port/sigclkreleased
add wave -noupdate /tb/u_target/ps2_port/sigsendend_s
add wave -noupdate /tb/u_target/ps2_port/sigsending_s
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {132733 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 235
configure wave -valuecolwidth 100
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
WaveRestoreZoom {72637 ns} {192829 ns}
