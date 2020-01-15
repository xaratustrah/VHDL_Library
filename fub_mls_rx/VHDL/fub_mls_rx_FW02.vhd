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

package fub_mls_rx_FW02_pkg is
  component fub_mls_rx_FW02
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
end fub_mls_rx_FW02_pkg;

package body fub_mls_rx_FW02_pkg is
end fub_mls_rx_FW02_pkg;

-- Entity Definition

library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_arith.all;
use IEEE.STD_LOGIC_unsigned.all;

use work.fub_mls_tx_pkg.all;

entity fub_mls_rx_FW02 is

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

end fub_mls_rx_FW02;

architecture fub_mls_rx_FW02_arch of fub_mls_rx_FW02 is

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

  signal addr_cmp : std_logic_vector(7 downto 0);
  signal data_cmp  : std_logic_vector(7 downto 0);
  signal strb_cmp : std_logic;
  signal busy_cmp : std_logic;

begin

  fub_mls_tx_inst : entity work.fub_mls_tx_FW02
	generic map	( 	
    strb_delay		 	=> 0 
	)  
	port map(  
			clk_i			    => clk_i,
			rst_i			    => rst_i,
      
			fub_adr_o		  => addr_cmp,
			fub_data_o		=> data_cmp,
			fub_str_o 		=> strb_cmp, 
			fub_busy_i		=> busy_cmp
	);


  data_comparator_inst : entity work.data_comparator_FW02
    generic map (
      use_adr => use_adr
      )
    port map(
      clk_i              => clk_i,
      rst_i              => rst_i,
      -- mls sequence to be checked
      fub_addr_i         => fub_adr_i,     
      fub_data_i         => fub_data_i,
      fub_strb_i         => fub_str_i,
      fub_busy_o         => fub_busy_o,
      -- interface to fub_mls_tx for verification purpose 
      addr_cmp_i         => addr_cmp,
      data_cmp_i         => data_cmp,
      strb_cmp_i         => strb_cmp,
      busy_cmp_o         => busy_cmp,

      locked_o           => locked_o,
      failure_vector_o   => failure_vector_o,
      failure_o          => failure_o,
      failure_overflow_o => failure_overflow_o

      ) ;

end fub_mls_rx_FW02_arch;
