library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use	work.reset_gen_pkg.all;
use work.fub_ram_interface_pkg.all;
use work.fub_tx_master_pkg.all;
use work.fub_rx_master_pkg.all;

entity fub_ram_interface_tb is
	generic (
			adr_width			:	integer		:=	16;
			data_width			:	integer		:=	8;
			delay_clk			:	integer		:=	2;			--	delay of RAM
			priority_on_read	:	std_logic	:=	'0';
			rst_clk				:	integer		:=	150;
			adr_start_value		:	integer		:=	16#20#;
			data_start_value 	:	integer		:=	16#10#;
			adr_stop_value		:	integer		:=	16#80#;
			data_stop_value		:	integer		:=	16#60#;
			adr_inc_value		:	integer		:=	16#1#;
			data_inc_value		:	integer		:=	16#1#;
			wait_clks			:	integer		:=	0
	);
end fub_ram_interface_tb;

architecture beh_arch of fub_ram_interface_tb is
	signal	clk				:	std_logic		:=	'0';
	signal	rst				:	std_logic;
			--	FUB in
	signal	fub_write_adr	:	std_logic_vector(adr_width-1 downto 0);
	signal	fub_write_data	:	std_logic_vector(data_width-1 downto 0);
	signal	fub_write_str	:	std_logic;
	signal	fub_write_busy	:	std_logic;
			--	FUB out
	signal	fub_read_adr	:	std_logic_vector(adr_width-1 downto 0);
	signal	fub_read_data	:	std_logic_vector(data_width-1 downto 0);
	signal	fub_read_str	:	std_logic;
	signal	fub_read_busy	:	std_logic;
			--	RAM
	signal	ram_wren		:	std_logic;
	signal	ram_adr			:	std_logic_vector (adr_width-1 downto 0);
	signal	ram_data		:	std_logic_vector (data_width-1 downto 0);
	signal	ram_q			:	std_logic_vector (data_width-1 downto 0);
	
	begin
		
		clk <=	not clk after 10 ns;
		
		reset_gen_inst	:	reset_gen		
		generic map(
			reset_clks	=>	rst_clk
		)
		port map(
			clk_i	=>	clk,
			rst_o	=>	rst
		);
		
		fub_tx_master_inst : fub_tx_master
		generic map(
			addr_width       => adr_width,
			data_width       => data_width,
			addr_start_value => 16#30#,
			data_start_value => data_start_value,
			addr_stop_value  => adr_stop_value,
			data_stop_value  => data_stop_value,
			addr_inc_value   => adr_inc_value,
			data_inc_value   => data_inc_value,
			wait_clks        => 0
		)
		port map (
			clk_i      => clk,
			rst_i      => rst,
			fub_str_o  => fub_write_str,
			fub_busy_i => fub_write_busy,
			fub_addr_o => fub_write_adr,
			fub_data_o => fub_write_data
		);
		
		
		fub_rx_master_inst : fub_rx_master
		generic map (
			addr_width       => adr_width,
			data_width       => data_width,
			addr_start_value => adr_start_value,
			addr_stop_value  => adr_stop_value,
			addr_inc_value   => adr_inc_value
		)
		port map (
			fub_str_o  => fub_read_str,
			fub_busy_i => fub_read_busy,
			fub_data_i => fub_read_data,
			fub_addr_o => fub_read_adr,
			rst_i      => rst,
			clk_i      => clk,
			data_o     => open,
			addr_o     => open,
			str_o      => open
		);
		
		
		fub_ram_interface_inst	:	fub_ram_interface
		generic map(
			adr_width			=>	adr_width,
			data_width			=>	data_width,
			delay_clk			=>	delay_clk,
			priority_on_read	=>	priority_on_read
		)
		port map(
			clk_i				=>	clk,
			rst_i				=>	rst,
			--	FUB in
			fub_write_adr_i		=>	fub_write_adr,
			fub_write_data_i	=>	fub_write_data,
			fub_write_str_i		=>	fub_write_str,
			fub_write_busy_o	=>	fub_write_busy,
			--	FUB out
			fub_read_adr_i		=>	fub_read_adr,
			fub_read_data_o		=>	fub_read_data,
			fub_read_str_i		=>	fub_read_str,
			fub_read_busy_o		=>	fub_read_busy,
			--	RAM
			ram_wren_o			=>	ram_wren,
			ram_adr_o			=>	ram_adr,
			ram_data_o			=>	ram_data,
			ram_q_i				=>	ram_q
		);

end beh_arch;