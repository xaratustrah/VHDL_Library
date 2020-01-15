-------------------------------------------------------------------------------
--
-- FUB 8 bit maximum length sequence receiver
-- T. Guthier
--
-------------------------------------------------------------------------------

-- Package Definition

library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_arith.all;
use IEEE.STD_LOGIC_unsigned.all;

package fub_mls_rx_pkg is
  component fub_mls_rx
    generic (
      use_adr : std_logic
      );
    port (
      clk_i              : in  std_logic;
      rst_i              : in  std_logic;
      fub_busy_o         : out std_logic;
      fub_data_i         : in  std_logic_vector(7 downto 0);
      fub_adr_i          : in  std_logic_vector(7 downto 0);
      fub_str_i          : in  std_logic;
      failure_vector_o   : out std_logic_vector(7 downto 0);
      failure_o          : out std_logic;
      failure_overflow_o : out std_logic;
      locked_o           : out std_logic
      );
  end component;
end fub_mls_rx_pkg;

package body fub_mls_rx_pkg is
end fub_mls_rx_pkg;

-- Entity Definition

library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_arith.all;
use IEEE.STD_LOGIC_unsigned.all;

use work.fub_mls_tx_pkg.all;

entity fub_mls_rx is

  generic (
    use_adr : std_logic := '1'
    );

  port (
    clk_i              : in  std_logic;
    rst_i              : in  std_logic;
    fub_busy_o         : out std_logic;
    fub_data_i         : in  std_logic_vector(7 downto 0);
    fub_adr_i          : in  std_logic_vector(7 downto 0);
    fub_str_i          : in  std_logic;
    failure_vector_o   : out std_logic_vector(7 downto 0);
    failure_o          : out std_logic;
    failure_overflow_o : out std_logic;
    locked_o           : out std_logic
    );

end fub_mls_rx;

architecture fub_mls_rx_arch of fub_mls_rx is

  component data_comparator

    generic (
      use_adr : std_logic := use_adr
      );

    port (
      clk_i              : in  std_logic;
      rst_i              : in  std_logic;
      fub_data_i         : in  std_logic_vector (7 downto 0);
      fub_adr_i          : in  std_logic_vector (7 downto 0);
      data_compare_i     : in  std_logic_vector (7 downto 0);
      adr_compare_i      : in  std_logic_vector (7 downto 0);
      fub_str_i          : in  std_logic;
      fub_busy_o         : out std_logic;
      locked_o           : out std_logic;
      failure_vector_o   : out std_logic_vector(7 downto 0);
      failure_o          : out std_logic;
      failure_overflow_o : out std_logic;
      busy_compare_o     : out std_logic
      ) ;

  end component;

  signal fub_mls_tx_fub_data_o : std_logic_vector(7 downto 0);
  signal fub_mls_tx_fub_adr_o  : std_logic_vector(7 downto 0);

  signal data_comparator_busy_compare_o : std_logic;

begin

  fub_mls_tx_inst : fub_mls_tx
    port map(
      clk_i      => clk_i,
      rst_i      => rst_i,
      fub_busy_i => data_comparator_busy_compare_o,
      fub_data_o => fub_mls_tx_fub_data_o,
      fub_adr_o  => fub_mls_tx_fub_adr_o,
      fub_str_o  => open
      );

  data_comparator_inst : data_comparator
    generic map (
      use_adr => use_adr
      )
    port map(
      clk_i              => clk_i,
      rst_i              => rst_i,
      fub_data_i         => fub_data_i,
      fub_adr_i          => fub_adr_i,
      data_compare_i     => fub_mls_tx_fub_data_o,
      adr_compare_i      => fub_mls_tx_fub_adr_o,
      fub_str_i          => fub_str_i,
      fub_busy_o         => fub_busy_o,
      locked_o           => locked_o,
      failure_vector_o   => failure_vector_o,
      failure_o          => failure_o,
      failure_overflow_o => failure_overflow_o,
      busy_compare_o     => data_comparator_busy_compare_o
      ) ;

end fub_mls_rx_arch;
