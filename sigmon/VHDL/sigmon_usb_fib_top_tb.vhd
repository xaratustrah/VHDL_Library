library ieee;
use ieee.std_logic_1164.all;
--use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.math_real.all;
use ieee.numeric_std.all;

use work.real_time_calculator_pkg.all;
use work.fub_rs232_tx_pkg.all;
use work.dds_synthesizer_pkg.all;
use work.clk_divider_pkg.all;

entity sigmon_usb_fib_top_tb is
  generic (
    clk_freq_in_hz     : real    := 100.0E6;  --50 MHz system clock frequency
    fib_clk_freq_in_hz : real    := 50.0E6;   --100 MHz system clock frequency
    rst_clks           : integer := 2;
    sig_data_increment : integer := 64;
    baud_rate          : real    := 10.0E6    --higher speed for simulation
    );
end entity;

architecture sigmon_usb_fib_top_tb_arch of sigmon_usb_fib_top_tb is

  component sigmon_usb_fib_top
    generic(
      clk_freq_in_hz     : real;
      sig_data_increment : integer;
      data_width         : integer;
      led_on_time_in_ms  : real
      );
    port (
      --trigger signals
      trig1_in  : in  std_logic;        --rst
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
      Piggy_Clk1  : out std_logic;      --dds_clk
      Piggy_RnW1  : out std_logic;      --dds_wr
      Piggy_RnW2  : in  std_logic;      --dds_vout_comp
      Piggy_Strb2 : out std_logic;      --dds_rst
      Piggy_Strb1 : out std_logic;      --dds_update_o
      Piggy_Ack1  : out std_logic;      --dds_fsk
      Piggy_Ack2  : out std_logic;      --dds_sh_key

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
      VG_A4 : in std_logic;             --FC(0)
      VG_A1 : in std_logic;             --FC(1)
      VG_A2 : in std_logic;             --only modulbus 
      VG_A0 : in std_logic;             --only modulbus 

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
  end component;

  component ft245bm_sim_model
    generic(
      wait_clks : integer := 0
      );
    port(
      rst_i  : in    std_logic;
      clk_i  : in    std_logic;
      d_io   : inout std_logic_vector (7 downto 0);
      nrd_i  : in    std_logic;
      wr_i   : in    std_logic;
      nrxf_o : out   std_logic;
      ntxe_o : out   std_logic
      );
  end component;

  component fab_adcdac_slave_top
    generic (
      vga_default_gain      : std_logic_vector (3 downto 0);
      spi_clk_perid_in_ns   : real;
      spi_setup_delay_in_ns : real;
      default_io_data       : std_logic_vector(15 downto 0);
      default_setup_data    : std_logic_vector (64-1 downto 0);
      reset_clks            : integer;
      clk_freq_in_hz        : real;
      clk_divider_width     : integer);
    port (
      piggy_clk_i  : in    std_logic;
      spi_sclk     : out   std_logic;
      spi_mosi     : out   std_logic;
      spi_miso     : in    std_logic;
      ncs_expander : out   std_logic;
      ncs_vga1     : out   std_logic;
      ncs_vga2     : out   std_logic;
      adc1d        : in    std_logic_vector (13 downto 0);
      adc2d        : in    std_logic_vector (13 downto 0);
      dac1d        : out   std_logic_vector (13 downto 0);
      dac2d        : out   std_logic_vector (13 downto 0);
      adc1clk      : out   std_logic;
      adc2clk      : out   std_logic;
      dac1clk      : out   std_logic;
      dac2clk      : out   std_logic;
      dat_alpha_i  : inout std_logic_vector (7 downto 0);
      adr_alpha_i  : in    std_logic_vector (4 downto 0);
      busy_alpha_o : in    std_logic;
      str_alpha_i  : in    std_logic;
      dat_beta_o   : inout std_logic_vector (7 downto 0);
      adr_beta_o   : in    std_logic_vector (4 downto 0);
      busy_beta_i  : in    std_logic;
      str_beta_o   : in    std_logic);
  end component;

  signal clk, clk0, rst : std_logic                     := '0';
  signal data_bus       : std_logic_vector(15 downto 0) := (others => '0');
  signal rs232_rx       : std_logic;
  signal nrs232_rx      : std_logic;


  signal ftdi_d    : std_logic_vector (7 downto 0);
  signal ftdi_nrd  : std_logic;
  signal ftdi_wr   : std_logic;
  signal ftdi_nrxf : std_logic;
  signal ftdi_ntxe : std_logic;

    signal uC_Link_D                    : std_logic_vector(7 downto 0);
  signal uC_Link_A                    : std_logic_vector(7 downto 0);
  signal Piggy_Clk1                   : std_logic;
  signal Piggy_RnW1                   : std_logic;
  signal Piggy_RnW2                   : std_logic;
  signal Piggy_Strb2                  : std_logic;
  signal Piggy_Strb1                  : std_logic;
  signal Piggy_Ack1                   : std_logic;
  signal Piggy_Ack2                   : std_logic;

  signal DSP_CRDY_R : std_logic;
  signal DSP_CREQ_R : std_logic;
  signal DSP_CACK_W : std_logic;
  signal DSP_CSTR_W : std_logic;

  signal DSP_D_W0 : std_logic;
  signal DSP_D_W1 : std_logic;
  signal DSP_D_W2 : std_logic;
  signal DSP_D_W3 : std_logic;
  signal DSP_D_W4 : std_logic;
  signal DSP_D_W5 : std_logic;
  signal DSP_D_W6 : std_logic;
  signal DSP_D_W7 : std_logic;

  signal DSP_D_R0 : std_logic;
  signal DSP_D_R1 : std_logic;
  signal DSP_D_R2 : std_logic;
  signal DSP_D_R3 : std_logic;
  signal DSP_D_R4 : std_logic;
  signal DSP_D_R5 : std_logic;
  signal DSP_D_R6 : std_logic;
  signal DSP_D_R7 : std_logic;

  constant vga_default_gain      : std_logic_vector (3 downto 0)    := "0001";
  constant spi_clk_perid_in_ns   : real                             := 1000.0;
  constant spi_setup_delay_in_ns : real                             := 1000.0;
  constant default_io_data       : std_logic_vector(15 downto 0)    := x"1100";
  constant default_setup_data    : std_logic_vector (64-1 downto 0) := x"0A200B20000001C3";
  constant reset_clks            : integer                          := 20;
--  constant clk_freq_in_hz        : real                             := 100.0E6;
  constant clk_divider_width     : integer                          := 8;

  signal piggy_clk_i  : std_logic;
  signal spi_sclk     : std_logic;
  signal spi_mosi     : std_logic;
  signal spi_miso     : std_logic;
  signal ncs_expander : std_logic;
  signal ncs_vga1     : std_logic;
  signal ncs_vga2     : std_logic;
  signal adc1d        : std_logic_vector (13 downto 0);
  signal adc2d        : std_logic_vector (13 downto 0);
  signal dac1d        : std_logic_vector (13 downto 0);
  signal dac2d        : std_logic_vector (13 downto 0);
  signal adc1clk      : std_logic;
  signal adc2clk      : std_logic;
  signal dac1clk      : std_logic;
  signal dac2clk      : std_logic;
  signal dat_alpha_i  : std_logic_vector (7 downto 0);
  signal adr_alpha_i  : std_logic_vector (4 downto 0);
  signal busy_alpha_o : std_logic;
  signal str_alpha_i  : std_logic;
  signal dat_beta_o   : std_logic_vector (7 downto 0);
  signal adr_beta_o   : std_logic_vector (4 downto 0);
  signal busy_beta_i  : std_logic;
  signal str_beta_o   : std_logic;

  signal dds1_data : std_logic_vector (13 downto 0);
  signal dds2_data : std_logic_vector (13 downto 0);

  signal dds_phase : std_logic_vector (13 downto 0);
  signal ftw       : std_logic_vector (13 downto 0);
  signal dds_rst   : std_logic;
  signal sim_rst   : std_logic;
  signal dds_clk   : std_logic;

begin
  
  sigmon_usb_fib_top_inst : sigmon_usb_fib_top
    generic map (
      clk_freq_in_hz     => clk_freq_in_hz,
      sig_data_increment => sig_data_increment,
      data_width         => 16,
      led_on_time_in_ms  => 0.001       --1us
      )
    port map (
      --common signals
      trig1_in  => '1',
      trig1_out => open,
      trig2_in  => '0',
      trig2_out => open,

      clk0 => clk,
      clk1 => '0',

      hf1_in => '0',
      hf2_in => '0',

      --uC-Link signals
      uC_Link_D => uC_Link_D,
      uC_Link_A => uC_Link_A,

      nuC_Link_ACK_R    => '0',
      nuC_Link_ACK_W    => open,
      nuC_Link_MRQ_R    => '0',
      nuC_Link_MRQ_W    => open,
      nuC_Link_RnW_R    => '0',
      nuC_Link_RnW_W    => open,
      nuC_Link_STROBE_R => '0',
      nuC_Link_STROBE_W => open,

      --piggy signals
      Piggy_Clk1  => Piggy_Clk1,         --dds_clk
      Piggy_RnW1  => Piggy_RnW1,         --dds_wr
      Piggy_RnW2  => Piggy_RnW2,         --dds_vout_comp
      Piggy_Strb2 => Piggy_Strb2,         --dds_rst
      Piggy_Strb1 => Piggy_Strb1,        --dds_update_o
      Piggy_Ack1  => Piggy_Ack1,         --dds_fsk
      Piggy_Ack2  => Piggy_Ack2,         --dds_sh_key

      --static dds-buffer signals
      uC_Link_DIR_D      => open,
      uC_Link_DIR_A      => open,
      nuC_Link_EN_CTRL_A => open,
      uC_Link_EN_DA      => open,

      --backplane signals
      A2nSW8      => '0',
      A3nSW9      => '0',
      A0nSW10     => '0',
      A1nSW11     => '0',
      Sub_A0nIW6  => '0',
      Sub_A1nIW7  => '0',
      Sub_A2nIW4  => '0',
      Sub_A3nIW5  => '0',
      Sub_A6nSW12 => '0',
      Sub_A7nSW13 => '0',
      Sub_A4nSW14 => '0',
      Sub_A5nSW15 => '0',
      nResetnSW0  => '0',
      SW1         => '0',
      nDSnSW2     => '0',
      BClocknSW3  => '0',
      RnWnSW4     => '0',
      SW5         => '0',
      A4nSW6      => '0',
      SW7         => '0',
      NEWDATA     => '0',
      FC_Str      => '0',
      FC0         => '0',
      FC1         => '0',
      FC2         => '0',
      FC3         => '0',
      FC4         => '0',
      FC5         => '0',
      VG_A3nFC6   => '0',
      FC7         => '0',
      SD          => '0',
      nDRQ2       => open,
      VG_SK0nSWF6 => '0',
      VG_SK1nSWF5 => '0',
      VG_SK2nSWF4 => '0',
      VG_SK3nSWF3 => '0',
      VG_SK4nSWF2 => '0',
      VG_SK5nSWF1 => '0',
      VG_SK6nSWF0 => '0',
      VG_SK7      => '0',
      VG_ID0nRes  => '0',
      VG_ID1nIW3  => '0',
      VG_ID2nIW2  => '0',
      VG_ID3nIW1  => '0',
      VG_ID4nIW0  => '0',
      VG_ID5      => '0',
      VG_ID6      => '0',
      VG_ID7nSWF7 => '0',
      VG_A0       => '0',
      VG_A2       => '0',


      --static backplane-buffer signals
      BBA_DIR => open,
      BBB_DIR => open,
      BBC_DIR => open,
      BBD_DIR => open,
      BBE_DIR => open,
      BBG_DIR => open,
      BBH_DIR => open,
      nBB_EN  => open,

      --static backplane open-collector outputs
      DRDY     => open,
      SRQ3     => open,
      DRQ      => open,
      INTERL   => open,
      DTACK    => open,
      nDRDY2   => open,
      SEND_EN  => open,
      SEND_STR => open,

      --dsp-link signals (read)
      DSP_CRDY_W => open,
      DSP_CREQ_W => open,
      DSP_CACK_R => '0',
      DSP_CSTR_R => '0',

      DSP_D_R0 => DSP_D_R0,
      DSP_D_R1 => DSP_D_R1,
      DSP_D_R2 => DSP_D_R2,
      DSP_D_R3 => DSP_D_R3,
      DSP_D_R4 => DSP_D_R4,
      DSP_D_R5 => DSP_D_R5,
      DSP_D_R6 => DSP_D_R6,
      DSP_D_R7 => DSP_D_R7,

      --dsp-link signals (write)                
      DSP_CRDY_R => DSP_CRDY_R,
      DSP_CREQ_R => DSP_CREQ_R,
      DSP_CACK_W => DSP_CACK_W,
      DSP_CSTR_W => DSP_CSTR_W,

      DSP_D_W0 => DSP_D_W0,
      DSP_D_W1 => DSP_D_W1,
      DSP_D_W2 => DSP_D_W2,
      DSP_D_W3 => DSP_D_W3,
      DSP_D_W4 => DSP_D_W4,
      DSP_D_W5 => DSP_D_W5,
      DSP_D_W6 => DSP_D_W6,
      DSP_D_W7 => DSP_D_W7,

      -- leds
      led1 => open,
      led2 => open,
      led3 => open,
      led4 => open,

      -- only for debug
      piggy_io => open,

      --adressing pins via FC
      VG_A4 => '0',                     --FC(0)
      VG_A1 => '0',                     --FC(1)

      --rs232
      rs232_rx_i => '0',
      rs232_tx_o => open,

      eeprom_data => '0',
      eeprom_dclk => open,
      eeprom_ncs  => open,
      eeprom_asdi => open,

      Testpin_J60 => open,

      --TCXO
      TCXO1_CNTRL => open,
      TCXO2_CNTRL => open,

      --mixed signal port
      nGPIO1_R  => '0',
      nGPIO1_W  => open,
      nGPIO2_R  => '0',
      nGPIO2_W  => open,
      nI2C_SCL  => open,
      nI2C_SDA  => open,
      nSPI_EN   => open,
      nSPI_MISO => '0',
      nSPI_MOSI => open,
      nSPI_SCK  => open,

      --optical links
      opt1_los => '0',
      opt1_rx  => '0',
      opt1_tx  => open,
      opt2_los => '0',
      opt2_rx  => '0',
      opt2_tx  => open

      );

  fab_adcdac_slave_top_1 : fab_adcdac_slave_top
    generic map (
      vga_default_gain      => vga_default_gain,
      spi_clk_perid_in_ns   => spi_clk_perid_in_ns,
      spi_setup_delay_in_ns => spi_setup_delay_in_ns,
      default_io_data       => default_io_data,
      default_setup_data    => default_setup_data,
      reset_clks            => reset_clks,
      clk_freq_in_hz        => clk_freq_in_hz,
      clk_divider_width     => clk_divider_width)
    port map (
      piggy_clk_i  => piggy_clk_i,
      spi_sclk     => spi_sclk,
      spi_mosi     => spi_mosi,
      spi_miso     => spi_miso,
      ncs_expander => ncs_expander,
      ncs_vga1     => ncs_vga1,
      ncs_vga2     => ncs_vga2,
      adc1d        => adc1d,
      adc2d        => adc2d,
      dac1d        => dac1d,
      dac2d        => dac2d,
      adc1clk      => adc1clk,
      adc2clk      => adc2clk,
      dac1clk      => dac1clk,
      dac2clk      => dac2clk,
      dat_alpha_i  => dat_alpha_i,
      adr_alpha_i  => adr_alpha_i,
      busy_alpha_o => busy_alpha_o,
      str_alpha_i  => str_alpha_i,
      dat_beta_o   => dat_beta_o,
      adr_beta_o   => adr_beta_o,
      busy_beta_i  => busy_beta_i,
      str_beta_o   => str_beta_o);

  ft245bm_sim_inst : ft245bm_sim_model
    port map (
      rst_i  => rst,
      clk_i  => clk,
      d_io   => ftdi_d,
      nrd_i  => ftdi_nrd,
      wr_i   => ftdi_wr,
      nrxf_o => ftdi_nrxf,
      ntxe_o => ftdi_ntxe
      );

  ftdi_d(0) <= not DSP_D_W0 when ftdi_nrd = '1' else 'Z';
  ftdi_d(1) <= not DSP_D_W1 when ftdi_nrd = '1' else 'Z';
  ftdi_d(2) <= not DSP_D_W2 when ftdi_nrd = '1' else 'Z';
  ftdi_d(3) <= not DSP_D_W3 when ftdi_nrd = '1' else 'Z';
  ftdi_d(4) <= not DSP_D_W4 when ftdi_nrd = '1' else 'Z';
  ftdi_d(5) <= not DSP_D_W5 when ftdi_nrd = '1' else 'Z';
  ftdi_d(6) <= not DSP_D_W6 when ftdi_nrd = '1' else 'Z';
  ftdi_d(7) <= not DSP_D_W7 when ftdi_nrd = '1' else 'Z';

  DSP_D_R0 <= not ftdi_d(0);
  DSP_D_R1 <= not ftdi_d(1);
  DSP_D_R2 <= not ftdi_d(2);
  DSP_D_R3 <= not ftdi_d(3);
  DSP_D_R4 <= not ftdi_d(4);
  DSP_D_R5 <= not ftdi_d(5);
  DSP_D_R6 <= not ftdi_d(6);
  DSP_D_R7 <= not ftdi_d(7);

  ftdi_wr  <= not DSP_CSTR_W;
  ftdi_nrd <= not DSP_CACK_W;

  DSP_CRDY_R <= not ftdi_nrxf;
  DSP_CREQ_R <= not ftdi_ntxe;

  clk  <= not clk  after 0.5 * freq_real_to_period_time(clk_freq_in_hz);
  clk0 <= not clk0 after 0.5 * freq_real_to_period_time(fib_clk_freq_in_hz);

  rst   <= '1', '0' after 50 ns;
  -- simulated signals
  adc1d <= std_logic_vector(shift_right(signed(dds1_data), 1));
  adc2d <= std_logic_vector(shift_right(signed(dds2_data), 1));
  ftw   <= std_logic_vector (to_signed(200, 14));

  dds_synthesizer_1 : dds_synthesizer
    generic map (
      ftw_width => 14)
    port map (
      clk_i   => dds_clk,
      rst_i   => dds_rst,
      ftw_i   => ftw,
      phase_i => (others => '0'),
      phase_o => dds_phase,
      ampl_o  => dds1_data);

  dds_synthesizer_2 : dds_synthesizer
    generic map (
      ftw_width => 14)
    port map (
      clk_i   => dds_clk,
      rst_i   => dds_rst,
      ftw_i   => ftw,
      phase_i => "01000000000000",
      phase_o => open,
      ampl_o  => dds2_data);

  divider1 : clk_divider
    generic map (
      clk_divider_width => 2)
    port map (
      clk_div_i => "11",
      rst_i     => rst,
      clk_i     => Piggy_Clk1,
      clk_o     => dds_clk);

  dds_rst <= not Piggy_Ack2;
--  clk0    <= simclk;

  
end architecture sigmon_usb_fib_top_tb_arch;
