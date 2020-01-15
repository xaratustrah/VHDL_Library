-- in progress

-- package definition
library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.all;
use ieee.numeric_std.all;

package flash_tb_pkg is

	component flash_tb 
		generic(
			number_of_slave_select	:	integer := 	9
		);
		port(
			clk_i			:	in	std_logic;
			rst_i			:	in	std_logic;
			spi_ss_i	:	in	std_logic_vector(number_of_slave_select-1 downto 0);
			spi_clk_i	:	in	std_logic;
			spi_mosi_i:	in	std_logic;
			spi_miso_o:	out	std_logic
		);
	end component;
	
end flash_tb_pkg;

package body flash_tb_pkg is
end flash_tb_pkg;

-- entity definition

library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.all;
use ieee.numeric_std.all;

entity fub_flash_tb is

	generic(
		number_of_slave_select	:	integer :=	9
	);
	port(
		clk_i			:	in	std_logic;
		rst_i			:	in	std_logic;
		spi_ss_i	:	in	std_logic_vector(number_of_slave_select-1 downto 0);
		spi_clk_i	:	in	std_logic;
		spi_mosi_i:	in	std_logic;
		spi_miso_o:	out	std_logic
	);

end fub_flash_tb;

architecture fub_flash_tb_arch of fub_flash_tb is

type states is (OPCODE, WRITE_ON_FLASH, READ_FROM_FLASH);
signal	state	:	states;

type	memory_buffer is array(3 downto 0) of std_logic_vector(7 downto 0);
signal	data		:	memory_buffer;
signal	memory	:	memory_buffer;

signal	input_vector			:	std_logic_vector(7 downto 0);
signal	write_bit_cnt			:	integer	range 7 downto 0;
signal	read_bit_cnt			:	integer	range 7 downto 0;
signal	write_byte_cnt		:	integer	range 1 downto 0;
signal	read_byte_cnt			:	integer	range 1 downto 0;
signal	rdy								:	std_logic;
signal	read_rdy					:	std_logic;
signal	write_flag				:	std_logic;
signal	read_flag					:	std_logic;

begin

	spi_one	:	process(clk_i, rst_i)
	begin
		if rst_i = '1' then
			state					<=	OPCODE;
			memory				<=	(3 => x"10", 2 => x"31", 1 =>	x"00", 0 => x"E1");
			read_flag			<=	'0';
			write_flag		<=	'0';
		elsif rising_edge(clk_i) then
			case state is
				when OPCODE	=>
					if input_vector	= "00000110" then
						state	<=	WRITE_ON_FLASH;
					elsif input_vector = "00000011" then
						state	<=	READ_FROM_FLASH;						
					end if;
				when WRITE_ON_FLASH	=>
					if input_vector	=	"11011000" then	-- erase
						memory	<=	(others => (others => '0'));
						if rdy = '1'	then
							read_flag	<=	'1';
							state		<=	OPCODE;
						end if;
					elsif	input_vector	=	"00000010" then -- write bytes
						write_flag			<=	'1';
						if rdy = '1' then
							state		<=	OPCODE;
							memory	<=	data;
						end if;
					end if;
				when READ_FROM_FLASH		=>
					read_flag	<=	'1';
					if	read_rdy	= '1' then
						state			<=	OPCODE;
						read_flag	<=	'0';
					end if;
			end case;
		end if;
	end process;
	
	spi_two	:	process(spi_clk_i, rst_i)
	begin
		if rst_i = '1' then
			write_bit_cnt				<=	7;
			write_byte_cnt			<=	1;
			rdy						<=	'0';
			input_vector	<=	(others => '0');
			data					<=	(others => (others => '0'));
			read_rdy			<=	'0';
			read_bit_cnt	<=	7;
			read_byte_cnt	<=	1;
			spi_miso_o		<=	'0';
		elsif rising_edge(spi_clk_i) then
			input_vector(write_bit_cnt) <=	spi_mosi_i;
			if write_bit_cnt	> 0 then
				rdy				<=	'0';
				write_bit_cnt		<=	write_bit_cnt - 1;
			elsif write_byte_cnt > 0 then
				write_bit_cnt			<=	7;
				write_byte_cnt		<=	write_byte_cnt - 1;
				if write_flag = '1' then
					data(1)		<=	input_vector;
				end if;
			else
				write_byte_cnt		<=	1;
				rdy					<=	'1';
				if write_flag = '1' then
					data(0)		<=	input_vector;
				end if;
			end if;
			-- auslesen aus dem flash
			if read_flag = '1' then
				spi_miso_o	<= memory(read_byte_cnt)(read_bit_cnt);
				if read_bit_cnt	> 0 then
					read_bit_cnt	<= read_bit_cnt - 1;
				elsif read_byte_cnt > 0 then
					read_byte_cnt	<=	read_byte_cnt - 1;
					read_bit_cnt	<=	7;
				else
					read_rdy			<=	'1';
					read_byte_cnt	<=	1;
				end if;
			end if;
		end if;
	end process;

	
end fub_flash_tb_arch;
			