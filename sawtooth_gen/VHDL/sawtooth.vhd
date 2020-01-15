--
-- Saw tooth generator by counting
-- 25.07.2006/sh
--

-- Package Definition

  library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

package sawtooth_pkg is
  component sawtooth
    generic (
      counter_width : integer);
    port (
      dat_o : out std_logic_vector (counter_width - 1 downto 0);
      rst_i : in  std_logic;
      clk_i : in  std_logic);
  end component;

end sawtooth_pkg;
package body sawtooth_pkg is
end sawtooth_pkg;

-- Entity Definition

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity sawtooth is

  generic (
    counter_width : integer := 14);

  port (
    dat_o : out std_logic_vector (counter_width - 1 downto 0);  -- data output
    rst_i : in  std_logic;                                      -- reset input
    clk_i : in  std_logic);                                     -- input clock

end sawtooth;

architecture sawtooth_arch of sawtooth is

  signal counter : integer range 0 to 2**counter_width -1;  -- counter variable

begin  -- sawtooth_arch

  p_saw_tooth : process (clk_i, rst_i, counter)

  begin  -- process p_dac1_test

    if rst_i = '1' then                 -- reset active high

      counter <= 2**counter_width - 1;

    elsif clk_i'event and clk_i = '1' then  -- rising clock edge

      if counter = 0 then
        counter <= 2**counter_width - 1;

      else
        counter <= counter - 1;
      end if;

      dat_o <= conv_std_logic_vector (counter, counter_width);

    end if;

  end process p_saw_tooth;

end sawtooth_arch;

