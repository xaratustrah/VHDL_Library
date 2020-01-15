-------------------------------------------------------------------------------
--
-- SPI Master Component. M. Kumm
--
-------------------------------------------------------------------------------

-- Package Definition

library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_arith.all;
use IEEE.STD_LOGIC_unsigned.all;

package fub_spi_master_pkg is

  component fub_spi_master
    generic (
      setup_clks : integer;
      spi_clks   : integer
      );
    port (
      clk_i      : in  std_logic;
      rst_i      : in  std_logic;
      fub_str_i  : in  std_logic;
      fub_busy_o : out std_logic;
      fub_data_i : in  std_logic_vector(7 downto 0);
      fub_str_o  : out std_logic;
      fub_busy_i : in  std_logic;
      fub_data_o : out std_logic_vector(7 downto 0);
      fub_error  : out std_logic;
      spi_mosi_o : out std_logic;
      spi_miso_i : in  std_logic;
      spi_clk_o  : out std_logic;
      spi_ss_o   : out std_logic);
  end component;

end fub_spi_master_pkg;

package body fub_spi_master_pkg is
end fub_spi_master_pkg;

-- Entity Definition

library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_arith.all;
use IEEE.STD_LOGIC_unsigned.all;

entity fub_spi_master is
  generic(
    setup_clks : integer := 2;          --must be even
    spi_clks   : integer := 10          --must be greater than setup_clks!
    );
  port(
    clk_i      : in  std_logic;
    rst_i      : in  std_logic;
    fub_str_i  : in  std_logic;
    fub_busy_o : out std_logic;
    fub_data_i : in  std_logic_vector(7 downto 0);
    fub_str_o  : out std_logic;
    fub_busy_i : in  std_logic;
    fub_data_o : out std_logic_vector(7 downto 0);
    fub_error  : out std_logic;
    spi_mosi_o : out std_logic;
    spi_miso_i : in  std_logic;
    spi_clk_o  : out std_logic;
    spi_ss_o   : out std_logic
    );

end fub_spi_master;

architecture fub_spi_master_arch of fub_spi_master is

--signal data_cnt       : integer range 0 to 10;

  signal data_tx  : std_logic_vector (7 downto 0);
  signal data_rx  : std_logic_vector (7 downto 0);
  signal cnt      : integer range 0 to setup_clks-1;
  signal data_cnt : integer range 0 to 7;

  type states is (WAIT_FOR_STR, WAIT_SETUP_TIME, SEND_RX_DATA, WAIT_HALF_CLK_PERIOD);
  signal state : states;

  signal spi_clk : std_logic;

begin

  process (clk_i, rst_i, fub_str_i, fub_data_i, spi_miso_i)
  begin

    spi_clk_o <= spi_clk;

    if rst_i = '1' then
      fub_busy_o <= '0';
      spi_clk    <= '0';
      spi_mosi_o <= '0';
      spi_ss_o   <= '1';
      fub_data_o <= (others => '0');
      fub_busy_o <= '0';
      fub_str_o  <= '0';
      data_cnt   <= 7;
      fub_error  <= '0';
      state      <= WAIT_FOR_STR;
    elsif clk_i'event and clk_i = '1' then
      case state is
        when WAIT_FOR_STR =>
          if fub_str_i = '1' then
            fub_busy_o <= '1';
            data_tx    <= fub_data_i;
            spi_ss_o   <= '0';
            spi_mosi_o <= fub_data_i(data_cnt);
            cnt        <= conv_integer(spi_clks/2-1);
            state      <= WAIT_HALF_CLK_PERIOD;
          end if;
        when WAIT_HALF_CLK_PERIOD =>
          if cnt = 0 then
            cnt <= conv_integer(spi_clks/2-1);
            if spi_clk = '0' then
              spi_clk <= '1';
            else
              spi_clk <= '0';
              if data_cnt = 0 then
                data_rx(0) <= spi_miso_i;
                data_cnt   <= 7;
                spi_ss_o   <= '1';
                state      <= SEND_RX_DATA;
              else
                data_rx(data_cnt) <= spi_miso_i;
                spi_mosi_o        <= data_tx(data_cnt - 1);
                data_cnt          <= data_cnt - 1;
              end if;
            end if;
          else
            cnt <= cnt - 1;
          end if;
        when SEND_RX_DATA =>
          if fub_busy_i = '0' then
            fub_data_o <= data_rx;
            fub_str_o  <= '1';
          else
            fub_error <= '1';
          end if;
          cnt   <= conv_integer(setup_clks-1);
          state <= WAIT_SETUP_TIME;
        when WAIT_SETUP_TIME =>
          fub_str_o <= '0';
          if cnt = 0 then
            fub_busy_o <= '0';
            state      <= WAIT_FOR_STR;
          else
            cnt <= cnt - 1;
          end if;
      end case;
    end if;
  end process;

end fub_spi_master_arch;
