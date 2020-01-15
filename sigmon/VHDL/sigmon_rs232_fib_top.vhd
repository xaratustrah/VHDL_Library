library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

use work.clk_detector_pkg.all;
use work.fub_rs232_rx_pkg.all;
use work.fub_rs232_tx_pkg.all;
use work.sigmon_ctrl_pkg.all;
use work.reset_gen_pkg.all;


entity sigmon_rs232_fib_top is
	generic(
		clk_freq_in_hz          : real := 100.0E6;  --100 MHz system clock frequency
		baud_rate       : real := 115200.0; 
		sig_data_increment : integer := 64; --this increment is added each clk cycle to the dummy data
		data_width : integer := 16  --data width of monitor signal
	);
	port (
		--common signals
		trig1_in: in std_logic;	--rst
		trig2_out: out std_logic;
		clk0: in std_logic;
		hf_in: in std_logic;

		--dds signals
		uC_Link_D: in std_logic_vector(7 downto 0); --dds_data
		uC_Link_A: in std_logic_vector(7 downto 0); --dds_addr
		Piggy_Clk1: out std_logic;	--dds_clk
		Piggy_RnW1: out std_logic;	--dds_wr
		Piggy_RnW2: in std_logic;		--dds_vout_comp
		Piggy_Strb2: out std_logic;	--dds_rst
		Piggy_Strb1: out std_logic;	--dds_update_o
		Piggy_Ack1: out std_logic;	--dds_fsk
		Piggy_Ack2: out std_logic;	--dds_sh_key

		--static dds-buffer signals
		uC_Link_DIR_D, uC_Link_DIR_A: out std_logic;
		nuC_Link_EN_CTRL_A: out std_logic;
		uC_Link_EN_DA: out std_logic;

		--backplane signals
		A2nSW8: in std_logic;
		A3nSW9: in std_logic;
		A0nSW10: in std_logic;
		A1nSW11: in std_logic;
		Sub_A6nSW12: in std_logic;
		Sub_A7nSW13: in std_logic;
		Sub_A4nSW14: in std_logic;
		Sub_A5nSW15: in std_logic;
		nResetnSW0: in std_logic;
		SW1: in std_logic;
		nDSnSW2: in std_logic;
		BClocknSW3: in std_logic;
		RnWnSW4: in std_logic;
		SW5: in std_logic;
		A4nSW6: in std_logic;
		SW7: in std_logic;
		NEWDATA: in std_logic;
		FC_Str: in std_logic;
		FC0: in std_logic;
		FC1: in std_logic;
		FC2: in std_logic;
		FC3: in std_logic;
		FC4: in std_logic;
		FC5: in std_logic;
		VG_A3nFC6: in std_logic;
		FC7: in std_logic;
		SD: in std_logic;
		nDRQ2: out std_logic;
		
		--static backplane-buffer signals
		BBA_DIR: out std_logic;
		BBB_DIR: out std_logic;
		BBC_DIR: out std_logic;
		BBD_DIR: out std_logic;
		BBE_DIR: out std_logic;
		BBG_DIR: out std_logic;
		BBH_DIR: out std_logic;
		nBB_EN: out std_logic;

		--static backplane open-collector outputs
		DRDY: out std_logic;
		SRQ3: out std_logic;
		DRQ: out std_logic;
		INTERL: out std_logic;
		DTACK: out std_logic;
		nDRDY2: out std_logic;
		SEND_EN: out std_logic;
		SEND_STR: out std_logic;
		
		--dsp-link signals (read)
		DSP_CRDY_W: out std_logic;
		DSP_CREQ_W: out std_logic;
		DSP_CACK_R: in std_logic;
		DSP_CSTR_R: in std_logic;

		DSP_D_R0: in std_logic;
		DSP_D_R1: in std_logic;
		DSP_D_R2: in std_logic;
		DSP_D_R3: in std_logic;
		DSP_D_R4: in std_logic;
		DSP_D_R5: in std_logic;
		DSP_D_R6: in std_logic;
		DSP_D_R7: in std_logic;

		--dsp-link signals (write)		
		DSP_CRDY_R: in std_logic;
		DSP_CREQ_R: in std_logic;
		DSP_CACK_W: out std_logic;
		DSP_CSTR_W: out std_logic;
		
		DSP_D_W0: out std_logic;
		DSP_D_W1: out std_logic;
		DSP_D_W2: out std_logic;
		DSP_D_W3: out std_logic;
		DSP_D_W4: out std_logic;
		DSP_D_W5: out std_logic;
		DSP_D_W6: out std_logic;
		DSP_D_W7: out std_logic;

		-- leds
		led1:	out std_logic;
		led2:	out std_logic;
		led3:	out std_logic;
		led4:	out std_logic;
		
		-- only for debug
		piggy_io: out std_logic_vector(7 downto 0);
		
		--adressing pins via FC
		VG_A4 : in std_logic; --FC(0)
		VG_A1 : in std_logic; --FC(1)
    
    --rs232
 	  rs232_rx_i		:	in  std_logic;
		rs232_tx_o		:	out std_logic
		
	);
end entity sigmon_rs232_fib_top;

architecture sigmon_rs232_fib_top_arch of sigmon_rs232_fib_top is

  ------------------ component declaration ----------------------

	component fifo_16bit is
		port
		(
			clock		: in std_logic ;
			data		: in std_logic_vector (data_width-1 downto 0);
			rdreq		: in std_logic ;
			sclr		: in std_logic ;
			wrreq		: in std_logic ;
			empty		: out std_logic ;
			full		: out std_logic ;
			q		: out std_logic_vector (data_width-1 downto 0)
		);
	end component;
	
	component pll0
		port
		(
			inclk0		: IN STD_LOGIC  := '0';
			c0		: OUT STD_LOGIC ;
			c1		: OUT STD_LOGIC ;
			locked		: OUT STD_LOGIC 
		);
	end component;

  ------------------ signal declaration ----------------------

	signal clk,clk100,clk200: std_logic;
	signal rst: std_logic;
	signal power_on_reset: std_logic;

  signal fifo_data_in: std_logic_vector(data_width-1 downto 0);
  signal fifo_data_out: std_logic_vector(data_width-1 downto 0);
  signal fifo_rdreq: std_logic;
  signal fifo_wrreq: std_logic;
  signal fifo_empty: std_logic;
  signal fifo_full: std_logic;
  
  signal fub_tx_str: std_logic;
  signal fub_tx_busy: std_logic;
  signal fub_tx_data: std_logic_vector(7 downto 0);

  signal fub_rx_str: std_logic;
  signal fub_rx_busy: std_logic;
  signal fub_rx_data: std_logic_vector(7 downto 0);

  signal sig_data: std_logic_vector(data_width-1 downto 0);
  

  -- FAB related signals
  constant FAB_REG_CTRL : std_logic_vector (5 downto 0) := conv_std_logic_vector(16#00#,6);  
  constant FAB_REG_STAT : std_logic_vector (5 downto 0) := conv_std_logic_vector(16#01#,6);
  constant FAB_REG_ADC1_ADR : std_logic_vector (5 downto 0) := conv_std_logic_vector(16#02#,6);
  constant FAB_REG_ADC2_ADR : std_logic_vector (5 downto 0) := conv_std_logic_vector(16#03#,6); 
  constant FAB_REG_DAC1_ADR : std_logic_vector (5 downto 0) := conv_std_logic_vector(16#04#,6);
  constant FAB_REG_DAC2_ADR : std_logic_vector (5 downto 0) := conv_std_logic_vector(16#05#,6);
  constant FAB_REG_CLKDIV_ADC1_ADR : std_logic_vector (5 downto 0) := conv_std_logic_vector(16#06#,6);
  constant FAB_REG_CLKDIV_ADC2_ADR : std_logic_vector (5 downto 0) := conv_std_logic_vector(16#07#,6);
  constant FAB_REG_CLKDIV_DAC1_ADR : std_logic_vector (5 downto 0) := conv_std_logic_vector(16#08#,6);
  constant FAB_REG_CLKDIV_DAC2_ADR : std_logic_vector (5 downto 0) := conv_std_logic_vector(16#09#,6);

  signal data_bus : std_logic_vector (15 downto 0);  -- FAB Data bus mapped to uCLinuk Address and Databus

  signal adr_o          : std_logic_vector (5 downto 0);  -- Address bus for FAB
  signal ext_driver_dir : std_logic;

  signal rnw_o : std_logic;
  signal strobe_o: std_logic;

  signal nrs232_rx : std_logic;
  
  begin
  ------------------ component instanciation ----------------------

	reset_gen_inst: reset_gen
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
			c0 => clk200,
			c1 => clk100,
			locked => open
	);


	fifo_inst: fifo_16bit
	port map (
			clock => clk,
			data => fifo_data_in,
			rdreq => fifo_rdreq,
			sclr => rst,
			wrreq => fifo_wrreq,
			empty => fifo_empty,
			full  => fifo_full,
			q	 => fifo_data_out
	);

  sigmon_ctrl_inst: sigmon_ctrl
		generic map(
			data_width    => data_width,
			fifo_size     => 4096,
			magic_number  => 1442775210 -- (=55ff00aa) magic number as header indentifier 
    )		
		port map(
			clk_i	=> clk,
			rst_i	=> rst,
			--data interface
			data_i	=> sig_data,
			--fifo interface
			fifo_d_o	=> fifo_data_in,
			fifo_rdreq_o		=> fifo_rdreq,
			fifo_wrreq_o		=> fifo_wrreq,
			fifo_empty_i		=> fifo_empty,
			fifo_full_i		=> fifo_full,
			fifo_d_i		=> fifo_data_out,
			--fub out
			fub_tx_str_o	=> fub_tx_str,
			fub_tx_busy_i	=> fub_tx_busy,
			fub_tx_data_o	=> fub_tx_data,
      --fub in
			fub_rx_str_i	=> fub_rx_str,
			fub_rx_busy_o	=> fub_rx_busy,
			fub_rx_data_i	=> fub_rx_data,
			test_o => led1
	);

  fub_rs232_tx_inst : fub_rs232_tx
	generic map(
 		clk_freq_in_hz => clk_freq_in_hz,
	  baud_rate => baud_rate
	)
	port map (
		clk_i => clk,
		rst_i => rst,
		rs232_tx_o => rs232_tx_o,
		fub_str_i => fub_tx_str,
		fub_busy_o => fub_tx_busy,
		fub_data_i => fub_tx_data
	);

  nrs232_rx <= not rs232_rx_i;

  fub_rs232_rx_inst : fub_rs232_rx
	generic map(
  		clk_freq_in_hz => clk_freq_in_hz,
	  baud_rate => baud_rate
	)
	port map (
		clk_i => clk,
		rst_i => rst,
		rs232_rx_i => nrs232_rx,
		fub_str_o => fub_rx_str,
		fub_busy_i => fub_rx_busy,
		fub_data_o => fub_rx_data,
  	 receive_error => led2
  );

	clk_detector_inst : clk_detector
		generic map(
   		clk_freq_in_hz => clk_freq_in_hz,
		  output_on_time_in_ms => 100.0 --100 ms
		)
		port map(
			clk_i => clk,
			rst_i => rst,
			x_i => fub_rx_str,
			x_o => led4
		);
		
  ------------------ static signal settings ----------------------

--	clk <= clk0;
	clk <= clk100;
	
--  led1<='1';
  led3<=rst;
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
	nBB_EN <= '0';

	--static backplane open-collector output settings
	DRDY <= '0';
	SRQ3 <= '0';
	DRQ <= '0';
	INTERL <= '0';
	DTACK <= '0';
	nDRDY2 <= '0';
	SEND_EN <= '0';
	SEND_STR <= '0';

	--static uC-Link buffer settings
--	uC_Link_DIR_D <= '1';
--	uC_Link_DIR_A <= '1';
--	nuC_Link_EN_CTRL_A <= '1';
--	uC_Link_EN_DA <= '0';

  nuC_Link_EN_CTRL_A <= '1';
  uC_Link_EN_DA      <= '0';


	--fab settings
	data_bus (7 downto 0) <= uC_Link_D ;
	data_bus (15 downto 8) <= uC_Link_A;
	
	Piggy_RnW1 <= rnw_o;
	Piggy_Strb1 <= strobe_o;
		
  piggy_io (5 downto 0) <= adr_o;

  uC_Link_DIR_A <= ext_driver_dir;
  uC_Link_DIR_D <= ext_driver_dir;
	
	Piggy_Clk1  <= clk200;

	
  process(clk,rst)
  begin
    if rst='1' then
      sig_data <= (others => '0');

    elsif clk='1' and clk'event then
      sig_data <= conv_std_logic_vector(conv_integer(sig_data) + sig_data_increment,data_width);
    end if;
  end process;
  
end architecture sigmon_rs232_fib_top_arch;