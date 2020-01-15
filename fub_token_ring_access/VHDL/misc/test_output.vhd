library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;


entity test_output is

	port	(
				clk_i	: in std_logic;
				data_o	: out std_logic
			);
			
end entity test_output;

architecture test_output_arch of test_output is

signal count1			: integer range 0 to 127	;
signal count2			: integer range 0 to 3	;
signal count3			: integer range 0 to 3	;
signal data_intern		: std_logic ;

begin
	
	test_output_process : process (clk_i)
	begin
		if clk_i'event and clk_i = '1' then
			data_o				<= data_intern;
			if count1 > 0 then
				data_intern 	<= not data_intern;
				count1			<= count1 - 1;
			elsif count2 > 0 then
				data_intern		<= '1';
				count2			<= count2 - 1;
			elsif count3 > 0 then
				data_intern		<= '0';
				count3			<= count3 - 1;
			else
				count2			<= 1;		--3
				count3			<= 1;		--3
				count1			<= 127;		--63
			end if;
		end if;
	
	end process;
	
end test_output_arch;