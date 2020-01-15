-------------------------------------------------------------------------------
--
-- FUB Interface to the AD9854 DDS in parallel port mode
-- The dds-update output pin is inout and the default direction is in 
-- (the default update direction from the DDS is out!), only when reg 1F bit 0 is set
-- the dds-update direction is switched to out
--
-- M. Kumm
--
-------------------------------------------------------------------------------

-- Package Definition

library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_arith.all;
use IEEE.STD_LOGIC_unsigned.all;
use ieee.math_real.all;

package fub_dds_pkg is
component fub_dds
	generic (
		clk_freq_in_hz : real;
		dds_clk_freq_in_hz : real;
		fub_addr_width : integer;
		update_adr : integer
	);
	port (
		rst_i: in std_logic;
		clk_i: in std_logic;
		-- FUB ------------------------------------------------
		fub_data_i: in std_logic_vector(7 downto 0);
		fub_addr_i: in std_logic_vector(fub_addr_width-1 downto 0);
		fub_str_i: in std_logic;
		fub_busy_o: out std_logic;
		-- DDS ------------------------------------------------
		dds_rst_o: out std_logic;
		dds_data_o: out std_logic_vector(7 downto 0);
		dds_addr_o: out std_logic_vector(5 downto 0);
		dds_nwr_o: out std_logic;
		dds_update_io: inout std_logic
	);
end component; 
end fub_dds_pkg;

package body fub_dds_pkg is
end fub_dds_pkg;

-- Entity Definition
library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_arith.all;
use IEEE.STD_LOGIC_unsigned.all;
use ieee.math_real.all;

use work.real_time_calculator_pkg.all;

entity fub_dds is
	generic (
		clk_freq_in_hz : real := 100.0E6;
		dds_clk_freq_in_hz : real := 200.0E6;
		fub_addr_width : integer := 6;
		update_adr : integer := 16#05#
	);
	port (
		rst_i: in std_logic;
		clk_i: in std_logic;
		-- FUB ------------------------------------------------
		fub_data_i: in std_logic_vector(7 downto 0);
		fub_addr_i: in std_logic_vector(fub_addr_width-1 downto 0);
		fub_str_i: in std_logic;
		fub_busy_o: out std_logic;
		-- DDS ------------------------------------------------
		dds_rst_o: out std_logic;
		dds_data_o: out std_logic_vector(7 downto 0);
		dds_addr_o: out std_logic_vector(5 downto 0);
		dds_nwr_o: out std_logic;
		dds_update_io: inout std_logic
	);
end fub_dds;
architecture fub_dds_arch of fub_dds is
  constant rst_clk_div  : integer := get_delay_in_ticks_ceil(clk_freq_in_hz, 10.0/dds_clk_freq_in_hz*1.0E9); --reset time is equal to 10 times the dds clock period

	type states is (
		DDS_RESET,
		SAMPLE_DATA,
		SAMPLE_ADDRESS
	);
	signal state: states;
	signal rst_cnt: integer range 0 to rst_clk_div;

  signal dds_update : std_logic;
  signal dds_update_oe : std_logic;
  
begin

  dds_update_io <= dds_update when dds_update_oe='1' else 'Z';

	process(clk_i, rst_i)
	begin
		if (rst_i = '1') then
		  rst_cnt <= rst_clk_div;
		  fub_busy_o <= '1'; --FUB is busy dureing DDS reset
	    dds_nwr_o <= '1';
 		  dds_rst_o <= '1';
 		  dds_data_o <= (others => '0');
 		  dds_addr_o <= (others => '0');
			state <= DDS_RESET;
		elsif (clk_i'event and clk_i = '1') then
			case state is
				when DDS_RESET =>
    		  dds_rst_o <= '1';
				  if rst_cnt = 0 then
      		  dds_rst_o <= '0';
      		  fub_busy_o <= '0';
      			state <= SAMPLE_DATA;
      		  rst_cnt <= rst_clk_div;
      		else
	  			  rst_cnt <= rst_cnt - 1;
				  end if;
				when SAMPLE_DATA =>
				  if fub_str_i='1' then
				    dds_data_o <= fub_data_i;
				    dds_addr_o <= fub_addr_i(5 downto 0);
				    fub_busy_o <= '1';
				    dds_nwr_o <= '1';
			      if fub_addr_i = conv_std_logic_vector(update_adr,fub_addr_width) then
			        dds_update <= '1';
				    else
			        dds_update <= '0';
				    end if;
			      if fub_addr_i = x"1F" then
			        dds_update_oe <= not fub_data_i(0);  --output enable for update
				    end if;
				    state <= SAMPLE_ADDRESS;
				  else
				    dds_nwr_o <= '1';
				  end if;
				when SAMPLE_ADDRESS =>
			    dds_nwr_o <= '0';				  
  		    fub_busy_o <= '0';
     			state <= SAMPLE_DATA;
			end case;
		end if;
	end process;


end fub_dds_arch;