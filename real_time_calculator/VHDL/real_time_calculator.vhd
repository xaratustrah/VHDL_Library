
-------------------------------------------------------------------------------
--
-- Real Time calculator from system clock frequency
--
-- Gets delay in clock ticks from a desired value in ns using a defined
-- system clock frequency.
--
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.math_real.all;

package real_time_calculator_pkg is

  -- function declarations

  -- Always returns the next upper integer value. The resulting value
  -- multiplied by system clock period is always larger than or equal to the desired
  -- delay in ns.
  -- Use this function when minimum delays should be guaranteed.
  
  function get_delay_in_ticks_ceil (
    clk_freq_in_hz      : real;
    desired_delay_in_ns : real)
    return integer;

  -- Always returns the next lower integer value. The resulting value
  -- multiplied by system clock period is always less than or equal to the desired
  -- delay in ns.

  function get_delay_in_ticks_floor (
    clk_freq_in_hz      : real;
    desired_delay_in_ns : real)
    return integer;

  -- Always returns the nearest integer value. The resulting value
  -- multiplied by system clock period is always the nearest to the desired
  -- delay in ns.
  -- Use this function when the most exact delay is necessary.
  
    function get_delay_in_ticks_round (
    clk_freq_in_hz      : real;
    desired_delay_in_ns : real)
    return integer;

  function limit_to_minimal_value(
    x   : integer;
    min : integer)
    return integer;

  -- Returns the period as type time from a given frequency as real
  -- Useful for clock generation in testbenches
  -- e.g. clk <= not clk after 0.5 * freq_real_to_period_time(clk_freq_in_hz);

  function freq_real_to_period_time(
    freq_in_hz      : real)
    return time;
    
end real_time_calculator_pkg;

-- package body

package body real_time_calculator_pkg is

  -- function implementations

  --calculate the maximum of two integers
  function maximum_int(
    x1 : integer;
    x2 : integer
    ) return integer is
  begin
    if x1 > x2 then
      return x1;
    else
      return x2;
    end if;
  end maximum_int;

  --limits the integer to a minimal value of one (for timing counters)
  function limit_to_minimal_value(
    x   : integer;
    min : integer)
    return integer is
  begin
    if x > min then
      return x;
    else
      return 1;
    end if;
  end limit_to_minimal_value;

  -- here comes the constant which is calculated offline

  function get_delay_in_ticks_ceil (
    clk_freq_in_hz      : real;
    desired_delay_in_ns : real)
    return integer is
  begin
    return limit_to_minimal_value(integer(ceil(clk_freq_in_hz * desired_delay_in_ns / 1.0e+9)), 0);
  end get_delay_in_ticks_ceil;

  function get_delay_in_ticks_floor (
    clk_freq_in_hz      : real;
    desired_delay_in_ns : real)
    return integer is
  begin
    return limit_to_minimal_value(integer(floor(clk_freq_in_hz * desired_delay_in_ns / 1.0e+9)), 0);
  end get_delay_in_ticks_floor;

  function get_delay_in_ticks_round (
    clk_freq_in_hz      : real;
    desired_delay_in_ns : real)
    return integer is
  begin
    return limit_to_minimal_value(integer(round(clk_freq_in_hz * desired_delay_in_ns / 1.0e+9)), 0);
  end get_delay_in_ticks_round;
  
  function freq_real_to_period_time(
    freq_in_hz      : real)
    return time is
  begin
    return (1.0/freq_in_hz) * 1 sec;
  end freq_real_to_period_time;

end real_time_calculator_pkg;

