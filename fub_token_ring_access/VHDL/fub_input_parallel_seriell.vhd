LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE IEEE.STD_LOGIC_arith.all;
USE IEEE.STD_LOGIC_unsigned.all;

entity fub_input_parallel_seriell is

generic ( 	
			packetSize 				: integer := 16	
		 );		

port ( 	
		-----------------------------------------------
		target_adr				:  in std_logic_vector(7 downto 0);	
		-----------------------------------------------
		clk_i	   	 		: in std_logic;
		rst_i	     		: in std_logic;
		data_i		 		: in std_logic_vector( packetSize - 1 downto 0 );
		str_i  	 	 		: in std_logic;
		block_transfer_i	: in std_logic;
		need_data_i			: in std_logic;
		data_for_error_detection_o	: out std_logic_vector( packetSize - 1 downto 0 );
		input_got_data_o			: out std_logic;
		block_transfer_o			: out std_logic;
		no_more_input_data_o		: out std_logic;
		busy_o		 				: out std_logic;
		data_o						: out std_logic
	 );
	
end fub_input_parallel_seriell;

architecture fub_input_parallel_seriell_arch of fub_input_parallel_seriell is

type state_type	is	( START, GOT_DATA, SEND, SEND_WAIT );

signal state		: state_type ;
signal count		: integer range 0 to packetSize + 8 := (packetSize + 7);	
signal data_intern	: std_logic_vector( packetSize + 7 downto 0 );
signal data_intern2	: std_logic_vector( packetSize - 1 downto 0 );	
	
 
begin
	
	fub_input_parallel_seriell_process : process( clk_i, rst_i )
	begin
		if rst_i = '1' then
			data_o 						<= '0';
			busy_o						<= '0';
			input_got_data_o			<= '0';
			block_transfer_o			<= '0';
			no_more_input_data_o		<= '0';
			data_for_error_detection_o	<= (others => '0');
			data_intern					<= (others => '0');
			data_intern2				<= (others => '0');
			count						<= (packetSize + 7);
			state						<= START;
		elsif clk_i'event and clk_i = '1' then	
			case state is
				when START =>						
					data_o 					<= '0';		-- set default data_o
					no_more_input_data_o	<= '0';		--|| reset no_more_input_data_o controll signal
					if str_i = '1' then
						if block_transfer_i = '1' then
							block_transfer_o	<= '1';		--|| block_transfer_o set
						end if;
						data_intern		<= target_adr & data_i;
						data_intern2	<= data_i;
						busy_o 			<= '1';					--|| set busy_o "I am busy"
						state  			<= GOT_DATA;
						input_got_data_o	<= '1';			--|| got data now ( this shows encoder that there is input data )
					else 
						state <= START;
					end if;
				when GOT_DATA =>				
					if need_data_i = '1' then
						data_for_error_detection_o	<= data_intern2;
						state						<= SEND;
						block_transfer_o			<= '0'; --|| reset block_transfer_o
						input_got_data_o			<= '0';	--|| input do not got new data, the old one needs to be send first
					else
						state	<= GOT_DATA;
					end if;
				when SEND =>						-- set's the output to its value
					data_o  <= data_intern(count);	
					state	<= SEND_WAIT;
				when SEND_WAIT =>					-- encoder needs 2 clk times to encode, so state has to wait one clk
					if count > 0 then 	-- size of the seriell output (bitsize and add_bitSize of incomming package + address vector( 8 bit ))
						state <= SEND;		
						count <= count - 1;	
					else
						count 					<= (packetSize + 7);	-- set count back to default value
						state 					<= START;
						no_more_input_data_o	<= '1';				--|| no more input_data_o set
						busy_o					<= '0';					--|| no more busy
					end if;
			end case;		
		end if;
	end process;
	
end fub_input_parallel_seriell_arch;
					