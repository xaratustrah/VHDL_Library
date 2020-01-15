-----------------------------------------------------------
-- 2010/09/07 deleted unused signals /ct
-----------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE IEEE.STD_LOGIC_arith.all;
USE IEEE.STD_LOGIC_unsigned.all;

entity encoder_memory is

port	(
			clk_i				: in std_logic;
			rst_i				: in std_logic;
			no_more_data_i		: in std_logic;
			no_more_data_o		: out std_logic;
			ring_str_i			: in std_logic;
			ring_got_data_i		: in std_logic;
			data_i				: in std_logic;
			trigger_i			: in std_logic;
			need_data_i			: in std_logic;
			ring_data_o			: out std_logic
		);
		
end entity encoder_memory;

architecture encoder_memory_arch of encoder_memory is

type state_type1 is ( START, WAIT_STATE );
type state_type2 is ( START, DATA_SET, DATA_WAIT );


signal n 					: integer range 0 to 7 :=7;
signal m 					: integer range 0 to 7 :=7;
signal state1 				: state_type1;
signal state2				: state_type2;
signal data_intern			: std_logic_vector(7 downto 0);
signal reset_intern			: std_logic;

begin

	encoder_memory_process : process(clk_i, rst_i)
	begin
		if rst_i = '1' then
			ring_data_o				<= '0';
			data_intern				<= (others => '0');
			n						<= 7;
			m						<= 7;
			reset_intern			<= '0';
			no_more_data_o			<= '0';
			state2					<= START;
			state1					<= START;
		elsif rising_edge(clk_i) then
			reset_intern		<= '0';
			if ring_str_i = '1' then
				reset_intern		<= '1';
			end if;
			if reset_intern = '1' then
				m	<= 7;
				n	<= 7;
			end if;
			case state1 is 									-- read in
				when START =>
					if trigger_i = '1' and ring_got_data_i = '1' then
						if n = 0 then
							n	<= 7;
						else
							n	<= n - 1;
						end if;
						data_intern(n)		<= data_i;
						state1				<= WAIT_STATE;
					else
						state1			<= START;
					end if;
				when WAIT_STATE =>
					state1		<= START;
			end case;
			case state2 is									-- set out
				when START =>
					if need_data_i = '1' then
						state2				<= DATA_SET;
						no_more_data_o		<= '0';			--|| reset no_more_data_o
					else
						state2	<= START;
					end if;
				when DATA_SET =>
					if m = 0 then
						m	<= 7;
					else
						m	<= m - 1;
					end if;
					ring_data_o	<= data_intern(m);
					state2		<= DATA_WAIT;
				when DATA_WAIT => 
					if m = n  and no_more_data_i = '1' then
						no_more_data_o	<= '1';
						state2			<= START;
						n				<= 7;
						m				<= 7;
					else
						state2	<= DATA_SET;
					end if;					
			end case;
		end if;
	end process;
	
end architecture encoder_memory_arch;