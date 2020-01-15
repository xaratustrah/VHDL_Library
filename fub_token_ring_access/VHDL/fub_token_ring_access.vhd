-------------------------------------------------------------------------------
--
-- FUB Token Ring Access
-- T. Guthier
--
-------------------------------------------------------------------------------

-- Package Definition

library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_arith.all;
use IEEE.STD_LOGIC_unsigned.all;

package fub_token_ring_access_pkg is
  component fub_token_ring_access
    generic (
      bitSize_input      : integer := 8;
      bitSize_output     : integer := 8;
      adr_bitSize_input  : integer := 8;
      use_adr_input      : integer := 1;
      adr_bitSize_output : integer := 8;
      use_adr_output     : integer := 1
      );        
    port (
      --------------------------------------------------------- old GENERICS
      target_adr       : in  std_logic_vector(7 downto 0) := (others => '0');
      local_adr        : in  std_logic_vector(7 downto 0) := (others => '0');
      master           : in  std_logic                      := '0';  --|| one access has to be master <= '1' 
      ----------------------------------------------------------
      rst_i            : in  std_logic;
      clk100_i         : in  std_logic;
      clk250_i         : in  std_logic;
      data_i           : in  std_logic;
      data_o           : out std_logic;
      observer_data    : out std_logic;  -----------------------------
      fub_data_i       : in  std_logic_vector(bitSize_input - 1 downto 0);
      fub_busy_o       : out std_logic;
      fub_str_i        : in  std_logic;
      fub_adr_i        : in  std_logic_vector(use_adr_input * (adr_bitSize_input - 1) downto 0);
      block_transfer_i : in  std_logic;
      fub_data_o       : out std_logic_vector(bitSize_output - 1 downto 0);
      fub_str_o        : out std_logic;
      fub_adr_o        : out std_logic_vector(use_adr_output * (adr_bitSize_output - 1) downto 0);
      fub_busy_i       : in  std_logic
      );
  end component;
end fub_token_ring_access_pkg;

package body fub_token_ring_access_pkg is
end fub_token_ring_access_pkg;

-- Entity Definition



library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_arith.all;
use IEEE.STD_LOGIC_unsigned.all;

entity fub_token_ring_access is
  generic (
    bitSize_input      : integer := 8;
    bitSize_output     : integer := 8;
    adr_bitSize_input  : integer := 8;
    use_adr_input      : integer := 1;
    adr_bitSize_output : integer := 8;
    use_adr_output     : integer := 1
    );
  port (
    --------------------------------------------------------- old GENERICS
    target_adr       : in  std_logic_vector(7 downto 0) := (others => '0');
    local_adr        : in  std_logic_vector(7 downto 0) := (others => '0');
    master           : in  std_logic                      := '0';  --|| one access has to be master <= '1' 
    ----------------------------------------------------------
    rst_i            : in  std_logic;
    clk100_i         : in  std_logic;
    clk250_i         : in  std_logic;
    data_i           : in  std_logic;
    data_o           : out std_logic;
    observer_data    : out std_logic;   -----------------------------
    fub_data_i       : in  std_logic_vector(bitSize_input - 1 downto 0);
    fub_busy_o       : out std_logic;
    fub_str_i        : in  std_logic;
    fub_adr_i        : in  std_logic_vector(use_adr_input * (adr_bitSize_input - 1) downto 0);
    block_transfer_i : in  std_logic;
    fub_data_o       : out std_logic_vector(bitSize_output - 1 downto 0);
    fub_str_o        : out std_logic;
    fub_adr_o        : out std_logic_vector(use_adr_output * (adr_bitSize_output - 1) downto 0);
    fub_busy_i       : in  std_logic
    );

end fub_token_ring_access;

architecture fub_token_ring_access_arch of fub_token_ring_access is

  component fub_input

    generic (
      bitSize     : integer := 8;
      adr_bitSize : integer := 8;
      use_adr     : integer
      );

    port (
      -------------------------------------------------
      target_adr                 : in  std_logic_vector(7 downto 0) := (others => '0');
      -------------------------------------------------
      clk_i                      : in  std_logic;
      rst_i                      : in  std_logic;
      fub_adr_i                  : in  std_logic_vector(use_adr * (adr_bitSize - 1) downto 0);
      fub_data_i                 : in  std_logic_vector(bitSize - 1 downto 0);
      fub_str_i                  : in  std_logic;
      fub_busy_o                 : out std_logic;
      block_transfer_i           : in  std_logic;
      block_transfer_o           : out std_logic;
      input_got_data_o           : out std_logic;
      no_more_input_data_o       : out std_logic;
      data_for_error_detection_o : out std_logic_vector(bitSize + adr_bitSize - 1 downto 0);
      need_data_i                : in  std_logic;
      data_o                     : out std_logic
      );

  end component;

  component fub_output

    generic (
      bitSize           : integer := 8;
      bitSize_input     : integer := 8;
      adr_bitSize       : integer := 8;
      adr_bitSize_input : integer := 8;
      use_adr           : integer
      );                
    port (
      -------------------------------------------------------------------------
      local_adr                  : in  std_logic_vector(7 downto 0) := (others => '0');
      target_adr                 : in  std_logic_vector(7 downto 0) := (others => '0');
      -------------------------------------------------------------------------
      clk_i                      : in  std_logic;
      rst_i                      : in  std_logic;
      fub_str_o                  : out std_logic;
      fub_data_o                 : out std_logic_vector(bitSize - 1 downto 0);
      fub_adr_o                  : out std_logic_vector(use_adr * (adr_bitSize - 1) downto 0);
      fub_busy_i                 : in  std_logic;
      delete_all_o               : out std_logic;
      data_for_error_detection_i : in  std_logic_vector(bitSize_input + adr_bitSize_input - 1 downto 0);
      token_deleted_i            : in  std_logic;
      ring_str_i                 : in  std_logic;
      data_i                     : in  std_logic;
      data_clk_i                 : in  std_logic;
      no_more_data_i             : in  std_logic
      );

  end component;

  component decoder_ring

    port (
      clk_i            : in  std_logic;
      rst_i            : in  std_logic;
      data_i           : in  std_logic;
      delete_all_i     : in  std_logic;
      observer_data    : out std_logic;  -----------------------------
      reset_detected_i : in  std_logic;
      token_deleted_o  : out std_logic;
      ring_got_data_o  : out std_logic;
      ring_str_o       : out std_logic;
      trigger_o        : out std_logic;
      data_clk_o       : out std_logic;
      no_more_data_o   : out std_logic;
      sending_i        : in  std_logic;
      data_o           : out std_logic
      );

  end component;

  component encoder_ring
    
    port (
      -----------------------------------------------------------
      master               : in  std_logic;
      -----------------------------------------------------------
      clk_i                : in  std_logic;
      rst_i                : in  std_logic;
      no_more_data_i       : in  std_logic;
      ring_str_i           : in  std_logic;
      ring_got_data_i      : in  std_logic;
      trigger_i            : in  std_logic;
      ring_data_i          : in  std_logic;
      reset_detected_o     : out std_logic;
      sending_o            : out std_logic;
      need_input_data_o    : out std_logic;
      input_data_i         : in  std_logic;
      input_got_data_i     : in  std_logic;
      block_transfer_i     : in  std_logic;
      no_more_input_data_i : in  std_logic;
      data_mc_o            : out std_logic
      );                                                                

  end component;

  signal fub_input_input_got_data_o     : std_logic;
  signal fub_input_no_more_input_data_o : std_logic;
  signal fub_input_data_o               : std_logic;
  signal fub_input_block_transfer_o     : std_logic;

  signal fub_output_delete_all_o : std_logic;

  signal fub_input_data_for_error_detection_o : std_logic_vector(bitSize_input + adr_bitSize_input - 1 downto 0);

  signal decoder_token_deleted_o : std_logic;
  signal decoder_ring_str_o      : std_logic;
  signal decoder_ring_got_data_o : std_logic;
  signal decoder_trigger_o       : std_logic;
  signal decoder_data_clk_o      : std_logic;
  signal decoder_no_more_data_o  : std_logic;
  signal decoder_data_o          : std_logic;

  signal encoder_reset_detected_o  : std_logic;
  signal encoder_sending_o         : std_logic;
  signal encoder_need_input_data_o : std_logic;

begin

  fub_input_inst : fub_input
    generic map (
      bitSize     => bitSize_input,
      adr_bitSize => adr_bitSize_input,
      use_adr     => use_adr_input
      )
    port map (
                                        --------------------------------------------
      target_adr                 => target_adr,
                                        --------------------------------------------
      clk_i                      => clk100_i,
      rst_i                      => rst_i,
      fub_adr_i                  => fub_adr_i,
      fub_data_i                 => fub_data_i,
      fub_str_i                  => fub_str_i,
      fub_busy_o                 => fub_busy_o,
      block_transfer_i           => block_transfer_i,
      block_transfer_o           => fub_input_block_transfer_o,
      data_for_error_detection_o => fub_input_data_for_error_detection_o,
      input_got_data_o           => fub_input_input_got_data_o,
      no_more_input_data_o       => fub_input_no_more_input_data_o,
      need_data_i                => encoder_need_input_data_o,
      data_o                     => fub_input_data_o
      );                        

  fub_output_inst : fub_output
    generic map (
      bitSize           => bitSize_output,
      bitSize_input     => bitSize_input,
      adr_bitSize       => adr_bitSize_output,
      adr_bitSize_input => adr_bitSize_input,
      use_adr           => use_adr_output
      )         
    port map (
                                        ----------------------------------------------
      local_adr                  => local_adr,
      target_adr                 => target_adr,
                                        ----------------------------------------------
      clk_i                      => clk250_i,
      rst_i                      => rst_i,
      fub_str_o                  => fub_str_o,
      fub_data_o                 => fub_data_o,
      fub_adr_o                  => fub_adr_o,
      fub_busy_i                 => fub_busy_i,
      data_for_error_detection_i => fub_input_data_for_error_detection_o,
      delete_all_o               => fub_output_delete_all_o,
      token_deleted_i            => decoder_token_deleted_o,
      ring_str_i                 => decoder_ring_str_o,
      data_i                     => decoder_data_o,
      data_clk_i                 => decoder_data_clk_o,
      no_more_data_i             => decoder_no_more_data_o
      );

  decoder_ring_inst : decoder_ring
    port map (
      clk_i            => clk250_i,
      rst_i            => rst_i,
      data_i           => data_i,
      observer_data    => observer_data,  -----------------------------
      delete_all_i     => fub_output_delete_all_o,
      reset_detected_i => encoder_reset_detected_o,
      token_deleted_o  => decoder_token_deleted_o,
      ring_got_data_o  => decoder_ring_got_data_o,
      ring_str_o       => decoder_ring_str_o,
      trigger_o        => decoder_trigger_o,
      data_clk_o       => decoder_data_clk_o,
      no_more_data_o   => decoder_no_more_data_o,
      data_o           => decoder_data_o,
      sending_i        => encoder_sending_o
      );

  encoder_ring_inst : encoder_ring
    
    port map (
      -------------------------------------------------
      master               => master,
      -------------------------------------------------
      clk_i                => clk100_i,
      rst_i                => rst_i,
      no_more_data_i       => decoder_no_more_data_o,
      ring_str_i           => decoder_ring_str_o,
      ring_got_data_i      => decoder_ring_got_data_o,
      trigger_i            => decoder_trigger_o,
      ring_data_i          => decoder_data_o,
      reset_detected_o     => encoder_reset_detected_o,
      sending_o            => encoder_sending_o,
      need_input_data_o    => encoder_need_input_data_o,
      input_data_i         => fub_input_data_o,
      input_got_data_i     => fub_input_input_got_data_o,
      block_transfer_i     => fub_input_block_transfer_o,
      no_more_input_data_i => fub_input_no_more_input_data_o,
      data_mc_o            => data_o
      );                                                                

end fub_token_ring_access_arch;
