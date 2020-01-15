
--
-- 16-bit Bus driver with Tri State outputs
-- 20.07.2006/sh
--

-- Package Definition

library ieee;
use ieee.std_logic_1164.all;

package busdriver_pkg is

  component busdriver
    port (
      en_write_to_bus_i : in    std_logic;  -- enable the buffer
      data_bus_io       : inout std_logic_vector (15 downto 0);  -- Bus connection
      data_to_bus_i     : in    std_logic_vector (15 downto 0);  -- data written into the bus
      data_from_bus_o   : out   std_logic_vector (15 downto 0)  -- data read from the bus
      );
  end component;
end busdriver_pkg;

package body busdriver_pkg is
end busdriver_pkg;

-- Entity Definition

library ieee;
use ieee.std_logic_1164.all;

entity busdriver is

  port (
    en_write_to_bus_i : in    std_logic;  -- enable the buffer
    data_bus_io       : inout std_logic_vector (15 downto 0);  -- Bus connection
    data_to_bus_i     : in    std_logic_vector (15 downto 0);  -- data written into the bus
    data_from_bus_o   : out   std_logic_vector (15 downto 0)  -- data read from the bus
    );

end busdriver;

architecture busdriver_arch of busdriver is

begin  -- busdriver_arch

  data_bus_io     <= data_to_bus_i when en_write_to_bus_i = '1' else (others => 'Z');
  data_from_bus_o <= data_bus_io;

end busdriver_arch;
