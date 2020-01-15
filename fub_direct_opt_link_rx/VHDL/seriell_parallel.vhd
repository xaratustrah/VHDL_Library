LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE IEEE.STD_LOGIC_arith.all;
USE IEEE.STD_LOGIC_unsigned.all;

entity seriell_parallel is

generic ( 
			packetSize	: integer := 8
		) ;

port (  
		rst_i			: in std_logic;
		clk_i			: in std_logic;
		data_i			: in std_logic;
		data_clk_i		: in std_logic;
		data_o			: out std_logic_vector( packetSize - 1 downto 0 );
		str_o			: out std_logic
	 );
	
end seriell_parallel;

architecture seriell_parallel_arch of seriell_parallel is

signal count			: integer range 0 to packetSize - 1 :=(packetSize - 1);
signal error_count		: integer range 0 to 15 :=15;
signal data_intern		: std_logic_vector( packetSize - 1 downto 0 );

begin
	seriell_parallel_process : process ( rst_i, clk_i )
	begin
		if rst_i = '1' then
			count  			<= packetSize - 1;
			error_count		<= 15;
			data_o 			<= ( others => '0' );
			data_intern		<= ( others => '0' );
			str_o			<= '0';
		elsif clk_i'event and clk_i = '1' then
			str_o		<= '0' ;		--|| str_o reset
			if data_clk_i = '1' then
				error_count		<= 15 ;
				-- !!! modified by mk & mw
				data_intern(count) 	<= data_i ;
				if count = 0 then						-- writing into the vector data_o
					str_o			<= '1';					--|| str_o set
--					data_intern(0)	<= data_i ;         -- !!! modified by mk & mw
					data_o 			<= data_intern ;		-- data_o will only change its value if all bits of the vector are set
					data_o(0)		<= data_i ;				-- data_intern will overwrite data_o when it is completly set // if busy_i = '1' this may cause package loss
					count 			<= packetSize - 1 ;
				else 									-- the last bit is set into the vector data_o
					count 				<= count - 1;
				end if;
			elsif error_count = 0 then
				error_count		<= 15 ;
				count			<= packetSize - 1 ;
			else
				error_count		<= error_count - 1 ;
			end if ;
		end if;
	end process;
end seriell_parallel_arch;