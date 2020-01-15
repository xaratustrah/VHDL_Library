-------------------------------------------------------------------------------
-- FUB FIFO Component
-- S. Sanjari
-------------------------------------------------------------------------------

-- Package Definition

library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_unsigned.all;

package fub_fifo_pkg is
  component fub_fifo
    generic (
      fub_data_width : integer;
      fub_addr_width : integer;
      fifo_depth     : integer);
    port (
      rst_i         : in  std_logic;
      clk_i         : in  std_logic;
      fub_rx_data_i : in  std_logic_vector (fub_data_width - 1 downto 0);
      fub_rx_strb_i : in  std_logic;
      fub_rx_busy_o : out std_logic;
      fub_rx_addr_i : in  std_logic_vector (fub_addr_width - 1 downto 0);
      fub_tx_strb_o : out std_logic;
      fub_tx_busy_i : in  std_logic;
      fub_tx_addr_o : out std_logic_vector (fub_addr_width - 1 downto 0);
      fub_tx_data_o : out std_logic_vector (fub_data_width - 1 downto 0));
  end component;
end fub_fifo_pkg;

package body fub_fifo_pkg is
end fub_fifo_pkg;

-- Entity Definition

library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_unsigned.all;

entity fub_fifo is
  
  generic (
    fub_data_width : integer := 8;
    fub_addr_width : integer := 2;
    fifo_depth     : integer := 256);

  port (
    rst_i : in std_logic;
    clk_i : in std_logic;

    -- FUB RX Slave Part
    fub_rx_data_i : in  std_logic_vector (fub_data_width - 1 downto 0);
    fub_rx_strb_i : in  std_logic;
    fub_rx_busy_o : out std_logic;
    fub_rx_addr_i : in  std_logic_vector (fub_addr_width - 1 downto 0);

    -- FUB TX Master Part
    fub_tx_strb_o : out std_logic;
    fub_tx_busy_i : in  std_logic;
    fub_tx_addr_o : out std_logic_vector (fub_addr_width - 1 downto 0);
    fub_tx_data_o : out std_logic_vector (fub_data_width - 1 downto 0));

end fub_fifo;

architecture fub_fifo_arch of fub_fifo is

  component fifo
    port (
      clock : in  std_logic;
      data  : in  std_logic_vector (fub_addr_width + fub_data_width - 1 downto 0);
      rdreq : in  std_logic;
      sclr  : in  std_logic;
      wrreq : in  std_logic;
      empty : out std_logic;
      full  : out std_logic;
      q     : out std_logic_vector (fub_addr_width + fub_data_width - 1 downto 0));
  end component;

  signal fifo_data_in                                            : std_logic_vector (fub_addr_width + fub_data_width - 1 downto 0);
  signal fifo_rdreq                                              : std_logic;
  signal fifo_wrreq                                              : std_logic;
  signal fifo_empty                                              : std_logic;
  signal fifo_full                                               : std_logic;
  signal fifo_data_out, fifo_data_out_sync1, fifo_data_out_sync2 : std_logic_vector (fub_addr_width + fub_data_width - 1 downto 0);

  type read_cycle_state_type is (FIRST, SECOND, THIRD, FOURTH);
  signal read_cycle_state : read_cycle_state_type;

begin  -- fub_fifo_arch

  fifo_inst : fifo
    port map (
      clock => clk_i,
      data  => fifo_data_in,
      rdreq => fifo_rdreq,
      sclr  => rst_i,
      wrreq => fifo_wrreq,
      empty => fifo_empty,
      full  => fifo_full,
      q     => fifo_data_out);

  fifo_wrreq <= '1';

  p_fub_rx_slave : process (clk_i, rst_i)
  begin  -- process p_fub_rx_slave
    if rst_i = '1' then                 -- asynchronous reset (active high)

      fub_tx_strb_o    <= '0';
      fub_tx_addr_o    <= (others => '0');
      fub_tx_data_o    <= (others => '0');
      read_cycle_state <= FIRST;
      
    elsif clk_i'event and clk_i = '1' then  -- rising clock edge

      -- Read Part

      case read_cycle_state is
        when FIRST =>
          if fifo_empty = '0' then
            fifo_rdreq       <= '1';
            read_cycle_state <= SECOND;
          end if;

        when SECOND =>
          fifo_rdreq <= '0';
          if fub_tx_busy_i = '0' then
            fub_tx_strb_o    <= '1';
            fub_tx_addr_o    <= fifo_data_out (fub_addr_width + fub_data_width - 1 downto 8);
            fub_tx_data_o    <= fifo_data_out (fub_data_width - 1 downto 0);
            read_cycle_state <= FIRST;
          else
            fub_tx_strb_o <= '0';
          end if;
          
        when others => null;
      end case;
    end process p_fub_rx_slave;

      p_write : process (clk_i, rst_i)
      begin  -- process p_write
        if rst_i = '1' then             -- asynchronous reset (active high)
          fub_rx_busy_o <= '0';
          
        elsif clk_i'event and clk_i = '1' then  -- rising clock edge
          -- Write Part
          if fub_rx_strb_i = '1' then
            if fifo_full = '0' then
              fub_rx_busy_o <= '0';
              fifo_data_in  <= fub_rx_addr_i & fub_rx_data_i;
            else
              fub_rx_busy_o <= '1';
            end if;
          end if;
        end if;
      end if;
    end process p_write;

    end fub_fifo_arch;
