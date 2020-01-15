LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE IEEE.STD_LOGIC_arith.all;
USE IEEE.STD_LOGIC_unsigned.all;

entity decoder_main_ring is		

generic	( 
		  wait_clk			: integer := 2 			-- depends on sampling frequency 				
		) ;		
											
port ( 	
		rst_i			: in std_logic ;
		clk_i			: in std_logic ;
		set_i 			: in std_logic ;
		value_i			: in std_logic ;
		sending_i		: in std_logic ;
		delete_all_i	: in std_logic ;
		reset_detected_i	: in std_logic ;
		token_deleted_o		: out std_logic ;
		trigger_o			: out std_logic ;
		ring_got_data_o		: out std_logic ;
		ring_str_o			: out std_logic ;
		no_more_data_o		: out std_logic ;
		data_clk_o			: out std_logic ;
		data_o				: out std_logic 
	 );
	
end decoder_main_ring ;

architecture decoder_main_ring_arch of decoder_main_ring is

type state_type is ( START, START2, START_WAIT, START_WAIT_DEFAULT0, START_WAIT_DEFAULT1, DATA_SET, DATA_WAIT ); 

signal state						: state_type ;
signal count						: integer range 0 to wait_clk :=wait_clk ; 
signal count_wait					: integer range 0 to 3 :=2 ;
signal full_tokens_in_a_row_count	: integer range 0 to 255 :=255; -- 2^8 <-- this is the max of token_accesses in the ring
signal first_data					: std_logic;	
signal sending						: std_logic;
signal delete_all					: std_logic;


begin
	
	decoder_main_ring_process : process( rst_i, clk_i )
	begin
		if rst_i = '1' then								-- reset
			state		 				<= START ;
			data_clk_o	 				<= '0' ;
			trigger_o	 				<= '0' ;
			ring_got_data_o				<= '0' ;
			sending						<= '0' ;
			delete_all					<= '0' ;
			token_deleted_o				<= '0' ;
			ring_str_o					<= '0' ;
			data_o 		 				<= '0' ;
			full_tokens_in_a_row_count	<= 255 ;
			no_more_data_o				<= '0' ;
			count 		 				<= wait_clk ;
			count_wait					<= 2 ;	
			first_data					<= '0';
		elsif clk_i'event and clk_i = '1' then	
			data_clk_o		 	<= '0' ;				--|| reset data_CLK
			if sending_i = '1' then
				sending		<= '1'; 
			end if ;
			if delete_all_i = '1' then
				delete_all	<= '1';
			end if;
			if reset_detected_i = '1' then					--|| RESET ||
				sending					<= '0';
				delete_all				<= '0';				
			end if; 		
			case state is
				when START_WAIT_DEFAULT0 =>			-- equal to start_wait // except changing to start 
					if count > 0 then
						count <= count - 1 ;
						state <= START_WAIT_DEFAULT0;
					else 
						count <= wait_clk ;
						state <= START ;
					end if ;									
				when START =>					-- now incoming data // looking at the first bit
					if set_i = '1' then
						if value_i = '1' then					-- first part ('1') of start "10" detected
							state <= START_WAIT_DEFAULT1;			
						else 								
							state <= START_WAIT_DEFAULT0;		-- default '0' detected
						end if;
					else			
						state				<= START;
					end if;
				when START_WAIT_DEFAULT1 =>			-- equal to start_wait // except changing to start2 
					if count > 0 then
						count <= count - 1 ;
						state <= START_WAIT_DEFAULT1;
					else 
						count <= wait_clk ;
						state <= START2 ;
					end if ;	
				when START2 => 									
					if set_i = '1' then							
						if value_i = '0' then			-- start "10" detected
							if delete_all = '1' then			-- error occured -> wait for reset signal
								ring_str_o		<= '0';
							elsif sending = '1' then			-- it is the token we sended, so it will not be send
								ring_str_o		<= '0';
								token_deleted_o	<= '1';		--|| set token_deleted_o
								sending			<= '0';		-- reset sending
							else
								ring_str_o	<= '1';				--|| ring_strobe_o set
							end if;
							state 			<= START_WAIT;
						else									-- default '1' detected ( may occur if the '0' series is misinterpreted as a series of '1' )
							state <= START_WAIT_DEFAULT1;
						end if;
					else
						state <= START2;
					end if;										
				when START_WAIT =>
					if count > 0 then
						count <= count - 1 ;
						state <= START_WAIT;
					else 
						count 		<= wait_clk ;
						state 		<= DATA_SET ;
						first_data	<= '1';			-- first data set
					end if ;					
				when DATA_SET =>					-- ready to set data
					if set_i = '1' then 						-- change of value
						trigger_o	<= '0' ;					--|| reset trigger
						data_o 		<= value_i ;					-- set data_o
						data_clk_o  <= '1' ;								--|| set data_clk_o
						if value_i = '1' and first_data = '1' then
							if full_tokens_in_a_row_count > 0 then
								no_more_data_o				<= '0';			--|| reset no_more_data_o
								ring_got_data_o				<= '1';			--|| tell encoder that ring got data
								full_tokens_in_a_row_count	<= full_tokens_in_a_row_count - 1;
							else
								ring_got_data_o 			<= '0';			--||ring_got_data_o 
								data_o						<= '0';			-- data_o forced to '0'
								full_tokens_in_a_row_count	<= 255;
							end if;
						elsif value_i = '0' and first_data = '1' then
							full_tokens_in_a_row_count	<= 255;
						end if;
						state 		<= DATA_WAIT ;
						count_wait	<= 2 ;
					elsif count_wait = 1 then
						trigger_o	<= '0';					--|| reset trigger
						state		<= DATA_SET;
						count_wait	<= count_wait - 1 ;
					elsif count_wait > 0 then				-- no change of value
						state		<= DATA_SET;
						count_wait	<= count_wait - 1 ;
					else
						state			<= START;			-- so there is no more data
						ring_got_data_o	<= '0';					--|| reset ring_got_data_o
						no_more_data_o	<= '1';					--|| no_more_data_o set
						count_wait		<= 2 ;
					end if;
				when DATA_WAIT =>					-- wait for mc middle change					
					if first_data = '0' then
						trigger_o	<= '1' ;			--|| trigger set
					end if;
					ring_str_o			<= '0';			--|| reset ring_strobe_o
					token_deleted_o		<= '0';			--|| reset token_deleted_o
					if count > 0 then
						count <= count - 1 ;
						state <= DATA_WAIT;
					else 	
						count		<= wait_clk ;
						state 		<= DATA_SET ;
						first_data	<= '0';	
					end if ;
			end case;
		end if;		
	end process;
	
end decoder_main_ring_arch ;