
-------------------------------------------------------------------------------
-- Inout Driver without clock
-- major modification on 09.05.2007/sh
-- Based on inout_driver
--
-------------------------------------------------------------------------------

-- Package Definition

library ieee;
use ieee.std_logic_1164.all;

package inout_driver02_pkg is

  component inout_driver02
    generic (
      io_bus_width : integer);
    port (
      read_not_write_to_bus_i : in    std_logic;
      data_bus_io             : inout std_logic_vector (io_bus_width - 1 downto 0);
      data_to_bus_i           : in    std_logic_vector (io_bus_width - 1 downto 0);
      data_from_bus_o         : out   std_logic_vector (io_bus_width - 1 downto 0));
  end component;

end inout_driver02_pkg;

package body inout_driver02_pkg is
end inout_driver02_pkg;

-- Entity Definition

library ieee;
use ieee.std_logic_1164.all;

entity inout_driver02 is
  generic (
    io_bus_width : integer := 16);              -- width of the IO bus
  port (
    read_not_write_to_bus_i : in    std_logic;  -- enable the buffer
    data_bus_io             : inout std_logic_vector (io_bus_width - 1 downto 0);
    -- Bus connection
    data_to_bus_i           : in    std_logic_vector (io_bus_width - 1 downto 0);
    -- data written into the bus
    data_from_bus_o         : out   std_logic_vector (io_bus_width - 1 downto 0)
    -- data read from the bus
    );

end inout_driver02;

architecture inout_driver02_arch of inout_driver02 is

begin  -- inout_driver02_arch

  data_bus_io     <= data_to_bus_i when read_not_write_to_bus_i = '0' else (others => 'Z');
  data_from_bus_o <= data_bus_io;
  
end inout_driver02_arch;
