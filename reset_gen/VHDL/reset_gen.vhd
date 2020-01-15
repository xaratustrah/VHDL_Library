
--
-- Reset Generator
--

library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_unsigned.all;

-- Package Definition

package reset_gen_pkg is

  component reset_gen
    generic (
      reset_clks : integer);
    port (
      clk_i : in  std_logic;
      rst_o : out std_logic);
  end component;

end reset_gen_pkg;

package body reset_gen_pkg is
end reset_gen_pkg;

-- Entity Definition

library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_arith.all;
use IEEE.STD_LOGIC_unsigned.all;

entity reset_gen is
  generic(
    reset_clks : integer := 10
    );
  port
    (
      clk_i : in  std_logic;
      rst_o : out std_logic :='1'
      );
end reset_gen;

architecture arch_reset_gen of reset_gen is
  signal count : integer range 0 to reset_clks :=0;
begin

  process (clk_i)
  begin
    if clk_i'event and clk_i = '1' then
      if count = reset_clks then
        rst_o <= '0';
      else
        count <= count + 1;
        rst_o <= '1';
      end if;
    end if;
  end process;
  
end arch_reset_gen;
