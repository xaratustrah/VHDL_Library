library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_arith.all;
use IEEE.STD_LOGIC_unsigned.all;
use ieee.math_real.all;

use work.iir_lp_filter_opt_pkg.all;

entity iir_lp_filter_opt_tb is
	generic(
			input_data_width 	: integer := 16;
			output_data_width 	: integer  := 16;
			internal_data_width 	: integer  := 32; --should be at least 2*f_3dB_div+input_data_width
      f_3dB_div      : integer := 8
	);
end iir_lp_filter_opt_tb; 

architecture iir_lp_filter_opt_tb_arch of iir_lp_filter_opt_tb is
  signal x : std_logic_vector(input_data_width-1 downto 0) := (others => '0'); --input
  signal y : std_logic_vector(output_data_width-1 downto 0); --output
  signal y_real : real;
  signal x_real : real;
  signal clk : std_logic := '0';
  signal rst : std_logic;

begin
    iir_lp_filter_opt_inst : iir_lp_filter_opt
    generic map(
      input_data_width  => input_data_width,
      internal_data_width => internal_data_width,
      output_data_width => output_data_width,
      f_3dB_div => f_3dB_div
      )
    port map(
      rst_i           => rst,
      clk_i           => clk,
      data_i       => x,
      data_str_i    => '1',
			data_str_o    => open,
      data_o      => y
      );
    
    clk <= not clk after 10 ns;
    rst <= '1', '0' after 20 ns;
    x_real <= real(conv_integer(signed(x)))/ 2.0**(input_data_width-1);
    y_real <= real(conv_integer(signed(y)))/ 2.0**(output_data_width-1);
    
--    x <= x"7FFF", x"0000" after 40 ns; --impulse response
    x <= x"7FFF"; --step response
--    x <= x"1000"; --step response
--    x <= x"0001", x"00000000" after 40 ns; --impulse response
--    x <= x"0001"; --step response

--    x <= x"01"; --step response, minimum positive value
--    x <= x"10"; --step response, positive value
--    x <= x"7F"; --step response, maximum positive value
--    x <= x"80"; --step response, maximum negative value

--    x <= x"7F", x"00" after 40 ns; --impulse response, maximum positive value


--    x <= conv_std_logic_vector(-1,input_data_width); --negative step response
--  process(clk)
--    begin
--    if clk='1' and clk'event then
--      x <= conv_std_logic_vector(conv_integer(x) + 1,input_data_width); --ramp response
--    end if;
--  end process;

    
end iir_lp_filter_opt_tb_arch;