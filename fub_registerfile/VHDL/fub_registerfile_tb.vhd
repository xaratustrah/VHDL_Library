-------------------------------------------------------------------------------
-- Title      : Testbench for design "fub_registerfile"
-- Project    : 
-------------------------------------------------------------------------------
-- File       : fub_registerfile_tb.vhd
-- Author     :   <ssanjari@BTPC088>
-- Company    : 
-- Created    : 2007-07-18
-- Last update: 2007-07-24
-- Platform   : 
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2007 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2007-07-18  1.0      ssanjari        Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use work.fub_tx_master_pkg.all;

-------------------------------------------------------------------------------

entity fub_registerfile_tb is

end fub_registerfile_tb;

-------------------------------------------------------------------------------

architecture fub_registerfile_tb_arch of fub_registerfile_tb is

  component fub_registerfile
    generic (
      no_of_registers   : integer;
      fub_address_width : integer;
      fub_data_width    : integer);
    port (
      clk_i          : in  std_logic;
      rst_i          : in  std_logic;
      fub_strb_i     : in  std_logic;
      fub_data_i     : in  std_logic_vector (fub_data_width - 1 downto 0);
      fub_addr_i     : in  std_logic_vector (fub_address_width - 1 downto 0);
      fub_busy_o     : out std_logic;
      registerfile_o : out std_logic_vector (no_of_registers * register_width - 1 downto 0));
  end component;

  -- component generics
  constant no_of_registers   : integer := 6;
  constant fub_address_width : integer := 16;
  constant fub_data_width    : integer := 8;

  -- component ports
  signal fub_str  : std_logic;
  signal fub_busy : std_logic;
  signal fub_addr : std_logic_vector (fub_address_width - 1 downto 0);
  signal fub_data : std_logic_vector (fub_data_width - 1 downto 0);

  -- clock
  signal sim_clk : std_logic := '1';
  signal sim_rst : std_logic;

begin  -- fub_registerfile_tb_arch

  fub_tx_master_inst : fub_tx_master
    generic map (
      addr_width       => fub_address_width,
      data_width       => fub_data_width,
      addr_start_value => 16#0000#,
      data_start_value => 16#10#,
      addr_stop_value  => 16#0006#,
      data_stop_value  => 16#60#,
      addr_inc_value   => 16#1#,
      data_inc_value   => 16#1#,
      wait_clks        => 0)
    port map (
      rst_i      => sim_rst,
      clk_i      => sim_clk,
      fub_str_o  => fub_str,
      fub_busy_i => fub_busy,
      fub_addr_o => fub_addr,
      fub_data_o => fub_data);

  fub_registerfile_inst : fub_registerfile
    generic map (
      no_of_registers   => no_of_registers,
      register_width    => register_width,
      fub_address_width => fub_address_width,
      fub_data_width    => fub_data_width)
    port map (
      clk_i          => sim_clk,
      rst_i          => sim_rst,
      fub_strb_i     => fub_str,
      fub_data_i     => fub_data,
      fub_addr_i     => fub_addr,
      fub_busy_o     => fub_busy,
      registerfile_o => open);

  -- clock generation
  sim_clk <= not sim_clk after 10 ns;   -- 50MHz
  sim_rst <= '1', '0' after 200 ns;

end fub_registerfile_tb_arch;
