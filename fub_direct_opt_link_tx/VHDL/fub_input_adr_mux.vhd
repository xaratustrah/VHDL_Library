LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE IEEE.STD_LOGIC_arith.all;
USE IEEE.STD_LOGIC_unsigned.all;

entity fub_input_adr_mux is							
														
generic	( 
			bitSize				: integer := 8;				-- bitsize of the FuB package
		  	adr_bitSize			: integer := 2;				-- bitsize of the incomming address vector
			use_adr				: integer
		) ;		
											
port ( 	
		rst_i			: in std_logic;
		clk_i			: in std_logic;
		fub_adr_i 		: in std_logic_vector( use_adr * (adr_bitSize - 1) downto 0 );
		fub_data_i		: in std_logic_vector( bitSize - 1 downto 0 );
		fub_str_i		: in std_logic;
		fub_busy_o		: out std_logic;
		data_o		: out std_logic_vector( bitSize + adr_bitSize - 1 downto 0 );
		str_o		: out std_logic;
		busy_i		: in std_logic
	 );
	
end fub_input_adr_mux;

architecture fub_input_adr_mux_arch of fub_input_adr_mux is

type state_type is ( START, BUSY, BUSY_WAIT1, BUSY_WAIT2 ); 

signal state 		: state_type;

begin

	fub_input_adr_mux_process : process(rst_i, clk_i)
	begin
		if rst_i = '1' then
			state			<= START;
			fub_busy_o		<= '0';
			data_o			<= (others => '0');
			str_o		<= '0';
		elsif clk_i'event and clk_i = '1' then
			str_o			<= '0';						--|| strobe reset
			case state is
				when START =>
					if fub_str_i = '1' then
						fub_busy_o		<= '1';						--|| busy set
						if use_adr = 1 then
							data_o			<= fub_adr_i & fub_data_i;
						else
							data_o			<= fub_data_i;
						end if;
						str_o			<= '1';						--|| strobe set
						state			<= BUSY;
					else
						state		<= START;
					end if;
				when BUSY =>				-- this state is needed, because busy_wait state is reached before parallel_seriell has switched its busy_output ... 
					if busy_i = '1' then
						state		<= BUSY_WAIT1;
					else
						state		<= BUSY;
					end if;
				when BUSY_WAIT1 =>
					if busy_i = '0' then				-- data send with token							
						state			<= BUSY_WAIT2;
					else
						state			<= BUSY_WAIT1;
					end if;
				when  BUSY_WAIT2 =>	
					fub_busy_o		<= '0' ;
					state			<= START ;
			end case;
		end if;
	end process; 	
	
end fub_input_adr_mux_arch;