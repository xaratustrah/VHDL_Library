library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_arith.all;
use IEEE.STD_LOGIC_unsigned.all;
use work.fub_spi_master_pkg.all;
use work.fub_tx_master_pkg.all;
use work.fub_rx_slave_pkg.all;

entity fub_spi_master_testbench is
  generic(
    clk_period : time := 10 ns
    );
end fub_spi_master_testbench;

architecture fub_spi_master_testbench_arch of fub_spi_master_testbench is

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

    port map (
      clk_i      => clk0,
      rst_i      => reset,
      fub_str_o  => fub_tx_str,
      fub_busy_i => fub_tx_busy,
      fub_data_o => fub_tx_data,
      fub_addr_o => fub_tx_addr
      );

  inst_fub_spi_master : fub_spi_master

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

  inst_fub_rx_slave : fub_rx_slave
    port map (
      clk_i      => clk0,
      rst_i      => reset,
      fub_str_i  => fub_rx_str,
      fub_busy_o => fub_rx_busy,
      fub_data_i => fub_rx_data,
      fub_addr_i => fub_rx_addr
      );

-- generate clock
  p_clock_gen : process
  begin
    loop
      clk0 <= '0';
      wait for clk_period;
      clk0 <= '1';
      wait for clk_period;
    end loop;
  end process p_clock_gen;

--generate reset signal
  p_reset_gen : process(clk0)
  begin

    if clk0 = '1' and clk0'event then
      if reset_cnt = 5 then
        reset <= '0';
      else
        reset     <= '1';
        reset_cnt <= reset_cnt + 1;
      end if;
    end if;
  end process p_reset_gen;

--spi slave
  p_spi_slave : process(spi_mosi, spi_ss, spi_clk)
  begin
    if spi_clk = '1' and spi_clk'event and spi_ss = '0' then
      spi_data <= conv_std_logic_vector((conv_integer(spi_data) / 2), 8) or conv_std_logic_vector((conv_integer(spi_mosi) * 128), 8);
      spi_miso <= spi_data(0);
    end if;
  end process p_spi_slave;

end fub_spi_master_testbench_arch;
