-----------------------------------------------------------------------------
--
-- FUB to RAM interface
--
-- This interface uses a FUB slave receiver for writing data on RAM-interface
-- and a FUB slave transmitter for reading out data from RAM-interface
-- written by T. Wollmann, 30.10.2008
--
-----------------------------------------------------------------------------



-- Package definition
library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

package fub_ram_interface_pkg is

	component fub_ram_interface
		generic (
			adr_width			:	integer		:=	16;
			data_width			:	integer		:=	8;
			delay_clk			:	integer		:=	2;			--	delay of RAM
			priority_on_read	:	std_logic	:=	'0'
		);
		port (
			clk_i				:	in	std_logic;
			rst_i				:	in	std_logic;
			--	FUB in
			fub_write_adr_i		:	in	std_logic_vector(adr_width-1 downto 0);
			fub_write_data_i	:	in	std_logic_vector(data_width-1 downto 0);
			fub_write_str_i		:	in	std_logic;
			fub_write_busy_o	:	out	std_logic;
			--	FUB out
			fub_read_adr_i		:	in	std_logic_vector(adr_width-1 downto 0);
			fub_read_data_o		:	out	std_logic_vector(data_width-1 downto 0);
			fub_read_str_i		:	in	std_logic;
			fub_read_busy_o		:	out	std_logic;
			--	RAM
			ram_wren_o			: out std_logic;
			ram_adr_o			: out std_logic_vector (adr_width-1 downto 0);
			ram_data_o			: out std_logic_vector (data_width-1 downto 0);
			ram_q_i				: in  std_logic_vector (data_width-1 downto 0)
		);
	end component;
	
end fub_ram_interface_pkg;

package body fub_ram_interface_pkg is
end fub_ram_interface_pkg;



-- Entity definition
library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;			

entity fub_ram_interface is
	generic (
		adr_width			:	integer		:=	16;
		data_width			:	integer		:=	8;
		delay_clk			:	integer		:=	2;			--	delay of RAM
		priority_on_read	:	std_logic	:=	'0'
	);
	port (
		clk_i				:	in	std_logic;
		rst_i				:	in	std_logic;
		--	FUB in
		fub_write_adr_i		:	in	std_logic_vector(adr_width-1 downto 0);
		fub_write_data_i	:	in	std_logic_vector(data_width-1 downto 0);
		fub_write_str_i		:	in	std_logic;
		fub_write_busy_o	:	out	std_logic;
		--	FUB out
		fub_read_adr_i		:	in	std_logic_vector(adr_width-1 downto 0);
		fub_read_data_o		:	out	std_logic_vector(data_width-1 downto 0);
		fub_read_str_i		:	in	std_logic;
		fub_read_busy_o		:	out	std_logic;
		--	RAM
		ram_wren_o			: out std_logic;
		ram_adr_o			: out std_logic_vector (adr_width-1 downto 0);
		ram_data_o			: out std_logic_vector (data_width-1 downto 0);
		ram_q_i				: in  std_logic_vector (data_width-1 downto 0)
	);
end fub_ram_interface;

architecture beh_arch of fub_ram_interface is
	
	--States
	type	STATES is (IDLE, READ_FROM_RAM, WRITE_TO_RAM);
	signal	STATE	:	STATES;
	
	--Signals
	signal	cnt			:	integer range delay_clk downto 0;
	signal	read_adr	:	std_logic_vector(adr_width-1 downto 0);
	signal	read_flag	:	std_logic;
	signal	write_data	:	std_logic_vector(data_width-1 downto 0);
	signal	write_adr	:	std_logic_vector(adr_width-1 downto 0);
	signal	write_flag	:	std_logic;
	
	begin
		
		statemachine : process(clk_i, rst_i, fub_write_str_i, fub_read_str_i)
		begin
			if rst_i = '1' then
				cnt													<=	0;
				fub_write_busy_o						<=	'1';
				fub_read_data_o							<=	(others => '0');
				fub_read_busy_o							<=	'1';
				ram_wren_o									<=	'0';
				ram_adr_o										<=	(others => '0');
				ram_data_o									<=	(others => '0');
				write_flag									<=	'0';
				write_adr										<=	(others => '0');
				write_data									<=	(others => '0');
				read_flag										<=	'0';
				read_adr										<=	(others => '0');
			elsif clk_i'event and clk_i = '1' then
				case STATE is
					when IDLE	=>
						cnt	<=	1;
						if cnt = 1 then
							if priority_on_read = '1' then
								if fub_read_str_i = '1' then
									fub_read_busy_o		<=	'1';
									fub_write_busy_o	<=	'1';
									read_adr					<=	fub_read_adr_i;
									read_flag					<=	'1';
									cnt								<=	0;
									STATE							<=	READ_FROM_RAM;
									if fub_write_str_i = '1' then
										write_adr				<=	fub_write_adr_i;
										write_data			<=	fub_write_data_i;
										write_flag			<=	'1';
									end if;
								elsif fub_write_str_i = '1' then
									fub_read_busy_o		<=	'1';
									fub_write_busy_o	<=	'1';
									write_adr					<=	fub_write_adr_i;
									write_data				<=	fub_write_data_i;
									write_flag				<=	'1';
									cnt								<=	0;
									STATE							<=	WRITE_TO_RAM;
								else
									fub_read_busy_o		<=	'0';
									fub_write_busy_o	<=	'0';
								end if;
							else
								if fub_write_str_i = '1' then
									fub_read_busy_o		<=	'1';
									fub_write_busy_o	<=	'1';
									write_adr					<=	fub_write_adr_i;
									write_data				<=	fub_write_data_i;
									write_flag				<=	'1';
									cnt								<=	0;
									STATE							<=	WRITE_TO_RAM;
									if fub_read_str_i = '1' then
										read_adr				<=	fub_read_adr_i;
										read_flag				<=	'1';
									end if;
								elsif fub_read_str_i = '1' then
									fub_read_busy_o		<=	'1';
									fub_write_busy_o	<=	'1';
									read_adr					<=	fub_read_adr_i;
									read_flag					<=	'1';
									cnt								<=	0;
									STATE							<=	READ_FROM_RAM;
								else
									fub_read_busy_o		<=	'0';
									fub_write_busy_o	<=	'0';
								end if;
							end if;
						end if;
					when READ_FROM_RAM	=>
						fub_write_busy_o				<=	'1';
						ram_wren_o							<=	'0';
						if read_flag = '0' then
							ram_adr_o							<=	fub_read_adr_i;
						else
							ram_adr_o							<=	read_adr;
						end if;
						if cnt = delay_clk then
							read_flag							<=	'0';
							fub_read_busy_o				<=	'0';
							fub_read_data_o				<=	ram_q_i;
							if fub_read_str_i = '0' then
								cnt									<=	0;
								if write_flag = '0' then
									STATE							<=	IDLE;
									fub_write_busy_o	<=	'0';									
								else
									STATE							<=	WRITE_TO_RAM;
								end if;
							else
								cnt									<=	1;
							end if;
						else
							 fub_read_busy_o		<=	'1';
							 cnt								<=	cnt+1;
						end if;
						if fub_write_str_i = '1' then
							write_adr						<=	fub_write_adr_i;
							write_data					<=	fub_write_data_i;
							write_flag					<=	'1';
						end if;
					when WRITE_TO_RAM	=>
						fub_read_busy_o				<=	'1';
						ram_wren_o						<=	'1';
						if write_flag = '0' then
							ram_adr_o						<=	fub_write_adr_i;
							ram_data_o					<=	fub_write_data_i;
						else
							ram_adr_o						<=	write_adr;
							ram_data_o					<=	write_data;
						end if;
						if cnt = delay_clk then
							write_flag					<=	'0';
							fub_write_busy_o		<=	'0';	
							if fub_write_str_i = '0' then
								cnt								<=	0;
								if read_flag = '0' then
									STATE						<=	IDLE;
									fub_read_busy_o	<=	'0';
								else
									STATE						<=	READ_FROM_RAM;
								end if;
							else
								cnt								<=	1;
							end if;
							if fub_read_str_i = '1' then
								read_adr					<=	fub_read_adr_i;
								read_flag					<=	'1';
							end if;
						else
							fub_write_busy_o		<=	'1';
							cnt									<=	cnt+1;
						end if;
					when others	=>
						null;
					end case;
				end if;
		end process statemachine;
			
end beh_arch;