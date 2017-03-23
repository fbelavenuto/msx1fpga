onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb/reset_n
add wave -noupdate /tb/clock
add wave -noupdate -radix hexadecimal /tb/u_target/u0/MCycle
add wave -noupdate -radix hexadecimal /tb/u_target/u0/MCycles
add wave -noupdate -radix hexadecimal /tb/u_target/u0/TState
add wave -noupdate -radix hexadecimal /tb/u_target/u0/TStates
add wave -noupdate /tb/u_target/iorq_s
add wave -noupdate /tb/u_target/int_cycle_n_s
add wave -noupdate /tb/u_target/iorq_n_s
add wave -noupdate /tb/u_target/ireq_inhibit_n_s
add wave -noupdate /tb/u_target/mreq_inhibit_s
add wave -noupdate -radix hexadecimal /tb/cpu_a
add wave -noupdate -radix hexadecimal /tb/cpu_di
add wave -noupdate -radix hexadecimal /tb/cpu_do
add wave -noupdate /tb/cpu_wait_n
add wave -noupdate /tb/cpu_m1_n
add wave -noupdate /tb/cpu_ioreq_n
add wave -noupdate /tb/cpu_mreq_n
add wave -noupdate /tb/cpu_rd_n
add wave -noupdate /tb/cpu_wr_n
add wave -noupdate /tb/cpu_rfsh_n
add wave -noupdate /tb/cpu_irq_n
add wave -noupdate /tb/cpu_nmi_n
add wave -noupdate /tb/cpu_busreq_n
add wave -noupdate /tb/cpu_halt_n
add wave -noupdate /tb/cpu_busak_n
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {15260 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 184
configure wave -valuecolwidth 75
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
WaveRestoreZoom {0 ns} {15864 ns}
