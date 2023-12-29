onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb/clock_s
add wave -noupdate /tb/clock_low_en_s
add wave -noupdate /tb/clock_high_en_s
add wave -noupdate -radix hexadecimal /tb/color_rgb_s
add wave -noupdate -radix hexadecimal /tb/color_vga_s
add wave -noupdate /tb/hsync_n_rgb_s
add wave -noupdate /tb/vsync_n_rgb_s
add wave -noupdate /tb/hsync_n_vga_s
add wave -noupdate /tb/vsync_n_vga_s
add wave -noupdate /tb/hblank_s
add wave -noupdate -divider Interno
add wave -noupdate /tb/u_target/hsync_n_t1_s
add wave -noupdate -radix unsigned /tb/u_target/hpos_s
add wave -noupdate /tb/u_target/ibank_s
add wave -noupdate /tb/u_target/obank_s
add wave -noupdate /tb/u_target/oddline_s
add wave -noupdate /tb/u_target/ohs_s
add wave -noupdate /tb/u_target/ohs_t1_s
add wave -noupdate -radix unsigned /tb/u_target/vs_cnt_s
add wave -noupdate /tb/u_target/ovs_t1_s
add wave -noupdate /tb/u_target/ovs_s
add wave -noupdate /tb/u_target/vsync_n_t1_s
add wave -noupdate /tb/u_target/we_a_s
add wave -noupdate /tb/u_target/we_b_s
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {37625 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 251
configure wave -valuecolwidth 49
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
WaveRestoreZoom {0 ns} {274240 ns}
