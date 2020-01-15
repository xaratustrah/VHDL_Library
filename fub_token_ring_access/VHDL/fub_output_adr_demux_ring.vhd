LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE IEEE.STD_LOGIC_arith.all;
USE IEEE.STD_LOGIC_unsigned.all;

entity fub_output_adr_demux_ring is			
														
generic	( 
			bitSize				: integer := 8;				-- bitsize of the FuB package
			use_adr				: integer;
		  	adr_bitSize			: integer := 8 				-- bitsize of the outgoing address vector
		) ;		
											
port ( 	
		rst_i			: in std_logic;
		clk_i			: in std_logic;
		fub_adr_o		: out std_logic_vector( use_adr * (adr_bitSize - 1) downto 0 );
		data_i			: in std_logic_vector( adr_bitSize + bitSize - 1 downto 0 );
		str_i			: in std_logic;
		fub_data_o		: out std_logic_vector( bitSize - 1 downto 0 );
		fub_str_o		: out std_logic;
		fub_busy_i		: in std_logic
	 );
	
end fub_output_adr_demux_ring;

architecture fub_output_adr_demux_ring_arch of fub_output_adr_demux_ring is

type state_type is ( START, OUTPUT ); 

signal state 		: state_type;

begin

	fub_output_adr_demux_ring_process : process(rst_i, clk_i)
	begin 
		if rst_i = '1' then
			state			<= START;
			fub_adr_o		<= (others => '0');
			fub_data_o		<= (others => '0');
			fub_str_o		<= '0';
		elsif clk_i'event and clk_i = '1' then
			case state is
				when START =>
					if str_i = '1' then
						if use_adr = 1 then 
							fub_adr_o			<= data_i( (adr_bitSize - 1) downto 0 );
							fub_data_o			<= data_i( (bitSize + adr_bitSize - 1) downto (adr_bitSize) );
						else
							fub_data_o	<= data_i;
							fub_adr_o	<= (others => '0');
						end if;
						state			<= output;
						fub_str_o		<= '1';		--|| strobe set
					else
						state	<= START;
					end if;
				when OUTPUT =>
					if fub_busy_i = '0' then
						fub_str_o		<= '0';		--|| strobe reset
						state			<= START;
					else 
						state		<= OUTPUT;
					end if;
			end case;
		end if;
	end process;
	
end fub_output_adr_demux_ring_arch;
