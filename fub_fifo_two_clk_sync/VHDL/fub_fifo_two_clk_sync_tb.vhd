library ieee;
library altera_mf;
use ieee.std_logic_1164.all;
use ieee.math_real.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use altera_mf.all;
use work.fub_fifo_two_clk_sync_pkg.all;
use work.fub_tx_master_pkg.all;
use work.reset_gen_pkg.all;
use work.fub_rx_slave_pkg.all;

entity fub_fifo_two_clk_sync_tb is

	generic(
		intended_device_family	:	string			:=	"Cyclone";
		worddepth								:	integer			:=	4;
		use_adr									:	integer			:=	1;
		fub_data_width					:	integer			:=	8;
		fub_adr_width						:	integer			:=	16
	);
	
end fub_fifo_two_clk_sync_tb;

architecture fub_fifo_two_clk_sync_tb_arch of fub_fifo_two_clk_sync_tb is

	signal	rst					:   std_logic;
	signal	write_clk		:   std_logic	:=	'0';
	signal	read_clk		 :   std_logic	:=	'0';
	-- FUB write Port
	signal	fub_write_data	:   std_logic_vector(fub_data_width-1 downto 0);
	signal	fub_write_adr		:   std_logic_vector((fub_adr_width-1)*use_adr downto 0);
	signal	fub_write_str		:   std_logic;
	signal	fub_write_busy	:   std_logic;
	-- FUB read Port
	signal	fub_read_data		:   std_logic_vector(fub_data_width-1 downto 0);
	signal	fub_read_adr		:   std_logic_vector((fub_adr_width-1)*use_adr downto 0);
	signal	fub_read_str		:   std_logic;
	signal	fub_read_busy		:   std_logic;
	
	begin

		write_clk	<=	not write_clk after 10ns;
		read_clk  <= not read_clk after 6.25ns;

		rst_gen	:	reset_gen
		generic map(
      reset_clks	=>	8
    )
    port map(
      clk_i				=>	write_clk,
      rst_o				=>	rst
    );

		fub_tx	:	fub_tx_master
		generic map(
      addr_width				=>	fub_adr_width,
      data_width				=>	fub_data_width,
      addr_start_value	=> 16#10#,
      data_start_value	=> 16#01#,
      addr_stop_value		=> 16#2f#,
      data_stop_value		=> 16#0f#,
      addr_inc_value		=> 16#1#,
      data_inc_value		=> 16#1#,
      wait_clks					=>	0
    )
    port map(
      rst_i				=>	rst,
      clk_i				=>	write_clk,
      fub_str_o		=>	fub_write_str,
      fub_busy_i	=>	fub_write_busy,
      fub_addr_o	=>	fub_write_adr,
      fub_data_o	=>	fub_write_data
    );
	
		sync	:	fub_fifo_two_clk_sync
		generic map(
			intended_device_family	=>	intended_device_family,
			worddepth								=>	worddepth,
			use_adr									=>	use_adr,
			fub_data_width					=>	fub_data_width,
			fub_adr_width						=>	fub_adr_width
		)
		port map(
			rst_i										=>	rst,
			write_clk_i							=>	write_clk,
			read_clk_i							=>	read_clk,
			-- FUB write Port
			fub_write_data_i				=>	fub_write_data,
			fub_write_adr_i					=>	fub_write_adr,
			fub_write_str_i					=>	fub_write_str,
			fub_write_busy_o				=>	fub_write_busy,
			-- FUB read Port
			fub_read_data_o					=>	fub_read_data,
			fub_read_adr_o					=>	fub_read_adr,
			fub_read_str_o					=>	fub_read_str,
			fub_read_busy_i					=>	fub_read_busy
		);
		
		fub_rx	:	fub_rx_slave
		generic map(
      addr_width	=>	fub_adr_width,
      data_width 	=>	fub_data_width,
      busy_clks		=>	0
      )
    port map(
      rst_i				=>	rst,
      clk_i      	=>	read_clk,
      fub_data_i	=>	fub_read_data,
      fub_str_i		=>	fub_read_str,
      fub_busy_o	=>	fub_read_busy,
      fub_addr_i	=>	fub_read_adr,
      data_o			=>	open,
      addr_o			=>	open,
      str_o				=>	open
    );

	end fub_fifo_two_clk_sync_tb_arch;
