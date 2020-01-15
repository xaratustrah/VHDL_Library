LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE IEEE.STD_LOGIC_arith.all;
USE IEEE.STD_LOGIC_unsigned.all;

entity parallel_seriell is

generic ( 	
			packetSize 	: integer := 8 
		);

port ( 	
		clk_i	   	: in std_logic;
		rst_i	    : in std_logic;
		data_i	 	: in std_logic_vector( packetSize - 1 downto 0 );
		str_i  	 	: in std_logic;
		busy_o	 	: out std_logic;
		data_o		: out std_logic;
		str_o		: out std_logic
	 );
	
end parallel_seriell;

architecture parallel_seriell_arch of parallel_seriell is

type state_type	is	( READY, WAIT_SETONEZEROSTART, WAIT_SETONEZERO, OUTPUT_WAIT, OUTPUT_SET );

signal state		: state_type ;
signal count		: integer range 0 to packetSize - 1 :=packetSize - 1;
signal count_wait	: integer range 0 to 3 :=2;
 
begin
	
	parallel_seriell_process : process( clk_i, rst_i )
	begin
		if rst_i = '1' then
			data_o 		<= '0';
			str_o 		<= '0';
			busy_o		<= '0';
			count_wait	<= 2 ;
			count		<= packetSize - 1;
			state		<= READY;
		elsif clk_i'event and clk_i = '1' then	
			str_o <= str_i ;							-- pass on strobe
			case state is
				when READY =>							-- ready to transform data from parallel to seriell
					data_o <= '0';							-- set data_o default '0', so it is '0' after last bit
					if str_i = '1' then
						busy_o 	<= '1';					-- set busy_o "I am busy" ( busy_o <= '0' after 20 Clks )
						state  	<= WAIT_SETONEZEROSTART;
					else 
						state <= READY;
					end if;
				when WAIT_SETONEZEROSTART =>			-- waiting 4 clks ( 2 data_clk ) unitil encoder can set the "10" in front of the package
					state 	<= WAIT_SETONEZERO;
				when WAIT_SETONEZERO =>					-- waiting unitil encoder can set the "10" in front of the package
					if count_wait > 0 then
						count_wait 	<= count_wait - 1;
						state 		<= WAIT_SETONEZERO;
					else
						count_wait 	<= 2;
						state 		<= OUTPUT_SET;
					end if;
				when OUTPUT_SET =>						-- set's the output to its value
					data_o  <= data_i(count);	
					state	<= output_wait;
				when OUTPUT_WAIT =>						-- encoder needs 2 clk times to encode, so state has to wait one clk
					if count > 0 then
						state <= OUTPUT_SET;
						count <= count - 1;	
					else
						count 		<= packetSize - 1;			-- set count back to default value
						state 		<= READY;
						busy_o		<= '0';					-- no more busy
					end if;
			end case;		
		end if;
	end process;
	
end parallel_seriell_arch;
					