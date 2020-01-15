-------------------------------------------------------------------------------
--
-- Implementation of the DSP-Link-Interface in sending mode
-- M. Kumm
--
-------------------------------------------------------------------------------

-- Package Definition

library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_arith.all;
use IEEE.STD_LOGIC_unsigned.all;
use work.real_time_calculator_pkg.all;

package fub_dsp_link_tx_pkg is
  component fub_dsp_link_tx
  generic(
  			clk_freq_in_hz : real := 0.0;
			dsp_link_delay_in_ns : real := 20.0
			);

  port(
  			rst_i:	in std_logic ;
  			clk_i:	in std_logic ;
  			fub_data_i:	in std_logic_vector(7 downto 0);
  			fub_str_i :	in std_logic := '0';
  			fub_busy_o:	out std_logic := '0';
  			fub_adr_i :	in std_logic_vector(1 downto 0);
  			dsp_data_o:	out std_logic_vector(7 downto 0);
  			dsp_cstr_o:	out std_logic ;
  			dsp_cack_o:	out std_logic ;
  			dsp_crdy_i:	in std_logic
  		);
  end component;

end fub_dsp_link_tx_pkg;

package body fub_dsp_link_tx_pkg is
end fub_dsp_link_tx_pkg;

-- Entity Definition

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use work.real_time_calculator_pkg.all;

entity fub_dsp_link_tx is
	generic(
			clk_freq_in_hz : real := 0.0;
			dsp_link_delay_in_ns : real := 20.0
			);
	port(
			rst_i:	in std_logic ;
			clk_i:	in std_logic ;
			fub_data_i:	in std_logic_vector(7 downto 0);
			fub_str_i:	in std_logic := '0';
			fub_busy_o:	out std_logic := '0';
			fub_adr_i:	in std_logic_vector(1 downto 0);
			dsp_data_o:	out std_logic_vector(7 downto 0);
			dsp_cstr_o:	out std_logic ;
			dsp_cack_o:	out std_logic ;
			dsp_crdy_i:	in std_logic
		);
	
end fub_dsp_link_tx; 

architecture fub_dsp_link_tx_arch of fub_dsp_link_tx is

	type states is (RECEIVING,SIGNAL_CSTR,WAIT_FOR_CRDY,WAIT_FOR_NCRDY);
	signal state: states;

	constant no_of_delay_ticks : integer := get_delay_in_ticks_round(clk_freq_in_hz, dsp_link_delay_in_ns);

	signal wait_cnt : integer range 0 to no_of_delay_ticks;
	signal wait_ticks : integer range 0 to no_of_delay_ticks;
begin

	switch_delay_ticks : if clk_freq_in_hz = 0.0 generate
	begin
		wait_ticks <= 0;
	end generate switch_delay_ticks;

	switch_delay_ticks1 : if clk_freq_in_hz /=0.0 generate
	begin
			wait_ticks <= no_of_delay_ticks -1;
	end generate switch_delay_ticks1;

	


	fub_dsp_link_tx_p: process (clk_i,rst_i,fub_str_i,fub_adr_i,fub_data_i,dsp_crdy_i)
	begin
		if rst_i ='1' then
			fub_busy_o <= '0';
			dsp_data_o <= (others => '0');
			dsp_cstr_o <= '1';
			dsp_cack_o <= '1';
			wait_cnt   <= 0;
			state <= receiving;
		elsif clk_i'event and clk_i = '1' then
			case state is
				when receiving =>
					if fub_str_i = '1' then
						dsp_data_o <= fub_data_i;
						state <= signal_cstr;
						fub_busy_o <= '1';
						if fub_adr_i = "00" then	
							dsp_cack_o <= '0';
						else 
							dsp_cack_o <= '1';
						end if;
					end if;
				when signal_cstr =>
					if wait_cnt < wait_ticks then
						wait_cnt <= wait_cnt + 1;
					else
						state <= wait_for_ncrdy;
						dsp_cstr_o <= '0';
						wait_cnt <= 0;
					end if;
				when wait_for_ncrdy =>
					if dsp_crdy_i = '0'  then
						state <= wait_for_crdy;
						dsp_cstr_o <= '1';
					end if;
				when wait_for_crdy =>
					if dsp_crdy_i = '1'  then
						state <= receiving;
						fub_busy_o <= '0';
					end if;
			end case;
		end if;
	end process fub_dsp_link_tx_p;

end fub_dsp_link_tx_arch;