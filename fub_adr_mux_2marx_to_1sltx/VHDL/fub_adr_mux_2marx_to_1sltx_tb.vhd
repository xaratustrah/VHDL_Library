library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_arith.all;
use IEEE.STD_LOGIC_unsigned.all;
use work.reset_gen_pkg.all;
use work.fub_rx_master_pkg.all;
use work.fub_adr_mux_2marx_to_1sltx_pkg.all;
use work.fub_tx_slave_pkg.all;


entity fub_adr_mux_2marx_to_1sltx_tb is
  
  generic(
    fub_data_width      : integer :=  8;
    fub_in_adr_width    : integer :=  9;
    fub_out_adr_width   : integer :=  8;
    reset_clks					:	integer	:=	10
  );
  
end fub_adr_mux_2marx_to_1sltx_tb;

architecture fub_adr_mux_2marx_to_1sltx_tb_arch of fub_adr_mux_2marx_to_1sltx_tb is

	signal	clk				:	std_logic	:=	'0';
	signal	rst				:	std_logic;

	signal	fubA_data	:	std_logic_vector(fub_data_width-1 downto 0);
	signal	fubA_adr	:	std_logic_vector(fub_out_adr_width-1 downto 0);
	signal	fubA_str	:	std_logic;
	signal	fubA_busy	:	std_logic;
	
	signal	fubB_data	:	std_logic_vector(fub_data_width-1 downto 0);
	signal	fubB_adr	:	std_logic_vector(fub_out_adr_width-1 downto 0);
	signal	fubB_str	:	std_logic;
	signal	fubB_busy	:	std_logic;
	
	signal	fub_data	:	std_logic_vector(fub_data_width-1 downto 0);
	signal	fub_adr		:	std_logic_vector(fub_in_adr_width-1 downto 0);
	signal	fub_str		:	std_logic;
	signal	fub_busy	:	std_logic;



	begin
		
		clk	<=	not clk after 20 ns;
		
		reset_gen_inst	:	reset_gen
		generic map(
      reset_clks	=>	reset_clks
    )
    port map(
      clk_i				=>	clk,
      rst_o				=>	rst
    );
		
		fub_rx_master_inst	:	fub_rx_master
		generic map(
      addr_width				=>	fub_in_adr_width,
      data_width				=>	fub_data_width,
      addr_start_value	=>	1,
      addr_stop_value		=>	512,
      addr_inc_value		=>	1
    )
    port map(
      fub_str_o		=>	fub_str,
      fub_busy_i	=>	fub_busy,
      fub_data_i	=>	fub_data,
      fub_addr_o	=>	fub_adr,
      rst_i				=>	rst,
      clk_i				=>	clk,
      data_o			=>	open,
      addr_o			=>	open,
      str_o				=>	open
    );
	
		fub_adr_mux_inst	:	fub_adr_mux_2marx_to_1sltx
		generic map(
			fub_data_width			=>	fub_data_width,
			fub_in_adr_width		=>	fub_in_adr_width,
			fub_out_adr_width		=>	fub_out_adr_width
		)
		port map(
			clk_i				=>	clk,
			rst_i				=>	rst,
			-- FUB channel A
			fubA_data_i	=>	fubA_data,
			fubA_adr_o	=>	fubA_adr,
			fubA_str_o	=>	fubA_str,
			fubA_busy_i =>	fubA_busy,
			-- FUB channel B
			fubB_data_i	=>	fubB_data,
			fubB_adr_o	=>	fubB_adr,
			fubB_str_o	=>	fubB_str,
			fubB_busy_i =>	fubB_busy,
			-- FUB output
			fub_data_o	=>	fub_data,
			fub_adr_i		=>	fub_adr,
			fub_str_i   =>	fub_str,
			fub_busy_o	=>	fub_busy
		);
		
		fub_tx_slave_A_inst	:	fub_tx_slave
		generic map(
      addr_width				=>	fub_out_adr_width,
      data_width				=>	fub_data_width,
      data_start_value	=>	1,
      data_stop_value		=>	256,
      data_inc_value		=>	1
    )
    port map(
      fub_str_i		=>	fubA_str,
      fub_busy_o	=>	fubA_busy,
      fub_data_o	=>	fubA_data,
      fub_addr_i	=>	fubA_adr,
      rst_i				=>	rst,
      clk_i				=>	clk,
      data_o			=>	open,
      addr_o			=>	open,
      str_o				=>	open
    );
    
    fub_tx_slave_B_inst	:	fub_tx_slave
		generic map(
      addr_width				=>	fub_out_adr_width,
      data_width				=>	fub_data_width,
      data_start_value	=>	1,
      data_stop_value		=>	256,
      data_inc_value		=>	1
    )
    port map(
      fub_str_i		=>	fubB_str,
      fub_busy_o	=>	fubB_busy,
      fub_data_o	=>	fubB_data,
      fub_addr_i	=>	fubB_adr,
      rst_i				=>	rst,
      clk_i				=>	clk,
      data_o			=>	open,
      addr_o			=>	open,
      str_o				=>	open
    );
    
end	fub_adr_mux_2marx_to_1sltx_tb_arch;