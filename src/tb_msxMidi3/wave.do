onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb/por_s
add wave -noupdate /tb/reset_s
add wave -noupdate /tb/clocksys_s
add wave -noupdate /tb/clock_s
add wave -noupdate /tb/clock_psg_en_s
add wave -noupdate /tb/clock_vdp_s
add wave -noupdate -radix hexadecimal /tb/ram_addr_s
add wave -noupdate /tb/ram_ce_s
add wave -noupdate -radix hexadecimal /tb/bus_addr_s
add wave -noupdate -radix hexadecimal /tb/bus_data_from_s
add wave -noupdate -radix hexadecimal /tb/bus_data_to_s
add wave -noupdate /tb/bus_int_n_s
add wave -noupdate /tb/bus_iorq_n_s
add wave -noupdate /tb/bus_m1_n_s
add wave -noupdate /tb/bus_mreq_n_s
add wave -noupdate /tb/bus_wr_n_s
add wave -noupdate /tb/bus_rd_n_s
add wave -noupdate /tb/clock_cpu_s
add wave -noupdate /tb/clock_3m_s
add wave -noupdate /tb/turbo_on_k_s
add wave -noupdate /tb/turbo_on_s
add wave -noupdate -divider MIDI3
add wave -noupdate /tb/clock_8m_s
add wave -noupdate /tb/midi_cs_n_s
add wave -noupdate -radix hexadecimal /tb/midi_data_from_s
add wave -noupdate /tb/midi_hd_s
add wave -noupdate /tb/midi_int_n_s
add wave -noupdate /tb/midi_tx_s
add wave -noupdate -divider Internal
add wave -noupdate /tb/midi3inst/busdir_s
add wave -noupdate /tb/midi3inst/clock_4m_s
add wave -noupdate -radix hexadecimal /tb/midi3inst/databd_s
add wave -noupdate /tb/midi3inst/dtr_s
add wave -noupdate /tb/midi3inst/rts_s
add wave -noupdate /tb/midi3inst/ffint_cs_n_s
add wave -noupdate /tb/midi3inst/ffint_q
add wave -noupdate /tb/midi3inst/ffint_wr_s
add wave -noupdate /tb/midi3inst/i8251_cs_n_s
add wave -noupdate /tb/midi3inst/i8253_cs_n_s
add wave -noupdate /tb/midi3inst/out0_s
add wave -noupdate /tb/midi3inst/out2_s
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {31650 ns} 0}
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
WaveRestoreZoom {2088 ns} {57768 ns}
