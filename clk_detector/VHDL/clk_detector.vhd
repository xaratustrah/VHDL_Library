-------------------------------------------------------------------------------
--
-- clk_detector is used for visualization of high speed signals on LEDs acting like a monoflop
-- When the one bit input x_i changes it's value, a pulse with a pulse length of "output_on_time_in_ms"
-- is produced at x_o, which can be directly put on an LED for signaling e.g. data strobes, 
-- activity on serial communications, fast triggers, etc. 
-- M. Kumm
-- 
-------------------------------------------------------------------------------

-- Package Definition

library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_arith.all;
use IEEE.STD_LOGIC_unsigned.all;
use ieee.math_real.all;

package clk_detector_pkg is
  component clk_detector
    generic(
      clk_freq_in_hz       : real;
      output_on_time_in_ms : real
      );
    port (
      clk_i : in std_logic;
      rst_i : in std_logic;
      x_i : in std_logic;
      x_o : out std_logic
      );

  end component;
end clk_detector_pkg;

package body clk_detector_pkg is
end clk_detector_pkg;

-- Entity Definition

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

use work.real_time_calculator_pkg.all;


entity clk_detector is
  generic (
    clk_freq_in_hz       : real := 50.0E6;
    output_on_time_in_ms : real := 100.0
    );
  port (
    clk_i : in  std_logic;
    rst_i : in  std_logic;
    x_i   : in  std_logic;
    x_o   : out std_logic
    );
end entity clk_detector;

architecture clk_detector_arch of clk_detector is
  
  constant OUTPUT_ON_TIME_IN_TICKS : integer := get_delay_in_ticks_round(clk_freq_in_hz, output_on_time_in_ms * 1.0E6);
  signal counter                   : integer range 0 to OUTPUT_ON_TIME_IN_TICKS;
  signal last_value                : std_logic;
  
begin

  x_o <= '0' when counter = 0 else '1';

  process(clk_i, rst_i, x_i)
  begin
    if (rst_i = '1') then
      counter    <= 0;
      last_value <= x_i;
    elsif (clk_i = '1' and clk_i'event) then
      last_value <= x_i;
      if (x_i = '1' and last_value = '0') then
        counter <= OUTPUT_ON_TIME_IN_TICKS;
      elsif (counter /= 0) then
        counter <= counter - 1;
      end if;
    end if;
  end process;
  
end architecture clk_detector_arch;
