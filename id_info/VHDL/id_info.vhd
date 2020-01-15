-------------------------------------------------------------------------------
--
--  Displays a firmware ID and a version number after reset with a few leds
--  After that, the normal LED meanig that is provided at the input is fed 
--  through to the output.
--  M. Kumm
-------------------------------------------------------------------------------

-- Package Definition

library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_arith.all;
use IEEE.STD_LOGIC_unsigned.all;
use ieee.math_real.all;

package id_info_pkg is
component id_info
	generic(
		clk_freq_in_hz          : real;
		display_time_in_ms      : real := 1000.0;  --time between switching the data display in ms
		firmware_id             : integer := 15;  --ID of the firmware (is displayed first)
		firmware_version        : integer := 15;  --Version of the firmware (is displayed after)
		firmware_configuration  : integer := 0;  --Configuration of firmware, e.g changed parameters (is displayed at last)
		led_cnt                 : integer := 4   --Number of LEDs
	);
	port(
		clk_i  :	in std_logic;                            --clk
		rst_i  :	in std_logic;                            --reset
		led_i  :  in std_logic_vector(led_cnt-1 downto 0); --normal led status signals
		led_o  :	out std_logic_vector(led_cnt-1 downto 0) --connection to leds
	);
	
end component id_info; 
end package id_info_pkg;

package body id_info_pkg is
end id_info_pkg;

-- Entity Definition


library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_arith.all;
use IEEE.STD_LOGIC_unsigned.all;

use work.real_time_calculator_pkg.all;

entity id_info is
	generic(
		clk_freq_in_hz          : real := 50.0E6;
		display_time_in_ms      : real := 1000.0;       --time between switching the data display in ms
		firmware_id             : integer := 1;          --ID of the firmware (is displayed first)
		firmware_version        : integer := 3;          --Version of the firmware (is displayed after)
		firmware_configuration  : integer := 0;
		led_cnt                 : integer := 4           --Number of LEDs
	);
	port(
		clk_i  :	in std_logic;                            --clk
		rst_i  :	in std_logic;                            --reset
		led_i  :  in std_logic_vector(led_cnt-1 downto 0); --normal led status signals
		led_o  :	out std_logic_vector(led_cnt-1 downto 0) --connection to leds
	);
end entity id_info; 

architecture id_info_arch of id_info is

	constant count_max : integer := get_delay_in_ticks_round(clk_freq_in_hz, 1.0E6 * display_time_in_ms);
	signal count : integer range 0 to count_max-1;

	type states is (
		DISP_ID,
		DISP_CLR1,
		DISP_VERSION,
		DISP_CLR2,
		DISP_CONF,
		DISP_INPUT
	);
	signal state: states;

begin

	process (clk_i,rst_i)
	begin
		if rst_i = '1' then
			led_o <= (others => '0');
			count <= 0; 
			state <= DISP_ID; 
		elsif rising_edge(clk_i) then
			if count = 0 then
				case state is
					when DISP_ID =>
						led_o <= conv_std_logic_vector(firmware_id, led_cnt);
						state <= DISP_CLR1;
						count <= count_max-1;
					when DISP_CLR1 =>
						led_o <= (others => '0');
						state <= DISP_VERSION;
						count <= count_max-1;					
					when DISP_VERSION =>
						led_o <= conv_std_logic_vector(firmware_version, led_cnt);
						state <= DISP_CLR2;
						count <= count_max-1;
					when DISP_CLR2 =>
						led_o <= (others => '0');
						state <= DISP_CONF;
						count <= count_max-1;					
					when DISP_CONF =>
						led_o <= conv_std_logic_vector(firmware_configuration, led_cnt);
						state <= DISP_INPUT;
						count <= count_max-1;
					when DISP_INPUT =>
						led_o <= led_i;
				end case;
			else
				count <= count - 1;
			end if;
		end if;
	end process;

end architecture id_info_arch;