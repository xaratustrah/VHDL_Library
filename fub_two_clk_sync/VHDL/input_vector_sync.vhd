LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE IEEE.STD_LOGIC_arith.all;
USE IEEE.STD_LOGIC_unsigned.all;

entity input_vector_sync is

generic(	
			bitSize		: integer := 8 
		);

port ( 
		clk_i	: in std_logic;
		rst_i	: in std_logic;
		data_i	: in std_logic_vector( bitSize - 1 downto 0 );
		data_o 	: out std_logic_vector( bitSize - 1 downto 0 )
	 );
	
end input_vector_sync;

architecture input_vector_sync_arch of input_vector_sync is

begin 

	input_vector_sync_process : process( clk_i, rst_i )
	begin
		if rst_i = '1' then
			data_o <= ( others => '0' );
		elsif clk_i'event and clk_i = '1' then
			data_o <= data_i;
		end if;
	end process;
	
end input_vector_sync_arch;