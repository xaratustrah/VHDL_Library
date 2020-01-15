
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

use work.reset_gen_pkg.all;
use work.id_info_pkg.all;

use work.clk_detector_pkg.all;
use work.fub_registerfile_cntrl_pkg.all;
use work.fub_rs232_rx_pkg.all;
use work.fub_rs232_tx_pkg.all;
use work.fub_seq_demux_pkg.all;
use work.fub_seq_mux_pkg.all;
use work.fub_flash_pkg.all;

--use work.registerfile_ram_interface_pkg.all;
use work.registerfile_ram_interface_pkg.all;

entity fib_registerfile_top is
  generic(
    clk_freq_in_hz          : real    := 50.0E6;
    firmware_id             : integer := 1;  --ID of the firmware (is displayed first)
    firmware_version        : integer := 3;  --Version of the firmware (is displayed after)
    no_of_registers         : integer := 186;
    baud_rate_rs232         : real    := 9600.0;
    rs232_seq_timeout_in_us : real    := 10.0E3
    );
  port (
    --trigger signals
    trig1_in  : in  std_logic;          --rst
    trig2_out : out std_logic;
    trig1_out : out std_logic;
    trig2_in  : in  std_logic;

    --clk's
    clk0 : in std_logic;
    clk1 : in std_logic;

    --rf in
    hf1_in : in std_logic;
    hf2_in : in std_logic;

    --uC-Link signals
    uC_Link_D         : out std_logic_vector(7 downto 0);  --dds_data
    uC_Link_A         : out std_logic_vector(7 downto 0);  --dds_addr
    nuC_Link_ACK_R    : in  std_logic;
    nuC_Link_ACK_W    : out std_logic;
    nuC_Link_MRQ_R    : in  std_logic;
    nuC_Link_MRQ_W    : out std_logic;
    nuC_Link_RnW_R    : in  std_logic;
    nuC_Link_RnW_W    : out std_logic;
    nuC_Link_STROBE_R : in  std_logic;
    nuC_Link_STROBE_W : out std_logic;

    --static uC-Link signals
    uC_Link_DIR_D, uC_Link_DIR_A : out std_logic;
    nuC_Link_EN_CTRL_A           : out std_logic;
    uC_Link_EN_DA                : out std_logic;

    --piggy signals
    Piggy_Clk1  : out std_logic;        --dds_clk
    Piggy_RnW1  : out std_logic;        --dds_wr
    Piggy_RnW2  : in  std_logic;        --dds_vout_comp
    Piggy_Strb2 : out std_logic;        --dds_rst
    Piggy_Strb1 : out std_logic;        --dds_update_o
    Piggy_Ack1  : out std_logic;        --dds_fsk
    Piggy_Ack2  : out std_logic;        --dds_sh_key

    --backplane signals
    A2nSW8      : in  std_logic;
    A3nSW9      : in  std_logic;
    A0nSW10     : in  std_logic;
    A1nSW11     : in  std_logic;
    Sub_A0nIW6  : in  std_logic;
    Sub_A1nIW7  : in  std_logic;
    Sub_A2nIW4  : in  std_logic;
    Sub_A3nIW5  : in  std_logic;
    Sub_A4nSW14 : in  std_logic;
    Sub_A5nSW15 : in  std_logic;
    Sub_A6nSW12 : in  std_logic;
    Sub_A7nSW13 : in  std_logic;
    nResetnSW0  : in  std_logic;
    SW1         : in  std_logic;
    nDSnSW2     : in  std_logic;
    BClocknSW3  : in  std_logic;
    RnWnSW4     : in  std_logic;
    SW5         : in  std_logic;
    A4nSW6      : in  std_logic;
    SW7         : in  std_logic;
    NEWDATA     : in  std_logic;
    FC_Str      : in  std_logic;
    FC0         : in  std_logic;
    FC1         : in  std_logic;
    FC2         : in  std_logic;
    FC3         : in  std_logic;
    FC4         : in  std_logic;
    FC5         : in  std_logic;
    VG_A3nFC6   : in  std_logic;
    FC7         : in  std_logic;
    SD          : in  std_logic;
    nDRQ2       : out std_logic;

    VG_SK0nSWF6 : in std_logic;
    VG_SK1nSWF5 : in std_logic;
    VG_SK2nSWF4 : in std_logic;
    VG_SK3nSWF3 : in std_logic;
    VG_SK4nSWF2 : in std_logic;
    VG_SK5nSWF1 : in std_logic;
    VG_SK6nSWF0 : in std_logic;
    VG_SK7      : in std_logic;

    VG_ID0nRes  : in std_logic;
    VG_ID1nIW3  : in std_logic;
    VG_ID2nIW2  : in std_logic;
    VG_ID3nIW1  : in std_logic;
    VG_ID4nIW0  : in std_logic;
    VG_ID5      : in std_logic;
    VG_ID6      : in std_logic;
    VG_ID7nSWF7 : in std_logic;

    D0nIW14 : inout std_logic;
    D1nIW15 : inout std_logic;
    D2nIW12 : inout std_logic;
    D3nIW13 : inout std_logic;
    D4nIW10 : inout std_logic;
    D5nIW11 : inout std_logic;
    D6nIW8  : inout std_logic;
    D7nIW9  : inout std_logic;

    --static backplane-buffer signals
    BBA_DIR : out std_logic;
    BBB_DIR : out std_logic;
    BBC_DIR : out std_logic;
    BBD_DIR : out std_logic;
    BBE_DIR : out std_logic;
    BBG_DIR : out std_logic;
    BBH_DIR : out std_logic;
    nBB_EN  : out std_logic;

    --static backplane open-collector outputs
    DRDY     : out std_logic;
    SRQ3     : out std_logic;
    DRQ      : out std_logic;
    INTERL   : out std_logic;
    DTACK    : out std_logic;
    nDRDY2   : out std_logic;
    SEND_EN  : out std_logic;
    SEND_STR : out std_logic;

    --dsp-link signals (read)
    DSP_CRDY_W : out std_logic;
    DSP_CREQ_W : out std_logic;
    DSP_CACK_R : in  std_logic;
    DSP_CSTR_R : in  std_logic;

    DSP_D_R0 : in std_logic;
    DSP_D_R1 : in std_logic;
    DSP_D_R2 : in std_logic;
    DSP_D_R3 : in std_logic;
    DSP_D_R4 : in std_logic;
    DSP_D_R5 : in std_logic;
    DSP_D_R6 : in std_logic;
    DSP_D_R7 : in std_logic;

    --dsp-link signals (write)          
    DSP_CRDY_R : in  std_logic;
    DSP_CREQ_R : in  std_logic;
    DSP_CACK_W : out std_logic;
    DSP_CSTR_W : out std_logic;

    DSP_D_W0 : out std_logic;
    DSP_D_W1 : out std_logic;
    DSP_D_W2 : out std_logic;
    DSP_D_W3 : out std_logic;
    DSP_D_W4 : out std_logic;
    DSP_D_W5 : out std_logic;
    DSP_D_W6 : out std_logic;
    DSP_D_W7 : out std_logic;

    DSP_DIR_D      : out std_logic;
    DSP_DIR_STRACK : out std_logic;
    DSP_DIR_REQRDY : out std_logic;

    -- leds
    led1 : out std_logic;
    led2 : out std_logic;
    led3 : out std_logic;
    led4 : out std_logic;

    -- only for debug
    piggy_io : out std_logic_vector(7 downto 0);

    --adressing pins via FC
    VG_A4 : in std_logic;               --FC(0)
    VG_A1 : in std_logic;               --FC(1)
    VG_A2 : in std_logic;               --only modulbus 
    VG_A0 : in std_logic;               --only modulbus 

    --rs232
    rs232_rx_i : in  std_logic;
    rs232_tx_o : out std_logic;

    --flash device
    eeprom_data : in  std_logic;
    eeprom_dclk : out std_logic;
    eeprom_ncs  : out std_logic;
    eeprom_asdi : out std_logic;

    --Jumper:
    Testpin_J60 : out std_logic;

    --TCXO
    TCXO1_CNTRL : out std_logic;
    TCXO2_CNTRL : out std_logic;

    --mixed signal port
    nGPIO1_R  : in  std_logic;
    nGPIO1_W  : out std_logic;
    nGPIO2_R  : in  std_logic;
    nGPIO2_W  : out std_logic;
    nI2C_SCL  : out std_logic;
    nI2C_SDA  : out std_logic;
    nSPI_EN   : out std_logic;
    nSPI_MISO : in  std_logic;
    nSPI_MOSI : out std_logic;
    nSPI_SCK  : out std_logic;

    --optical links
    opt1_los : in  std_logic;
    opt1_rx  : in  std_logic;
    opt1_tx  : out std_logic;
    opt2_los : in  std_logic;
    opt2_rx  : in  std_logic;
    opt2_tx  : out std_logic
    );
end entity fib_registerfile_top;

architecture arch_fib_registerfile_top of fib_registerfile_top is

  -- common signals
  signal clk : std_logic;
  signal rst : std_logic;

  -- LED signals
  signal led_id_inf_i : std_logic_vector(3 downto 0);
  signal led_id_inf_o : std_logic_vector(3 downto 0);

  signal nrs232_rx_i            : std_logic;
  signal rs232_rx_data_detected : std_logic;

  signal fub_rs232_rx_data : std_logic_vector(7 downto 0);
  signal fub_rs232_rx_str  : std_logic;
  signal fub_rs232_rx_busy : std_logic;

  signal fub_rs232_rx_conf_data : std_logic_vector(7 downto 0);
  signal fub_rs232_rx_conf_adr  : std_logic_vector(15 downto 0);
  signal fub_rs232_rx_conf_str  : std_logic;
  signal fub_rs232_rx_conf_busy : std_logic;

  signal fub_rs232_tx_data : std_logic_vector(7 downto 0);
  signal fub_rs232_tx_str  : std_logic;
  signal fub_rs232_tx_busy : std_logic;

  signal fub_rs232_tx_conf_data : std_logic_vector(7 downto 0);
  signal fub_rs232_tx_conf_adr  : std_logic_vector(15 downto 0);
  signal fub_rs232_tx_conf_str  : std_logic;
  signal fub_rs232_tx_conf_busy : std_logic;

  signal registerfile_wren_a : std_logic;
  signal registerfile_adr_a  : std_logic_vector (15 downto 0);
  signal registerfile_dat_a  : std_logic_vector (7 downto 0);
  signal registerfile_q_a    : std_logic_vector (7 downto 0);

  signal registerfile     : std_logic_vector (no_of_registers * 8 - 1 downto 0);
  signal eeprom_data_sync : std_logic;

  signal fub_flash_fub_read_busy_o            : std_logic;
  signal fub_flash_fub_read_data_o            : std_logic_vector(7 downto 0);
  signal fub_registerfile_cntrl_fub_fr_str_o  : std_logic;
  signal fub_registerfile_cntrl_fub_fr_adr_o  : std_logic_vector(15 downto 0);
  signal fub_registerfile_cntrl_fub_fw_str_o  : std_logic;
  signal fub_flash_fub_write_busy_o           : std_logic;
  signal fub_registerfile_cntrl_fub_fw_data_o : std_logic_vector(7 downto 0);
  signal fub_registerfile_cntrl_fub_fw_adr_o  : std_logic_vector(15 downto 0);

  signal fub_registerfile_cntrl_fub_fr_adr_o_extended : std_logic_vector(23 downto 0);
  signal fub_registerfile_cntrl_fub_fw_adr_o_extended : std_logic_vector(23 downto 0);


  type registerfile_array_type is array(0 to no_of_registers-1) of std_logic_vector(7 downto 0);
  signal registerfile_array : registerfile_array_type;

  signal eeprom_ncs_intern  : std_logic;
  signal eeprom_asdi_intern : std_logic;
  signal eeprom_dclk_intern : std_logic;


begin

  reset_gen_inst : reset_gen
    generic map(
      reset_clks => 2
      )
    port map (
      clk_i => clk0,
      rst_o => rst
      );

  id_info_inst : id_info
    generic map (
      clk_freq_in_hz     => 50.0E6,
      display_time_in_ms => 1.0,
      firmware_id        => firmware_id,
      firmware_version   => firmware_version,
      led_cnt            => 4
      )
    port map (
      clk_i => clk,
      rst_i => rst,
      led_i => led_id_inf_i,
      led_o => led_id_inf_o
      );


  clk <= clk0;

  --led signal mapping
  led4 <= led_id_inf_o(0);
  led3 <= led_id_inf_o(1);
  led2 <= led_id_inf_o(2);
  led1 <= led_id_inf_o(3);

  led_id_inf_i(0) <= '1';
  led_id_inf_i(1) <= rs232_rx_data_detected;
  led_id_inf_i(2) <= '0';
  led_id_inf_i(3) <= '0';


  --static backplane buffer settings
  BBA_DIR <= '0';
  BBB_DIR <= '0';
  BBC_DIR <= '0';
  BBD_DIR <= '0';
  BBE_DIR <= '0';
  BBG_DIR <= '0';
  BBH_DIR <= '0';
  nBB_EN  <= '1';                       --backplane buffers switched off!

  --static backplane open-collector output settings
  DRDY     <= '0';
  SRQ3     <= '0';
  DRQ      <= '0';
  INTERL   <= '0';
  DTACK    <= '0';
  nDRDY2   <= '0';
  SEND_EN  <= '0';
  SEND_STR <= '0';

  --static uC-Link buffer settings

  uC_Link_DIR_D      <= '1';  --DIR: '1'=from FPGA (A->B side),'0'=to FPGA (B->A side)
  uC_Link_DIR_A      <= '1';  --DIR: '1'=from FPGA (A->B side),'0'=to FPGA (B->A side)
  nuC_Link_EN_CTRL_A <= '1';            --EN: '1'=disabled, '0'=enabled
  uC_Link_EN_DA      <= '0';            --EN: '1'=disabled, '0'=enabled !!

  --static DSP-Link buffer settings
  DSP_D_W0 <= '0';
  DSP_D_W1 <= '0';
  DSP_D_W2 <= '0';
  DSP_D_W3 <= '0';
  DSP_D_W4 <= '0';
  DSP_D_W5 <= '0';
  DSP_D_W6 <= '0';
  DSP_D_W7 <= '0';

  --DSP-Link Direction:
  --DSP_DIR_D='1', DSP_DIR_STRACK='1', DSP_DIR_REQRDY='0' -> Dataflow *to* FPGA
  --DSP_DIR_D='0', DSP_DIR_STRACK='0', DSP_DIR_REQRDY='1' -> Dataflow *from* FPGA
  DSP_DIR_D      <= '1';                --DIR: '1'=to FPGA, '0'=from FPGA
  DSP_DIR_STRACK <= '1';                --DIR: '1'=to FPGA, '0'=from FPGA
  DSP_DIR_REQRDY <= '0';                --DIR: '1'=to FPGA, '0'=from FPGA


  process(clk, rst)
  begin
    if clk = '1' and clk'event then
      nrs232_rx_i      <= not rs232_rx_i;
      eeprom_data_sync <= eeprom_data;
    end if;
  end process;

  rs232_rx_inst : fub_rs232_rx
    generic map (
      clk_freq_in_hz => clk_freq_in_hz,
      baud_rate      => baud_rate_rs232
      )
    port map (
      clk_i      => clk,
      rst_i      => rst,
      rs232_rx_i => nrs232_rx_i,
      fub_str_o  => fub_rs232_rx_str,
      fub_busy_i => fub_rs232_rx_busy,
      fub_data_o => fub_rs232_rx_data
      );

  fub_seq_demux_inst : fub_seq_demux
    generic map (
      fub_address_width => 16,
      fub_data_width    => 8,
      clk_freq_in_hz    => clk_freq_in_hz,
      timeout_in_us     => rs232_seq_timeout_in_us
      )
    port map (
      clk_i          => clk,
      rst_i          => rst,
      fub_strb_o     => fub_rs232_rx_conf_str,
      fub_data_o     => fub_rs232_rx_conf_data,
      fub_addr_o     => fub_rs232_rx_conf_adr,
      fub_busy_i     => fub_rs232_rx_conf_busy,
      seq_busy_o     => fub_rs232_rx_busy,
      seq_data_i     => fub_rs232_rx_data,
      seq_strb_i     => fub_rs232_rx_str,
      crc_mismatch_o => open
      );

  fub_registerfile_cntrl_inst : fub_registerfile_cntrl
    generic map(
      adr_width              => 16,
      data_width             => 8,
      default_start_adr      => 16#0000#,
      default_end_adr        => no_of_registers,
      reg_adr_cmd            => 16#fff0#,
      reg_adr_start_adr_high => 16#fff1#,
      reg_adr_start_adr_low  => 16#fff2#,
      reg_adr_end_adr_high   => 16#fff3#,
      reg_adr_end_adr_low    => 16#fff4#
      )
    port map (
      rst_i                  => rst,
      clk_i                  => clk,
      fub_cfg_reg_in_dat_i   => fub_rs232_rx_conf_data,
      fub_cfg_reg_in_adr_i   => fub_rs232_rx_conf_adr,
      fub_cfg_reg_in_str_i   => fub_rs232_rx_conf_str,
      fub_cfg_reg_in_busy_o  => fub_rs232_rx_conf_busy,
      fub_cfg_reg_out_str_o  => fub_rs232_tx_conf_str,
      fub_cfg_reg_out_dat_o  => fub_rs232_tx_conf_data,
      fub_cfg_reg_out_adr_o  => fub_rs232_tx_conf_adr,
      fub_cfg_reg_out_busy_i => fub_rs232_tx_conf_busy,
      fub_fr_busy_i          => fub_flash_fub_read_busy_o,
      fub_fr_dat_i           => fub_flash_fub_read_data_o,
      fub_fr_str_o           => fub_registerfile_cntrl_fub_fr_str_o,
      fub_fr_adr_o           => fub_registerfile_cntrl_fub_fr_adr_o,
      fub_fw_str_o           => fub_registerfile_cntrl_fub_fw_str_o,
      fub_fw_busy_i          => fub_flash_fub_write_busy_o,
      fub_fw_dat_o           => fub_registerfile_cntrl_fub_fw_data_o,
      fub_fw_adr_o           => fub_registerfile_cntrl_fub_fw_adr_o,
      fub_out_data_o         => open,
      fub_out_adr_o          => open,
      fub_out_str_o          => open,
      fub_out_busy_i         => '0',
      ram_wren_o             => registerfile_wren_a,
      ram_adr_o              => registerfile_adr_a,
      ram_dat_o              => registerfile_dat_a,
      ram_q_i                => registerfile_q_a
      );

  fub_registerfile_cntrl_fub_fr_adr_o_extended <= ("00000000" & fub_registerfile_cntrl_fub_fr_adr_o);
  fub_registerfile_cntrl_fub_fw_adr_o_extended <= ("00000000" & fub_registerfile_cntrl_fub_fw_adr_o);

  fub_flash_inst : fub_flash
    generic map(
      main_clk                   => clk_freq_in_hz,
      priority_on_reading        => '1',
      my_delay_in_ns_for_reading => 25.0,  -- equal to 40 MHz // 25ns high 25ns low => 50ns equal to 20MHz CLK Signal
      my_delay_in_ns_for_writing => 20.0,  -- equal to 50 MHz // 20ns high 20ns low => 40ns equal to 25MHz CLK Signal
      erase_in_front_of_write    => '1'
      )                                                                 
    port map(
      clk_i            => clk,
      rst_i            => rst,
      fub_write_busy_o => fub_flash_fub_write_busy_o,
      fub_write_data_i => fub_registerfile_cntrl_fub_fw_data_o,
      fub_write_adr_i  => fub_registerfile_cntrl_fub_fw_adr_o_extended,
      fub_write_str_i  => fub_registerfile_cntrl_fub_fw_str_o,
      fub_read_busy_o  => fub_flash_fub_read_busy_o,
      fub_read_data_o  => fub_flash_fub_read_data_o,
      fub_read_adr_i   => fub_registerfile_cntrl_fub_fr_adr_o_extended,
      fub_read_str_i   => fub_registerfile_cntrl_fub_fr_str_o,
      erase_str_i      => '0',
      erase_adr_i      => (others => '0'),
      nCS_o            => eeprom_ncs_intern,
      asdi_o           => eeprom_asdi_intern,
      dclk_o           => eeprom_dclk_intern,
      data_i           => eeprom_data_sync
      );

  registerfile_ram_interface_inst : registerfile_ram_interface
    generic map (
      adr_width          => 16,
      data_width         => 8,
      no_of_registers    => no_of_registers
      )
    port map(
      rst_i      => rst,
      clk_i      => clk,
      wren_a     => registerfile_wren_a,
      adr_a      => registerfile_adr_a,
      dat_a      => registerfile_dat_a,
      q_a        => registerfile_q_a,
      register_o => registerfile,
      register_i => registerfile        --read back the same registers
      );

  
  registerfile_array_to_parallel_gen : for i in 0 to no_of_registers-1 generate
    registerfile_array(i) <= registerfile((i+1)*8-1 downto i*8);
  end generate;

  fub_seq_mux_inst : fub_seq_mux
    generic map (
      fub_address_width => 16,
      fub_data_width    => 8,
      clk_freq_in_hz    => clk_freq_in_hz,
      timeout_in_us     => rs232_seq_timeout_in_us
      )
    port map (
      clk_i      => clk,
      rst_i      => rst,
      fub_strb_i => fub_rs232_tx_conf_str,
      fub_data_i => fub_rs232_tx_conf_data,
      fub_addr_i => fub_rs232_tx_conf_adr,
      fub_busy_o => fub_rs232_tx_conf_busy,
      seq_busy_i => fub_rs232_tx_busy,
      seq_data_o => fub_rs232_tx_data,
      seq_strb_o => fub_rs232_tx_str
      );

  fub_rs232_tx_inst : fub_rs232_tx
    generic map (
      clk_freq_in_hz => clk_freq_in_hz,
      baud_rate      => baud_rate_rs232
      )
    port map (
      clk_i      => clk,
      rst_i      => rst,
      rs232_tx_o => rs232_tx_o,
      fub_str_i  => fub_rs232_tx_str,
      fub_busy_o => fub_rs232_tx_busy,
      fub_data_i => fub_rs232_tx_data
      );

  -- detection of rs232
  rs232_clk_detector_inst : clk_detector
    generic map (
      clk_freq_in_hz       => clk_freq_in_hz,
      output_on_time_in_ms => 50.0
      )
    port map (
      clk_i => clk,
      rst_i => rst,
      x_i   => rs232_rx_i,
      x_o   => rs232_rx_data_detected
      );

  eeprom_ncs  <= eeprom_ncs_intern;
  eeprom_asdi <= eeprom_asdi_intern;
  eeprom_dclk <= eeprom_dclk_intern;


--piggy_io(1)                   <= eeprom_ncs_intern;
--piggy_io(3)                   <= eeprom_asdi_intern;
--piggy_io(5)                   <= eeprom_dclk_intern;
--piggy_io(7)                   <= eeprom_data_sync;

  piggy_io <= registerfile_array(0);
--  uC_Link_D      <= registerfile_array(1);
--  uC_Link_A      <= registerfile_array(2);
  
  
end architecture arch_fib_registerfile_top;
