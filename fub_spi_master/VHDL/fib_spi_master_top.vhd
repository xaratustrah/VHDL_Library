-------------------------------------------------------------------------------
--
-- FIB Test program for the SPI Master component. M. Kumm.
--
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_arith.all;
use IEEE.STD_LOGIC_unsigned.all;
use work.fub_tx_master_pkg.all;
use work.fub_spi_master_pkg.all;

entity fib_spi_master_top is
  generic(
    clk_period : time := 10 ns
    );
  port(
    clk0_i    : in  std_logic;
    nSPI_MOSI : out std_logic;
    nSPI_MISO : in  std_logic;
    nSPI_SCK  : out std_logic;
    nSPI_SS   : out std_logic;
    TRIG1_I   : in  std_logic
    );
end fib_spi_master_top;

architecture fib_spi_master_top_arch of fib_spi_master_top is

--external signals
  signal clk0        : std_logic := '0';
  signal reset       : std_logic := '0';
  signal fub_tx_str  : std_logic;
  signal fub_tx_busy : std_logic;
  signal fub_tx_data : std_logic_vector(7 downto 0);
  signal fub_tx_addr : std_logic_vector(7 downto 0);
  signal fub_rx_str  : std_logic;
  signal fub_rx_busy : std_logic;
  signal fub_rx_data : std_logic_vector(7 downto 0);
  signal fub_rx_addr : std_logic_vector(7 downto 0);
  signal spi_mosi    : std_logic;
  signal spi_miso    : std_logic;
  signal spi_clk     : std_logic;
  signal spi_ss      : std_logic;

--internal signals
  signal reset_cnt : integer                      := 0;
  signal spi_data  : std_logic_vector(7 downto 0) := "00000000";

begin

  inst_fub_tx_master : fub_tx_master
    generic map (
      addr_width       => 8,
      data_width       => 8,
      addr_start_value => 16#20#,
      data_start_value => 16#10#,
      addr_stop_value  => 16#80#,
      data_stop_value  => 16#60#,
      addr_inc_value   => 16#1#,
      data_inc_value   => 16#1#,
      wait_clks        => 5000000)
    
    port map (
      clk_i      => clk0,
      rst_i      => reset,
      fub_str_o  => fub_tx_str,
      fub_busy_i => fub_tx_busy,
      fub_data_o => fub_tx_data,
      fub_addr_o => fub_tx_addr
      );

  inst_spi_master : fub_spi_master
    generic map (
      setup_clks => 500,
      spi_clks   => 100)

    port map (
      clk_i      => clk0,
      rst_i      => reset,
      fub_str_i  => fub_tx_str,
      fub_busy_o => fub_tx_busy,
      fub_data_i => fub_tx_data,
      fub_str_o  => fub_rx_str,
      fub_busy_i => fub_rx_busy,
      fub_data_o => fub_rx_data,
      fub_error  => open,
      spi_mosi_o => spi_mosi,
      spi_miso_i => spi_miso,
      spi_clk_o  => spi_clk,
      spi_ss_o   => spi_ss
      );

  process(clk0_i)
  begin
    clk0      <= clk0_i;
    reset     <= TRIG1_I;
    nSPI_MOSI <= not spi_mosi;
    spi_miso  <= not nSPI_MISO;
    nSPI_SS   <= not spi_ss;
    nSPI_SCK  <= not spi_clk;
  end process;

end fib_spi_master_top_arch;

