library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_arith.all;
use IEEE.STD_LOGIC_unsigned.all;
use ieee.math_real.all;

use work.fub_rs232_tx_pkg.all;
use work.fub_tx_master_pkg.all;
use work.reset_gen_pkg.all;
use work.fub_fifo_pkg.all; -- wo ist dieses pkg

entity fub_super_duper_fifo_40Bitx256_top is  -- fub_super_duper_fifo_40Bitx256_top
  generic(
    clk_freq_in_hz : real := 50.0E6;
    baud_rate      : real := 9600.0
    );
  port(
    clk0_i     : in  std_logic;
    trig1_i    : in  std_logic;
    rs232_rx_i : in  std_logic;
    led0_o     : out std_logic;
    led1_o     : out std_logic;
    led2_o     : out std_logic;
    led3_o     : out std_logic;
    rs232_tx_o : out std_logic
    );

end fub_fifo_top;

architecture fub_fifo_top_arch of fub_fifo_top is
  signal fub1_str  : std_logic;
  signal fub1_busy : std_logic;
  signal fub1_data : std_logic_vector(7 downto 0);
  signal fub1_addr : std_logic_vector(1 downto 0);

  signal fub2_str  : std_logic;
  signal fub2_busy : std_logic;
  signal fub2_data : std_logic_vector(7 downto 0);
  signal fub2_addr : std_logic_vector(1 downto 0);

  signal rst : std_logic;
  
begin

  led1_o <= '1';

  fub_tx_master_inst : fub_tx_master
    generic map(
      addr_width       => 2,
      data_width       => 8,
      addr_start_value => 16#0#,       --ASCII 'A'
      data_start_value => 16#41#,
      addr_stop_value  => 16#3#,
      data_stop_value  => 16#5A#,       --ASCII 'Z'
      addr_inc_value   => 16#1#,
      data_inc_value   => 16#1#,
      wait_clks        => 0
      )
    port map (
      clk_i      => clk0_i,
      rst_i      => rst,
      fub_str_o  => fub1_str,
      fub_busy_i => fub1_busy,
      fub_data_o => fub1_data,
      fub_addr_o => fub1_addr
      );

  reset_gen_inst : reset_gen
    generic map (
      reset_clks => 2
      )
    port map (
      clk_i => clk0_i,
      rst_o => rst
      );

  fub_fifo_1 : fub_fifo
    generic map (
      fub_data_width => 8,
      fub_addr_width => 2,
      fifo_depth     => 128)
    port map (
      rst_i         => rst,
      clk_i         => clk0_i,
      fub_rx_data_i => fub1_data,
      fub_rx_strb_i => fub1_str,
      fub_rx_busy_o => fub1_busy,
      fub_rx_addr_i => fub1_addr,
      fub_tx_strb_o => fub2_str,
      fub_tx_busy_i => fub2_busy,
      fub_tx_addr_o => fub2_addr,
      fub_tx_data_o => fub2_data);

    fub_rs232_tx_inst : fub_rs232_tx
    generic map (
      clk_freq_in_hz => clk_freq_in_hz,
      baud_rate      => baud_rate
      )
    port map (
      clk_i      => clk0_i,
      rst_i      => rst,
      rs232_tx_o => rs232_tx_o,
      fub_str_i  => fub2_str,
      fub_busy_o => fub2_busy,
      fub_data_i => fub2_data
      );
--fub2_busy <= '1';
  
end fub_fifo_top_arch;
