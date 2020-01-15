LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE IEEE.STD_LOGIC_arith.all;
USE IEEE.STD_LOGIC_unsigned.all;

entity input_synchron is

port (  
		clk_i	: in std_logic ;
		rst_i	: in std_logic ;
		data_i	: in std_logic ;
		data_o 	: out std_logic
	 );
	
end input_synchron;

architecture input_synchron_arch of input_synchron is

begin 

	input_synchron_process : process( clk_i, rst_i )
	begin
		if rst_i = '1' then
			data_o <= '0' ;
		elsif clk_i'event and clk_i = '1' then
			data_o <= data_i ;
		end if;
	end process;
	
end input_synchron_arch;