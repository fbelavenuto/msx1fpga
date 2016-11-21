onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb/clock_s
add wave -noupdate /tb/clock_en_10m7_s
add wave -noupdate /tb/vram_oe_s
add wave -noupdate -radix hexadecimal /tb/vram_addr_s
add wave -noupdate -radix hexadecimal /tb/vram_data_i_s
add wave -noupdate -radix hexadecimal /tb/vram_data_o_s
add wave -noupdate /tb/rgb_b_s
add wave -noupdate /tb/rgb_g_s
add wave -noupdate /tb/rgb_r_s
add wave -noupdate -radix unsigned /tb/u_target/hor_vert_b/cnt_hor_q
add wave -noupdate -radix unsigned /tb/u_target/hor_vert_b/cnt_vert_q
add wave -noupdate /tb/u_target/blank_s
add wave -noupdate /tb/hsync_n_s
add wave -noupdate /tb/vsync_n_s
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {49002167 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 264
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
WaveRestoreZoom {48349218 ns} {50348066 ns}
