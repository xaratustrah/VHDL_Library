LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE IEEE.STD_LOGIC_arith.all;
USE IEEE.STD_LOGIC_unsigned.all;

entity clk_sync_input is

generic(	
			bitSize		: integer := 8; 
			adrSize		: integer := 2
		);

port(	
		rst_i				: in std_logic;
		clk_i				: in std_logic;
		fub_data_i			: in std_logic_vector( bitSize - 1 downto 0 );
		fub_adr_i			: in std_logic_vector( adrSize - 1 downto 0 );
		fub_str_i			: in std_logic;
		fub_busy_o			: out std_logic;
		data_set_intern_i	: in std_logic;
		str_intern_o		: out std_logic;
		data_intern_o		: out std_logic_vector( bitSize - 1 downto 0 );
		adr_intern_o		: out std_logic_vector( adrSize - 1 downto 0 )
	);
	
end entity;

architecture clk_sync_input_arch of clk_sync_input is

type state_type is ( READY, SENDING, WAIT_SENDING );

signal state			: state_type;

begin

	clk_sync_input_process : process( clk_i, rst_i )
	begin
		if rst_i = '1' then
			fub_busy_o		<= '0';
			str_intern_o	<= '0';
			state			<= READY;
			data_intern_o	<= ( others => '0' );
			adr_intern_o	<= ( others => '0' );
		elsif clk_i'event and clk_i = '1' then
			case state is
				when READY =>
					if fub_str_i = '1' then					-- new incoming data 
						fub_busy_o		<= '1';				-- "I am busy now"
						data_intern_o	<= fub_data_i;		-- data to receiver
						adr_intern_o	<= fub_adr_i;
						if data_set_intern_i = '0' then		-- receiver has already received strobe_intern = '0' and is ready for new data
							str_intern_o	<= '1';				-- strobe signal to receiver
							state			<= SENDING;
						else 								-- receiver has not jet received strobe_intern = '0' and therefore is NOT ready for new data
							state 			<= WAIT_SENDING;	
						end if;		
					else
						state			<= READY;
					end if;
				when WAIT_SENDING =>						-- waiting for receiver to say " i saw strobe_intern = '0' , i am ready for new data "
					if data_set_intern_i = '0' then	
						str_intern_o		<= '1';
						state				<= SENDING;
					else 									
						state				<= WAIT_SENDING;
					end if; 
				when SENDING =>
					if data_set_intern_i = '1' then			-- receiver finished its work
						fub_busy_o		<= '0';				-- "no more busy"
						str_intern_o	<= '0';				-- force strobe_intern_o to be '0' for at last one CLK period
						state			<= READY;
					else
						state			<= SENDING;
					end if;
			end case;
		end if;
	end process;
	
end clk_sync_input_arch;
