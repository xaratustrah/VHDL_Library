LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE IEEE.STD_LOGIC_arith.all;
USE IEEE.STD_LOGIC_unsigned.all;

entity clk_sync_output is

generic(	
			bitSize		: integer := 8; 
			adrSize		: integer := 2
		);

port(	
		rst_i				: in std_logic;
		clk_i				: in std_logic;
		str_intern_i		: in std_logic;
		data_intern_i		: in std_logic_vector( bitSize - 1 downto 0 );
		adr_intern_i		: in std_logic_vector( adrSize - 1 downto 0 );
		fub_data_o			: out std_logic_vector( bitSize - 1 downto 0 );
		fub_adr_o			: out std_logic_vector( adrSize - 1 downto 0 );
		fub_str_o			: out std_logic;
		fub_busy_i			: in std_logic;
		data_set_intern_o	: out std_logic
	);
	
end entity;

architecture clk_sync_output_arch of clk_sync_output is

type state_type is ( READY, WAIT_WORK, WORK, WAIT_READY );

signal state			: state_type;

begin

	clk_sync_output_process : process( clk_i, rst_i )
	begin
		if rst_i = '1' then
			data_set_intern_o	<= '0';
			fub_data_o			<= ( others => '0' );
			fub_adr_o			<= ( others => '0' );
			fub_str_o			<= '0';
			state				<= READY;
		elsif clk_i'event and clk_i = '1' then
			case state is 
				when READY =>
					if str_intern_i = '1' then
						fub_data_o		<= data_intern_i;
						fub_adr_o		<= adr_intern_i;
						if fub_busy_i = '0' then
							fub_str_o	<= '1';
							state			<= WORK;
						else 								-- fub interface is not ready jet
							state			<= WAIT_WORK;
						end if;
					else
						state			<= READY;
					end if;
				when WAIT_WORK =>							-- wait to begin work
					if fub_busy_i = '0' then
						fub_str_o			<= '1';
						state				<= WORK;
					else									-- fub interface is not ready jet
						state				<= WAIT_WORK;
					end if;
				when WORK =>
					fub_str_o			<= '0';					-- reset strobe_o to '0'
					if fub_busy_i = '0' then				-- fub interface has finished its work
						data_set_intern_o	<= '1';			-- gives signal to receiver to get new data
						state				<= WAIT_READY;
					else									-- fub interface is still working
						state			<= WORK;
					end if;
				when WAIT_READY => 
					if str_intern_i = '0' then				-- transmitter gives signal that he saw data_set_intern 
						data_set_intern_o	<= '0';
						state				<= READY;
					else
						state			<= WAIT_READY;
					end if;
			end case;
		end if;
	end process;
	
end clk_sync_output_arch;