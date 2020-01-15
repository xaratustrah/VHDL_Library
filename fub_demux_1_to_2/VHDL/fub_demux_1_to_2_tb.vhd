
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use work.fub_demux_1_to_2_pkg.all;
use work.fub_tx_master_pkg.all;
use work.fub_rx_slave_pkg.all;
use work.real_time_calculator_pkg.all;

entity fub_demux_1_to_2_tb is
 	generic (
		clk_freq_in_hz : real := 50.0E6;
		wait_clks      : integer := 0;
		busy_clks_a    : integer := 0;
		busy_clks_b    : integer := 0
  );
begin

end entity fub_demux_1_to_2_tb;

architecture fub_demux_1_to_2_tb_arch of fub_demux_1_to_2_tb is

  signal clk      : std_logic                    := '0';
  signal rst    : std_logic                    := '0';

  signal fub_data    : std_logic_vector(7 downto 0);  
  signal fub_adr     : std_logic_vector(7 downto 0);  
  signal fub_str     : std_logic;
  signal fub_busy    : std_logic;
  signal fub_a_data  : std_logic_vector(7 downto 0);
  signal fub_a_adr   : std_logic_vector(7 downto 0);
  signal fub_a_str   : std_logic;
  signal fub_a_busy  : std_logic;
  signal fub_b_data  : std_logic_vector(7 downto 0);
  signal fub_b_adr   : std_logic_vector(7 downto 0);
  signal fub_b_str   : std_logic;
  signal fub_b_busy  : std_logic;


begin

  fub_tx_master_inst : fub_tx_master
    generic map(
      addr_width       => 8,
      data_width       => 8,
      addr_start_value => 16#20#,
      data_start_value => 16#10#,
      addr_stop_value  => 16#80#,
      data_stop_value  => 16#60#,
      addr_inc_value   => 16#1#,
      data_inc_value   => 16#1#,
      wait_clks        => wait_clks
      )
  port map (
    clk_i      => clk,
    rst_i      => rst,
    fub_str_o  => fub_str,
    fub_busy_i => fub_busy,
    fub_addr_o => fub_adr,
    fub_data_o => fub_data
    );
 
  fub_demux_1_to_2_inst : fub_demux_1_to_2
  	generic map(
  		fub_data_width   => 8,
  		fub_adr_width    => 8
  	)
  	port map(
  		clk_i            => clk,
  		rst_i            => rst,
  		fub_data_i       => fub_data,
  		fub_adr_i        => fub_adr,
  		fub_str_i        => fub_str,
  		fub_busy_o       => fub_busy,
  		fub_a_data_o     => fub_a_data,
  		fub_a_adr_o      => fub_a_adr, 
  		fub_a_str_o      => fub_a_str, 
  		fub_a_busy_i     => fub_a_busy,
  		fub_b_data_o     => fub_b_data,
  		fub_b_adr_o      => fub_b_adr, 
  		fub_b_str_o      => fub_b_str, 
  		fub_b_busy_i     => fub_b_busy
  	);


  fub_rx_slave1_inst : fub_rx_slave
    generic map(
      addr_width => 8,
      data_width => 8,
      busy_clks  => busy_clks_a
      )
    port map(
      rst_i      => rst,
      clk_i      => clk,
      fub_data_i => fub_a_data,
      fub_str_i  => fub_a_str,
      fub_busy_o => fub_a_busy,
      fub_addr_i => fub_a_adr,
      data_o     => open,
      addr_o     => open,
      str_o      => open
      );

  fub_rx_slave2_inst : fub_rx_slave
    generic map(
      addr_width => 8,
      data_width => 8,
      busy_clks  => busy_clks_b
      )
    port map(
      rst_i      => rst,
      clk_i      => clk,
      fub_data_i => fub_b_data,
      fub_str_i  => fub_b_str,
      fub_busy_o => fub_b_busy,
      fub_addr_i => fub_b_adr,
      data_o     => open,
      addr_o     => open,
      str_o      => open
      );

  clk <= not clk after 0.5 * freq_real_to_period_time(clk_freq_in_hz);
  rst <= '1', '0' after 50 ns;

end architecture fub_demux_1_to_2_tb_arch;