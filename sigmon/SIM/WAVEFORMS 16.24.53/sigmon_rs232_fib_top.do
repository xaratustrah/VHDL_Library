onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Logic /sigmon_rs232_fib_top_tb/sigmon_rs232_fib_top_inst/clk
add wave -noupdate -format Logic /sigmon_rs232_fib_top_tb/sigmon_rs232_fib_top_inst/clk100
add wave -noupdate -format Logic /sigmon_rs232_fib_top_tb/sigmon_rs232_fib_top_inst/clk200
add wave -noupdate -format Logic /sigmon_rs232_fib_top_tb/sigmon_rs232_fib_top_inst/rst
add wave -noupdate -divider {RS 232}
add wave -noupdate -format Logic /sigmon_rs232_fib_top_tb/sigmon_rs232_fib_top_inst/rs232_rx_i
add wave -noupdate -format Logic /sigmon_rs232_fib_top_tb/sigmon_rs232_fib_top_inst/rs232_tx_o
add wave -noupdate -divider {FUB RS 232 TB}
add wave -noupdate -format Logic /sigmon_rs232_fib_top_tb/fub_rx_str
add wave -noupdate -format Logic /sigmon_rs232_fib_top_tb/fub_rx_busy
add wave -noupdate -format Literal -radix hexadecimal /sigmon_rs232_fib_top_tb/fub_rx_data
add wave -noupdate -divider fifo
add wave -noupdate -format Literal -radix hexadecimal /sigmon_rs232_fib_top_tb/sigmon_rs232_fib_top_inst/fifo_data_in
add wave -noupdate -format Literal -radix hexadecimal /sigmon_rs232_fib_top_tb/sigmon_rs232_fib_top_inst/fifo_data_out
add wave -noupdate -format Logic /sigmon_rs232_fib_top_tb/sigmon_rs232_fib_top_inst/fifo_rdreq
add wave -noupdate -format Logic /sigmon_rs232_fib_top_tb/sigmon_rs232_fib_top_inst/fifo_wrreq
add wave -noupdate -format Logic /sigmon_rs232_fib_top_tb/sigmon_rs232_fib_top_inst/fifo_empty
add wave -noupdate -format Logic /sigmon_rs232_fib_top_tb/sigmon_rs232_fib_top_inst/fifo_full
add wave -noupdate -divider {fub out}
add wave -noupdate -format Logic /sigmon_rs232_fib_top_tb/sigmon_rs232_fib_top_inst/fub_tx_str
add wave -noupdate -format Logic /sigmon_rs232_fib_top_tb/sigmon_rs232_fib_top_inst/fub_tx_busy
add wave -noupdate -format Literal -radix hexadecimal /sigmon_rs232_fib_top_tb/sigmon_rs232_fib_top_inst/fub_tx_data
add wave -noupdate -divider {fub in}
add wave -noupdate -format Logic /sigmon_rs232_fib_top_tb/sigmon_rs232_fib_top_inst/fub_rx_str
add wave -noupdate -format Logic /sigmon_rs232_fib_top_tb/sigmon_rs232_fib_top_inst/fub_rx_busy
add wave -noupdate -format Literal -radix hexadecimal /sigmon_rs232_fib_top_tb/sigmon_rs232_fib_top_inst/fub_rx_data
add wave -noupdate -divider {signal data}
add wave -noupdate -format Literal -radix hexadecimal /sigmon_rs232_fib_top_tb/sigmon_rs232_fib_top_inst/sig_data
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {54320000 ps} 0}
configure wave -namecolwidth 520
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
WaveRestoreZoom {0 ps} {63 us}
