library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_arith.all;
use IEEE.STD_LOGIC_unsigned.all;

use work.resampler_pkg.all;

entity resampler_tb is
	generic(
		clk1_freq_in_hz : real := 101.0E6;
		clk2_freq_in_hz : real := 103.0E6;
		data_width : integer := 8
	);
end resampler_tb; 

architecture resampler_tb_arch of resampler_tb is

signal clk1,clk2 : std_logic := '0';
signal data_in: std_logic_vector(data_width-1 downto 0) := (others => '0');
signal data_out : std_logic_vector(data_width-1 downto 0);

begin

  clk1 <= not clk after 0.5 * freq_real_to_period_time(clk1_freq_in_hz);
  clk2 <= not clk after 0.5 * freq_real_to_period_time(clk2_freq_in_hz);
  
  resampler_inst : resampler
  generic map(
      data_width => data_width
  )
  port map(
      clk1_i => clk1,
      clk2_i => clk2,
      data_i => data_in,
      data_o => data_out
  );
        
gen_input_data : process(clk1)
begin
	if	clk1 = '1' and clk1'event then
	    data_in <= data_in + 1;
	end if;
end process;



end resampler_tb_arch;
