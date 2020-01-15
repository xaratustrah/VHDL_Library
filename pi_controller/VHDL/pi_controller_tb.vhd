library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_arith.all;
use IEEE.STD_LOGIC_unsigned.all;
use ieee.math_real.all;

use work.pi_controller_pkg.all;

entity pi_controller_tb is
	generic(
			data_width 						: integer :=	32;
			internal_data_width 	: integer := 64;
			sampling_frequency : real := 60.0E6;
--      kp : real := 0.0029614746747839782; --@60MHz
--      ki : real := 131.59472534785812     --@60MHz
      kp : real := 0.00148073733739198910; --@60MHz
      ki : real := 65.797362673929058     --@60MHz
 	);
	
end pi_controller_tb; 

architecture pi_controller_tb_arch of pi_controller_tb is
  signal x : std_logic_vector(data_width-1 downto 0) := (others => '0'); --input
  signal y : std_logic_vector(data_width-1 downto 0); --output
  signal y_real : real;
  signal clk : std_logic := '0';
  signal rst : std_logic;

begin
    pi_controller_inst : pi_controller
    generic map(
      data_width  => data_width,
      internal_data_width => internal_data_width,
      sampling_frequency => sampling_frequency,
      kp => kp,
      ki => ki,
      use_altera_lpm	=> true
      )
    port map(
      rst_i           => rst,
      clk_i           => clk,
      data_i       => x,
      data_o      => y
      );
    
    clk <= not clk after 10 ns;
    rst <= '1', '0' after 20 ns;
    y_real <= real(conv_integer(y))/ 2.0**(data_width-1);
    
    x <= conv_std_logic_vector(integer(0.1*2.0**(data_width-1)),data_width);
--    x <= x"7FFFFFFF", x"00000000" after 40 ns; --impulse response
--    x <= x"00000001", x"00000000" after 40 ns; --impulse response
--    x <= x"00000001"; --step response
--    x <= conv_std_logic_vector(-1,data_width); --negative step response
--  process(clk)
--    begin
--    if clk='1' and clk'event then
--      x <= conv_std_logic_vector(conv_integer(x) + 1,data_width); --ramp response
--    end if;
--  end process;

    
end pi_controller_tb_arch;