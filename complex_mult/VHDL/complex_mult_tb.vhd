-------------------------------------------------------------------------------
--
--
-- M. Kumm
--
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.resize_tools_pkg.all;
use work.complex_mult_pkg.all;

entity complex_mult_tb is
  	generic(
  	  clock_period : time := 10 ns;
  		input_data_width  : integer := 16;
  		internal_data_width  : integer := 32;
  		output_data_width  : integer := 16
  	);
end complex_mult_tb; 

architecture complex_mult_tb_arch of complex_mult_tb is

signal rst : std_logic;
signal clk : std_logic := '0';

signal i1 : std_logic_vector(input_data_width-1 downto 0);
signal q1 : std_logic_vector(input_data_width-1 downto 0);
signal i2 : std_logic_vector(input_data_width-1 downto 0);
signal q2 : std_logic_vector(input_data_width-1 downto 0);

signal i_o : std_logic_vector(output_data_width-1 downto 0);
signal q_o : std_logic_vector(output_data_width-1 downto 0);


begin

  complex_mult_inst : complex_mult
	generic map(
		input_data_width    => input_data_width,
		internal_data_width => internal_data_width,
		output_data_width   => output_data_width,
		use_altera_lpm      => true
	)
	port map(
			clk_i		 => clk,
			rst_i		 => rst,
			i1_i     => i1,
			q1_i     => q1,
			i2_i     => i2,
			q2_i     => q2,
		  iq_str_i => '1',
			i_o			 => i_o,
			q_o			 => q_o,
 			iq_str_o => open
	);

  clk <= not clk after clock_period/2;
  rst <= '1', '0' after 2*clock_period;

  --perfect numerical result should be i_o=-1638 (-0.05), q_o=3277 (0.1)
  i1 <= std_logic_vector(to_signed(3277,input_data_width));
  q1 <= std_logic_vector(to_signed(6554,input_data_width));
  i2 <= std_logic_vector(to_signed(9830,input_data_width));
  q2 <= std_logic_vector(to_signed(13107,input_data_width));


--  i1 <= std_logic_vector(to_signed(-31648,input_data_width));
--  q1 <= std_logic_vector(to_signed(2775,input_data_width));
--  i2 <= std_logic_vector(to_signed(21920,input_data_width));
--  q2 <= std_logic_vector(to_signed(-19039,input_data_width));

end complex_mult_tb_arch;


