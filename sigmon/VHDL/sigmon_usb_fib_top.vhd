library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

use work.clk_detector_pkg.all;
use work.fub_ftdi_usb_pkg.all;
use work.sigmon_ctrl_pkg.all;
use work.reset_gen_pkg.all;


entity sigmon_usb_fib_top is
  generic(
    clk_freq_in_hz       : real    := 100.0E6;
    sig_data_increment   : integer := 64;  --this increment is added each clk cycle to the dummy data
    data_width           : integer := 16;  --data width of monitor signal
    led_on_time_in_ms    : real    := 25.0;
    enable_sigmon_output : boolean := true  -- turn off/on the SIGMON
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
    uC_Link_D         : in  std_logic_vector(7 downto 0);  --dds_data
    uC_Link_A         : in  std_logic_vector(7 downto 0);  --dds_addr
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
    Piggy_RnW2  : out std_logic;        --dds_vout_comp
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
end entity sigmon_usb_fib_top;

architecture sigmon_usb_fib_top_arch of sigmon_usb_fib_top is

  ------------------ component declaration ----------------------

  component fifo_16bit is
    port
      (
        clock : in  std_logic;
        data  : in  std_logic_vector (data_width-1 downto 0);
        rdreq : in  std_logic;
        sclr  : in  std_logic;
        wrreq : in  std_logic;
        empty : out std_logic;
        full  : out std_logic;
        q     : out std_logic_vector (data_width-1 downto 0)
        );
  end component;

  component pll0
    port
      (
        inclk0 : in  std_logic := '0';
        c0     : out std_logic;
        c1     : out std_logic;
        locked : out std_logic
        );
  end component;

  ------------------ signal declaration ----------------------

  signal clk, clk100, clk200 : std_logic;
  signal rst                 : std_logic;
  signal power_on_reset      : std_logic;

--   signal fifo_data_in  : std_logic_vector(data_width-1 downto 0);
--   signal fifo_data_out : std_logic_vector(data_width-1 downto 0);
--   signal fifo_rdreq    : std_logic;
--   signal fifo_wrreq    : std_logic;
--   signal fifo_empty    : std_logic;
--   signal fifo_full     : std_logic;

--   signal fub_tx_str  : std_logic;
--   signal fub_tx_busy : std_logic;
--   signal fub_tx_data : std_logic_vector(7 downto 0);

--   signal fub_rx_str  : std_logic;
--   signal fub_rx_busy : std_logic;
--   signal fub_rx_data : std_logic_vector(7 downto 0);

  signal sig_data : std_logic_vector(data_width-1 downto 0);

  signal data_bus : std_logic_vector (15 downto 0);  -- FAB Data bus mapped to uCLinuk Address and Databus

  signal adr_o          : std_logic_vector (5 downto 0);  -- Address bus for FAB
  signal ext_driver_dir : std_logic;

  signal rnw_o    : std_logic;
  signal strobe_o : std_logic;

  --FTDI signals
--   signal ftdi_d    : std_logic_vector (7 downto 0);
--   signal ftdi_nrd  : std_logic;
--   signal ftdi_wr   : std_logic;
--   signal ftdi_nrxf : std_logic;
--   signal ftdi_ntxe : std_logic;

--   signal ftdi_nrxf_synced : std_logic;
--   signal ftdi_ntxe_synced : std_logic;

  signal data_from_adc : std_logic_vector (15 downto 0);
  
begin
  ------------------ component instantiation ----------------------

  reset_gen_inst : reset_gen
    generic map(
      reset_clks => 2
      )
    port map (
      clk_i => clk0,
      rst_o => power_on_reset
      );

  pll0_ins : pll0
    port map (
      inclk0 => clk0,
      c0     => clk200,
      c1     => clk100,
      locked => open
      );

--   fifo_inst : fifo_16bit
--     port map (
--       clock => clk,
--       data  => fifo_data_in,
--       rdreq => fifo_rdreq,
--       sclr  => rst,
--       wrreq => fifo_wrreq,
--       empty => fifo_empty,
--       full  => fifo_full,
--       q     => fifo_data_out
--       );

--   fub_ftdi_usb_inst : fub_ftdi_usb
--     generic map (
--       clk_freq_in_hz => clk_freq_in_hz
--       )
--     port map (
--       clk_i          => clk,
--       rst_i          => rst,
--       fub_in_str_i   => fub_tx_str,
--       fub_in_busy_o  => fub_tx_busy,
--       fub_in_data_i  => fub_tx_data,
--       fub_out_str_o  => fub_rx_str,
--       fub_out_busy_i => fub_rx_busy,
--       fub_out_data_o => fub_rx_data,
--       ftdi_d_io      => ftdi_d,
--       ftdi_nrd_o     => ftdi_nrd,
--       ftdi_wr_o      => ftdi_wr,
--       ftdi_nrxf_i    => ftdi_nrxf_synced,
--       ftdi_ntxe_i    => ftdi_ntxe_synced
--       );

--   sigmon_ctrl_inst : sigmon_ctrl
--     generic map(
--       data_width          => data_width,
--       fifo_size           => 4096,
--       external_trigger_en => false,
--       magic_number        => 1442775210  -- (=55ff00aa) magic number as header indentifier 
--       )         
--     port map(
--       clk_i          => clk,
--       rst_i          => rst,
--       --data interface
--       data_i         => sig_data,
--       data_trigger_i => '0',
--       --fifo interface
--       fifo_d_o       => fifo_data_in,
--       fifo_rdreq_o   => fifo_rdreq,
--       fifo_wrreq_o   => fifo_wrreq,
--       fifo_empty_i   => fifo_empty,
--       fifo_full_i    => fifo_full,
--       fifo_d_i       => fifo_data_out,
--       --fub out
--       fub_tx_str_o   => fub_tx_str,
--       fub_tx_busy_i  => fub_tx_busy,
--       fub_tx_data_o  => fub_tx_data,
--       --fub in
--       fub_rx_str_i   => fub_rx_str,
--       fub_rx_busy_o  => fub_rx_busy,
--       fub_rx_data_i  => fub_rx_data,
--       test_o         => led1
--       );



--   fub_rx_str_inst : clk_detector
--     generic map(
--       clk_freq_in_hz       => clk_freq_in_hz,
--       output_on_time_in_ms => led_on_time_in_ms
--       )
--     port map(
--       clk_i => clk,
--       rst_i => rst,
--       x_i   => fub_rx_str,
--       x_o   => led4
--       );

--   fub_tx_str_inst : clk_detector
--     generic map(
--       clk_freq_in_hz       => clk_freq_in_hz,
--       output_on_time_in_ms => led_on_time_in_ms
--       )
--     port map(
--       clk_i => clk,
--       rst_i => rst,
--       x_i   => fub_tx_str,
--       x_o   => led3
--       );

  ------------------ static signal settings ----------------------

--      clk <= clk0;
  clk <= clk100;

--  led1<='1';
  led2 <= rst;
--  led4<='1';

  rst <= (not trig1_in) or power_on_reset;

  --static backplane buffer settings
  BBA_DIR <= '0';
  BBB_DIR <= '0';
  BBC_DIR <= '0';
  BBD_DIR <= '0';
  BBE_DIR <= '0';
  BBG_DIR <= '0';
  BBH_DIR <= '0';
  nBB_EN  <= '0';

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
  uC_Link_DIR_D      <= '0';  --DIR: '1'=from FPGA (A->B side),'0'=to FPGA (B->A side)
  uC_Link_DIR_A      <= '0';  --DIR: '1'=from FPGA (A->B side),'0'=to FPGA (B->A side)
  nuC_Link_EN_CTRL_A <= '1';            --EN: '1'=disabled, '0'=enabled
  uC_Link_EN_DA      <= '0';            --EN: '1'=disabled, '0'=enabled !!

--   --DSP-Link Direction:
--   DSP_DIR_D      <= not ftdi_nrd;       --DIR: '1'=to FPGA, '0'=from FPGA
--   DSP_DIR_STRACK <= '0';                --DIR: '1'=to FPGA, '0'=from FPGA
--   DSP_DIR_REQRDY <= '1';                --DIR: '1'=to FPGA, '0'=from FPGA
--   --FTDI signal mapping
--   ftdi_d(0)      <= not DSP_D_R0 when ftdi_nrd = '0' else 'Z';
--   ftdi_d(1)      <= not DSP_D_R1 when ftdi_nrd = '0' else 'Z';
--   ftdi_d(2)      <= not DSP_D_R2 when ftdi_nrd = '0' else 'Z';
--   ftdi_d(3)      <= not DSP_D_R3 when ftdi_nrd = '0' else 'Z';
--   ftdi_d(4)      <= not DSP_D_R4 when ftdi_nrd = '0' else 'Z';
--   ftdi_d(5)      <= not DSP_D_R5 when ftdi_nrd = '0' else 'Z';
--   ftdi_d(6)      <= not DSP_D_R6 when ftdi_nrd = '0' else 'Z';
--   ftdi_d(7)      <= not DSP_D_R7 when ftdi_nrd = '0' else 'Z';
--   DSP_D_W0       <= not ftdi_d(0);
--   DSP_D_W1       <= not ftdi_d(1);
--   DSP_D_W2       <= not ftdi_d(2);
--   DSP_D_W3       <= not ftdi_d(3);
--   DSP_D_W4       <= not ftdi_d(4);
--   DSP_D_W5       <= not ftdi_d(5);
--   DSP_D_W6       <= not ftdi_d(6);
--   DSP_D_W7       <= not ftdi_d(7);
--   DSP_CSTR_W     <= not ftdi_wr;
--   DSP_CACK_W     <= not ftdi_nrd;
--   ftdi_nrxf      <= not DSP_CRDY_R;
--   ftdi_ntxe      <= not DSP_CREQ_R;

--   p_dsplink : process(clk)
--   begin
--     if clk = '1' and clk'event then
--       ftdi_nrxf_synced <= ftdi_nrxf;
--       ftdi_ntxe_synced <= ftdi_ntxe;
--     end if;
--   end process p_dsplink;

  process(clk, rst)
  begin
    if rst = '1' then
      sig_data <= (others => '0');

    elsif clk = '1' and clk'event then
      sig_data <= conv_std_logic_vector(conv_integer(sig_data) + sig_data_increment, data_width);
    end if;
  end process;


-- fab signals

  Piggy_Clk1            <= clk200;
  piggy_io (7 downto 4) <= "0011";      -- alpha Address of the ADC2-HB
  piggy_io (3 downto 0) <= "0010";      -- beta Address of the ADC2-LB
  Piggy_RnW1            <= '1';         -- alpha rnw
  Piggy_RnW2            <= '1';         -- beta rnw
  Piggy_Ack2            <= not rst;     -- nRST signal von FAB
  Piggy_Ack1            <= '1';         -- OE Signal von FAB
  Piggy_Strb1           <= '1';         -- Allways active
  Piggy_Strb2           <= '1';         -- Allways active

--   sig_data <= data_from_adc;

  p_adc_copy : process (clk, rst)
  begin  -- process p_adc_copy
    if rst = '1' then                   -- asynchronous reset (active high)
      data_from_adc <= (others => '0');
      
    elsif clk'event and clk = '1' then  -- rising clock edge
      data_from_adc (7 downto 0)  <= uC_Link_D;
      data_from_adc (15 downto 8) <= uC_Link_A;
    end if;
  end process p_adc_copy;

-------------------------------------------------------------------------------
-- SIGMON USB Generate MODULE
-- BEGIN
-------------------------------------------------------------------------------  

  sigmon_gen : if (enable_sigmon_output = true) generate
    
    component fifo_16bit is
      port
        (
          clock : in  std_logic;
          data  : in  std_logic_vector (15 downto 0);
          rdreq : in  std_logic;
          sclr  : in  std_logic;
          wrreq : in  std_logic;
          empty : out std_logic;
          full  : out std_logic;
          q     : out std_logic_vector (15 downto 0)
          );
    end component;

    -- FIFO Signals

    signal fifo_data_in  : std_logic_vector(15 downto 0);
    signal fifo_data_out : std_logic_vector(15 downto 0);
    signal fifo_rdreq    : std_logic;
    signal fifo_wrreq    : std_logic;
    signal fifo_empty    : std_logic;
    signal fifo_full     : std_logic;

    signal fub_tx_str  : std_logic;
    signal fub_tx_busy : std_logic;
    signal fub_tx_data : std_logic_vector(7 downto 0);

    signal fub_rx_str  : std_logic;
    signal fub_rx_busy : std_logic;
    signal fub_rx_data : std_logic_vector(7 downto 0);


    -- FTDI Signals
    signal fub_usb_data : std_logic_vector (7 downto 0);
    signal fub_usb_str  : std_logic;
    signal fub_usb_busy : std_logic;

    signal ftdi_d    : std_logic_vector (7 downto 0);
    signal ftdi_nrd  : std_logic;
    signal ftdi_wr   : std_logic;
    signal ftdi_nrxf : std_logic;
    signal ftdi_ntxe : std_logic;

    signal ftdi_nrxf_synced : std_logic;
    signal ftdi_ntxe_synced : std_logic;

    signal signal_probe : std_logic_vector(15 downto 0);


  begin
    --- SIGMON
    
    fifo_inst : fifo_16bit
      port map (
        clock => clk,
        data  => fifo_data_in,
        rdreq => fifo_rdreq,
        sclr  => rst,
        wrreq => fifo_wrreq,
        empty => fifo_empty,
        full  => fifo_full,
        q     => fifo_data_out
        );

    fub_ftdi_usb_inst : fub_ftdi_usb
      generic map (
        clk_freq_in_hz => clk_freq_in_hz
        )
      port map (
        clk_i          => clk,
        rst_i          => rst,
        fub_in_str_i   => fub_tx_str,
        fub_in_busy_o  => fub_tx_busy,
        fub_in_data_i  => fub_tx_data,
        fub_out_str_o  => fub_rx_str,
        fub_out_busy_i => fub_rx_busy,
        fub_out_data_o => fub_rx_data,
        ftdi_d_io      => ftdi_d,
        ftdi_nrd_o     => ftdi_nrd,
        ftdi_wr_o      => ftdi_wr,
        ftdi_nrxf_i    => ftdi_nrxf_synced,
        ftdi_ntxe_i    => ftdi_ntxe_synced
        );

    sigmon_ctrl_inst : sigmon_ctrl
      generic map(
        data_width          => 16,
        fifo_size           => 4096,
        external_trigger_en => false,
        magic_number        => 1442775210  -- (=55ff00aa) magic number as header indentifier 
        )         
      port map(
        clk_i          => clk,
        rst_i          => rst,
        --data interface
        data_i         => signal_probe,
        data_trigger_i => '0',
        --fifo interface
        fifo_d_o       => fifo_data_in,
        fifo_rdreq_o   => fifo_rdreq,
        fifo_wrreq_o   => fifo_wrreq,
        fifo_empty_i   => fifo_empty,
        fifo_full_i    => fifo_full,
        fifo_d_i       => fifo_data_out,
        --fub out
        fub_tx_str_o   => fub_tx_str,
        fub_tx_busy_i  => fub_tx_busy,
        fub_tx_data_o  => fub_tx_data,
        --fub in
        fub_rx_str_i   => fub_rx_str,
        fub_rx_busy_o  => fub_rx_busy,
        fub_rx_data_i  => fub_rx_data,
        test_o         => open
        );

    -- UDL Platine
    --DSP-Link Direction:
    DSP_DIR_D      <= not ftdi_nrd;     --DIR: '1'=to FPGA, '0'=from FPGA
    DSP_DIR_STRACK <= '0';              --DIR: '1'=to FPGA, '0'=from FPGA
    DSP_DIR_REQRDY <= '1';              --DIR: '1'=to FPGA, '0'=from FPGA

    --FTDI signal mapping
    ftdi_d(0)  <= not DSP_D_R0 when ftdi_nrd = '0' else 'Z';
    ftdi_d(1)  <= not DSP_D_R1 when ftdi_nrd = '0' else 'Z';
    ftdi_d(2)  <= not DSP_D_R2 when ftdi_nrd = '0' else 'Z';
    ftdi_d(3)  <= not DSP_D_R3 when ftdi_nrd = '0' else 'Z';
    ftdi_d(4)  <= not DSP_D_R4 when ftdi_nrd = '0' else 'Z';
    ftdi_d(5)  <= not DSP_D_R5 when ftdi_nrd = '0' else 'Z';
    ftdi_d(6)  <= not DSP_D_R6 when ftdi_nrd = '0' else 'Z';
    ftdi_d(7)  <= not DSP_D_R7 when ftdi_nrd = '0' else 'Z';
    DSP_D_W0   <= not ftdi_d(0);
    DSP_D_W1   <= not ftdi_d(1);
    DSP_D_W2   <= not ftdi_d(2);
    DSP_D_W3   <= not ftdi_d(3);
    DSP_D_W4   <= not ftdi_d(4);
    DSP_D_W5   <= not ftdi_d(5);
    DSP_D_W6   <= not ftdi_d(6);
    DSP_D_W7   <= not ftdi_d(7);
    DSP_CSTR_W <= not ftdi_wr;
    DSP_CACK_W <= not ftdi_nrd;
    ftdi_nrxf  <= not DSP_CRDY_R;
    ftdi_ntxe  <= not DSP_CREQ_R;

    -----------------------------------------------------------------------------

    --- Sigmon processes

    p_synch_udl : process(clk)
    begin
      if clk = '1' and clk'event then
        ftdi_nrxf_synced <= ftdi_nrxf;
        ftdi_ntxe_synced <= ftdi_ntxe;
      end if;
    end process p_synch_udl;

--     signal_probe (13 downto 0)  <= detected_amplitude_ch1 when sigmon_channel = 1 else detected_amplitude_ch2;
--     signal_probe (15 downto 14) <= (others => '0');

    signal_probe <= sig_data;
    
  end generate sigmon_gen;

-------------------------------------------------------------------------------
-- END
-- SIGMON USB Generate MODULE
-------------------------------------------------------------------------------  


end architecture sigmon_usb_fib_top_arch;
