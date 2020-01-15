-------------------------------------------------------------------------------
--
-- RS232 receiver with fub interface M. Kumm
--
-------------------------------------------------------------------------------

-- Package Definition

library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_arith.all;
use IEEE.STD_LOGIC_unsigned.all;
use ieee.math_real.all;

package fub_rs232_rx_pkg is
component fub_rs232_rx
	generic(
		clk_freq_in_hz : real;
		baud_rate  : real
	);
	port(
			clk_i							:	in  std_logic;
			rst_i							:	in  std_logic;
			rs232_rx_i				:	in std_logic;
			fub_str_o					:	out std_logic;
			fub_busy_i				: in	std_logic;
			fub_data_o				:	out std_logic_vector(7 downto 0);
			receive_error	: out std_logic
	);
	
end component; 
end fub_rs232_rx_pkg;

package body fub_rs232_rx_pkg is
end fub_rs232_rx_pkg;

-- Entity Definition

library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_arith.all;
use IEEE.STD_LOGIC_unsigned.all;

use work.real_time_calculator_pkg.all;

entity fub_rs232_rx is
	generic(
		clk_freq_in_hz : real := 50.0E6;
		baud_rate  : real := 9600.0
	);
	port(
			clk_i							:	in  std_logic;
			rst_i							:	in  std_logic;
			rs232_rx_i				:	in std_logic;
			fub_str_o					:	out std_logic;
			fub_busy_i				: in	std_logic;
			fub_data_o				:	out std_logic_vector(7 downto 0);
			receive_error : out std_logic
	);
	
end fub_rs232_rx; 

architecture fub_rs232_rx_arch of fub_rs232_rx is

constant clk_div  : integer := get_delay_in_ticks_round(clk_freq_in_hz, 1.0/baud_rate * 1.0E9);

signal data_cnt 	: integer range 0 to 9;
signal data						: std_logic_vector (7 downto 0);
signal clk_cnt 		: integer range 0 to clk_div;

--signal sample_clk : std_logic;
signal rs232_rx_finished : std_logic;
signal fub_tx_ready 		: std_logic;
signal fub_data							: std_logic_vector (7 downto 0);

type states is (WAIT_FOR_STARTBIT, WAIT_0_5_T232, WAIT_T232, SAMPLE_DATA);
signal state: states;

begin

rs232_rx_p: process (clk_i, rst_i, fub_busy_i)
begin

	if rst_i = '1' then
		data_cnt <= 0;
		clk_cnt <= 0;
		data <= (others => '0');
		state <= WAIT_FOR_STARTBIT;
		rs232_rx_finished <= '0';
		receive_error <= '0';
		fub_data <= (others => '0');
	elsif clk_i'EVENT and clk_i = '1' then	
			case state is
				when WAIT_FOR_STARTBIT =>
					if rs232_rx_i = '0' then
						state <= WAIT_0_5_T232;
					end if;
					rs232_rx_finished <= '0';
				when WAIT_0_5_T232 =>
					if clk_cnt = (clk_div/2)-2 then
						clk_cnt <= 0;
						state <= WAIT_T232;
					else
						clk_cnt <= clk_cnt + 1;
					end if;
				when WAIT_T232 =>
					if clk_cnt = clk_div-2 then
						clk_cnt <= 0;
						state <= SAMPLE_DATA;
					else
						clk_cnt <= clk_cnt + 1;
					end if;
				when SAMPLE_DATA =>
					if data_cnt <= 7 then
						data(data_cnt) <= rs232_rx_i;
						data_cnt <= data_cnt + 1;
						state <= WAIT_T232;
					else
						if fub_tx_ready = '1' then
							fub_data <= data;
							rs232_rx_finished <= '1';
						else
							--datenverlust, fub-empfänger kommt nicht mit. empfangene daten werden verworfen
							receive_error <= '1';
						end if;
						data_cnt <= 0;
						state <= WAIT_FOR_STARTBIT;
					end if;
			end case;
	end if;
end process;

fub_tx_p: process (clk_i, rst_i, fub_busy_i)
begin
	if rst_i = '1' then
		fub_tx_ready <= '1';
		fub_str_o <= '0';
		fub_data_o <= (others => '0');
	elsif clk_i'EVENT and clk_i = '1' then	
		if rs232_rx_finished = '1' or fub_tx_ready = '0' then
			fub_tx_ready <= '0';
			if fub_busy_i = '0' then
				fub_data_o <= fub_data;
				fub_str_o <= '1';
				fub_tx_ready <= '1';
			end if;
		else
			fub_str_o <= '0';
		end if;
	end if;
end process;

end fub_rs232_rx_arch;

