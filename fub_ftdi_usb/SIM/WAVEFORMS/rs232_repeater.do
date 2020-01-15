onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Logic /fib_rs232_repeater_top_tb/clk
add wave -noupdate -format Logic /fib_rs232_repeater_top_tb/rst
add wave -noupdate -divider fub
add wave -noupdate -format Literal /fib_rs232_repeater_top_tb/fib_rs232_repeater_top_inst/fub_ftdi_in_data
add wave -noupdate -format Logic /fib_rs232_repeater_top_tb/fib_rs232_repeater_top_inst/fub_ftdi_in_str
add wave -noupdate -format Logic /fib_rs232_repeater_top_tb/fib_rs232_repeater_top_inst/fub_ftdi_in_busy
add wave -noupdate -format Literal /fib_rs232_repeater_top_tb/fib_rs232_repeater_top_inst/fub_ftdi_out_data
add wave -noupdate -format Logic /fib_rs232_repeater_top_tb/fib_rs232_repeater_top_inst/fub_ftdi_out_str
add wave -noupdate -format Logic /fib_rs232_repeater_top_tb/fib_rs232_repeater_top_inst/fub_ftdi_out_busy
add wave -noupdate -divider {RS 232}
add wave -noupdate -format Logic /fib_rs232_repeater_top_tb/fib_rs232_repeater_top_inst/rs232_rx_i
add wave -noupdate -format Logic /fib_rs232_repeater_top_tb/fib_rs232_repeater_top_inst/rs232_tx_o
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {647 ns} 0}
configure wave -namecolwidth 414
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
update
WaveRestoreZoom {0 ns} {1936 ns}
