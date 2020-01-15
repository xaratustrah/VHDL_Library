------------------------------------------------------------------------------
-- D_FF.vhd
-- D FlipFlop

----------------------------------------------------------------by S.Schaefer 


-- Package Definition
library IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE IEEE.STD_LOGIC_arith.all;
USE IEEE.STD_LOGIC_unsigned.all;
use work.real_time_calculator_pkg.all;
LIBRARY lpm;
USE lpm.lpm_components.all;


package D_FF_pkg is
  component D_FF
  	generic(
      clk_freq_in_hz  :	real		:=	50.0E+6	-- clock frequency in Hertz
  	);
  	port(
      Clk_i			      : IN	STD_LOGIC;     
      rst_i		        : IN	STD_LOGIC;  
      trigger_input_i	: IN	STD_LOGIC; 
      D_FF_output_o		: OUT	STD_LOGIC
  	);
  end component;
end D_FF_pkg;

package body D_FF_pkg is
end D_FF_pkg;

library IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE IEEE.STD_LOGIC_arith.all;
USE IEEE.STD_LOGIC_unsigned.all;
use work.real_time_calculator_pkg.all;
LIBRARY lpm;
USE lpm.lpm_components.all;



ENTITY D_FF IS
  	generic(
      clk_freq_in_hz  :	real		:=	50.0E+6	-- clock frequency in Hertz
  	);
  	port(
      Clk_i			      : IN	STD_LOGIC;     
      rst_i		        : IN	STD_LOGIC;  
      trigger_input_i	: IN	STD_LOGIC; 
      D_FF_output_o		: OUT	STD_LOGIC
  	);
END D_FF;

ARCHITECTURE Arch_D_FF OF D_FF IS

BEGIN


 
D_FF: PROCESS (rst_i, Clk_i) 
	BEGIN
    IF rst_i = '1' THEN
      D_FF_output_o <= '0';     
    ELSIF RISING_EDGE (Clk_i) THEN
      D_FF_output_o <=  trigger_input_i; 
    END IF;
	END PROCESS D_FF;
	

END Arch_D_FF;
