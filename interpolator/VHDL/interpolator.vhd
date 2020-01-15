-------------------------------------------------------------------------------
--
-- Implementation of an interpolator for multirate systems. The interpolator
-- adds interpolation_factor-1 zero samples when an input sample is received.
-- M. Kumm
--
-------------------------------------------------------------------------------

-- Package Definition

library ieee;
library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_arith.all;
use IEEE.STD_LOGIC_signed.all;

package interpolator_pkg is
  component interpolator
  	generic(
  		data_width  : integer;
  		interpolation_factor  : integer
  	);
  	port(
  			clk_i							:	in  std_logic;
  			rst_i							:	in  std_logic;
  			data_i				:	in std_logic_vector(data_width-1 downto 0);
  			data_str_i				:	in std_logic;
  			data_o				:	out std_logic_vector(data_width-1 downto 0);
  			data_str_o				:	out std_logic
  	);
  end component;
end interpolator_pkg;

package body interpolator_pkg is
end interpolator_pkg;

-- Entity Definition

library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_arith.all;
use IEEE.STD_LOGIC_signed.all;

entity interpolator is
	generic(
		data_width  : integer := 16;
		interpolation_factor  : integer := 2
	);
	port(
			clk_i							:	in  std_logic;
			rst_i							:	in  std_logic;
			data_i				:	in std_logic_vector(data_width-1 downto 0);
			data_str_i				:	in std_logic;
			data_o				:	out std_logic_vector(data_width-1 downto 0);
 			data_str_o				:	out std_logic
	);
	
end interpolator; 

architecture interpolator_arch of interpolator is

signal cnt : integer range 0 to interpolation_factor-1;

begin

process (clk_i, rst_i)
begin
	if rst_i = '1' then
	  data_o <= (others => '0');
	  cnt <= 0;
    data_str_o <= '0';
	elsif clk_i'EVENT and clk_i = '1' then	
	    if cnt = 0 then
    	  if data_str_i = '1' then
    	    data_o <= data_i;
    	    data_str_o <= '1';
    	    cnt <= interpolation_factor-1;
        else
  	      data_str_o <= '0';
    	  end if;
	    else
  	    data_o <= (others => '0');
  	    data_str_o <= '1';
  	    cnt <= cnt - 1;
  	  end if;
	end if;
end process;

end interpolator_arch;