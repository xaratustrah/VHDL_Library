-------------------------------------------------------------------------------
-- Title      : Testbench for design "edge_detector"
-- Project    : 
-------------------------------------------------------------------------------
-- File       : edge_detector_tb.vhd
-- Author     : 
-- Company    : 
-- Created    : 2009-06-15
-- Last update: 2009-06-15
-- Platform   : 
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2009 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2009-06-15  1.0      shahab	Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

-------------------------------------------------------------------------------

entity edge_detector_tb is

end edge_detector_tb;

-------------------------------------------------------------------------------

architecture edge_detector_arch of edge_detector_tb is

  component edge_detector
    generic (
      output_on_time_in_clks : integer);
    port (
      clk_i : in  std_logic;
      rst_i : in  std_logic;
      x_i   : in  std_logic;
      x_o   : out std_logic);
  end component;

  -- component generics
  constant output_on_time_in_clks : integer := 1;

  -- component ports
  signal sim_clk : std_logic := '1';
  signal sim_rst : std_logic;
  signal x_i   : std_logic;

begin  -- edge_detector_arch

  -- component instantiation
  DUT: edge_detector
    generic map (
      output_on_time_in_clks => output_on_time_in_clks)
    port map (
      clk_i => sim_clk,
      rst_i => sim_rst,
      x_i   => x_i,
      x_o   => open);

  -- clock generation
  sim_clk <= not sim_clk after 10 ns;
  sim_rst <= '1', '0' after 30 ns;

  x_i <= '1', '0' after 40 ns, '1' after 75 ns,'0' after 133 ns,'1' after 167 ns,'0' after 210 ns;
end architecture edge_detector_arch;

  
--library ieee;
--use ieee.math_real.all; -- for UNIFORM, TRUNC
--use ieee.numeric_std.all; -- for TO_UNSIGNED

--process
---- Seed values for random generator
--variable seed1, seed2: positive;
---- Random real-number value in range 0 to 1.0
--variable rand: real;
---- Random integer value in range 0..4095
--variable int_rand: integer;
---- Random 12-bit stimulus
--variable stim: std_logic_vector(11 downto 0);
--begin
---- initialise seed1, seed2 if you want -
---- otherwise they're initialised to 1 by default
--loop -- testbench stimulus loop?
--UNIFORM(seed1, seed2, rand);
---- get a 12-bit random value...
---- 1. rescale to 0..(nearly)4096, find integer part
--int_rand := INTEGER(TRUNC(rand*4096.0));
---- 2. convert to std_logic_vector
--stim := std_logic_vector(to_unsigned(int_rand, stim'LENGTH));
