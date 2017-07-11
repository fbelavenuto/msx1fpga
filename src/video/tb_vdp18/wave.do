onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb/por_s
add wave -noupdate /tb/reset_s
add wave -noupdate /tb/clock_s
add wave -noupdate /tb/clock_en_10m7_s
add wave -noupdate -divider CPU
add wave -noupdate -radix hexadecimal /tb/cd_i_s
add wave -noupdate -radix hexadecimal /tb/cd_o_s
add wave -noupdate -radix hexadecimal /tb/mode_s
add wave -noupdate /tb/csr_n_s
add wave -noupdate /tb/csw_n_s
add wave -noupdate /tb/int_n_s
add wave -noupdate /tb/wait_s
add wave -noupdate -divider VRAM
add wave -noupdate /tb/vram_oe_s
add wave -noupdate -radix hexadecimal /tb/vram_addr_s
add wave -noupdate -radix hexadecimal /tb/vram_data_i_s
add wave -noupdate -radix hexadecimal /tb/vram_data_o_s
add wave -noupdate -divider Video
add wave -noupdate /tb/rgb_b_s
add wave -noupdate /tb/rgb_g_s
add wave -noupdate /tb/rgb_r_s
add wave -noupdate -radix unsigned /tb/u_target/hor_vert_b/cnt_hor_q
add wave -noupdate -radix unsigned /tb/u_target/hor_vert_b/cnt_vert_q
add wave -noupdate /tb/u_target/blank_s
add wave -noupdate /tb/hsync_n_s
add wave -noupdate /tb/vsync_n_s
add wave -noupdate -divider vdp18
add wave -noupdate /tb/u_target/cpu_io_b/wait_s
add wave -noupdate /tb/u_target/access_type_s
add wave -noupdate /tb/u_target/clk_en_acc_s
add wave -noupdate /tb/u_target/clk_en_5m37_s
add wave -noupdate -radix unsigned /tb/u_target/num_line_s
add wave -noupdate -radix unsigned /tb/u_target/num_pix_s
add wave -noupdate /tb/u_target/vram_read_s
add wave -noupdate /tb/u_target/vram_write_s
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {10000837 ns} 0}
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
WaveRestoreZoom {9998885 ns} {10002789 ns}
