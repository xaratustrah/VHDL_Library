-------------------------------------------------------------------------------
-- Title      : Testbench for design "clk_divider"
-- Project    : 
-------------------------------------------------------------------------------
-- File       : clk_divider_tb.vhd
-- Author     :   <hfaccnt4@BTPC66>
-- Company    : 
-- Created    : 2006-07-27
-- Last update: 2009-06-16
-- Platform   : 
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2006 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2006-07-27  1.0      hfaccnt4        Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

-------------------------------------------------------------------------------

entity clk_divider_tb is
  generic (
    clk_period : time    := 20 ns;
    rst_clks   : integer := 20
    );
end clk_divider_tb;

-------------------------------------------------------------------------------

architecture asd of clk_divider_tb is

  component clk_divider
    generic (
      clk_divider_width : integer);
    port (
      clk_div_i : in  std_logic_vector (clk_divider_width - 1 downto 0);
      rst_i     : in  std_logic;
      clk_i     : in  std_logic;
      clk_o     : out std_logic);
  end component;

  -- component generics
  constant clk_divider_width : integer := 16;

  -- component ports
  signal sim_rst : std_logic;
  signal sim_clk : std_logic := '1';
  signal sim_teiler : std_logic_vector (clk_divider_width - 1 downto 0);
  
begin  -- asd

  -- component instantiation

  DUT : clk_divider
    generic map (
      clk_divider_width => clk_divider_width)
    port map (
      clk_div_i => sim_teiler,
      rst_i     => sim_rst,
      clk_i     => sim_clk,
      clk_o     => open);

  -- wave generation
  sim_clk <= not sim_clk after clk_period /2;
  sim_rst <= '1', '0' after 200 ns;

sim_teiler <= (others => '0'), x"0003" after 500 ns , x"0001" after 1000 ns, x"0002" after 1500 ns, x"0000" after 2000 ns, x"0005" after 2500 ns;
end asd;
