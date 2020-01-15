library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use work.fub_adr_demux_1slrx_to_2matx_pkg.all;
use work.fub_tx_master_pkg.all;
use work.fub_rx_slave_pkg.all;

entity fub_adr_demux_1slrx_to_2matx_tb is
	generic(
		adr_width	:	integer	:=	8;
		data_width	:	integer	:=	8
	);
end fub_adr_demux_1slrx_to_2matx_tb;

architecture arch of fub_adr_demux_1slrx_to_2matx_tb is
	signal	rst				:	std_logic;
	signal	clk				:	std_logic	:=	'0';
	signal	tx_str			:	std_logic;
	signal	tx_busy			:	std_logic;
	signal	tx_adr			:	std_logic_vector(adr_width-1 downto 0);
	signal	tx_data			:	std_logic_vector(data_width-1 downto 0);
	signal	rx1_data		:	std_logic_vector(data_width-1 downto 0);
	signal	rx1_adr			:	std_logic_vector(adr_width-2 downto 0);
	signal	rx1_str			:	std_logic;
	signal	rx1_busy		:	std_logic;
	signal	rx2_data		:	std_logic_vector(data_width-1 downto 0);
	signal	rx2_adr			:	std_logic_vector(adr_width-2 downto 0);
	signal	rx2_str			:	std_logic;
	signal	rx2_busy		:	std_logic;
	signal	data_rx_port1	:	std_logic_vector(data_width-1 downto 0);
	signal	adr_rx_port1	:	std_logic_vector(adr_width-2 downto 0);
	signal	data_rx_port2	:	std_logic_vector(data_width-1 downto 0);
	signal	adr_rx_port2	:	std_logic_vector(adr_width-2 downto 0);
	
	begin

		clk	<=	not	clk	after 10ns;
		rst	<=	'1', '0' after 100ns;

		fub_tx_master_inst	:	fub_tx_master  
		generic map(
			addr_width		=>	adr_width,
			data_width		=>	data_width,
			addr_start_value	=>	16#20#,
			data_start_value	=>	16#10#,
			addr_stop_value	=>	16#80#,
			data_stop_value	=>	16#60#,
			addr_inc_value	=>	16#1#,
			data_inc_value	=>	16#1#,
			wait_clks			=>	0
			)
		port map(
			rst_i		=>	rst,
			clk_i		=>	clk,
			fub_str_o	=>	tx_str,
			fub_busy_i	=>	tx_busy,
			fub_addr_o	=>	tx_adr,
			fub_data_o	=>	tx_data
		);
		
		fub_adr_demux_inst	:	fub_adr_demux_1slrx_to_2matx
		generic map(
			fub_i_data_width	=>	data_width,
			fub_a_data_width	=>	data_width,
			fub_b_data_width	=>	data_width,
			fub_i_adr_width		=>	adr_width,
			fub_a_adr_width		=>	adr_width-1,
			fub_b_adr_width		=>	adr_width-1
		)
		port map(
			clk_i			=>	clk,
			rst_i			=>	rst,
			fub_i_data_i	=>	tx_data,
			fub_i_adr_i		=>	tx_adr,
			fub_i_str_i		=>	tx_str,
			fub_i_busy_o	=>	tx_busy,
			fub_a_data_o	=>	rx1_data,
			fub_a_adr_o		=>	rx1_adr,
			fub_a_str_o		=>	rx1_str,
			fub_a_busy_i	=>	rx1_busy,
			fub_b_data_o	=>	rx2_data,
			fub_b_adr_o		=>	rx2_adr,
			fub_b_str_o		=>	rx2_str,
			fub_b_busy_i	=>	rx2_busy
		);
		
		rx_one_inst	:	fub_rx_slave
		generic map(
			addr_width	=>	adr_width-1,
			data_width	=>	data_width,
			busy_clks		=>	0
		)
		port map(
			rst_i		=>	rst,
			clk_i		=>	clk,
			fub_data_i	=>	rx1_data,
			fub_str_i	=>	rx1_str,
			fub_busy_o	=>	rx1_busy,
			fub_addr_i	=>	rx1_adr,
			data_o		=>	data_rx_port1,
			addr_o		=>	adr_rx_port1,
			str_o		=>	open
		);
		
		rx_two_inst	:	fub_rx_slave
		generic map(
			addr_width	=>	adr_width-1,
			data_width	=>	data_width,
			busy_clks		=>	0
		)
		port map(
			rst_i		=>	rst,
			clk_i		=>	clk,
			fub_data_i	=>	rx2_data,
			fub_str_i	=>	rx2_str,
			fub_busy_o	=>	rx2_busy,
			fub_addr_i	=>	rx2_adr,
			data_o		=>	data_rx_port2,
			addr_o		=>	adr_rx_port2,
			str_o		=>	open
		);
		
end arch;