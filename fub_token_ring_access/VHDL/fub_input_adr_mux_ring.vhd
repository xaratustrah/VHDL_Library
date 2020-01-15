LIBRARY ieee;	
USE ieee.std_logic_1164.all;
USE IEEE.STD_LOGIC_arith.all;
USE IEEE.STD_LOGIC_unsigned.all;

entity fub_input_adr_mux_ring is							
														
generic	( 
			bitSize				: integer := 8;				-- bitsize of the FuB package
			adr_bitSize			: integer;
			use_adr				: integer
		) ;		
											
port ( 	
		rst_i			: in std_logic;
		clk_i			: in std_logic;
		fub_adr_i 			: in std_logic_vector( use_adr * (adr_bitSize - 1) downto 0 );
		fub_data_i			: in std_logic_vector( bitSize - 1 downto 0 );
		fub_str_i			: in std_logic;
		fub_busy_o			: out std_logic;
		block_transfer_i	: in std_logic;
		data_o					: out std_logic_vector( bitSize + adr_bitSize - 1 downto 0 );
		str_o					: out std_logic;
		block_transfer_o		: out std_logic;
		busy_i					: in std_logic
	 );
	
end fub_input_adr_mux_ring;

architecture fub_input_adr_mux_ring_arch of fub_input_adr_mux_ring is

type state_type is ( START, BUSY, BUSY_WAIT ); 

signal state 		: state_type;

begin

	fub_input_adr_mux_process : process(rst_i, clk_i)
	begin
		if rst_i = '1' then
			state				<= START;
			fub_busy_o			<= '0';
			block_transfer_o	<= '0';
			data_o				<= (others => '0');
			str_o				<= '0';
		elsif clk_i'event and clk_i = '1' then
			str_o		<= '0';							--|| strobe reset
			case state is
				when START =>
					if fub_str_i = '1' then
						fub_busy_o		<= '1';						--|| busy set 
						if use_adr = 1 then
							data_o	<= fub_data_i & fub_adr_i;
						else
							data_o	<= fub_data_i;
						end if;
						block_transfer_o	<= block_transfer_i;
						str_o				<= '1';						--|| strobe set
						state				<= BUSY;
					else
						state		<= START;
					end if;
				when BUSY =>				-- this state is needed, because busy_wait state is reached before parallel_seriell has switched its busy_output ... 
					if busy_i = '1' then
						state		<= BUSY_WAIT;
					else
						state		<= BUSY;
					end if;
				when BUSY_WAIT =>
					if busy_i = '0' then				-- data send with token							
						fub_busy_o		<= '0';					--|| no more busy
						state			<= START;
					else
						state			<= BUSY_WAIT;
					end if;
			end case;
		end if;
	end process; 	
	
end fub_input_adr_mux_ring_arch;