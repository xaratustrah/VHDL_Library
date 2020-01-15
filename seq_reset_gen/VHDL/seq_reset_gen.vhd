-------------------------------------------------------------------------------
-- Sequentially reset several components
--
-- S. Sanjari
-------------------------------------------------------------------------------

-- Package Definition
library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_arith.all;
use IEEE.STD_LOGIC_unsigned.all;
use ieee.math_real.all;

package seq_reset_gen_pkg is

  component seq_reset_gen
    generic (
      time_between_resets_in_us : real;
      rst_signal_cnt            : integer;
      clk_freq_in_hz            : real);
    port (
      rst_i : in  std_logic;
      clk_i : in  std_logic;
      rst_o : out std_logic_vector(rst_signal_cnt - 1 downto 0));
  end component;

end seq_reset_gen_pkg;

package body seq_reset_gen_pkg is
end seq_reset_gen_pkg;

-- Entity Definition

library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_arith.all;
use IEEE.STD_LOGIC_unsigned.all;
use ieee.math_real.all;

use work.real_time_calculator_pkg.all;

entity seq_reset_gen is
  
  generic (
    time_between_resets_in_us : real    := 50.0;
    rst_signal_cnt            : integer := 3;
    clk_freq_in_hz            : real    := 50.0E6);

  port (
    rst_i : in  std_logic;
    clk_i : in  std_logic;
    rst_o : out std_logic_vector(rst_signal_cnt - 1 downto 0));

end seq_reset_gen;

architecture seq_reset_gen_arch of seq_reset_gen is

  constant count_max      : integer := get_delay_in_ticks_round(clk_freq_in_hz, 1.0E3 * time_between_resets_in_us);
  signal count            : integer range 0 to count_max - 1 := count_max - 1;
  signal current_resetter : integer range 0 to 2**integer(ceil(log2(real(rst_signal_cnt))));
  
begin  -- seq_reset_gen_arch

  p_main : process (clk_i, rst_i)
  begin  -- process p_main
    if rst_i = '1' then                 -- asynchronous reset (active high)

      rst_o            <= (others => '1');
      count            <= count_max - 1;
      current_resetter <= 0;
      
    elsif clk_i'event and clk_i = '1' then  -- rising clock edge

      if count = 0 then
        count <= count_max - 1;
        if current_resetter < rst_signal_cnt then
          rst_o (current_resetter) <= '0';
          current_resetter         <= current_resetter + 1;
        end if;

      else
        count <= count - 1;
      end if;
    end if;

  end process p_main;
end seq_reset_gen_arch;

