-------------------------------------------------------------------------------
--
-- FUB interface to FTDI USB controler FT245R
-- M. Kumm
--
-------------------------------------------------------------------------------

-- Package Definition

library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_arith.all;
use IEEE.STD_LOGIC_unsigned.all;

package fub_ftdi_usb_pkg is

component fub_ftdi_usb
	generic(
		clk_freq_in_hz : real --system clock frequency
	);
	port(
			rst_i						:	in std_logic ;
			clk_i						:	in std_logic ;
			--FUB in signals
			fub_in_data_i		:	in std_logic_vector (7 downto 0);
			fub_in_str_i 		:	in std_logic;
			fub_in_busy_o		:	out std_logic;
			--FUB out signals
			fub_out_data_o	:	out std_logic_vector (7 downto 0);
			fub_out_str_o 	:	out std_logic;
			fub_out_busy_i	:	in std_logic;
			--FTDI signals
			ftdi_d_io						:	inout std_logic_vector (7 downto 0);
			ftdi_nrd_o : out std_logic;
			ftdi_wr_o: out std_logic;
			ftdi_nrxf_i : in std_logic;
			ftdi_ntxe_i : in std_logic
		);
	
end component;

end fub_ftdi_usb_pkg;

package body fub_ftdi_usb_pkg is
end fub_ftdi_usb_pkg;

-- Entity Definition

library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_arith.all;
use IEEE.STD_LOGIC_unsigned.all;

use work.real_time_calculator_pkg.all;

entity fub_ftdi_usb is
	generic(
		clk_freq_in_hz : real --system clock frequency
	);
	port(
			rst_i						:	in std_logic ;
			clk_i						:	in std_logic ;
			--FUB in signals
			fub_in_data_i		:	in std_logic_vector (7 downto 0);
			fub_in_str_i 		:	in std_logic;
			fub_in_busy_o		:	out std_logic;
			--FUB out signals
			fub_out_data_o	:	out std_logic_vector (7 downto 0);
			fub_out_str_o 	:	out std_logic;
			fub_out_busy_i	:	in std_logic;
			--FTDI signals
			ftdi_d_io	    :	inout std_logic_vector (7 downto 0);
			ftdi_nrd_o    : out std_logic;
			ftdi_wr_o     : out std_logic;
			ftdi_nrxf_i   : in std_logic;
			ftdi_ntxe_i   : in std_logic
		);
	
end fub_ftdi_usb; 


architecture fub_ftdi_usb_arch of fub_ftdi_usb is
	
  --calculate the maximum of two integers
	function maximum_int(x1: integer; x2: integer) return integer is
	begin
		if x1 > x2 then
			return x1;
		else
			return x2;
		end if;
	end maximum_int;

	--theses parameters are defined for FT245R:
	constant DELAY_WR_TO_DATA_ACTIVE_IN_NS : real := 25.0; 
	constant DELAY_DATA_ACTIVE_TO_NWR_IN_NS : real := 25.0; 
	constant DELAY_AFTER_TRANSFER_IN_NS : real := 60.0 + 1.0/clk_freq_in_hz; --max. delay from datasheet + reserve + 1 clk cycle synchronization
	constant DELAY_AFTER_RD_ACTIVE_IN_NS : real := 80.0;  --50ns from datasheet are too unsecure

	constant DELAY_WR_TO_DATA_ACTIVE_IN_TICKS:  integer := limit_to_minimal_value(get_delay_in_ticks_ceil(clk_freq_in_hz, DELAY_WR_TO_DATA_ACTIVE_IN_NS)-2, 0);--2 clock cycles are needed for the state machine
	constant DELAY_DATA_ACTIVE_TO_NWR_IN_TICKS: integer := limit_to_minimal_value(get_delay_in_ticks_ceil(clk_freq_in_hz, DELAY_DATA_ACTIVE_TO_NWR_IN_NS)-2, 0);--2 clock cycles are needed for the state machine
	constant DELAY_AFTER_TRANSFER_IN_TICKS:     integer := limit_to_minimal_value(get_delay_in_ticks_ceil(clk_freq_in_hz, DELAY_AFTER_TRANSFER_IN_NS)-2, 0);--2 clock cycles are needed for the state machine
	constant DELAY_AFTER_RD_ACTIVE_IN_TICKS:     integer := limit_to_minimal_value(get_delay_in_ticks_ceil(clk_freq_in_hz, DELAY_AFTER_RD_ACTIVE_IN_NS), 0);
	


	type states is (WAIT_FOR_DATA, WAIT_RD_ACTIVE_TIME, WAIT_FOR_NTXE, WAIT_WR_TO_DATA_TIME, PUT_DATA_ON_BUS, WAIT_DATA_ACTIVE_TIME, CLR_WR, WAIT_FOR_NEXT_TRANSFER);
  signal state	: states;
	
	
	signal delay_cnt: integer range 0 to maximum_int(maximum_int(DELAY_WR_TO_DATA_ACTIVE_IN_TICKS, maximum_int(DELAY_DATA_ACTIVE_TO_NWR_IN_TICKS,DELAY_AFTER_RD_ACTIVE_IN_TICKS)), DELAY_AFTER_TRANSFER_IN_TICKS);
	
	signal data : std_logic_vector(7 downto 0);
	signal ftdi_d_o : std_logic_vector(7 downto 0);
	signal ftdi_nrd : std_logic;
	signal fub_in_busy : std_logic;

--		signal delay_cnt: integer range 0 to 5;
	
	begin

  ftdi_nrd_o <= ftdi_nrd;
	ftdi_d_io <= ftdi_d_o when ftdi_nrd = '1' else (others => 'Z');	
	fub_in_busy_o <= fub_in_busy;
	
	process (clk_i,rst_i)
	begin
		if rst_i ='1' then
			state <= WAIT_FOR_DATA;
			fub_in_busy <= '0';	
			ftdi_wr_o <= '0';
  		ftdi_nrd <= '1';
      fub_out_str_o <= '0';
		elsif clk_i'EVENT and clk_i = '1' then	
			case state is
				when WAIT_FOR_DATA =>
					if fub_in_str_i = '1' then --sending has higher priority than receiving
						data <= fub_in_data_i;
						fub_in_busy <= '1';
						state <= WAIT_FOR_NTXE;
          elsif ftdi_nrxf_i = '0' then
 						fub_in_busy <= '1';
						delay_cnt <= DELAY_AFTER_RD_ACTIVE_IN_TICKS;
					  state <= WAIT_RD_ACTIVE_TIME;
--					else
--  					fub_in_busy <= '0';  --ready for a new datagram
					end if;
				when WAIT_RD_ACTIVE_TIME =>
				  if fub_in_str_i = '1' and ftdi_nrd = '1' then --for a "late strobe", first serve the sending
				    data <= fub_in_data_i;
				    state <= WAIT_FOR_NTXE; 
				  else
				    ftdi_nrd <= '0';
				  end if;
					if delay_cnt = 0 then
					  if fub_out_busy_i = '0' then
  					  fub_out_data_o <= ftdi_d_io;
  					  fub_out_str_o <= '1';
  					else 
  					  assert false report "Data is lost from USB!";
  					end if;
 					  ftdi_nrd <= '1';
  					delay_cnt <= DELAY_AFTER_TRANSFER_IN_TICKS;
						state <= WAIT_FOR_NEXT_TRANSFER;
					else
            delay_cnt <= delay_cnt - 1;
					end if;										
				when WAIT_FOR_NTXE =>
					if ftdi_ntxe_i = '0' then
						ftdi_wr_o <= '1';
						delay_cnt <= DELAY_WR_TO_DATA_ACTIVE_IN_TICKS;
						state <= WAIT_WR_TO_DATA_TIME;
					end if;
				when WAIT_WR_TO_DATA_TIME =>
					if delay_cnt = 0 then
						state <= PUT_DATA_ON_BUS;
					else
            delay_cnt <= delay_cnt - 1;
					end if;					
				when PUT_DATA_ON_BUS =>
					ftdi_d_o <= data;
					delay_cnt <= DELAY_DATA_ACTIVE_TO_NWR_IN_TICKS;
					state <= WAIT_DATA_ACTIVE_TIME;
				when WAIT_DATA_ACTIVE_TIME =>
					if delay_cnt = 0 then
						state <= CLR_WR;
					else
            delay_cnt <= delay_cnt - 1;
					end if;					
				when CLR_WR =>
					ftdi_wr_o <= '0';
					delay_cnt <= DELAY_AFTER_TRANSFER_IN_TICKS;
					state <= WAIT_FOR_NEXT_TRANSFER;
				when WAIT_FOR_NEXT_TRANSFER =>
				  fub_out_str_o <= '0';
					if delay_cnt = 0 then
  					fub_in_busy <= '0';  --ready for a new datagram
						state <= WAIT_FOR_DATA;
					else
            delay_cnt <= delay_cnt - 1;
					end if;					
			end case;
		end if;
	end process;
	
end fub_ftdi_usb_arch;
