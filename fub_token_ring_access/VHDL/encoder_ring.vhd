library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_arith.all;
use IEEE.STD_LOGIC_unsigned.all;

entity encoder_ring is
  
  
  port (
    ---------------------------------------------
    master               : in  std_logic := '0';
    ---------------------------------------------
    clk_i                : in  std_logic;
    rst_i                : in  std_logic;
    no_more_data_i       : in  std_logic;
    ring_got_data_i      : in  std_logic;
    ring_str_i           : in  std_logic;
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

end encoder_ring;

architecture encoder_ring_arch of encoder_ring is

  component encoder_sync

    port (
      clk_i           : in  std_logic;
      rst_i           : in  std_logic;
      no_more_data_i  : in  std_logic;
      ring_got_data_i : in  std_logic;
      data_i          : in  std_logic;
      trigger_i       : in  std_logic;
      ring_str_i      : in  std_logic;
      trigger_o       : out std_logic;
      no_more_data_o  : out std_logic;
      ring_data_o     : out std_logic;
      ring_got_data_o : out std_logic;
      ring_str_o      : out std_logic
      );

  end component;

  component encoder_memory

    port (
      clk_i           : in  std_logic;
      rst_i           : in  std_logic;
      no_more_data_i  : in  std_logic;
      no_more_data_o  : out std_logic;
      ring_str_i      : in  std_logic;
      ring_got_data_i : in  std_logic;
      data_i          : in  std_logic;
      trigger_i       : in  std_logic;
      need_data_i     : in  std_logic;
      ring_data_o     : out std_logic
      );

  end component;

  component encoder_main
    
    port (
      ------------------------------------------------
      master               : in  std_logic;
      ------------------------------------------------
      clk_i                : in  std_logic;
      rst_i                : in  std_logic;
      no_more_ring_data_i  : in  std_logic;
      ring_got_data_i      : in  std_logic;
      ring_str_i           : in  std_logic;
      ring_data_i          : in  std_logic;
      reset_detected_o     : out std_logic;
      sending_o            : out std_logic;
      need_ring_data_o     : out std_logic;
      need_input_data_o    : out std_logic;
      input_data_i         : in  std_logic;
      input_got_data_i     : in  std_logic;
      block_transfer_i     : in  std_logic;
      no_more_input_data_i : in  std_logic;
      data_mc_o            : out std_logic
      );                                                                

  end component;

  signal encoder_sync_ring_data_o     : std_logic;
  signal encoder_sync_no_more_data_o  : std_logic;
  signal encoder_sync_ring_str_o      : std_logic;
  signal encoder_sync_ring_got_data_o : std_logic;
  signal encoder_sync_trigger_o       : std_logic;

  signal encoder_memory_ring_data_o    : std_logic;
  signal encoder_memory_no_more_data_o : std_logic;

  signal encoder_main_need_ring_data_o : std_logic;

begin

  encoder_sync_inst : encoder_sync
    port map (
      clk_i           => clk_i,
      rst_i           => rst_i,
      no_more_data_i  => no_more_data_i,
      ring_got_data_i => ring_got_data_i,
      data_i          => ring_data_i,
      trigger_i       => trigger_i,
      ring_str_i      => ring_str_i,
      trigger_o       => encoder_sync_trigger_o,
      no_more_data_o  => encoder_sync_no_more_data_o,
      ring_data_o     => encoder_sync_ring_data_o,
      ring_got_data_o => encoder_sync_ring_got_data_o,
      ring_str_o      => encoder_sync_ring_str_o
      );

  encoder_memory_inst : encoder_memory
    port map(
      clk_i           => clk_i,
      rst_i           => rst_i,
      no_more_data_i  => encoder_sync_no_more_data_o,
      data_i          => encoder_sync_ring_data_o,
      trigger_i       => encoder_sync_trigger_o,
      no_more_data_o  => encoder_memory_no_more_data_o,
      ring_got_data_i => encoder_sync_ring_got_data_o,
      ring_str_i      => encoder_sync_ring_str_o,
      need_data_i     => encoder_main_need_ring_data_o,
      ring_data_o     => encoder_memory_ring_data_o
      );

  encoder_main_inst : encoder_main
    port map (
                                        ---------------------------------------
      master               => master,
                                        ---------------------------------------
      clk_i                => clk_i,
      rst_i                => rst_i,
      no_more_ring_data_i  => encoder_memory_no_more_data_o,
      ring_got_data_i      => encoder_sync_ring_got_data_o,
      ring_str_i           => encoder_sync_ring_str_o,
      ring_data_i          => encoder_memory_ring_data_o,
      sending_o            => sending_o,
      reset_detected_o     => reset_detected_o,
      need_ring_data_o     => encoder_main_need_ring_data_o,
      need_input_data_o    => need_input_data_o,
      input_data_i         => input_data_i,
      input_got_data_i     => input_got_data_i,
      block_transfer_i     => block_transfer_i,
      no_more_input_data_i => no_more_input_data_i,
      data_mc_o            => data_mc_o
      );                                                                

end encoder_ring_arch;
