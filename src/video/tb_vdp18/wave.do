onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb/por_s
add wave -noupdate /tb/reset_s
add wave -noupdate /tb/clock_s
add wave -noupdate /tb/clock_en_10m7_s
add wave -noupdate -divider Outs
add wave -noupdate -radix unsigned /tb/u_target/hor_vert_b/cnt_hor_q
add wave -noupdate -radix unsigned /tb/u_target/hor_vert_b/cnt_vert_q
add wave -noupdate -radix hexadecimal /tb/rgb_b_s
add wave -noupdate -radix hexadecimal /tb/rgb_g_s
add wave -noupdate -radix hexadecimal /tb/rgb_r_s
add wave -noupdate /tb/hsync_n_s
add wave -noupdate /tb/vsync_n_s
add wave -noupdate -divider VRAM
add wave -noupdate /tb/vram_ce_s
add wave -noupdate /tb/vram_oe_s
add wave -noupdate /tb/vram_we_s
add wave -noupdate -radix hexadecimal /tb/vram_addr_s
add wave -noupdate -radix hexadecimal /tb/vram_data_i_s
add wave -noupdate -radix hexadecimal /tb/vram_data_o_s
add wave -noupdate -divider CPU
add wave -noupdate /tb/mode_s
add wave -noupdate -radix hexadecimal /tb/cd_i_s
add wave -noupdate -radix hexadecimal /tb/cd_o_s
add wave -noupdate /tb/csr_n_s
add wave -noupdate /tb/csw_n_s
add wave -noupdate /tb/wait_s
add wave -noupdate -divider StateMachine
add wave -noupdate /tb/u_target/cpu_io_b/clk_en_acc_i
add wave -noupdate /tb/u_target/cpu_io_b/access_type_i
add wave -noupdate /tb/u_target/cpu_io_b/destr_rd_status_s
add wave -noupdate /tb/u_target/cpu_io_b/load_addr_s
add wave -noupdate /tb/u_target/cpu_io_b/rdvram_q
add wave -noupdate /tb/u_target/cpu_io_b/sched_rdvram_s
add wave -noupdate /tb/u_target/cpu_io_b/rdvram_sched_q
add wave -noupdate /tb/u_target/cpu_io_b/state_q
add wave -noupdate /tb/u_target/cpu_io_b/state_s
add wave -noupdate -radix hexadecimal /tb/u_target/cpu_io_b/tmp_q
add wave -noupdate /tb/u_target/cpu_io_b/wrbuf_cpu_s
add wave -noupdate -radix hexadecimal /tb/u_target/cpu_io_b/buffer_q
add wave -noupdate /tb/u_target/cpu_io_b/sched_wrvram_s
add wave -noupdate /tb/u_target/cpu_io_b/wrvram_sched_q
add wave -noupdate /tb/u_target/cpu_io_b/wrvram_q
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {2570963 ns} 0}
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
WaveRestoreZoom {2567059 ns} {2574867 ns}
