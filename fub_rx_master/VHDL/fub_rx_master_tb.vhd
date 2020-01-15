-------------------------------------------------------------------------------
-- Title      : Testbench for design "fub_rx_master"
-- Project    : 
-------------------------------------------------------------------------------
-- File       : fub_rx_master_tb.vhd
-- Author     :   <ssanjari@BTPC088>
-- Company    : 
-- Created    : 2007-05-29
-- Last update: 2007-11-30
-- Platform   : 
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2007 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2007-05-29  1.0      ssanjari        Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use work.reset_gen_pkg.all;

-------------------------------------------------------------------------------

entity fub_rx_master_tb is

end fub_rx_master_tb;

-------------------------------------------------------------------------------

architecture fub_rx_master_tb_arch of fub_rx_master_tb is

  component fub_rx_master
    generic (
      addr_width       : integer;
      data_width       : integer;
      addr_start_value : integer;
      addr_stop_value  : integer;
      addr_inc_value   : integer);
    port (
      fub_str_o  : out std_logic;
      fub_busy_i : in  std_logic;
      fub_data_i : in  std_logic_vector (data_width-1 downto 0);
      fub_addr_o : out std_logic_vector (addr_width-1 downto 0);
      rst_i      : in  std_logic;
      clk_i      : in  std_logic;
      data_o     : out std_logic_vector (data_width-1 downto 0);
      addr_o     : out std_logic_vector (addr_width-1 downto 0);
      str_o      : out std_logic);
  end component;

  component fub_tx_slave
    generic (
      addr_width       : integer;
      data_width       : integer;
      data_start_value : integer;
      data_stop_value  : integer;
      data_inc_value   : integer);
    port (
      fub_str_i  : in  std_logic;
      fub_busy_o : out std_logic;
      fub_data_o : out std_logic_vector (data_width-1 downto 0);
      fub_addr_i : in  std_logic_vector (addr_width-1 downto 0);
      rst_i      : in  std_logic;
      clk_i      : in  std_logic;
      data_o     : out std_logic_vector (data_width-1 downto 0);
      addr_o     : out std_logic_vector (addr_width-1 downto 0);
      str_o      : out std_logic);
  end component;

  -- component generics
  constant addr_width       : integer := 8;
  constant data_width       : integer := 8;
  constant addr_start_value : integer := 16#20#;
  constant addr_stop_value  : integer := 16#24#;
  constant addr_inc_value   : integer := 16#1#;

  -- component generics
  constant data_start_value : integer := 16#10#;
  constant data_stop_value  : integer := 16#60#;
  constant data_inc_value   : integer := 16#1#;

  -- clock
  signal sim_clk : std_logic := '1';
  signal sim_rst : std_logic := '1';

  signal sim_strobe : std_logic;
  signal sim_busy   : std_logic;
  signal sim_data   : std_logic_vector(data_width-1 downto 0);
  signal sim_addr   : std_logic_vector(addr_width-1 downto 0);

begin  -- fub_rx_master_tb_arch

  reset_gen_1 : reset_gen
    generic map (
      reset_clks => 20)
    port map (
      clk_i => sim_clk,
      rst_o => sim_rst);

  -- component instantiation
  fub_rx_master_1 : fub_rx_master
    generic map (
      addr_width       => addr_width,
      data_width       => data_width,
      addr_start_value => addr_start_value,
      addr_stop_value  => addr_stop_value,
      addr_inc_value   => addr_inc_value)
    port map (
      fub_str_o  => sim_strobe,
      fub_busy_i => sim_busy,
      fub_data_i => sim_data,
      fub_addr_o => sim_addr,
      rst_i      => sim_rst,
      clk_i      => sim_clk,
      data_o     => open,
      addr_o     => open,
      str_o      => open);

  fub_tx_slave_1 : fub_tx_slave
    generic map (
      addr_width       => addr_width,
      data_width       => data_width,
      data_start_value => data_start_value,
      data_stop_value  => data_stop_value,
      data_inc_value   => data_inc_value)
    port map (
      fub_str_i  => sim_strobe,
      fub_busy_o => sim_busy,
      fub_data_o => sim_data,
      fub_addr_i => sim_addr,
      rst_i      => sim_rst,
      clk_i      => sim_clk,
      data_o     => open,
      addr_o     => open,
      str_o      => open);

  -- clock generation
  sim_clk <= not sim_clk after 10 ns;

end fub_rx_master_tb_arch;
