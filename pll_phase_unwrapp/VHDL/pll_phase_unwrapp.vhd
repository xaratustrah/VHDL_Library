-------------------------------------------------------------------------------
--
-- Implementation of phase-unwrap circuit for expanding the lock-in range of pll's.
--
--
-- M. Kumm
--
-------------------------------------------------------------------------------

-- Package Definition

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package pll_phase_unwrapp_pkg is
  component pll_phase_unwrapp
  	generic(
  		input_data_width  : integer;
  		no_of_unwrapp_bits  : integer  --no of bits for extra resolution, output_data_width=input_data_width+unwrapp_width
  	);
  	port(
  			clk_i							:	in  std_logic;
  			rst_i							:	in  std_logic;
  			phase_i				    :	in std_logic_vector(input_data_width-1 downto 0);
  		  phase_str_i				:	in std_logic;
  			phase_o				    :	out std_logic_vector(input_data_width+no_of_unwrapp_bits-1 downto 0);
   			phase_str_o				:	out std_logic
  	);
  end component;
end pll_phase_unwrapp_pkg;

package body pll_phase_unwrapp_pkg is
end pll_phase_unwrapp_pkg;

-- Entity Definition

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pll_phase_unwrapp is
  	generic(
  		input_data_width  : integer := 16;
  		no_of_unwrapp_bits  : integer := 7 --no of bits for extra resolution, output_data_width=input_data_width+unwrapp_width
  	);
  	port(
  			clk_i							:	in  std_logic;
  			rst_i							:	in  std_logic;
  			phase_i				    :	in std_logic_vector(input_data_width-1 downto 0);
  		  phase_str_i				:	in std_logic;
  			phase_o				    :	out std_logic_vector(input_data_width+no_of_unwrapp_bits-1 downto 0);
   			phase_str_o				:	out std_logic
  	);

end pll_phase_unwrapp; 

architecture pll_phase_unwrapp_arch of pll_phase_unwrapp is

signal phased  			      : std_logic_vector(input_data_width-1 downto 0);
signal phasedd 			      : std_logic_vector(input_data_width-1 downto 0);
--signal phaseddd			      : std_logic_vector(input_data_width-1 downto 0);
signal delta_phase		      : std_logic_vector(input_data_width downto 0);
signal delta_phased	      : std_logic_vector(1 downto 0);
signal phase_inc	: std_logic_vector(1 downto 0);
signal phase_tmp	: std_logic_vector(no_of_unwrapp_bits-1 downto 0);
signal phase_unwrapp_inc	: std_logic_vector(no_of_unwrapp_bits-1 downto 0);
signal phase_unwrapp	    : std_logic_vector(no_of_unwrapp_bits-1 downto 0);
signal phase_unwrappd	    : std_logic_vector(no_of_unwrapp_bits-1 downto 0);


begin


  delta_phase <= std_logic_vector(to_signed(to_integer(unsigned(phase_i)) - to_integer(unsigned(phased)),input_data_width+1));

  phase_inc(0) <= delta_phased(0) xor delta_phased(1);
  phase_inc(1) <= delta_phased(0) and not delta_phased(1);

  phase_unwrapp_inc(no_of_unwrapp_bits-1 downto 1) <= (others => phase_inc(1)); --sign extension
  phase_unwrapp_inc(0) <= phase_inc(0);

  phase_unwrapp <= std_logic_vector(signed(phase_unwrappd) + signed(phase_unwrapp_inc));


  phase_o(input_data_width+no_of_unwrapp_bits-1 downto input_data_width) <= phase_unwrappd;
  phase_o(input_data_width-1 downto 0) <= phasedd;


process (clk_i, rst_i)
begin
	if rst_i = '1' then
    phased <= (others => '0');
    phasedd <= (others => '0');
    delta_phased <= (others => '0');
    phase_unwrappd <= (others => '0');
	elsif clk_i'EVENT and clk_i = '1' then	
    if phase_str_i='1' then
      phased <= phase_i;
      phasedd <= phased;
      delta_phased <= delta_phase(input_data_width downto input_data_width-1); 
      phase_unwrappd <= phase_unwrapp;
      
      phase_str_o<= '1';
    else
      phase_str_o<= '0';  
    end if;
  end if;
end process;


end pll_phase_unwrapp_arch;


