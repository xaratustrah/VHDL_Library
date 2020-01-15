-------------------------------------------------------------------------------
-- Title      : Testbench for design "fub_multi_spi_master"
-- Project    : 
-------------------------------------------------------------------------------
-- File       : fub_multi_spi_master_tb.vhd
-- Author     : 
-- Company    : 
-- Created    : 2008-10-29
-- Last update: 2008-11-12
-- Platform  :: 
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2008 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2008-10-29  1.0      ssanjari        Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_arith.all;
use IEEE.STD_LOGIC_unsigned.all;
use ieee.math_real.all;
use ieee.numeric_std.all;


-------------------------------------------------------------------------------

entity fub_multi_spi_master_tb is

end fub_multi_spi_master_tb;

-------------------------------------------------------------------------------

architecture fub_multi_spi_master_arch of fub_multi_spi_master_tb is

  -- component generics
  constant slave0_byte_count : integer := 3;
  constant slave1_byte_count : integer := 0;
  constant slave2_byte_count : integer := 0;
  constant slave3_byte_count : integer := 0;
  constant slave4_byte_count : integer := 0;
  constant slave5_byte_count : integer := 0;
  constant slave6_byte_count : integer := 0;
  constant slave7_byte_count : integer := 0;
  constant slave8_byte_count : integer := 0;
  constant slave9_byte_count : integer := 0;

  constant data_width : integer := 8;

  constant addr_start_value : integer := 16#4#;
  constant data_start_value : integer := 16#AA#;
  constant addr_stop_value  : integer := 16#0#;
  constant data_stop_value  : integer := 16#EE#;
  constant addr_inc_value   : integer := -1;
  constant data_inc_value   : integer := 16#1#;
  constant wait_clks        : integer := 0;

  constant number_of_required_bits : integer := integer(ceil(log2(real(slave0_byte_count + slave1_byte_count + slave2_byte_count + slave3_byte_count + slave4_byte_count + slave5_byte_count + slave6_byte_count + slave7_byte_count + slave8_byte_count + slave9_byte_count))));

  component fub_multi_spi_master
    generic (
      clk_freq_in_hz        : real;
      spi_clk_perid_in_ns   : real;
      spi_setup_delay_in_ns : real;
      slave0_byte_count     : integer;
      slave1_byte_count     : integer;
      slave2_byte_count     : integer;
      slave3_byte_count     : integer;
      slave4_byte_count     : integer;
      slave5_byte_count     : integer;
      slave6_byte_count     : integer;
      slave7_byte_count     : integer;
      slave8_byte_count     : integer;
      slave9_byte_count     : integer;
      data_width            : integer);
    port (
      clk_i       : in  std_logic;
      rst_i       : in  std_logic;
      fub_str_i   : in  std_logic;
      fub_busy_o  : out std_logic;
      fub_data_i  : in  std_logic_vector(7 downto 0);
      fub_addr_i  : in  std_logic_vector(number_of_required_bits - 1 downto 0);
      fub_error_o : out std_logic;
      fub_str_o   : out std_logic;
      fub_busy_i  : in  std_logic;
      fub_data_o  : out std_logic_vector(7 downto 0);
      spi_mosi_o  : out std_logic;
      spi_miso_i  : in  std_logic;
      spi_clk_o   : out std_logic;
      spi_ss_o    : out std_logic_vector (9 downto 0));
  end component;

  component fub_tx_master
    generic (
      addr_width       : integer;
      data_width       : integer;
      addr_start_value : integer;
      data_start_value : integer;
      addr_stop_value  : integer;
      data_stop_value  : integer;
      addr_inc_value   : integer;
      data_inc_value   : integer;
      wait_clks        : integer);
    port (
      rst_i      : in  std_logic;
      clk_i      : in  std_logic;
      fub_str_o  : out std_logic;
      fub_busy_i : in  std_logic;
      fub_addr_o : out std_logic_vector (number_of_required_bits - 1 downto 0);
      fub_data_o : out std_logic_vector (data_width-1 downto 0));
  end component;

  -- component ports
  signal fubA_str   : std_logic;
  signal fubA_busy  : std_logic;
  signal fubA_data  : std_logic_vector(7 downto 0);
  signal fubA_addr  : std_logic_vector(number_of_required_bits - 1 downto 0);
  signal fubA_error : std_logic;

  signal spi_mosi : std_logic;
  signal spi_miso : std_logic;
  signal spi_clk  : std_logic;
  signal spi_ss   : std_logic_vector (9 downto 0);


  -- clock
  signal simclk : std_logic := '1';
  signal simrst : std_logic;
  
begin  -- fub_multi_spi_master_arch

  -- component instantiation
  fub_multi_spi_master_inst1 : fub_multi_spi_master
    generic map (
      clk_freq_in_hz => 50.0E6,

      spi_clk_perid_in_ns   => 1000.0,
      spi_setup_delay_in_ns => 1000.0,

      slave0_byte_count => slave0_byte_count,
      slave1_byte_count => slave1_byte_count,
      slave2_byte_count => slave2_byte_count,
      slave3_byte_count => slave3_byte_count,
      slave4_byte_count => slave4_byte_count,
      slave5_byte_count => slave5_byte_count,
      slave6_byte_count => slave6_byte_count,
      slave7_byte_count => slave7_byte_count,
      slave8_byte_count => slave8_byte_count,
      slave9_byte_count => slave9_byte_count,
      data_width        => data_width)
    port map (
      clk_i       => simclk,
      rst_i       => simrst,
      fub_str_i   => fubA_str,
      fub_busy_o  => fubA_busy,
      fub_data_i  => fubA_data,
      fub_addr_i  => fubA_addr,
      fub_error_o => fubA_error,
      fub_str_o   => open,
      fub_busy_i  => '0',
      fub_data_o  => open,
      spi_mosi_o  => spi_mosi,
      spi_miso_i  => spi_miso,
      spi_clk_o   => spi_clk,
      spi_ss_o    => spi_ss);

  fub_tx_master_inst1 : fub_tx_master
    generic map (
      addr_width       => number_of_required_bits,
      data_width       => data_width,
      addr_start_value => addr_start_value,
      data_start_value => data_start_value,
      addr_stop_value  => addr_stop_value,
      data_stop_value  => data_stop_value,
      addr_inc_value   => addr_inc_value,
      data_inc_value   => data_inc_value,
      wait_clks        => wait_clks)
    port map (
      rst_i      => simrst,
      clk_i      => simclk,
      fub_str_o  => fubA_str,
      fub_busy_i => fubA_busy,
      fub_addr_o => fubA_addr,
      fub_data_o => fubA_data);

  -- clock generation
  simclk <= not simclk after 10 ns;     -- 50 MHz
  simrst <= '1', '0' after 30 ns;
  
end fub_multi_spi_master_arch;
