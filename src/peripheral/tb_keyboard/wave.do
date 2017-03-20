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
add wave -noupdate -radix hexadecimal -childformat {{/tb/u_target/keymap_addr_s(9) -radix hexadecimal} {/tb/u_target/keymap_addr_s(8) -radix hexadecimal} {/tb/u_target/keymap_addr_s(7) -radix hexadecimal} {/tb/u_target/keymap_addr_s(6) -radix hexadecimal} {/tb/u_target/keymap_addr_s(5) -radix hexadecimal} {/tb/u_target/keymap_addr_s(4) -radix hexadecimal} {/tb/u_target/keymap_addr_s(3) -radix hexadecimal} {/tb/u_target/keymap_addr_s(2) -radix hexadecimal} {/tb/u_target/keymap_addr_s(1) -radix hexadecimal} {/tb/u_target/keymap_addr_s(0) -radix hexadecimal}} -subitemconfig {/tb/u_target/keymap_addr_s(9) {-radix hexadecimal} /tb/u_target/keymap_addr_s(8) {-radix hexadecimal} /tb/u_target/keymap_addr_s(7) {-radix hexadecimal} /tb/u_target/keymap_addr_s(6) {-radix hexadecimal} /tb/u_target/keymap_addr_s(5) {-radix hexadecimal} /tb/u_target/keymap_addr_s(4) {-radix hexadecimal} /tb/u_target/keymap_addr_s(3) {-radix hexadecimal} /tb/u_target/keymap_addr_s(2) {-radix hexadecimal} /tb/u_target/keymap_addr_s(1) {-radix hexadecimal} /tb/u_target/keymap_addr_s(0) {-radix hexadecimal}} /tb/u_target/keymap_addr_s
add wave -noupdate -radix hexadecimal -childformat {{/tb/u_target/keymap_data_s(7) -radix hexadecimal} {/tb/u_target/keymap_data_s(6) -radix hexadecimal} {/tb/u_target/keymap_data_s(5) -radix hexadecimal} {/tb/u_target/keymap_data_s(4) -radix hexadecimal} {/tb/u_target/keymap_data_s(3) -radix hexadecimal} {/tb/u_target/keymap_data_s(2) -radix hexadecimal} {/tb/u_target/keymap_data_s(1) -radix hexadecimal} {/tb/u_target/keymap_data_s(0) -radix hexadecimal}} -subitemconfig {/tb/u_target/keymap_data_s(7) {-radix hexadecimal} /tb/u_target/keymap_data_s(6) {-radix hexadecimal} /tb/u_target/keymap_data_s(5) {-radix hexadecimal} /tb/u_target/keymap_data_s(4) {-radix hexadecimal} /tb/u_target/keymap_data_s(3) {-radix hexadecimal} /tb/u_target/keymap_data_s(2) {-radix hexadecimal} /tb/u_target/keymap_data_s(1) {-radix hexadecimal} /tb/u_target/keymap_data_s(0) {-radix hexadecimal}} /tb/u_target/keymap_data_s
add wave -noupdate /tb/u_target/keymap_seq_s
add wave -noupdate /tb/led_caps_s
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {9690 ns} 0}
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
WaveRestoreZoom {3756 ns} {11268 ns}
