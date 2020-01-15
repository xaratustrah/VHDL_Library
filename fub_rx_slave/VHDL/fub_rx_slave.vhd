-------------------------------------------------------------------------------
--
-- Reference implementation of FUB receiver in slave mode
-- M. Kumm
--
-------------------------------------------------------------------------------

-- Package Definition

library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_arith.all;
use IEEE.STD_LOGIC_unsigned.all;

package fub_rx_slave_pkg is

  component fub_rx_slave
    generic (
      addr_width : integer := 8;
      data_width : integer := 8;
      busy_clks  : integer := 0
      );
    port (
      rst_i      : in  std_logic;
      clk_i      : in  std_logic;
      fub_data_i : in  std_logic_vector (data_width-1 downto 0);
      fub_str_i  : in  std_logic := '0';
      fub_busy_o : out std_logic := '0';
      fub_addr_i : in  std_logic_vector (addr_width-1 downto 0);
      data_o     : out std_logic_vector (data_width-1 downto 0);
      addr_o     : out std_logic_vector (addr_width-1 downto 0);
      str_o      : out std_logic);
  end component;

end fub_rx_slave_pkg;

package body fub_rx_slave_pkg is
end fub_rx_slave_pkg;

-- Entity Definition

library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_arith.all;
use IEEE.STD_LOGIC_unsigned.all;

entity fub_rx_slave is
  generic(
    addr_width : integer := 8;
    data_width : integer := 8;
    busy_clks  : integer := 0
    );
  port(
    rst_i      : in  std_logic;
    clk_i      : in  std_logic;
    fub_data_i : in  std_logic_vector (data_width-1 downto 0);
    fub_str_i  : in  std_logic := '0';
    fub_busy_o : out std_logic := '0';
    fub_addr_i : in  std_logic_vector (addr_width-1 downto 0);
    data_o     : out std_logic_vector (data_width-1 downto 0);
    addr_o     : out std_logic_vector (addr_width-1 downto 0);
    str_o      : out std_logic
    );

end fub_rx_slave;

architecture arch_fub_rx_slave of fub_rx_slave is
  
  signal busy_count : integer range 0 to busy_clks;
  type states is (RECEIVING, BUSY);
  signal state      : states;
  
begin
  
  process (clk_i, rst_i, fub_str_i, fub_addr_i)
  begin
    if rst_i = '1' then
      fub_busy_o <= '0';
      data_o     <= (others => '0');
      addr_o     <= (others => '0');
      str_o      <= '0';
      busy_count <= 0;
      state      <= RECEIVING;
    elsif clk_i'event and clk_i = '1' then
      case state is
        when RECEIVING =>
          if fub_str_i = '1' then
            addr_o <= fub_addr_i;
            data_o <= fub_data_i;
            str_o  <= '1';
            if busy_clks > 0 then
              fub_busy_o <= '1';
              state      <= BUSY;
            end if;
          else
            str_o <= '0';
          end if;
        when BUSY =>
          if busy_count = busy_clks-1 then
            state      <= RECEIVING;
            busy_count <= 0;
            fub_busy_o <= '0';
          else
            busy_count <= busy_count + 1;
          end if;
      end case;
    end if;
  end process;
  
end arch_fub_rx_slave;
