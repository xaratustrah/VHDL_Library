-------------------------------------------------------------------------------
--
-- Resamples the input data with clk1 to a new sample rate clk2
-- M. Kumm
--
-------------------------------------------------------------------------------

-- Package Definition

library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_arith.all;
use IEEE.STD_LOGIC_unsigned.all;
use ieee.math_real.all;

package resampler_pkg is
component resampler
	generic(
		data_width : integer
	);
	port(
	    clk1_i : in std_logic;
	    clk2_i : in std_logic;
	    data_i : in std_logic_vector(data_width-1 downto 0);
	    data_o : out std_logic_vector(data_width-1 downto 0)
	);
end component; 
end resampler_pkg;

package body resampler_pkg is
end resampler_pkg;

-- Entity Definition

library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_arith.all;
use IEEE.STD_LOGIC_unsigned.all;

entity resampler is
	generic(
		data_width : integer := 8
	);
	port(
	    clk1_i : in std_logic;
	    clk2_i : in std_logic;
	    data_i : in std_logic_vector(data_width-1 downto 0);
	    data_o : out std_logic_vector(data_width-1 downto 0)
	);
end resampler; 

architecture resampler_arch of resampler is

signal data_pos_clk1, data_neg_clk1: std_logic_vector(data_width-1 downto 0);
signal data_pos_clk2, data_neg_clk2: std_logic_vector(data_width-1 downto 0);
signal select_neg  : std_logic;
signal data_mux : std_logic_vector(data_width-1 downto 0);

begin
    
  process(clk1_i)
  begin
    if clk1_i='1' and clk1_i'event then
        data_pos_clk1 <= data_i;
    end if;
  end process;	

  process(clk1_i)
  begin
    if clk1_i='0' and clk1_i'event then
        data_neg_clk1 <= data_pos_clk1;
    end if;
  end process;	
  
  process(clk2_i)
  begin
    if clk2_i='0' and clk2_i'event then
        data_pos_clk2 <= data_pos_clk1;
        data_neg_clk2 <= data_neg_clk1;
        select_neg <= clk1_i;
        data_o <= data_mux;
    end if;
  end process;	

  data_mux <= data_neg_clk2 when select_neg = '1' else data_pos_clk2;

end resampler_arch;