onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb/clock_s
add wave -noupdate -divider Sync
add wave -noupdate -radix hexadecimal /tb/addr_s
add wave -noupdate -radix hexadecimal /tb/data_i_s
add wave -noupdate -radix hexadecimal /tb/data_o_s
add wave -noupdate /tb/ce_n_s
add wave -noupdate /tb/oe_n_s
add wave -noupdate /tb/we_n_s
add wave -noupdate -divider Output
add wave -noupdate -radix hexadecimal -childformat {{/tb/sram_addr_s(17) -radix hexadecimal} {/tb/sram_addr_s(16) -radix hexadecimal} {/tb/sram_addr_s(15) -radix hexadecimal} {/tb/sram_addr_s(14) -radix hexadecimal} {/tb/sram_addr_s(13) -radix hexadecimal} {/tb/sram_addr_s(12) -radix hexadecimal} {/tb/sram_addr_s(11) -radix hexadecimal} {/tb/sram_addr_s(10) -radix hexadecimal} {/tb/sram_addr_s(9) -radix hexadecimal} {/tb/sram_addr_s(8) -radix hexadecimal} {/tb/sram_addr_s(7) -radix hexadecimal} {/tb/sram_addr_s(6) -radix hexadecimal} {/tb/sram_addr_s(5) -radix hexadecimal} {/tb/sram_addr_s(4) -radix hexadecimal} {/tb/sram_addr_s(3) -radix hexadecimal} {/tb/sram_addr_s(2) -radix hexadecimal} {/tb/sram_addr_s(1) -radix hexadecimal} {/tb/sram_addr_s(0) -radix hexadecimal}} -subitemconfig {/tb/sram_addr_s(17) {-radix hexadecimal} /tb/sram_addr_s(16) {-radix hexadecimal} /tb/sram_addr_s(15) {-radix hexadecimal} /tb/sram_addr_s(14) {-radix hexadecimal} /tb/sram_addr_s(13) {-radix hexadecimal} /tb/sram_addr_s(12) {-radix hexadecimal} /tb/sram_addr_s(11) {-radix hexadecimal} /tb/sram_addr_s(10) {-radix hexadecimal} /tb/sram_addr_s(9) {-radix hexadecimal} /tb/sram_addr_s(8) {-radix hexadecimal} /tb/sram_addr_s(7) {-radix hexadecimal} /tb/sram_addr_s(6) {-radix hexadecimal} /tb/sram_addr_s(5) {-radix hexadecimal} /tb/sram_addr_s(4) {-radix hexadecimal} /tb/sram_addr_s(3) {-radix hexadecimal} /tb/sram_addr_s(2) {-radix hexadecimal} /tb/sram_addr_s(1) {-radix hexadecimal} /tb/sram_addr_s(0) {-radix hexadecimal}} /tb/sram_addr_s
add wave -noupdate -radix hexadecimal /tb/sram_data_io_s
add wave -noupdate /tb/sram_ub_n_s
add wave -noupdate /tb/sram_lb_n_s
add wave -noupdate /tb/sram_ce_n_s
add wave -noupdate /tb/sram_oe_n_s
add wave -noupdate /tb/sram_we_n_s
add wave -noupdate -divider Internal
add wave -noupdate -radix hexadecimal /tb/u_target/sram_a_s
add wave -noupdate -radix hexadecimal /tb/u_target/sram_d_s
add wave -noupdate /tb/u_target/sram_oe_n_s
add wave -noupdate /tb/u_target/sram_we_n_s
add wave -noupdate /tb/u_target/main/state_v
add wave -noupdate /tb/u_target/main/p_ce_q
add wave -noupdate /tb/u_target/main/access_v
add wave -noupdate /tb/u_target/main/p_req_v
add wave -noupdate /tb/u_target/main/p_we_v
add wave -noupdate -radix hexadecimal /tb/u_target/main/p_addr_v
add wave -noupdate -radix hexadecimal /tb/u_target/main/p_data_v
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {625 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 223
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
WaveRestoreZoom {0 ns} {1628 ns}
