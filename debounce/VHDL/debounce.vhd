-------------------------------------------------------------------------------
--
-- M. Kumm
-- 
-- Debounce logic for debouncing of machanical switches or similar noisy input logic
--2010/09/07 added rst_i to sensitivity list of process /ct
--2011/03/31 added real_debouncer_arch /ct
-------------------------------------------------------------------------------

-- Package Definition

library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_arith.all;
use IEEE.STD_LOGIC_unsigned.all;

package debounce_pkg is
  component debounce
  	generic(
  		debounce_clks  : integer
  	);
  	port(
  			rst_i	:	in std_logic ;
  			clk_i	:	in std_logic ;
  			x_i		:	in std_logic ;
  			x_o 	:	out std_logic
  	);
  end component debounce;
end package debounce_pkg;

package body debounce_pkg is
end debounce_pkg;

-- Entity Definition

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity debounce is
	generic(
		debounce_clks  : integer :=2
	);
	port(
			rst_i	:	in std_logic ;
			clk_i	:	in std_logic ;
			x_i		:	in std_logic ;
			x_o 	:	out std_logic
	);
end entity debounce; 

architecture debounce_arch of debounce is
	signal count : integer range 0 to debounce_clks;
	signal x_sync: std_logic;

begin

debounce_p: process (clk_i, rst_i, x_i)
begin
	if rst_i='1' then
		x_o <= x_i;
	elsif rising_edge(clk_i) then
		x_sync <= x_i;
		if x_sync = '1' then
			if count = debounce_clks then
				x_o <= '1';
			else
				count <= count + 1;
			end if;
		else
			if count = 0 then
				x_o <= '0';
			else
				count <= count - 1;
			end if;
		end if;
	end if;
end process debounce_p;

end architecture debounce_arch;

architecture real_debouncer_arch of debounce is
	constant	ALL_ONES	: integer := (2**debounce_clks)- 1;
	signal		shift_x_i	: std_logic_vector(debounce_clks - 1 downto 0);
begin
	debunce_process: process (rst_i,clk_i,x_i) is
	begin
		if rst_i = '1' then
			shift_x_i	<= (others => '0');
			x_o <= '0';
		elsif rising_edge(clk_i) then
			shift_x_i	<= x_i & shift_x_i(shift_x_i'left downto 1);
			case conv_integer(unsigned(shift_x_i)) is
				when 0 =>
					x_o <= '0';
				when ALL_ONES =>
					x_o <= '1';
				when others =>
					null;
			end case;
		end if;
	end process debunce_process;

end architecture real_debouncer_arch;
