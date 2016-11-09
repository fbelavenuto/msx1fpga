onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb/reset_s
add wave -noupdate /tb/clock_s
add wave -noupdate /tb/clock_en_s
add wave -noupdate /tb/cs_s
add wave -noupdate /tb/wr_s
add wave -noupdate /tb/rd_s
add wave -noupdate -radix hexadecimal /tb/addr_s
add wave -noupdate -radix hexadecimal /tb/data_i_s
add wave -noupdate -radix hexadecimal /tb/data_o_s
add wave -noupdate -radix hexadecimal /tb/ram_addr_s
add wave -noupdate -radix hexadecimal /tb/ram_data_s
add wave -noupdate /tb/ram_ce_s
add wave -noupdate /tb/ram_oe_s
add wave -noupdate /tb/ram_we_s
add wave -noupdate /tb/map_type_s
add wave -noupdate -radix hexadecimal /tb/wave_s
add wave -noupdate -radix hexadecimal /tb/u_target/wav_addr_s
add wave -noupdate -radix hexadecimal /tb/u_target/WavDbi
add wave -noupdate /tb/u_target/wav_copy_s
add wave -noupdate /tb/u_target/wav_cs_s
add wave -noupdate /tb/u_target/cs_i
add wave -noupdate /tb/u_target/cs_dly_s
add wave -noupdate -radix binary /tb/u_target/DecSccA
add wave -noupdate -radix binary /tb/u_target/DecSccB
add wave -noupdate -radix binary /tb/u_target/SccSel_s
add wave -noupdate /tb/u_target/SccModeA
add wave -noupdate /tb/u_target/SccModeB
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {3519 ns} 0}
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
WaveRestoreZoom {2222 ns} {5956 ns}
