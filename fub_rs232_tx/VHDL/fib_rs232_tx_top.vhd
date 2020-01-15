library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_arith.all;
use IEEE.STD_LOGIC_unsigned.all;
use ieee.math_real.all;

use work.fub_rs232_tx_pkg.all;
use work.fub_tx_master_pkg.all;
use work.reset_gen_pkg.all;


entity fib_rs232_tx_top is
		generic(
  	  	clk_freq_in_hz : real := 50.0E6;
		  baud_rate  : real := 9600.0
		);
		port(
			clk0_i						:	in  std_logic;
			trig1_i 				:	in  std_logic;
			rs232_rx_i		:	in  std_logic;
			led0_o						:	out std_logic;
			led1_o						:	out std_logic;
			led2_o						:	out std_logic;
			led3_o						:	out std_logic;
			rs232_tx_o		:	out std_logic
	);
	
end fib_rs232_tx_top; 

architecture fib_rs232_tx_top_arch of fib_rs232_tx_top is
	signal fub_str : std_logic;
	signal fub_busy : std_logic;
	signal fub_data : std_logic_vector(7 downto 0);
	signal fub_addr : std_logic_vector(7 downto 0);
	
	signal rst : std_logic;
	
begin

led1_o <= '1';

fub_rs232_tx_inst : fub_rs232_tx
	generic map (
		clk_freq_in_hz => clk_freq_in_hz,
		baud_rate => baud_rate
	)
	port map (
		clk_i => clk0_i,
		rst_i => rst,
		rs232_tx_o => rs232_tx_o,
		fub_str_i => fub_str,
		fub_busy_o => fub_busy,
		fub_data_i => fub_data
	);

fub_tx_master_inst : fub_tx_master
  generic map(
      addr_width       => 8,
      data_width       => 8,
      addr_start_value => 16#20#, --ASCII 'A'
      data_start_value => 16#41#,
      addr_stop_value  => 16#80#,
      data_stop_value  => 16#5A#, --ASCII 'Z'
      addr_inc_value   => 16#1#,
      data_inc_value   => 16#1#,
      wait_clks        => 0
  )
	port map (
		clk_i => clk0_i,
		rst_i => rst,
		fub_str_o => fub_str,
		fub_busy_i => fub_busy,
		fub_data_o => fub_data,
		fub_addr_o => fub_addr
	);

	reset_gen_inst : reset_gen
	generic map (
    reset_clks => 2
	)
	port map (
			clk_i => clk0_i,
			rst_o	=> rst
	);

	
end fib_rs232_tx_top_arch;
