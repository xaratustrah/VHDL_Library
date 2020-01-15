LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE IEEE.STD_LOGIC_arith.all;
USE IEEE.STD_LOGIC_unsigned.all;

entity fub_output_adr_demux is			
														
generic	( 
			bitSize				: integer := 8;				-- bitsize of the FuB package
		  	adr_bitSize			: integer := 2;				-- bitsize of the outgoing address vector
			use_adr				: integer
		) ;		
											
port ( 	
		rst_i			: in std_logic;
		clk_i			: in std_logic;
		fub_adr_o 		: out std_logic_vector( use_adr * (adr_bitSize - 1) downto 0 );
		data_i			: in std_logic_vector( adr_bitSize + bitSize - 1 downto 0 );
		str_i			: in std_logic;
		fub_data_o		: out std_logic_vector( bitSize - 1 downto 0 );
		fub_str_o		: out std_logic;
		fub_busy_i		: in std_logic
	 );
	
end fub_output_adr_demux;

architecture fub_output_adr_demux_arch of fub_output_adr_demux is

type state_type is ( START, OUTPUT ); 

signal state 		: state_type;

begin

	fub_output_adr_demux_process : process(rst_i, clk_i)
	begin 
		if rst_i = '1' then
			state			<= start;
			fub_adr_o		<= (others => '0');
			fub_data_o		<= (others => '0');
			fub_str_o		<= '0';
		elsif clk_i'event and clk_i = '1' then
			case state is
				when START =>
					if str_i = '1' then
						if use_adr = 1 then 
							for n in 0 to bitSize - 1 loop
								fub_data_o(n)	<= data_i(n);
							end loop;
							for m in 0 to adr_bitSize - 1 loop
								fub_adr_o(m) 	<= data_i(bitSize + m);
							end loop;
						else
							fub_data_o	<= data_i(bitSize-1 downto 0);   -- Korrektur von Stefan Schäfer. Vorher stand da:  "fub_data_o	<= data_i" das gibt Probleme wenn use_adr=0 ist;
						end if;
						state			<= OUTPUT;
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
	
end fub_output_adr_demux_arch;
