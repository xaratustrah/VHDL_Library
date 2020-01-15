-------------------------------------------------------------------------------
-- Title      : Testbench for design "fub_vga"
-- Project    : 
-------------------------------------------------------------------------------
-- File       : fub_vga_tb.vhd
-- Author     : 
-- Company    : 
-- Created    : 2008-11-03
-- Last update: 2008-11-03
-- Platform   : 
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2008 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2008-11-03  1.0      ssanjari        Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use work.fub_rx_slave_pkg.all;
use work.fub_vga_pkg.all;

architecture fub_vga_tb_arch of fub_vga_tb is

  -- component generics
  constant default_gain   : std_logic_vector (3 downto 0) := "0100";
  constant spi_address    : integer                       := 2;
  constant fub_addr_width : integer                       := 4;
  constant fub_data_width : integer                       := 8;

  -- component ports
  signal vga_gain : std_logic_vector(3 downto 0);
  signal vga_str  : std_logic;
  signal vga_busy : std_logic;
  signal fub_data : std_logic_vector(fub_data_width - 1 downto 0);
  signal fub_adr  : std_logic_vector(fub_addr_width - 1 downto 0);
  signal fub_str  : std_logic;
  signal fub_busy : std_logic;

  -- clock
  signal simclk : std_logic := '1';
  signal simrst : std_logic;

begin  -- fub_vga_tb_arch

  -- component instantiation
  fub_vga_inst1 : fub_vga
    generic map (
      default_gain   => default_gain,
      spi_address    => spi_address,
      fub_addr_width => fub_addr_width,
      fub_data_width => fub_data_width)
    port map (
      clk_i      => simclk,
      rst_i      => simrst,
      vga_gain_i => vga_gain,
      vga_str_i  => vga_str,
      vga_busy_o => vga_busy,
      fub_data_o => fub_data,
      fub_adr_o  => fub_adr,
      fub_str_o  => fub_str,
      fub_busy_i => fub_busy);

  fub_rx_slave_inst1 : fub_rx_slave
    generic map (
      addr_width => fub_addr_width,
      data_width => fub_data_width,
      busy_clks  => 10)
    port map (
      rst_i      => simrst,
      clk_i      => simclk,
      fub_data_i => fub_data,
      fub_str_i  => fub_str,
      fub_busy_o => fub_busy,
      fub_addr_i => fub_adr,
      data_o     => open,
      addr_o     => open,
      str_o      => open);

  -- clock generation
  simclk   <= not simclk after 10 ns;
  simrst   <= '1', '0' after 30 ns;
  vga_gain <= "0000", "1100" after 200 ns;
  vga_str  <= '0', '1' after 350 ns;

end fub_vga_tb_arch;

