-- 
-- clock divider
-- 21.07.2006/sh
-- Revision : 10.07.2007/sh
--
-- Package Definition

-- Wenn clk_div_i=0 -> clk_o=0 (Statisch)
-- Wenn clk_div_i=1 -> clk_o=clk_i (hart verdrahtet)
-- Wenn clk_div_i>1 -> clk_div_i gibt die Anzahl der pos. Flanken an bis clk_o=1 für einen Takt ist


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package clk_divider_pkg is

  component clk_divider
    generic (
      clk_divider_width : integer);
    port (
      clk_div_i : in  std_logic_vector (clk_divider_width - 1 downto 0);
      rst_i     : in  std_logic;
      clk_i     : in  std_logic;
      clk_o     : out std_logic);
  end component;

end clk_divider_pkg;

package body clk_divider_pkg is
end clk_divider_pkg;

-- Entity Definition

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity clk_divider is
  generic (
    clk_divider_width : integer := 16);  -- Bit Width of the clock divider

  port (
    clk_div_i : in  std_logic_vector (clk_divider_width - 1 downto 0);  -- clock division constant
    rst_i     : in  std_logic;          -- async reset  in
    clk_i     : in  std_logic;          -- clk input
    clk_o     : out std_logic);         -- clk out

end clk_divider;

architecture clk_divider_arch of clk_divider is

  signal clk_cnt     : integer range 0 to 2**clk_divider_width - 1;  -- clk counter variable
  signal clk_o_local : std_logic;       -- local clock for the operations
  
begin  -- clk_divider_arch

  clk_o <= '0' when to_integer(unsigned(clk_div_i)) = 0 else clk_i when to_integer(unsigned(clk_div_i)) = 1 else clk_o_local;

  p_clock : process (clk_i, rst_i, clk_div_i)
  begin  -- process p_clock
    if rst_i = '1' then                 -- asynchronous reset (active high)

      clk_cnt     <= 0;
--      clk_cnt     <= to_integer(unsigned(clk_div_i));  -- initialize with the constant
      clk_o_local <= '0';               -- initialize the output clock to zero
      
    elsif clk_i'event and clk_i = '1' then

      if (clk_cnt = to_integer(unsigned(clk_div_i))-1) then
        clk_o_local <= '1';
        clk_cnt     <= 0;               -- initialize with the constant
      else
        clk_o_local <= '0';

        if (to_integer(unsigned(clk_div_i)) > 1)  then  -- if controll becuse of
                                                     -- ModelSIM Error!
        clk_cnt     <= clk_cnt + 1;
        end if;
      end if;
    end if;
  end process p_clock;
end clk_divider_arch;
