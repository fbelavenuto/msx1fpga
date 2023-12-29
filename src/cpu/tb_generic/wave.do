onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb/reset_n
add wave -noupdate /tb/texto
add wave -noupdate -radix unsigned /tb/u_target/mcycle_s
add wave -noupdate -radix unsigned /tb/u_target/tstate_s
add wave -noupdate /tb/clock
add wave -noupdate /tb/clock_enable
add wave -noupdate -radix hexadecimal /tb/cpu_a
add wave -noupdate -radix hexadecimal /tb/cpu_di
add wave -noupdate -radix hexadecimal /tb/u_target/data_r_s
add wave -noupdate -radix hexadecimal /tb/cpu_do
add wave -noupdate /tb/cpu_wait_n
add wave -noupdate /tb/cpu_m1_n
add wave -noupdate /tb/cpu_rfsh_n
add wave -noupdate /tb/cpu_mreq_n
add wave -noupdate /tb/cpu_ioreq_n
add wave -noupdate /tb/cpu_rd_n
add wave -noupdate /tb/cpu_wr_n
add wave -noupdate /tb/cpu_irq_n
add wave -noupdate /tb/cpu_nmi_n
add wave -noupdate /tb/cpu_busreq_n
add wave -noupdate /tb/cpu_halt_n
add wave -noupdate /tb/cpu_busak_n
add wave -noupdate /tb/u_target/noread_s
add wave -noupdate /tb/u_target/write_s
add wave -noupdate /tb/u_target/intcycle_n_s
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {240 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 169
configure wave -valuecolwidth 40
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 120
configure wave -griddelta 20
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ns} {14864 ns}
