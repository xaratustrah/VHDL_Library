LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE IEEE.STD_LOGIC_arith.all;
USE IEEE.STD_LOGIC_unsigned.all;

entity decoder_main is										-- //// MANCHESTER DECODER //// --
	generic(
		wait_clk		: integer := 2; 			-- depends on sampling frequency 
	 	packetSize		: integer := 10				--  [ f decoder(real, including delta f ) / f clk ] >> [ waitCLK + 1 ] >=  [ 1/2 f decoder(real) / f clk ]
	);
	port(
		rst_i		: in std_logic ;
		clk_i		: in std_logic ;
		set_i 		: in std_logic ;
		value_i		: in std_logic ;
		data_clk_o	: out std_logic ;
		data_o		: out std_logic 
	);
end entity decoder_main ;

architecture decoder_main_arch of decoder_main is

type state_type is ( START, START2, START_WAIT, START_WAIT_DEFAULT0, START_WAIT_DEFAULT1, DATA_SET, DATA_WAIT ); 

signal state		: state_type ;
signal count		: integer range 0 to wait_clk :=wait_clk; 			-- depends on sampling frequency
signal counter		: integer range 0 to wait_clk ; 					-- depends on sampling frequency
signal count_bit	: integer range 0 to packetSize - 1 :=(packetSize - 1);	
signal shift_reg	: std_logic_vector (8 downto 0) := (others=>'0');
signal mc_violated	: std_logic := '0';
signal reset		: std_logic := '0';

begin

	reset <= rst_i or mc_violated when rising_edge(clk_i);

	-- decoder_main_process : process( rst_i, clk_i, mc_violated)
	decoder_main_process : process( reset, clk_i)
		variable tmp_set_val : std_logic_vector(1 downto 0) := "00";
	begin
		-- if rst_i = '1' or mc_violated = '1' then								-- reset
		if reset = '1' then	-- reset
			state		 <= START ;
			data_clk_o	 <= '0' ;
			data_o 		 <= '0' ;
			count 		 <= wait_clk ;
			count_bit 	 <= packetSize - 1 ;
		elsif rising_edge(clk_i) then
			tmp_set_val := set_i & value_i;
			data_clk_o <= '0' ;					-- reset data_CLK
			case state is
				when START =>					-- now incoming data // looking at the first bit
					case tmp_set_val is
						when "11"	=>	state <= START_WAIT_DEFAULT1;	-- first part ('1') of start "10" detected
						when "10"	=>	state <= START_WAIT_DEFAULT0;	-- default '0' detected
						when others	=>	state <= START;
					end case;

				when START2 =>
					case tmp_set_val is
						when "10"	=>	state <= START_WAIT;				-- start "10" detected
						when "11"	=>	state <= START_WAIT_DEFAULT1;	-- default '1' detected ( may occur if the '0' series is misinterpreted as a series of '1' )
						when others	=>	state <= START2;
					end case;

				when START_WAIT_DEFAULT0 =>			-- equal to start_wait // except changing to start 
					if count > 0 then
						count <= count - 1 ;
						state <= START_WAIT_DEFAULT0;
					else
						count <= wait_clk ;
						state <= START ;
					end if;

				when START_WAIT_DEFAULT1 =>			-- equal to start_wait // except changing to start2 
					if count > 0 then
						count <= count - 1 ;
						state <= START_WAIT_DEFAULT1;
					else 
						count <= wait_clk ;
						state <= START2 ;
					end if;

				when START_WAIT =>
					if count > 0 then
						count <= count - 1 ;
						state <= START_WAIT;
					else
						count <= wait_clk ;
						state <= DATA_SET ;
					end if;

				when DATA_SET =>					-- ready to set data
					if set_i = '1' then 			-- change of value
						data_o 		<= value_i;	-- set data_o
						data_clk_o  <= '1' ;		-- set data_clk_o
						state 		<= DATA_WAIT ;
					else							-- no change of value
						state 	<= DATA_SET;		-- stay ready
					end if;

				when DATA_WAIT =>					-- wait for mc middle change
					if count > 0 then
						count 	<= count - 1 ;
						state 	<= DATA_WAIT;
					elsif count_bit > 0	then
						count_bit 	<= count_bit - 1;
						count 		<= wait_clk ;
						state 		<= DATA_SET ;
					else
						count 		<= wait_clk ;
						count_bit 	<= packetSize - 1;
						state 		<= START ;
						data_o 		<= '0'; 		-- after packetSize Bit set output = '0'
					end if;
			end case;
		end if;
	end process decoder_main_process;

	mc_violation : process(clk_i,rst_i)is
	variable tmp_test : integer := 0;
	begin
		tmp_test := 0;
		if rst_i = '1' then
			shift_reg <= (others => '0');
			mc_violated <= '0';
		elsif rising_edge(clk_i)then
			shift_reg <= shift_reg(7 downto 0) & value_i;
			for i in 0 to 8 loop
				tmp_test := tmp_test + conv_integer(shift_reg(i));
			end loop;
			if tmp_test > 7 then
				mc_violated <= '1';
			else
				mc_violated <= '0';
			end if;
		end if;
	end process mc_violation;

end architecture decoder_main_arch ;