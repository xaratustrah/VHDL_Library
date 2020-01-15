-------------------------------------------------------------------------------
--
-- Implementation of the DSP-Link-Interface in receiving mode
-- M. Kumm
--
-------------------------------------------------------------------------------

-- Package Definition

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

package fub_dsp_link_rx_pkg is
  component fub_dsp_link_rx
  	port(
  		rst_i: in std_logic ;
  		clk_i: in std_logic ;
  		fub_busy_i: in std_logic ;			
  		fub_str_o : out std_logic ;
  		fub_adr_o : out std_logic_vector (1 downto 0);
  		fub_data_o: out std_logic_vector (7 downto 0);
  		dsp_data_i: in std_logic_vector (7 downto 0);
  		dsp_cstr_i: in std_logic ;
  		dsp_cack_i: in std_logic ;
  		dsp_crdy_o: out std_logic 
  	);
  end component;

end fub_dsp_link_rx_pkg;

package body fub_dsp_link_rx_pkg is
end fub_dsp_link_rx_pkg;

-- Entity Definition

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity fub_dsp_link_rx is
	port(
		rst_i: in std_logic ;
		clk_i: in std_logic ;
		fub_busy_i: in std_logic ;			
		fub_str_o: out std_logic ;
		fub_adr_o: out std_logic_vector (1 downto 0);
		fub_data_o: out std_logic_vector (7 downto 0);
		dsp_data_i: in std_logic_vector (7 downto 0);
		dsp_cstr_i: in std_logic ;
		dsp_cack_i: in std_logic ;
		dsp_crdy_o: out std_logic 
	);
end fub_dsp_link_rx; 


architecture fub_dsp_link_rx_arch of fub_dsp_link_rx is
--	signal count: integer range 0 to 2**2;
	signal fub_adr: std_logic_vector (1 downto 0);
	type states is (INIT, RECEIVING,WAIT_STATE,WAIT_FOR_NBUSY,WAIT_FOR_CSTR);
	signal state: states;
begin

	master_x :process (clk_i,rst_i,fub_busy_i,dsp_data_i,dsp_cstr_i,dsp_cack_i)
	begin
		if rst_i ='1' then
			fub_str_o <= '0';
			fub_adr <= (others => '0');
			dsp_crdy_o <= '1';
			fub_data_o <= (others => '0');	
			fub_adr_o <= (others => '0');	
			state <= init;
		elsif clk_i = '1' and clk_i'event then
			case state is
				when init =>
					if fub_busy_i = '0' then	-- warte bis andere seite fertig ist
						state <= receiving;
					end if;
				when receiving =>
					if dsp_cstr_i = '0' then
						fub_data_o <= dsp_data_i;					-- und bevor die neuen daten ausgegeben werden, wird noch gewartet.
						fub_str_o <= '1';		-- strobe wird sofort auf 1 gesetzt wie im fub(fpga universal bus) interface definiert.
						if (dsp_cack_i = '0') then	
							fub_adr_o <= "00";
							fub_adr <= "01";
						else
							fub_adr_o <= fub_adr;
							if (fub_adr = "11") then
								fub_adr <= "00";
							else
								fub_adr <= fub_adr + 1;
							end if;
						end if;
						state <= wait_state;
					end if;
				when wait_state =>
					fub_str_o <= '0';		-- strobe muss zurückgesetzt werden da übertragung des 1. bytes fertig ist.
					state <= wait_for_nbusy;
				when wait_for_nbusy =>
					if fub_busy_i = '0' then
						dsp_crdy_o <= '0';
						state <= wait_for_cstr;
					end if;
				when wait_for_cstr =>
					if (dsp_cstr_i = '1') then
						state <= receiving;
						dsp_crdy_o <= '1';
					end if;
			end case;
		end if;
	end process master_x;

end fub_dsp_link_rx_arch;