library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_arith.all;
use IEEE.STD_LOGIC_unsigned.all;

use work.real_time_calculator_pkg.all;
use work.id_info_pkg.all;

entity if_info_tb is
	generic(
		clk_freq_in_hz : real := 50.0E6
	);
end if_info_tb;

architecture if_info_tb_arch of if_info_tb is

signal clk : std_logic := '0';
signal rst : std_logic;

signal led_id_inf_i : std_logic_vector(3 downto 0);
signal led_id_inf_o : std_logic_vector(3 downto 0);


begin

	id_info_inst: id_info
	generic map (
		clk_freq_in_hz     => 50.0E6,
		display_time_in_ms => 1.0,
		firmware_id        => 2,   
		firmware_version   => 3,   
		led_cnt            => 4    
	)
	port map (
		clk_i => clk,
		rst_i => rst,
		led_i => led_id_inf_i,
		led_o => led_id_inf_o
	);

  clk <= not clk after 0.5 * freq_real_to_period_time(clk_freq_in_hz);
  rst <= '1', '0' after 50 ns;

  led_id_inf_i <= "0101";
  
end if_info_tb_arch;