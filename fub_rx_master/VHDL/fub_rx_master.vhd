-------------------------------------------------------------------------------
--
-- Reference implementation for FUB receiver in Master mode.
-- S. Sanjari
-- 04.may.2007
--
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_arith.all;
use IEEE.STD_LOGIC_unsigned.all;

-- Package Definition

package fub_rx_master_pkg is

  component fub_rx_master
    generic (
      addr_width       : integer;
      data_width       : integer;
      addr_start_value : integer;
      addr_stop_value  : integer;
      addr_inc_value   : integer);
    port (
      fub_str_o  : out std_logic;
      fub_busy_i : in  std_logic;
      fub_data_i : in  std_logic_vector (data_width-1 downto 0);
      fub_addr_o : out std_logic_vector (addr_width-1 downto 0);
      rst_i      : in  std_logic;
      clk_i      : in  std_logic;
      data_o     : out std_logic_vector (data_width-1 downto 0);
      addr_o     : out std_logic_vector (addr_width-1 downto 0);
      str_o      : out std_logic);
  end component;

end fub_rx_master_pkg;

package body fub_rx_master_pkg is
end fub_rx_master_pkg;

-- Entity Definition

library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_arith.all;
use IEEE.STD_LOGIC_unsigned.all;

entity fub_rx_master is
  
  generic (
    addr_width       : integer := 8;
    data_width       : integer := 8;
    addr_start_value : integer := 16#20#;
    addr_stop_value  : integer := 16#80#;
    addr_inc_value   : integer := 16#1#
    );

  port (
    fub_str_o  : out std_logic;
    fub_busy_i : in  std_logic;
    fub_data_i : in  std_logic_vector (data_width-1 downto 0);
    fub_addr_o : out std_logic_vector (addr_width-1 downto 0);

    rst_i  : in  std_logic;
    clk_i  : in  std_logic;
    data_o : out std_logic_vector (data_width-1 downto 0);
    addr_o : out std_logic_vector (addr_width-1 downto 0);
    str_o  : out std_logic
    );

end fub_rx_master;

architecture fub_rx_master_arch of fub_rx_master is

  signal addr  : integer range 0 to 2**( addr_width + 1 ) - 1;
  type states_type is (START, WAITING, CHECK_BUSY);
  signal state : states_type;
  
begin  -- fub_rx_master_arch

  p_main : process (clk_i, rst_i)
  begin  -- process p_main
    if rst_i = '1' then                 -- asynchronous reset (active high)
      fub_str_o  <= '0';
      fub_addr_o <= (others => '0');
      data_o     <= (others => '0');
      addr_o     <= (others => '0');
      str_o      <= '0';
      addr       <= addr_start_value;
      state      <= START;
      
    elsif clk_i'event and clk_i = '1' then  -- rising clock edge
      case state is

        when START =>
          fub_addr_o <= conv_std_logic_vector (addr, addr_width);
          addr       <= addr + addr_inc_value;
          fub_str_o  <= '1';
          state      <= WAITING;

        when WAITING=>
          if addr = addr_stop_value + addr_inc_value then
            fub_str_o <= '0';
          else
            fub_addr_o <= conv_std_logic_vector (addr, addr_width);
            addr       <= addr + addr_inc_value;
            fub_str_o  <= '1';
          end if;
          state <= CHECK_BUSY;
          
        when CHECK_BUSY =>
          if fub_busy_i = '0' then
            data_o <= fub_data_i;
            state  <= WAITING;
          else
            state <= CHECK_BUSY;
          end if;
        when others => null;

      end case;
    end if;
  end process p_main;
end fub_rx_master_arch;
