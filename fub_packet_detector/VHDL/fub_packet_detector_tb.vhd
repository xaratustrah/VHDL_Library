-------------------------------------------------------------------------------
-- Title      : Testbench for design "fub_packet_detector"
-- Project    : 
-------------------------------------------------------------------------------
-- File       : fub_packet_detector_tb.vhd
-- Author     :   <ssanjari@BTPC088>
-- Company    : 
-- Created    : 2007-10-05
-- Last update: 2007-10-05
-- Platform   : 
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2007 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2007-10-05  1.0      ssanjari        Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use work.fub_tx_master_pkg.all;
use work.fub_packet_detector_pkg.all;

-------------------------------------------------------------------------------

entity fub_packet_detector_tb is

end fub_packet_detector_tb;

-------------------------------------------------------------------------------

architecture fub_packet_detector_arch of fub_packet_detector_tb is

  -- component ports
  signal fub_data : std_logic_vector(7 downto 0);
  signal fub_addr : std_logic_vector(7 downto 0);
  signal fub_strb : std_logic;
  signal fub_busy : std_logic;
  signal detect   : std_logic;

  -- clock
  signal clk : std_logic := '1';
  signal rst : std_logic := '1';

begin  -- fub_packet_detector_arch

  -- component instantiation
  DUT : fub_packet_detector
    generic map (
      detect_on_address        => 16#25#,
      enable_address_detection => false,
      detect_on_data           => 16#17#,
      enable_data_detection    => true,
      fub_data_width           => 8,
      fub_adr_width            => 8
    )
    port map (
      clk_i      => clk,
      rst_i      => rst,
      fub_data_i => fub_data,
      fub_addr_i => fub_addr,
      fub_strb_i => fub_strb,
      fub_busy_o => fub_busy,
      detect_o   => detect);

  fub_tx_master_1 : fub_tx_master
    generic map (
      addr_width       => 8,
      data_width       => 8,
      addr_start_value => 16#20#,
      data_start_value => 16#10#,
      addr_stop_value  => 16#80#,
      data_stop_value  => 16#60#,
      addr_inc_value   => 16#1#,
      data_inc_value   => 16#1#,
      wait_clks        => 0)      
    port map (
      rst_i      => rst,
      clk_i      => clk,
      fub_str_o  => fub_strb,
      fub_busy_i => fub_busy,
      fub_addr_o => fub_addr,
      fub_data_o => fub_data);

  -- clock generation
  clk <= not clk after 10 ns;
  rst <= '1', '0' after 40 ns;

end fub_packet_detector_arch;

