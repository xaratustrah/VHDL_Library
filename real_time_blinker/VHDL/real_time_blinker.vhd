-------------------------------------------------------------------------------
-- Real Time Blinker for use with LEDs, Buzzers, etc.
-- S. Sanjari
-------------------------------------------------------------------------------

-- Inst BSP
  -- acceptance_test_conditions_gen_real_time_blinker_inst : entity work.real_time_blinker
    -- generic map (
      -- clk_freq_in_hz     => 50.0,
      -- blink_period_in_ms => 200.0
      -- )
    -- port map(
      -- clk_i  => clk50, 
      -- rst_i  => rst50,
      -- blink_o => blink_o
      -- );





-- Package Definition

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use work.real_time_calculator_pkg.all;

package real_time_blinker_pkg is

  component real_time_blinker
    generic (
      clk_freq_in_hz     : real;
      blink_period_in_ms : real);
    port (
      clk_i   : in  std_logic;
      rst_i   : in  std_logic;
      blink_o : out std_logic);
  end component;

end real_time_blinker_pkg;

package body real_time_blinker_pkg is
end real_time_blinker_pkg;

-- Entity Definition

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use work.real_time_calculator_pkg.all;

entity real_time_blinker is
  generic (
    clk_freq_in_hz     : real := 50.0E6;
    blink_period_in_ms : real := 1000.0
    );
  port (
    clk_i   : in  std_logic;            -- main clock input
    rst_i   : in  std_logic;            -- main reset input
    blink_o : out std_logic             -- blinker output
    );

end real_time_blinker;

architecture real_time_blinker_arch of real_time_blinker is
  
  constant count     : integer := get_delay_in_ticks_round(clk_freq_in_hz, 1.0E6 * blink_period_in_ms);
  signal counter     : integer range 0 to count - 1;
  signal local_blink : std_logic;
  
begin  -- real_time_blinker_arch

  blink_o <= local_blink;

  p_main : process (clk_i, rst_i)
  begin  -- process p_main
    if rst_i = '1' then                     -- asynchronous reset (active high)
      local_blink <= '0';
      counter     <= 0;
    elsif clk_i'event and clk_i = '1' then  -- rising clock edge
      if counter = count - 1 then
        local_blink <= not local_blink;
        counter     <= 0;
      else
        counter <= counter + 1;
      end if;
    end if;
  end process p_main;
end real_time_blinker_arch;
