-- Package Definition

library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_arith.all;
use IEEE.STD_LOGIC_unsigned.all;
use ieee.math_real.all;

package input_sync_pkg is
component input_sync
	port (  
			clk_i	: in std_logic ;
			rst_i	: in std_logic ;
			data_i	: in std_logic ;
			data_o 	: out std_logic
		 );
	
end component; 
end input_sync_pkg;

package body input_sync_pkg is
end input_sync_pkg;

-- Entity Definition

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE IEEE.STD_LOGIC_arith.all;
USE IEEE.STD_LOGIC_unsigned.all;

entity input_sync is

port (  
		clk_i	: in std_logic ;
		rst_i	: in std_logic ;
		data_i	: in std_logic ;
		data_o 	: out std_logic
	 );
	
end input_sync;

architecture input_sync_arch of input_sync is

begin 

	input_sync_process : process( clk_i, rst_i )
	begin
		if rst_i = '1' then
			data_o <= '0' ;
		elsif clk_i'event and clk_i = '1' then
			data_o <= data_i ;
		end if;
	end process;
	
end input_sync_arch;