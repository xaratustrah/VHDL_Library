-------------------------------------------------------------------------------
--
-- Implementation of an decimator for multirate systems. The decimator
-- drop's decimation_factor-1 samples the received input samples.
-- M. Kumm
--
-------------------------------------------------------------------------------

-- Package Definition

library ieee;
library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_arith.all;
use IEEE.STD_LOGIC_signed.all;

package decimator_pkg is
  component decimator
  	generic(
  		data_width  : integer;
  		decimation_factor  : integer
  	);
  	port(
  			clk_i					:	in  std_logic;
  			rst_i					:	in  std_logic;
  			data_i				:	in std_logic_vector(data_width-1 downto 0);
  			data_str_i		:	in std_logic;
  			data_o				:	out std_logic_vector(data_width-1 downto 0);
  			data_str_o		:	out std_logic
  	);
  end component;
end decimator_pkg;

package body decimator_pkg is
end decimator_pkg;

-- Entity Definition

library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_arith.all;
use IEEE.STD_LOGIC_signed.all;

entity decimator is
	generic(
		data_width  : integer := 16;
		decimation_factor  : integer := 2
	);
	port(
			clk_i					:	in  std_logic;
			rst_i					:	in  std_logic;
			data_i				:	in std_logic_vector(data_width-1 downto 0);
			data_str_i		:	in std_logic;
			data_o				:	out std_logic_vector(data_width-1 downto 0);
 			data_str_o		:	out std_logic
	);
	
end decimator; 

architecture decimator_arch of decimator is

signal cnt : integer range 0 to decimation_factor-1;

begin

process (clk_i, rst_i)
begin
	if rst_i = '1' then
	  data_o <= (others => '0');
	  cnt <= 0;
    data_str_o <= '0';
	elsif clk_i'EVENT and clk_i = '1' then	
	  if data_str_i = '1' then
      if cnt = 0 then
  	    data_o <= data_i;
  	    data_str_o <= '1';
  	    cnt <= decimation_factor-1;
      else
  	    cnt <= cnt - 1;
        data_str_o <= '0';
      end if;
    else
      data_str_o <= '0';
	  end if;
	end if;
end process;

end decimator_arch;