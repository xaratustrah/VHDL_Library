-------------------------------------------------------------------------------
--
-- FUB sender that transmit the content of a ROM
--
-- fub_rom_tx is a FUB sender that transmits the content of a user defined ROM. The input data format 
-- must be defined in a separate package with the name init_rom_pkg by the user (as type init_rom) 
-- with a specified ROM size (as constant init_rom_size) and a specified wordsize (as constant init_data_width). 
-- This package is automatically included (used) in fub_rom_tx and must be used in the userfile. 
-- The package definition for a 100 byte ROM and a standard wordsize of 8 bit can be defined as follows:
-- 
-- 
-- library ieee;
-- use ieee.std_logic_1164.all;
-- 
-- package init_rom_pkg is
-- 
-- constant init_rom_size : integer := 100;
-- constant init_data_width : integer := 8;
-- type init_rom is array(0 to init_rom_size-1) of std_logic_vector(init_data_width-1 downto 0);
-- 
-- end init_rom_pkg;
-- 
-- package body init_rom_pkg is
-- end init_rom_pkg;
--
--
-- M. Kumm
-------------------------------------------------------------------------------
-- Package Definition

library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_arith.all;
use IEEE.STD_LOGIC_unsigned.all;
use ieee.math_real.all;

use work.init_rom_pkg.all;

package fub_rom_tx_pkg is

component fub_rom_tx
	generic (
		wait_clks: integer;
		addr_width: integer;
		endless_loop: boolean
	);
	port (
		rst_i: in std_logic;
		clk_i: in std_logic;
		init_data_i : in init_rom;  --init_rom must be defined in init_rom_pkg by the user!
		fub_data_o: out std_logic_vector(init_data_width-1 downto 0);
		fub_addr_o: out std_logic_vector(addr_width-1 downto 0);
		fub_str_o: out std_logic;
		fub_busy_i: in std_logic
	);
end component; 
end fub_rom_tx_pkg;

package body fub_rom_tx_pkg is
end fub_rom_tx_pkg;

-- Entity Definition

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

use work.init_rom_pkg.all;

entity fub_rom_tx is
	generic (
		wait_clks: integer := 1;
		addr_width: integer := 6;
		endless_loop: boolean := false
	);
	port (
		rst_i: in std_logic;
		clk_i: in std_logic;
		init_data_i : in init_rom;
		fub_data_o: out std_logic_vector(init_data_width-1 downto 0);
		fub_addr_o: out std_logic_vector(addr_width-1 downto 0);
		fub_str_o: out std_logic;
		fub_busy_i: in std_logic
	);
end fub_rom_tx;

architecture arch_fub_rom_tx of fub_rom_tx is


	signal count: integer range 0 to wait_clks;
	signal addr: integer range 0 to init_rom_size-1;
	signal finished: std_logic;
begin

	process (clk_i, rst_i)
	begin
		if rst_i = '1' then
			fub_str_o <= '0';
			count <= 0;
			addr <= 0;
			finished <= '0';
		elsif clk_i = '1' and clk_i'event then
 			if count = wait_clks then
  			if finished = '0' then
  				count <= 0;
  				if fub_busy_i = '0' then
  					fub_data_o <= init_data_i(addr);
  					fub_addr_o <= conv_std_logic_vector(addr, addr_width);
  					if (addr = init_rom_size-1) then
  						if endless_loop = true then
  							addr <= 0;
  						else
  							finished <= '1';	--the end
  						end if;
  					else
  						fub_str_o <= '1';
  						addr <= addr + 1;
  					end if;
  				end if;
        else
  				if fub_busy_i = '0' then
    				fub_str_o <= '0';
    			end if;
  			end if;
			else
				if (count < wait_clks) then count <= count + 1; end if;
				fub_str_o <= '0';
			end if;
		end if;
	end process;	

end arch_fub_rom_tx;