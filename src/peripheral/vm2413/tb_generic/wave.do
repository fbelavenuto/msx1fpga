onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb/reset_s
add wave -noupdate /tb/clock_s
add wave -noupdate /tb/clock_en_s
add wave -noupdate -divider CPU
add wave -noupdate -radix hexadecimal /tb/addr_s
add wave -noupdate -radix hexadecimal /tb/data_i_s
add wave -noupdate /tb/cs_n_s
add wave -noupdate /tb/wr_n_s
add wave -noupdate -divider Output
add wave -noupdate -radix decimal /tb/melody_s
add wave -noupdate -radix decimal /tb/rythm_s
add wave -noupdate -divider Internal
add wave -noupdate -radix unsigned /tb/u_target/slot
add wave -noupdate -radix unsigned /tb/u_target/stage
add wave -noupdate -radix hexadecimal /tb/u_target/opllptr
add wave -noupdate -radix hexadecimal /tb/u_target/oplldat
add wave -noupdate /tb/u_target/opllwr
add wave -noupdate -radix hexadecimal /tb/u_target/ct/regs_addr
add wave -noupdate /tb/u_target/ct/regs_wr
add wave -noupdate -radix hexadecimal /tb/u_target/ct/regs_rdata
add wave -noupdate -radix hexadecimal /tb/u_target/ct/regs_wdata
add wave -noupdate /tb/u_target/ct/user_voice_addr
add wave -noupdate /tb/u_target/ct/user_voice_wr
add wave -noupdate -radix hexadecimal /tb/u_target/ct/user_voice_rdata
add wave -noupdate -radix hexadecimal /tb/u_target/ct/user_voice_wdata
add wave -noupdate -radix hexadecimal /tb/u_target/ct/u_register_memory/regs_array
add wave -noupdate -radix hexadecimal /tb/u_target/ct/vmem/voices
add wave -noupdate -radix hexadecimal /tb/u_target/ct/u_register_memory/regs_array
add wave -noupdate /tb/u_target/ct/wr_dly_s
add wave -noupdate /tb/u_target/ct/pending_wr_s
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {225 ns} 0}
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
WaveRestoreZoom {0 ns} {90271 ns}
