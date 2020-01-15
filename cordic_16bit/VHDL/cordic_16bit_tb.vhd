library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use ieee.math_real.all;

use work.cordic_16bit_pkg.all;

entity cordic_tb is
    generic(
      clk_period : time := 10 ns;
      data_width : natural := 16
   );

end cordic_tb;
architecture cordic_tb_arch of cordic_tb is

  signal clk,rst : std_logic := '0';
  signal i,q : std_logic_vector(data_width-1 downto 0) := (others => '0');
  signal magnitude,phase : std_logic_vector(data_width-1 downto 0);

  signal phase_r,magnitude_r : real;
  signal exact_phase_r,exact_magnitude_r,exact_magnitude_rd,exact_phase_rd : real;
begin
    
    cordic_16bit_inst : cordic_16bit
      port map(
				clk_i => clk,
				rst_i => rst,
				i_i  => i,
				q_i  => q,
				magnitude_o => magnitude,
				phase_o => phase
      );
        
    clk <= not clk after clk_period/2;
    rst <= '1','0' after 2*clk_period;
    
    i <=  conv_std_logic_vector(100,data_width) after 3*clk_period,
          conv_std_logic_vector(0,data_width) after 4*clk_period,
          conv_std_logic_vector(100,data_width) after 5*clk_period,
          conv_std_logic_vector(10000,data_width) after 6*clk_period,
          conv_std_logic_vector(32767,data_width) after 7*clk_period;
    
    q <=  conv_std_logic_vector(100,data_width) after 3*clk_period,
          conv_std_logic_vector(100,data_width) after 4*clk_period,
          conv_std_logic_vector(0,data_width) after 5*clk_period,
          conv_std_logic_vector(10000,data_width) after 6*clk_period,
          conv_std_logic_vector(32767,data_width) after 7*clk_period;
          
    magnitude_r <= (real(conv_integer(magnitude))/1.6467)/32767.0;
--    exact_magnitude_r <= sqrt((real(conv_integer(i)))**2+(real(conv_integer(q)))**2);
--    magnitude_r <= real(conv_integer(magnitude))/1.6467;
    exact_magnitude_rd <= exact_magnitude_r'delayed(175 ns);
    exact_magnitude_r <= sqrt((real(conv_integer(i))/32767.0)**2+(real(conv_integer(q))/32767.0)**2);

    phase_r <= (real(conv_integer(phase))/32767.0)*180.0;
--    exact_phase_r <= atan((real(conv_integer(q))/32767.0)/(real(conv_integer(i))/32767.0))/(2.0*MATH_PI)*360.0;
--    exact_phase_rd <= exact_phase_r'delayed(175 ns);
-- -> kein atan in Modelsim ...    

end cordic_tb_arch;