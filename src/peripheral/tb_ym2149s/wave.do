onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb/reset_s
add wave -noupdate /tb/clock_s
add wave -noupdate -radix unsigned /tb/clock_en/cnt1_q
add wave -noupdate /tb/clock_en_s
add wave -noupdate -radix unsigned /tb/addr_s
add wave -noupdate /tb/req_s
add wave -noupdate /tb/rd_n_s
add wave -noupdate /tb/wr_n_s
add wave -noupdate -radix hexadecimal /tb/data_i_s
add wave -noupdate -radix hexadecimal /tb/data_o_s
add wave -noupdate -radix hexadecimal /tb/audio_s
add wave -noupdate -radix hexadecimal /tb/u_target/reg_addr_q
add wave -noupdate -radix hexadecimal -childformat {{/tb/u_target/regs_q(0) -radix hexadecimal} {/tb/u_target/regs_q(1) -radix hexadecimal} {/tb/u_target/regs_q(2) -radix hexadecimal} {/tb/u_target/regs_q(3) -radix hexadecimal} {/tb/u_target/regs_q(4) -radix hexadecimal} {/tb/u_target/regs_q(5) -radix hexadecimal} {/tb/u_target/regs_q(6) -radix hexadecimal} {/tb/u_target/regs_q(7) -radix hexadecimal} {/tb/u_target/regs_q(8) -radix hexadecimal} {/tb/u_target/regs_q(9) -radix hexadecimal} {/tb/u_target/regs_q(10) -radix hexadecimal} {/tb/u_target/regs_q(11) -radix hexadecimal} {/tb/u_target/regs_q(12) -radix hexadecimal} {/tb/u_target/regs_q(13) -radix hexadecimal} {/tb/u_target/regs_q(14) -radix hexadecimal} {/tb/u_target/regs_q(15) -radix hexadecimal}} -expand -subitemconfig {/tb/u_target/regs_q(0) {-height 15 -radix hexadecimal} /tb/u_target/regs_q(1) {-height 15 -radix hexadecimal} /tb/u_target/regs_q(2) {-height 15 -radix hexadecimal} /tb/u_target/regs_q(3) {-height 15 -radix hexadecimal} /tb/u_target/regs_q(4) {-height 15 -radix hexadecimal} /tb/u_target/regs_q(5) {-height 15 -radix hexadecimal} /tb/u_target/regs_q(6) {-height 15 -radix hexadecimal} /tb/u_target/regs_q(7) {-height 15 -radix hexadecimal} /tb/u_target/regs_q(8) {-height 15 -radix hexadecimal} /tb/u_target/regs_q(9) {-height 15 -radix hexadecimal} /tb/u_target/regs_q(10) {-height 15 -radix hexadecimal} /tb/u_target/regs_q(11) {-height 15 -radix hexadecimal} /tb/u_target/regs_q(12) {-height 15 -radix hexadecimal} /tb/u_target/regs_q(13) {-height 15 -radix hexadecimal} /tb/u_target/regs_q(14) {-height 15 -radix hexadecimal} /tb/u_target/regs_q(15) {-height 15 -radix hexadecimal}} /tb/u_target/regs_q
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1300 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 163
configure wave -valuecolwidth 40
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 100
configure wave -gridperiod 200
configure wave -griddelta 2
configure wave -timeline 1
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ns} {28499968 ns}
