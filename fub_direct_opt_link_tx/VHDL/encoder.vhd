LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE IEEE.STD_LOGIC_arith.all;
USE IEEE.STD_LOGIC_unsigned.all;

entity encoder is

generic ( 
			packetSize	: integer 	:= 8 
		) ; 
									
port ( 	
		clk_i		: in std_logic;
		str_i		: in std_logic;
		rst_i		: in std_logic;
		data_i		: in std_logic;			--  data:
		opt_data_o	: out std_logic			--  frequency = 1/2 clk frequenz
	  );								
	
end encoder ;

architecture encoder_arch of encoder is

type state_type is ( WAIT1, WAIT2, START1, START2, START3, START4, LOOK_DATA, SET_DATA );

signal state 	: state_type;
signal count	: integer range 0 to packetSize - 1 :=(packetSize - 1);

begin

	encoder_process : process( clk_i, rst_i )
	begin
		if rst_i = '1' then
			opt_data_o 		<= '1' ;
			state			<= WAIT1 ;
			count 			<= packetSize - 1 ;
		elsif clk_i'event and clk_i = '1' then
			case state is
				when WAIT1 =>						-- waiting for strobe_i to come // setting default '0' to data_mc_o
					opt_data_o 	<= '1';						-- '1' becuase of default '0'
					if str_i = '1' then
						opt_data_o 	<= '0';					-- '0' because of changing state
						state 		<= START1 ;
					else
						state <= WAIT2 ;
					end if ;
				when WAIT2 =>						-- waiting for strobe_i to come // setting default '0' to data_mc_o
					opt_data_o 	<= '0';
					if str_i = '1' then
						state 	<= START1;
					else 
						state <= WAIT1;
					end if;
				when START1 =>						-- set '1' of "10" befor encoding data
					opt_data_o 	<= '0' ;
					state 		<= START2;
				when START2 =>						-- set '1' of "10" befor encoding data
					opt_data_o 	<= '1' ;
					state 		<= START3;
				when START3 => 						-- set '0' of "10" befor encoding data
					opt_data_o	<= '1' ;
					state 		<= START4;
				when START4 =>						-- set '0' of "10" befor encoding data
					opt_data_o	<= '0' ;
					state 		<= LOOK_DATA;
				when LOOK_DATA =>					-- start encoding data // first part of manchester encoding
					opt_data_o 	<= not data_i;
					state 		<= SET_DATA;
				when SET_DATA =>					-- secound part of manchester encoding 			
					opt_data_o 	<= data_i;
					if count > 0 then 						-- count to bitSize
						state 	<= LOOK_DATA;
						count 	<= count - 1;
					else
						count 	<= packetSize - 1;
						state 	<= WAIT1;
					end if;
			end case;
		end if ;
	end process ;
	
end encoder_arch ;
					
			