LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE IEEE.STD_LOGIC_arith.all;
USE IEEE.STD_LOGIC_unsigned.all;

entity decoder_comparator_ring is

port ( 
		clk_i	: in std_logic;
		rst_i	: in std_logic;
		data_i	: in std_logic;
		observer_data		: out std_logic;	-----------------------------
		value_o				: out std_logic;
		set_o				: out std_logic
	 );
	
end entity decoder_comparator_ring ;

architecture decoder_comparator_ring_arch of decoder_comparator_ring is

begin

	decoder_comparator_ring_process : process (rst_i, clk_i) is
	begin 
		if rst_i = '1' then
			observer_data		<= '0';
			set_o 				<= '0';
			value_O				<= '0';
		elsif rising_edge(clk_i) then
			if ( data_i'last_value xor data_i ) = '1' then
				set_o 		<= '1';
				value_o 	<= data_i;
			else 
				set_o 		<= '0';
			end if;
			observer_data	<= data_i;
		end if;
	end process decoder_comparator_ring_process;

end architecture decoder_comparator_ring_arch;