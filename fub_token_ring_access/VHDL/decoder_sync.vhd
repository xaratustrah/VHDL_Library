LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE IEEE.STD_LOGIC_arith.all;
USE IEEE.STD_LOGIC_unsigned.all;

entity decoder_sync is

port (  
		clk_i	: in std_logic ;
		rst_i	: in std_logic ;
		data_i	: in std_logic ;
		data_o 	: out std_logic ;
		reset_detected_i	: in std_logic ;
		reset_detected_o	: out std_logic
	 );
	
end decoder_sync;

architecture decoder_sync_arch of decoder_sync is

begin 

	decoder_sync_process : process( clk_i, rst_i )
	begin
		if rst_i = '1' then
			data_o <= '0' ;
		elsif clk_i'event and clk_i = '1' then
			data_o 				<= data_i ;
			reset_detected_o	<= reset_detected_i;
		end if;
	end process;
	
end decoder_sync_arch;