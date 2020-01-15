-------------------------------------------------------------------------------
-- PEB Top Level Entity Template
-- 
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.reset_gen_pkg.all;
use work.fub_rs232_tx_pkg.all;
use work.real_time_blinker_pkg.all;
use work.fub_tx_master_pkg.all;
use work.debounce_pkg.all;
use work.clk_detector_pkg.all;

use work.fub_io_expander_pkg.all;
use work.fub_multi_spi_master_pkg.all;
use work.debounce_pkg.all;

entity fub_io_expander_top is
  generic(
    clk_freq_in_hz  	: real := 100.0E6;
    rs232_baud_rate 	: real := 9600.0;
    usb_baud_rate   	: real := 9600.0;
    default_io_data    	: std_logic_vector(15 downto 0) 	:= x"AAAA"; 
    default_setup_data 	: std_logic_vector (64-1 downto 0) := x"0A200B2000000100";
    spi_address        	: integer := 0;
    fub_addr_width     	: integer := 2;
    fub_data_width     	: integer := 8;
    setup_length		: integer := 4;
    no_of_data_bytes	: integer := 6);
  port (                          

    -- Backplane Signals

    userpin1      : out std_logic;
    userpin2      : out std_logic;
    userpin3      : out std_logic;
    userpin4      : out std_logic;
    userpin5      : out std_logic;
    userpin6      : out std_logic;
    userpin7      : out std_logic;
    userpin8      : out std_logic;
    userpin9      : out std_logic;
    userpin10     : out std_logic;
    userpin11     : out std_logic;
    userpin12     : out std_logic;
    userpin13     : out std_logic;
    userpin14     : out std_logic;
    userpin15     : out std_logic;
    userpin16     : out std_logic;
    userpin17     : out std_logic;
    userpin18     : out std_logic;
    userpin19     : out std_logic;
    rs485datain1  : in  std_logic;
    rs485datain2  : in  std_logic;
    rs485dataout1 : out std_logic;
    rs485dataout2 : out std_logic;
    reset_in      : in  std_logic;
    request_out   : out std_logic;
    select_in     : in  std_logic;

    -- FIB Piggy Interface

    piggy_ack1  : out std_logic;
    piggy_ack2  : out std_logic;
    piggy_strb1 : out std_logic;
    piggy_strb2 : out std_logic;
    piggy_r_w1  : out std_logic;
    piggy_r_w2  : out std_logic;
    piggy_io0   : out std_logic;
    piggy_io1   : out std_logic;
    piggy_io2   : out std_logic;
    piggy_io3   : out std_logic;
    piggy_io4   : out std_logic;
    piggy_io5   : out std_logic;
    piggy_io6   : out std_logic;
    piggy_io7   : out std_logic;
    uc_link_a0  : out std_logic;
    uc_link_a1  : out std_logic;
    uc_link_a2  : out std_logic;
    uc_link_a3  : out std_logic;
    uc_link_a4  : out std_logic;
    uc_link_a5  : out std_logic;
    uc_link_a6  : out std_logic;
    uc_link_d0  : out std_logic;
    uc_link_d1  : out std_logic;
    uc_link_d2  : out std_logic;
    uc_link_d3  : out std_logic;
    uc_link_d4  : out std_logic;
    uc_link_d5  : out std_logic;
    uc_link_d6  : out std_logic;
    uc_link_d7  : out std_logic;
    strobe      : out std_logic;
    r_w         : out std_logic;
    mrq         : out std_logic;
    ack         : out std_logic;
    fibclock    : in  std_logic;

    -- Coding switches

    cod1schalter4 : in std_logic;
    cod1schalter2 : in std_logic;
    cod1schalter8 : in std_logic;
    cod1schalter1 : in std_logic;
    cod2schalter4 : in std_logic;
    cod2schalter2 : in std_logic;
    cod2schalter8 : in std_logic;
    cod2schalter1 : in std_logic;
    cod3schalter4 : in std_logic;
    cod3schalter2 : in std_logic;
    cod3schalter8 : in std_logic;
    cod3schalter1 : in std_logic;

    -- Virtual JZAG Signals

    vj1tck : in  std_logic;
    vj1tdo : out std_logic;
    vj1tms : out  std_logic;
    vj1tdi : out  std_logic;

    vj2tck : In std_logic;
    vj2tdo : Out  std_logic;
    vj2tms : out std_logic;
    vj2tdi : out std_logic;

    vj3tck : in std_logic;
    vj3tdo : out  std_logic;
    vj3tms : out std_logic;
    vj3tdi : out std_logic;

    -- IO Signals

    bank1io0 : in std_logic;
    bank1io1 : in std_logic;
    bank1io2 : in std_logic;
    bank1io3 : in std_logic;
    bank1io4 : in std_logic;
    bank1io5 : in std_logic;
    bank1io6 : in std_logic;
    bank1io7 : in std_logic;
    bank2io0 : in std_logic;
    bank2io1 : in std_logic;
    bank2io2 : in std_logic;
    bank2io3 : in std_logic;
    bank2io4 : in std_logic;
    bank2io5 : out std_logic;
    bank2io6 : in std_logic;
    bank2io7 : out std_logic;

    -- Misc Signals

    testpin    : out std_logic;
    rel1       : out std_logic;
    rel2       : out std_logic;
    led1       : out std_logic;
    led2       : out std_logic;
    buzzer     : out std_logic;
    tast1      : in  std_logic;
    tast2      : in  std_logic;
    usbrx      : out  std_logic;
    usbtx      : in std_logic;
    rs232r1out : in  std_logic;
    rs232t1in  : out std_logic;
    pin_58     : out std_logic;         --Pin auf der Platine nicht verfügbar
    quarz      : in  std_logic;
    hfin       : in  std_logic;
    hfin2      : in  std_logic

    );

end fub_io_expander_top;

architecture fub_io_expander_top_arch of fub_io_expander_top is

  -- Common Signals
  signal clk : std_logic;
  signal rst : std_logic;

  -- RS232 Signals
  signal rs232_str  : std_logic;
  signal rs232_busy : std_logic;
  signal rs232_data : std_logic_vector(7 downto 0);

  signal tast1_deb : std_logic;

  signal blink : std_logic;
  
  Signal fubA_str	: std_logic;
  Signal fubA_busy	: std_logic;
  Signal fubA_addr	: std_logic_vector(fub_addr_width-1 downto 0);
  Signal fubA_data	: std_logic_vector(7 downto 0);
  
  Signal expander_data_i	: std_logic_vector(15 downto 0);
  Signal spi_mosi_miso		: std_logic;
  Signal tast2_deb			: std_logic;
  Signal spi_ss_vec			: std_logic_vector(9 downto 0);

  constant slave0_byte_count : integer := 3;
  constant slave1_byte_count : integer := 0;
  constant slave2_byte_count : integer := 0;
  constant slave3_byte_count : integer := 0;
  constant slave4_byte_count : integer := 0;
  constant slave5_byte_count : integer := 0;
  constant slave6_byte_count : integer := 0;
  constant slave7_byte_count : integer := 0;
  constant slave8_byte_count : integer := 0;
  constant slave9_byte_count : integer := 0;
  
  constant data_width : integer := 8;
                 
 signal expander_str_i : std_logic;
                  
begin  -- fub_io_expander_top_arch

  reset_gen_inst : reset_gen
    generic map(
      reset_clks => 10
      )
    port map (
      clk_i => clk,
      rst_o => rst
      );
      
--clk <= hfin;      
  clk <= quarz;

  debounce_1 : debounce
    generic map (
      debounce_clks => 50)
    port map (
	rst_i	=> rst,
      clk_i => clk,
      x_i   => tast1,
      x_o   => tast1_deb);

  fub_tx_master_1 : fub_tx_master
    generic map (
      addr_width       => 8,
      data_width       => 8,
      addr_start_value => 16#20#,
      data_start_value => 16#10#,
      addr_stop_value  => 16#80#,
      data_stop_value  => 16#60#,
      addr_inc_value   => 16#1#,
      data_inc_value   => 16#1#,
      wait_clks        => 0)
    port map (
      rst_i      => rst,
      clk_i      => clk,
      fub_str_o  => rs232_str,
      fub_busy_i => rs232_busy,
      fub_addr_o => open,
      fub_data_o => rs232_data);

  fub_rs232_tx_inst1 : fub_rs232_tx
    generic map (
      clk_freq_in_hz => clk_freq_in_hz,
      baud_rate      => usb_baud_rate)
    port map (
      clk_i      => clk,
      rst_i      => rst,
      rs232_tx_o => usbrx,
      fub_str_i  => rs232_str,
      fub_busy_o => rs232_busy,
      fub_data_i => rs232_data);

  real_time_blinker_1 : real_time_blinker
    generic map (
      clk_freq_in_hz     => clk_freq_in_hz,
      blink_period_in_ms => 1000.0)
    port map (
      clk_i   => clk,
      rst_i   => rst,
      blink_o => expander_str_i);

  led2 <= not tast2_deb;--blink;
	rel1 <= blink;

  clk_detector_inst1 : clk_detector
    generic map (
      clk_freq_in_hz       => clk_freq_in_hz,
      output_on_time_in_ms => 50.0)
    port map (
      clk_i => clk,
      rst_i => rst,
      x_i   => tast1,
      x_o   => buzzer);

  clk_detector_inst2 : clk_detector
    generic map (
      clk_freq_in_hz       => clk_freq_in_hz,
      output_on_time_in_ms => 50.0)
    port map (
      clk_i => clk,
      rst_i => rst,
      x_i   => hfin,
      x_o   => led1);

  --bank1io0 <= hfin;

-- hier baustelle
  
  
  	debounce_2	: debounce
    generic map (
      debounce_clks => 50)
    port map (
	rst_i	=> rst,
      clk_i => clk,
      x_i   => tast2,
      x_o   => tast2_deb);
  
--  expander_data_i <=(bank1io0,bank1io1,bank1io2,bank1io3,bank1io4,bank1io5,bank1io6,bank1io7,bank2io0,bank2io1,bank2io2,bank2io3,bank2io4,bank2io5,bank2io6,bank2io7);

expander_data_i <= x"4444";

    fub_io_expander_inst: fub_io_expander
    generic map (
      default_io_data    => default_io_data,
      default_setup_data => default_setup_data,
      spi_address        => spi_address,
      fub_addr_width     => fub_addr_width,
      fub_data_width     => fub_data_width)--,
      --setup_length		 => setup_length,
      --no_of_data_bytes	 => no_of_data_bytes)
    port map (
      clk_i              => clk,
      rst_i              => rst,--not tast2_deb,
      
      io_expander_data_i => expander_data_i,--io_expander_data_i
      io_expander_str_i  => expander_str_i,
      io_expander_busy_o => open,
      fub_data_o         => fubA_data,
      fub_adr_o          => fubA_addr,
      fub_str_o          => fubA_str,
      fub_busy_i         => fubA_busy);

                                        -- io data in aus den testbench bankio
                                        -- benutzen.
    
  
  -- instance von multi spi master noch hier
  fub_multi_spi_master_inst1 : fub_multi_spi_master
    generic map (
      clk_freq_in_hz => 10.0E7,

      spi_clk_perid_in_ns   => 1000.0,
      spi_setup_delay_in_ns => 1000.0,

      slave0_byte_count => slave0_byte_count,
      slave1_byte_count => slave1_byte_count,
      slave2_byte_count => slave2_byte_count,
      slave3_byte_count => slave3_byte_count,
      slave4_byte_count => slave4_byte_count,
      slave5_byte_count => slave5_byte_count,
      slave6_byte_count => slave6_byte_count,
      slave7_byte_count => slave7_byte_count,
      slave8_byte_count => slave8_byte_count,
      slave9_byte_count => slave9_byte_count,
      data_width        => data_width)
    port map (
      clk_i       => clk,
      rst_i       => rst,--not tast2_deb,
      fub_str_i   => fubA_str,
      fub_busy_o  => fubA_busy,
      fub_data_i  => fubA_data,
      fub_addr_i  => fubA_addr,
      fub_error_o => open,
      fub_str_o   => open,
      fub_busy_i  => '0',
      fub_data_o  => open,
      spi_mosi_o  => VJ1TDO,
      spi_miso_i  => VJ1TCK,
      spi_clk_o   => VJ1TMS,
      spi_ss_o    => spi_ss_vec);
	  
	  bank2io7 <= spi_ss_vec(0);
 
end fub_io_expander_top_arch;
