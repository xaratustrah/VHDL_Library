-------------------------------------------------------------------------------
-- Digital Rectifier (Diode)
-- S. Sanjari
-------------------------------------------------------------------------------

-- Package Definition

library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_arith.all;
use IEEE.STD_LOGIC_unsigned.all;

package rectifier_pkg is

  component rectifier
    generic (
      data_bus_width : integer;
      neg_not_pos    : std_logic);
    port (
      clk_i  : in  std_logic;
      rst_i  : in  std_logic;
      data_i : in  std_logic_vector (data_bus_width -1 downto 0);
      data_o : out std_logic_vector (data_bus_width -1 downto 0));
  end component;

end rectifier_pkg;

package body rectifier_pkg is
end rectifier_pkg;

-- Entity Definition

library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_arith.all;
use IEEE.STD_LOGIC_unsigned.all;

entity rectifier is
  
  generic (
    data_bus_width : integer   := 8;
    neg_not_pos    : std_logic := '0');

  port (
    clk_i  : in  std_logic;             -- Clock input
    rst_i  : in  std_logic;
    data_i : in  std_logic_vector (data_bus_width -1 downto 0);
    data_o : out std_logic_vector (data_bus_width -1 downto 0)
    );

end rectifier;

architecture rectifier_arch of rectifier is

begin  -- rectifier_arch

  p_main : process (clk_i, rst_i)
  begin  -- process p_main
    if rst_i = '1' then                 -- asynchronous reset (active high)
      data_o <= (others => '0');

    elsif clk_i'event and clk_i = '1' then  -- rising clock edge
      data_o (data_bus_width - 2 downto 0) <= data_i (data_bus_width - 2 downto 0);
      if neg_not_pos = '1' then
        data_o (data_bus_width - 1) <= '1';
      else
        data_o (data_bus_width - 1) <= '0';
      end if;
    end if;
  end process p_main;

end rectifier_arch;
