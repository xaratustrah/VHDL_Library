library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_arith.all;
use IEEE.STD_LOGIC_unsigned.all;

use work.real_time_calculator_pkg.all;


entity fib_rs232_tx_top_tb is
	generic(
		clk_freq_in_hz : real := 50.0E6;
		baud_rate  : real := 9600.0
	);
end fib_rs232_tx_top_tb;

architecture fib_rs232_tx_top_tb_arch of fib_rs232_tx_top_tb is

component fib_rs232_tx_top
		generic(
  	  	clk_freq_in_hz : real;
		  baud_rate  : real
		);
	port(
			clk0_i					:	in  std_logic;
			trig1_i 			:	in  std_logic;
			rs232_rx_i	:	in  std_logic;
			led0_o					:	out std_logic;
			led1_o					:	out std_logic;
			led2_o					:	out std_logic;
			led3_o					:	out std_logic;
			rs232_tx_o	:	out std_logic
	);
	end component; 

--external signals
signal clk0							: std_logic := '0';
signal rst						: std_logic := '0';
signal rs232_rx_i : std_logic := '0';
signal led0_o 				: std_logic := '0';
signal led1_o 				: std_logic := '0';
signal led2_o 				: std_logic := '0';
signal led3_o 				: std_logic := '0';
signal rs232_tx_o : std_logic := '0';

begin

	fib_rs232_tx_top_inst : fib_rs232_tx_top
		generic map(
    		clk_freq_in_hz => clk_freq_in_hz,
		  baud_rate => baud_rate
		)
		port map (
			clk0_i => clk0,
			trig1_i => rst,
			rs232_rx_i => rs232_rx_i,
			led0_o => led0_o,
			led1_o => led1_o,
			led2_o => led2_o,
			led3_o => led3_o,
			rs232_tx_o => rs232_tx_o
		);

  clk0 <= not clk0 after 0.5 * freq_real_to_period_time(clk_freq_in_hz);
  rst <= '1', '0' after 50 ns;

end fib_rs232_tx_top_tb_arch;