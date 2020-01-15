LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE IEEE.STD_LOGIC_arith.all;
USE IEEE.STD_LOGIC_unsigned.all;

entity decoder_comparator is

port ( 	
		clk_i	: in std_logic;
		rst_i	: in std_logic;
		data_i	: in std_logic;
		value_o	: out std_logic;
		set_o	: out std_logic;
    wait_count : in integer
	 );
	
end decoder_comparator ;

architecture decoder_comparator_arch of decoder_comparator is

signal old_data : std_logic ;

begin

	decoder_comparator_process : process (rst_i, clk_i)
	begin 
		if rst_i = '1' then
			set_o 		<= '0' ;
			value_o		<= '0' ;
			old_data 	<= '1' ;
		elsif rising_edge(clk_i) then
			if (( old_data XOR data_i ) = '1') and (wait_count < 1) then
				set_o <= '1' ;
				value_o <= data_i ;
			else 
				set_o <= '0' ;
			end if;
			old_data <= data_i ;
		end if;
	end process;

end decoder_comparator_arch;