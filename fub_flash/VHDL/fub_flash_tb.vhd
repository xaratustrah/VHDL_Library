-------------------------------------------------------------------------------
-- Title      : Testbench for design "fub_flash"
-- Project    : 
-------------------------------------------------------------------------------
-- File       : fub_flash_tb.vhd
-- Author     :   <t.guthier>
-- Company    : GSI
-- Created    : 2007
-- Last update: 2007
-- Platform   : 
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2007 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  		Description
-- 2007		   1.0      t.guthier       Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use work.reset_gen_pkg.all;
use work.fub_rx_master_pkg.all;
use work.fub_tx_master_pkg.all;
use work.fub_flash_pkg.all;

-------------------------------------------------------------------------------

entity fub_flash_tb is

end fub_flash_tb;

-------------------------------------------------------------------------------

architecture fub_flash_tb_arch of fub_flash_tb is

  -- component generics
  constant addr_width       : integer := 24;
  constant data_width       : integer := 8;
  constant addr_start_value : integer := 16#20#;
  constant addr_stop_value  : integer := 16#80#;
  constant addr_inc_value   : integer := 16#1#;

  -- component generics
  constant data_start_value : integer := 16#10#;
  constant data_stop_value  : integer := 16#60#;
  constant data_inc_value   : integer := 16#1#;

  -- clock
  signal sim_clk : std_logic := '1';
  signal sim_rst : std_logic := '1';

signal fub_rx_master_fub_addr_o		: std_logic_vector( (addr_width - 1) downto 0);
signal fub_rx_master_fub_str_o		: std_logic;
signal fub_flash_fub_read_busy_o	: std_logic;
signal fub_flash_fub_read_data_o	: std_logic_vector( (data_width - 1) downto 0);

signal fub_flash_fub_write_busy_o	: std_logic;
signal fub_tx_master_fub_str_o		: std_logic;
signal fub_tx_master_fub_data_o		: std_logic_vector( (data_width - 1) downto 0);
signal fub_tx_master_fub_addr_o		: std_logic_vector( (addr_width - 1) downto 0);



begin  -- fub_flash_tb_arch

  reset_gen_1 : reset_gen
    generic map (
      reset_clks => 20)
    port map (
      clk_i => sim_clk,
      rst_o => sim_rst);

  -- component instantiation
  fub_rx_master_inst : fub_rx_master
    generic map (
      addr_width       => addr_width,
      data_width       => data_width,
      addr_start_value => addr_start_value,
      addr_stop_value  => addr_stop_value,
      addr_inc_value   => addr_inc_value)
    port map (
      fub_str_o  => fub_rx_master_fub_str_o,
      fub_busy_i => fub_flash_fub_read_busy_o,
      fub_data_i => fub_flash_fub_read_data_o,
      fub_addr_o => fub_rx_master_fub_addr_o,
      rst_i      => sim_rst,
      clk_i      => sim_clk,
      data_o     => open,
      addr_o     => open,
      str_o      => open);

	fub_tx_master_inst	:	fub_tx_master
	  generic map(
	    addr_width       => addr_width,
	    data_width       => data_width,
	    addr_start_value => addr_start_value,
	    data_start_value => data_start_value,
	    addr_stop_value  => addr_stop_value,
	    data_stop_value  => data_stop_value,
	    addr_inc_value   => addr_inc_value,
	    data_inc_value   => data_inc_value,
	    wait_clks        => 5
	    )
	  port map(
	    rst_i      => sim_rst,
	    clk_i      => sim_clk,
	    fub_str_o  => fub_tx_master_fub_str_o,
	    fub_busy_i => fub_flash_fub_write_busy_o,
	    fub_addr_o => fub_tx_master_fub_addr_o,
	    fub_data_o => fub_tx_master_fub_data_o
	    );
	
	fub_flash_inst	:	fub_flash
	generic map(
			    main_clk       				=> 100.0E+6,
				priority_on_reading			=> '1',
			    my_delay_in_ns_for_reading 	=> 25.0,	-- equal to 40 MHz // 25ns high 25ns low => 50ns equal to 20MHz CLK Signal
				my_delay_in_ns_for_writing 	=> 20.0		-- equal to 50 MHz // 20ns high 20ns low => 40ns equal to 25MHz CLK Signal
			)
	port map(  
			clk_i			=> sim_clk,
			rst_i			=> sim_rst,
			fub_write_busy_o		=> fub_flash_fub_write_busy_o,
			fub_write_data_i		=> fub_tx_master_fub_data_o,
			fub_write_adr_i			=> fub_tx_master_fub_addr_o,
			fub_write_str_i 		=> fub_tx_master_fub_str_o,
			fub_read_busy_o		=> fub_flash_fub_read_busy_o,
			fub_read_data_o		=> fub_flash_fub_read_data_o,
			fub_read_adr_i		=> fub_rx_master_fub_addr_o,
			fub_read_str_i 		=> fub_rx_master_fub_str_o,
			nCS_o					=> open,
			asdi_o					=> open,
			dclk_o					=> open,
			data_i					=> '1'
		 );


  -- clock generation
  sim_clk <= not sim_clk after 5 ns;


end fub_flash_tb_arch;
