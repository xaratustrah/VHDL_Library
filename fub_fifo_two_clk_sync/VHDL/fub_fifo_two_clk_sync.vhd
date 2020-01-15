library ieee;
library altera_mf;
use ieee.std_logic_1164.all;
use ieee.math_real.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use altera_mf.all;


package fub_fifo_two_clk_sync_pkg is

	component fub_fifo_two_clk_sync
		generic(
			intended_device_family	:	string		:=	"Cyclone";
			worddepth								:	integer		:=	4;
			use_adr									:	integer		:=	1;
			fub_data_width					:	integer		:=	8;
			fub_adr_width						:	integer		:=	16
		);
		port(
			write_clk_i				:	in	std_logic;
			read_clk_i				:	in	std_logic;
 			rst80							:	in	std_logic;     
			rst200						:	in	std_logic;      
			-- FUB write Port
			fub_write_data_i	:	in	std_logic_vector(fub_data_width-1 downto 0);
			fub_write_adr_i		:	in	std_logic_vector((fub_adr_width-1)*use_adr downto 0);
			fub_write_str_i		:	in	std_logic;
			fub_write_busy_o	:	out	std_logic;
			-- FUB read Port
			fub_read_data_o		:	out	std_logic_vector(fub_data_width-1 downto 0);
			fub_read_adr_o		:	out	std_logic_vector((fub_adr_width-1)*use_adr downto 0);
			fub_read_str_o		:	out	std_logic;
			fub_read_busy_i		:	in	std_logic
		);
	end component;
	
end fub_fifo_two_clk_sync_pkg;

package body fub_fifo_two_clk_sync_pkg is
end fub_fifo_two_clk_sync_pkg;


library ieee;
library altera_mf;
use ieee.std_logic_1164.all;
use ieee.math_real.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use altera_mf.all;


entity fub_fifo_two_clk_sync is

	generic(
		intended_device_family	:	string	:=	"Cyclone";
		worddepth								:	integer	:=	4;
		use_adr									:	integer			:=	1;
		fub_data_width					:	integer	:=	8;
		fub_adr_width						:	integer	:=	16
	);
	port(
			write_clk_i				:	in	std_logic;
			read_clk_i				:	in	std_logic;
 			rst80							:	in	std_logic;     
			rst200						:	in	std_logic;             
			-- FUB write Port
			fub_write_data_i	:	in	std_logic_vector(fub_data_width-1 downto 0);
			fub_write_adr_i		:	in	std_logic_vector((fub_adr_width-1)*use_adr downto 0);
			fub_write_str_i		:	in	std_logic;
			fub_write_busy_o	:	out	std_logic;
			-- FUB read Port
			fub_read_data_o		:	out	std_logic_vector(fub_data_width-1 downto 0);
			fub_read_adr_o		:	out	std_logic_vector((fub_adr_width-1)*use_adr downto 0);
			fub_read_str_o		:	out	std_logic;
			fub_read_busy_i		:	in	std_logic
	);

end fub_fifo_two_clk_sync;

architecture fub_fifo_two_clk_sync_arch of fub_fifo_two_clk_sync is
		
	constant	lpm_width			:	integer	:=	fub_data_width + fub_adr_width;
	
	-- fifo write signals
	signal	data_in	:	std_logic_vector(lpm_width-1 downto 0);
	signal	wrreq		:	std_logic;
	signal	wrfull	:	std_logic;
	
	signal	write_buffer	:	std_logic_vector(lpm_width-1 downto 0);
	signal	buffer_flag		:	std_logic;
	
	signal adr_in		:	std_logic_vector(lpm_width-1 downto 0);
	
	-- fifo read signals
	signal	adr_out		:	std_logic_vector(data_in'range);
	signal	rdreq			:	std_logic;
	signal	rdempty		:	std_logic;
	signal	flag_2		:	std_logic;
	signal	cnt				:	integer range 2 downto 0;
	
	signal	read_buffer		:	std_logic_vector(lpm_width-1 downto 0);
	signal	read_buffer_1	:	std_logic_vector(lpm_width-1 downto 0);
	signal	busy_flag			:	std_logic;
--	signal	busy_flag_d		:	std_logic;
--	signal	busy_flag_dd	:	std_logic;
	
	-- state machine
	type writestates is	(RESET, IDLE,	WRITE_FIFO);
	signal writestate : writestates;

	type readstates	is (RESET, IDLE,	ACTION, READ_FIFO);
	signal readstate : readstates;

	component dcfifo
		generic (
			add_ram_output_register		: string;
			clocks_are_synchronized		: string;
			intended_device_family		: string;
			lpm_numwords							: natural;
			lpm_showahead							: string;
			lpm_type									: string;
			lpm_width									: natural;
			lpm_widthu								: natural;
			overflow_checking					: string;
			underflow_checking				: string;
			use_eab										: string
		);
		port (
			wrclk		: in 	std_logic;
			rdempty	: out std_logic;
			rdreq		: in 	std_logic;
			aclr		: in 	std_logic;
			wrfull	: out std_logic;
			rdclk		: in 	std_logic;
			q				: out std_logic_vector(lpm_width-1 downto 0);
			wrreq		: in 	std_logic ;
			data		: in 	std_logic_vector(lpm_width-1 downto 0)
		);
	end component;
	
begin
	
	write_control	:	process(write_clk_i, rst200, fub_write_str_i, fub_write_data_i, fub_write_adr_i)
		begin
			if rst200 = '1' then															--	alle signale/ports zurücksetzen!!
				wrreq							<=	'0';
				fub_write_busy_o	<=	'0';
				buffer_flag				<=	'0';
				writestate				<=	RESET;
				write_buffer			<=	(others =>	'0');
				data_in						<=	(others =>	'0');
--				busy_flag_d				<=	'0';
--				busy_flag_dd			<=	'0';
			elsif write_clk_i'event and write_clk_i	= '1' then
--				busy_flag_dd			<=	busy_flag_d;
--				busy_flag_d				<=	busy_flag;
				case writestate is
					when RESET =>
						if rst200 = '0' then
							writestate	<=	IDLE;
						end if;
					when IDLE	=>
						wrreq				<=	'0';
						if fub_write_str_i = '1' then
							fub_write_busy_o	<=	'1';
							buffer_flag				<=	'1';
							writestate				<=	WRITE_FIFO;
							if use_adr = 0 then
								write_buffer		<=	fub_write_data_i;
							else
								write_buffer		<=	adr_in;
							end if;
						end if;
					when WRITE_FIFO	=>
						if wrfull	= '1' then	--  or busy_flag_dd = '1'
--							wrreq							<=	'0';
							fub_write_busy_o	<=	'1';
							if buffer_flag =	'0' then
								if use_adr = 0 then
									write_buffer		<=	fub_write_data_i;
								else
									write_buffer		<=	adr_in;
								end if;
								buffer_flag	<=	'1';
							end if;
						else 	
							wrreq	<=	'1';
							fub_write_busy_o	<=	'0';
							if buffer_flag = '1' then
								data_in						<=	write_buffer;
								buffer_flag				<=	'0';
							else
								if use_adr = 0 then
									data_in			<=	fub_write_data_i;
								else
									data_in			<=	adr_in;
								end if;
								if fub_write_str_i	=	'0' then
									writestate	<=	IDLE;
								end if;
							end if;
						end if;
					when others => null;	
				end case;							
			end if;
		if use_adr = 1 then
			adr_in		<=	fub_write_data_i	& fub_write_adr_i;
		end if;
	end process;
			
	dcfifo_component : dcfifo
		generic map(
			add_ram_output_register => "ON",
			clocks_are_synchronized => "FALSE",
			intended_device_family 	=> intended_device_family,
			lpm_numwords						=> 16,
			lpm_showahead 					=> "OFF",
			lpm_type 								=> "dcfifo",
			lpm_width 							=> lpm_width,					-- data width
			lpm_widthu 							=> worddepth,					-- worddepth
			overflow_checking 			=> "ON",
			underflow_checking 			=> "ON",
			use_eab 								=> "ON"
		)
		port map(
			wrclk 	=> write_clk_i,
			rdreq 	=> rdreq,
			aclr 		=> rst200,
			rdclk 	=> read_clk_i,
			wrreq 	=> wrreq,
			data 		=> data_in,
			rdempty => rdempty,
			wrfull 	=> wrfull,
			q 			=> adr_out
		);
		
	read_control	:	process(read_clk_i, rst80, rdempty, fub_read_busy_i)
	begin
		if rst80 = '1' then
			rdreq						<=	'0';
			fub_read_str_o	<=	'0';
			fub_read_data_o	<=	(others => '0');
			fub_read_adr_o	<=	(others => '0');
			readstate				<=	RESET;
			busy_flag				<=	'0';
			read_buffer			<=	(others => '0');
			read_buffer_1		<=	(others => '0');
			cnt							<=	0;
			flag_2					<=	'0';
		elsif read_clk_i'event and read_clk_i	= '1' then
			case readstate is
				when RESET =>
					if rst80 = '0' then
						readstate	<=	IDLE;
					end if;
				when IDLE =>
					fub_read_str_o	<=	'0';
					if rdempty = '0' then
						readstate	<=	ACTION;
					end if;
				when ACTION =>
					if fub_read_busy_i = '0' then
						fub_read_str_o	<=	'0';
						rdreq						<=	'1';
						cnt							<=	1;
						if cnt = 1 then
							readstate	<=	READ_FIFO;
							cnt				<=	0;
						end if;
					else
						rdreq			<=	'0';
					end if;
				when READ_FIFO =>
					if fub_read_busy_i	<=	'0' then
						cnt	<=	0;
						if busy_flag	= '1' then
							fub_read_data_o	<=	read_buffer_1(lpm_width-1 downto fub_adr_width);
							if use_adr = 1 then
								fub_read_adr_o	<=	read_buffer_1(fub_read_adr_o'range);
							end if;
							flag_2	<= '1';
							if flag_2 = '1' then
								busy_flag				<=	'0';
								flag_2	<= '0';
							end if;
						else
							fub_read_data_o	<=	adr_out(lpm_width-1 downto fub_adr_width);
							if use_adr = 1 then
								fub_read_adr_o	<=	adr_out(fub_read_adr_o'range);
							end if;
						end if;
						rdreq						<=	'1';
						fub_read_str_o	<=	'1';
						if rdempty = '1' then
							readstate			<=	IDLE;
							rdreq					<=	'0';
						end if;
					else
						read_buffer				<=	adr_out;
						if cnt = 1 then
							read_buffer_1	<=	read_buffer;
							cnt						<=	2;
						elsif cnt = 0 then
							cnt	<=	1;				
						end if;
						busy_flag					<=	'1';
						rdreq							<=	'0';
					end if;
				when others => null;
			end case;
		end if;
	end process;

end fub_fifo_two_clk_sync_arch;