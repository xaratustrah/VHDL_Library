
-------------------------------------------------------------------------------
--
-- example using real time calculator package
-- 20.12.2006/sh
--
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.all;
use work.real_time_calculator_pkg.all;

entity RTCalc_example is
  generic (
    main_clk       : real := 50.0E+6;
    my_delay_in_ns : real := 90.0);

end RTCalc_example;

architecture RTCalc_example_arch of RTCalc_example is

  signal my_delay_in_ticks_ceil : integer := get_delay_in_ticks_ceil(main_clk, my_delay_in_ns);

    signal my_delay_in_ticks_floor : integer := get_delay_in_ticks_floor(main_clk, my_delay_in_ns);

    signal my_delay_in_ticks_round : integer := get_delay_in_ticks_round(main_clk, my_delay_in_ns);

begin  -- RTCalc_example_arch

end RTCalc_example_arch;

