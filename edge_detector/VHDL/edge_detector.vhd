-------------------------------------------------------------------------------
-- Edge detector
-- S. Sanjari
-------------------------------------------------------------------------------

-- Package Definition

library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_arith.all;
use IEEE.STD_LOGIC_unsigned.all;
use ieee.math_real.all;

package edge_detector_pkg is
  component edge_detector
    generic(
      output_on_time_in_clks : integer := 1  -- for future implelmentations
      );
    port (
      clk_i : in  std_logic;
      rst_i : in  std_logic;
      x_i   : in  std_logic;
      x_o   : out std_logic
      );

  end component;
end edge_detector_pkg;

package body edge_detector_pkg is
end edge_detector_pkg;

-- Entity Definition

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity edge_detector is
  generic (
    output_on_time_in_clks : integer := 1  -- for future implelmentations
    );
  port (
    clk_i : in  std_logic;
    rst_i : in  std_logic;
    x_i   : in  std_logic;
    x_o   : out std_logic
    );
end entity edge_detector;

architecture edge_detector_arch of edge_detector is
  
  signal out_sig, last_value : std_logic;
  
begin

  x_o <= out_sig;

  edge_finder : process (clk_i, rst_i, x_i)
  begin  -- process edge_finder
    if rst_i = '1' then                 -- asynchronous reset (active high)
      last_value <= '0';
      out_sig    <= '0';

    elsif clk_i'event and clk_i = '1' then  -- rising clock edge
      if (last_value = '0' and x_i = '1') then
        out_sig <= '1';
      else
        out_sig <= '0';
      end if;
      last_value <= x_i;
    end if;
  end process edge_finder;

end architecture edge_detector_arch;
