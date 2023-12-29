onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb/por_s
add wave -noupdate /tb/reset_s
add wave -noupdate /tb/clock_s
add wave -noupdate -divider Clocks
add wave -noupdate /tb/clock_3m_en_s
add wave -noupdate /tb/clock_5m_en_s
add wave -noupdate /tb/clock_7m_en_s
add wave -noupdate /tb/clock_10m_en_s
add wave -noupdate -divider CPU
add wave -noupdate /tb/u_target/reset_n_s
add wave -noupdate -radix unsigned /tb/u_target/cpu/mcycle_s
add wave -noupdate -radix unsigned /tb/u_target/cpu/tstate_s
add wave -noupdate -radix hexadecimal /tb/u_target/cpu_addr_s
add wave -noupdate -radix hexadecimal /tb/u_target/d_to_cpu_s
add wave -noupdate -radix hexadecimal /tb/u_target/d_from_cpu_s
add wave -noupdate /tb/u_target/wait_n_s
add wave -noupdate /tb/u_target/m1_n_s
add wave -noupdate /tb/u_target/rfsh_n_s
add wave -noupdate /tb/u_target/mreq_n_s
add wave -noupdate /tb/u_target/iorq_n_s
add wave -noupdate /tb/u_target/rd_n_s
add wave -noupdate /tb/u_target/wr_n_s
add wave -noupdate /tb/u_target/req_mem_s
add wave -noupdate /tb/u_target/req_io_s
add wave -noupdate -divider RAM
add wave -noupdate -radix hexadecimal /tb/ram_addr_s
add wave -noupdate -radix hexadecimal /tb/ram_data_from_s
add wave -noupdate -radix hexadecimal /tb/ram_data_to_s
add wave -noupdate /tb/ram_ce_n_s
add wave -noupdate /tb/ram_oe_n_s
add wave -noupdate /tb/ram_we_n_s
add wave -noupdate -divider VRAM
add wave -noupdate -radix hexadecimal /tb/u_target/vram_addr_o
add wave -noupdate /tb/u_target/vram_ce_n_o
add wave -noupdate -radix hexadecimal /tb/u_target/vram_data_i
add wave -noupdate -radix hexadecimal /tb/u_target/vram_data_o
add wave -noupdate /tb/u_target/vram_oe_n_o
add wave -noupdate /tb/u_target/vram_we_n_o
add wave -noupdate -divider Internal
add wave -noupdate /tb/u_target/vdp_wait_n_s
add wave -noupdate /tb/u_target/vdp/csr_n_i
add wave -noupdate /tb/u_target/vdp/csw_n_i
add wave -noupdate /tb/u_target/vdp/cpu_io_b/load_addr_s
add wave -noupdate /tb/u_target/vdp/cpu_io_b/access_ctrl/transfer_mode_v
add wave -noupdate /tb/u_target/vdp/cpu_io_b/wrvram_q
add wave -noupdate /tb/u_target/vdp/cpu_io_b/wrvram_sched_q
add wave -noupdate /tb/u_target/vdp/access_type_s
add wave -noupdate /tb/u_target/vdp/cpu_io_b/state_q
add wave -noupdate /tb/u_target/vdp/cpu_io_b/state_s
add wave -noupdate /tb/u_target/vdp/cpu_io_b/wrbuf_cpu_s
add wave -noupdate /tb/u_target/vdp/cpu_io_b/sched_wrvram_s
add wave -noupdate -divider OPLL
add wave -noupdate /tb/u_target/popll/opll1/ct/clk
add wave -noupdate /tb/u_target/popll/opll1/ct/clkena
add wave -noupdate -radix hexadecimal /tb/u_target/popll/opll1/ct/addr
add wave -noupdate -radix hexadecimal /tb/u_target/popll/opll1/ct/data
add wave -noupdate /tb/u_target/popll/opll1/ct/pending_wr_s
add wave -noupdate /tb/u_target/popll/opll1/ct/wr_dly_s
add wave -noupdate /tb/u_target/popll/opll1/ct/wr_i
add wave -noupdate /tb/u_target/popll/opll1/ct/regs_wr
add wave -noupdate /tb/u_target/popll/opll1/ct/regs_wr_dly_s
add wave -noupdate /tb/u_target/popll/opll1/ct/user_voice_addr
add wave -noupdate -radix hexadecimal /tb/u_target/popll/opll1/ct/user_voice_rdata
add wave -noupdate -radix hexadecimal /tb/u_target/popll/opll1/ct/user_voice_wdata
add wave -noupdate /tb/u_target/popll/opll1/ct/user_voice_wr
add wave -noupdate /tb/u_target/popll/opll1/ct/user_voice_wr_dly_s
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {6142 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 250
configure wave -valuecolwidth 40
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
WaveRestoreZoom {0 ns} {19800 ns}
