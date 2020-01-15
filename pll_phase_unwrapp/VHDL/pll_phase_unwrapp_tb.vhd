-------------------------------------------------------------------------------
--
--
--
-- M. Kumm
--
-------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.pll_phase_unwrapp_pkg.all;

entity pll_phase_unwrapp_tb is
  	generic(
  	  clock_period : time := 10 ns;
  	  phase_inc : integer := 16;
  		input_data_width  : integer := 8;
  		no_of_unwrapp_bits  : integer := 4 --no of bits for extra resolution, output_data_width=input_data_width+unwrapp_width
  	);
end pll_phase_unwrapp_tb; 

architecture pll_phase_unwrapp_tb_arch of pll_phase_unwrapp_tb is

signal rst : std_logic;
signal clk : std_logic := '0';

signal phase_i : std_logic_vector(input_data_width-1 downto 0);
signal phase_o : std_logic_vector(input_data_width+no_of_unwrapp_bits-1 downto 0);

signal sign : integer;

begin

  pll_phase_unwrapp_inst : pll_phase_unwrapp
  	generic map(
  		input_data_width   => input_data_width,
  		no_of_unwrapp_bits => no_of_unwrapp_bits
  	)
  	port map(
  			clk_i				=> clk,
  			rst_i				=> rst,
  			phase_i			=> phase_i,
  		  phase_str_i	=> '1',
  			phase_o			=> phase_o,
   			phase_str_o	=> open
  	);

  clk <= not clk after clock_period/2;
  rst <= '1', '0' after 2*clock_period;

  sign <= 1, -1 after 10 us;

process (clk, rst)
begin

	if rst = '1' then
    phase_i <= (others => '0');
	elsif clk'EVENT and clk = '1' then	
	  phase_i <= std_logic_vector(to_signed(to_integer(signed(phase_i)) + sign*phase_inc,input_data_width));
  end if;
end process;


end pll_phase_unwrapp_tb_arch;


