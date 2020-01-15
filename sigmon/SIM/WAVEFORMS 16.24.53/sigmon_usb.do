onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Logic /sigmon_usb_fib_top_tb/sigmon_usb_fib_top_inst/clk
add wave -noupdate -format Logic /sigmon_usb_fib_top_tb/sigmon_usb_fib_top_inst/clk100
add wave -noupdate -format Logic /sigmon_usb_fib_top_tb/sigmon_usb_fib_top_inst/clk200
add wave -noupdate -format Logic /sigmon_usb_fib_top_tb/sigmon_usb_fib_top_inst/rst
add wave -noupdate -divider FIFO
add wave -noupdate -format Literal -radix hexadecimal /sigmon_usb_fib_top_tb/sigmon_usb_fib_top_inst/fifo_data_in
add wave -noupdate -format Literal -radix hexadecimal /sigmon_usb_fib_top_tb/sigmon_usb_fib_top_inst/fifo_data_out
add wave -noupdate -format Logic /sigmon_usb_fib_top_tb/sigmon_usb_fib_top_inst/fifo_rdreq
add wave -noupdate -format Logic /sigmon_usb_fib_top_tb/sigmon_usb_fib_top_inst/fifo_wrreq
add wave -noupdate -format Logic /sigmon_usb_fib_top_tb/sigmon_usb_fib_top_inst/fifo_empty
add wave -noupdate -format Logic /sigmon_usb_fib_top_tb/sigmon_usb_fib_top_inst/fifo_full
add wave -noupdate -divider FTDI
add wave -noupdate -format Literal -radix hexadecimal /sigmon_usb_fib_top_tb/sigmon_usb_fib_top_inst/ftdi_d
add wave -noupdate -format Logic /sigmon_usb_fib_top_tb/sigmon_usb_fib_top_inst/ftdi_nrd
add wave -noupdate -format Logic /sigmon_usb_fib_top_tb/sigmon_usb_fib_top_inst/ftdi_wr
add wave -noupdate -format Logic /sigmon_usb_fib_top_tb/sigmon_usb_fib_top_inst/ftdi_nrxf
add wave -noupdate -format Logic /sigmon_usb_fib_top_tb/sigmon_usb_fib_top_inst/ftdi_ntxe
add wave -noupdate -format Logic /sigmon_usb_fib_top_tb/sigmon_usb_fib_top_inst/ftdi_nrxf_synced
add wave -noupdate -format Logic /sigmon_usb_fib_top_tb/sigmon_usb_fib_top_inst/ftdi_ntxe_synced
add wave -noupdate -divider {FUB In}
add wave -noupdate -format Literal -radix hexadecimal /sigmon_usb_fib_top_tb/sigmon_usb_fib_top_inst/fub_ftdi_usb_inst/fub_in_data_i
add wave -noupdate -format Logic /sigmon_usb_fib_top_tb/sigmon_usb_fib_top_inst/fub_ftdi_usb_inst/fub_in_str_i
add wave -noupdate -format Logic /sigmon_usb_fib_top_tb/sigmon_usb_fib_top_inst/fub_ftdi_usb_inst/fub_in_busy_o
add wave -noupdate -divider {FUB Out}
add wave -noupdate -format Literal -radix hexadecimal /sigmon_usb_fib_top_tb/sigmon_usb_fib_top_inst/fub_ftdi_usb_inst/fub_out_data_o
add wave -noupdate -format Logic /sigmon_usb_fib_top_tb/sigmon_usb_fib_top_inst/fub_ftdi_usb_inst/fub_out_str_o
add wave -noupdate -format Logic /sigmon_usb_fib_top_tb/sigmon_usb_fib_top_inst/fub_ftdi_usb_inst/fub_out_busy_i
add wave -noupdate -format Logic /sigmon_usb_fib_top_tb/sigmon_usb_fib_top_inst/sigmon_ctrl_inst/fub_rx_busy_o
add wave -noupdate -divider {signal data}
add wave -noupdate -format Literal -radix hexadecimal /sigmon_usb_fib_top_tb/sigmon_usb_fib_top_inst/sig_data
add wave -noupdate -divider {SigMon CTRL}
add wave -noupdate -format Literal /sigmon_usb_fib_top_tb/sigmon_usb_fib_top_inst/sigmon_ctrl_inst/state
add wave -noupdate -divider fub_ftdi_usb
add wave -noupdate -format Literal /sigmon_usb_fib_top_tb/sigmon_usb_fib_top_inst/fub_ftdi_usb_inst/state
add wave -noupdate -format Literal /sigmon_usb_fib_top_tb/sigmon_usb_fib_top_inst/sigmon_ctrl_inst/state
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {22685000 ps} 0}
configure wave -namecolwidth 448
configure wave -valuecolwidth 103
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
WaveRestoreZoom {20958751 ps} {24839433 ps}
