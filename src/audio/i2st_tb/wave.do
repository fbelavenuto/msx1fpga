onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb/clock_s
add wave -noupdate /tb/reset_s
add wave -noupdate -divider {New Divider}
add wave -noupdate /tb/pcm_l_s
add wave -noupdate /tb/pcm_r_s
add wave -noupdate -divider {New Divider}
add wave -noupdate /tb/i2s_mclk_s
add wave -noupdate /tb/i2s_bclk_s
add wave -noupdate /tb/i2s_lrclk_s
add wave -noupdate /tb/i2s_d_s
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {160 ns} 0}
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
WaveRestoreZoom {9998418 ns} {10000294 ns}
