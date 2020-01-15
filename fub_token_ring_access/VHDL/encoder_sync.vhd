LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE IEEE.STD_LOGIC_arith.all;
USE IEEE.STD_LOGIC_unsigned.all;

entity encoder_sync is

port	(
			clk_i			: in std_logic;
			rst_i			: in std_logic;
			no_more_data_i		: in std_logic;
			ring_got_data_i		: in std_logic;
			data_i				: in std_logic;
			trigger_i			: in std_logic;
			ring_str_i			: in std_logic;
			trigger_o					: out std_logic;
			no_more_data_o				: out std_logic;
			ring_data_o					: out std_logic;
			ring_got_data_o				: out std_logic;
			ring_str_o					: out std_logic
		);
		
end encoder_sync;

architecture encoder_sync_arch of encoder_sync is

begin

	encoder_sync_process : process(clk_i, rst_i)
	begin
		if rst_i = '1' then
			no_more_data_o			<= '0';
			ring_data_o				<= '0';
			ring_str_o				<= '0';
			ring_got_data_o			<= '0';
			trigger_o				<= '0';
		elsif clk_i'event and clk_i = '1' then
			ring_data_o				<= data_i;
			ring_str_o				<= ring_str_i;
			no_more_data_o			<= no_more_data_i;
			ring_got_data_o			<= ring_got_data_i;
			trigger_o				<= trigger_i;
		end if;
	end process;
	
end encoder_sync_arch;