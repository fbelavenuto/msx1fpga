onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb/clock_s
add wave -noupdate /tb/reset_n_s
add wave -noupdate /tb/int_n_s
add wave -noupdate /tb/vram_ce_s
add wave -noupdate /tb/vram_oe_s
add wave -noupdate /tb/vram_we_s
add wave -noupdate -radix hexadecimal /tb/vram_addr_s
add wave -noupdate -radix hexadecimal /tb/vram_data_i_s
add wave -noupdate -radix hexadecimal /tb/vram_data_o_s
add wave -noupdate -radix hexadecimal /tb/col_s
add wave -noupdate /tb/hsync_n_s
add wave -noupdate /tb/vsync_n_s
add wave -noupdate /tb/u_target/access_type_s
add wave -noupdate -radix decimal /tb/u_target/num_pix_s
add wave -noupdate -radix decimal /tb/u_target/num_line_s
add wave -noupdate -radix unsigned /tb/u_target/sprite_b/sprite_num_q
add wave -noupdate -divider WaitState
add wave -noupdate /tb/csr_n_s
add wave -noupdate /tb/csw_n_s
add wave -noupdate -radix hexadecimal /tb/cd_i_s
add wave -noupdate -radix hexadecimal /tb/cd_o_s
add wave -noupdate /tb/wait_s
add wave -noupdate /tb/u_target/cpu_io_b/clock_i
add wave -noupdate /tb/u_target/cpu_io_b/clk_en_acc_i
add wave -noupdate /tb/u_target/cpu_io_b/wrbuf_cpu_s
add wave -noupdate -radix hexadecimal /tb/u_target/cpu_io_b/buffer_q
add wave -noupdate /tb/u_target/cpu_io_b/destr_rd_status_s
add wave -noupdate /tb/u_target/cpu_io_b/incr_addr_s
add wave -noupdate /tb/u_target/cpu_io_b/load_addr_s
add wave -noupdate /tb/u_target/cpu_io_b/state_q
add wave -noupdate /tb/u_target/cpu_io_b/state_s
add wave -noupdate /tb/u_target/cpu_io_b/write_reg_s
add wave -noupdate /tb/u_target/cpu_io_b/write_tmp_s
add wave -noupdate /tb/u_target/cpu_io_b/sched_wrvram_s
add wave -noupdate /tb/u_target/cpu_io_b/abort_wrvram_s
add wave -noupdate /tb/u_target/cpu_io_b/wrvram_sched_q
add wave -noupdate /tb/u_target/cpu_io_b/wrvram_q
add wave -noupdate /tb/u_target/cpu_io_b/sched_rdvram_s
add wave -noupdate /tb/u_target/cpu_io_b/rdvram_sched_q
add wave -noupdate /tb/u_target/cpu_io_b/rdvram_q
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {30402775 ns} 0}
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
WaveRestoreZoom {30400240 ns} {30404140 ns}
