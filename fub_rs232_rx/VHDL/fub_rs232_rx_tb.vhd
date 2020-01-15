library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_arith.all;
use IEEE.STD_LOGIC_unsigned.all;

use work.fub_rs232_tx_pkg.all;
use work.fub_rs232_rx_pkg.all;
use work.fub_tx_master_pkg.all;
use work.fub_rx_slave_pkg.all;
use work.real_time_calculator_pkg.all;

entity fub_rs232_rx_tb is
	generic(
		clk_freq_in_hz : real := 50.0E6;
		baud_rate  : real := 9600.0
	);
end fub_rs232_rx_tb; 

architecture fub_rs232_rx_tb_arch of fub_rs232_rx_tb is
	signal fub_tx_str : std_logic;
	signal fub_tx_busy : std_logic;
	signal fub_tx_data : std_logic_vector(7 downto 0);
	signal fub_tx_addr : std_logic_vector(7 downto 0);

	signal fub_rx_str : std_logic;
	signal fub_rx_busy : std_logic;
	signal fub_rx_data : std_logic_vector(7 downto 0);
	signal fub_rx_addr : std_logic_vector(7 downto 0);
	
	signal rs232 : std_logic;
	
	signal rx_data : std_logic_vector(7 downto 0);
	signal rx_addr : std_logic_vector(7 downto 0);
	signal rx_str 	: std_logic;

	signal clk : std_logic := '0';
	signal rst : std_logic;


begin

fub_tx_master_inst : fub_tx_master
  generic map (
		addr_width  	  => 8,
		data_width 		  => 8,
		addr_start_value  => 0,
		addr_stop_value   => 0,
		addr_inc_value 	  => 0,
		data_start_value  => 16#61#, --'a'
		data_stop_value   => 16#7a#, --'z'
		data_inc_value 	  => 16#1#,
		wait_clks  		  => 0
	)      
	port map (
		clk_i => clk,
		rst_i => rst,
		fub_str_o => fub_tx_str,
		fub_busy_i => fub_tx_busy,
		fub_data_o => fub_tx_data,
		fub_addr_o => fub_tx_addr
	);

rs232_tx_inst : fub_rs232_tx
	generic map (
		clk_freq_in_hz => clk_freq_in_hz,
		baud_rate => baud_rate
	)
	port map (
		clk_i => clk,
		rst_i => rst,
		rs232_tx_o => rs232,
		fub_str_i => fub_tx_str,
		fub_busy_o => fub_tx_busy,
		fub_data_i => fub_tx_data
	);

rs232_rx_inst : fub_rs232_rx
	generic map (
		clk_freq_in_hz => clk_freq_in_hz,
		baud_rate => baud_rate
	)
	port map (
		clk_i => clk,
		rst_i => rst,
		rs232_rx_i => rs232,
		fub_str_o => fub_rx_str,
		fub_busy_i => fub_rx_busy,
		fub_data_o => fub_rx_data
	);


fub_rx_slave_inst : fub_rx_slave
  generic map (
		addr_width  => 8,
		data_width => 8,
		busy_clks => 60000
  )
	port map (
		clk_i => clk,
		rst_i => rst,
		fub_data_i => fub_rx_data,
		fub_str_i => fub_rx_str,
		fub_busy_o => fub_rx_busy,
		fub_addr_i => fub_rx_addr,
		data_o => rx_data,
		addr_o => rx_addr,
		str_o => rx_str
	);

  clk <= not clk after 0.5 * freq_real_to_period_time(clk_freq_in_hz);
  rst <= '1', '0' after 50 ns;

end fub_rs232_rx_tb_arch;
