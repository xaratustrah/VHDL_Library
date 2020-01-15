--
-- Testbench for fib_registerfile_top
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

use work.reset_gen_pkg.all;
use work.real_time_calculator_pkg.all;
use work.fub_tx_master_pkg.all;
use work.fub_seq_mux_pkg.all;
use work.fub_rs232_tx_pkg.all;
use work.parallel_to_fub_pkg.all;

entity fib_registerfile_top_tb is
	generic (
  		clk_freq_in_hz 			           : real := 50.0E6;
  		sim_baud_rate       : real := 10.0E6;
      no_of_data_bytes : integer := 20;
      adr_width        : integer := 16
	);
end entity;

architecture fib_registerfile_top_tb_arch of fib_registerfile_top_tb is

	component fib_registerfile_top
		generic(
      clk_freq_in_hz          : real;
      firmware_id             : integer;
      firmware_version        : integer;
      no_of_registers         : integer;
      baud_rate_rs232         : real;
      rs232_seq_timeout_in_us : real
		);
		port (
		--trigger signals
		trig1_in  : in std_logic;	--rst
		trig2_out : out std_logic;
    trig1_out : out std_logic;
    trig2_in  : in std_logic;
		
		--clk's
		clk0 : in std_logic;
    clk1 : in std_logic;
		
		--rf in
		hf1_in: in std_logic;
		hf2_in: in std_logic;

		--uC-Link signals
		uC_Link_D: out std_logic_vector(7 downto 0); --dds_data
		uC_Link_A: out std_logic_vector(7 downto 0); --dds_addr
    nuC_Link_ACK_R    : in std_logic;
    nuC_Link_ACK_W    : out std_logic;
    nuC_Link_MRQ_R    : in std_logic;
    nuC_Link_MRQ_W    : out std_logic;
    nuC_Link_RnW_R    : in std_logic;
    nuC_Link_RnW_W    : out std_logic;
    nuC_Link_STROBE_R : in std_logic;
    nuC_Link_STROBE_W : out std_logic;
    
		--static uC-Link signals
		uC_Link_DIR_D, uC_Link_DIR_A: out std_logic;
		nuC_Link_EN_CTRL_A: out std_logic;
		uC_Link_EN_DA: out std_logic;

    --piggy signals
		Piggy_Clk1: out std_logic;	--dds_clk
		Piggy_RnW1: out std_logic;	--dds_wr
		Piggy_RnW2: in std_logic;		--dds_vout_comp
		Piggy_Strb2: out std_logic;	--dds_rst
		Piggy_Strb1: out std_logic;	--dds_update_o
		Piggy_Ack1: out std_logic;	--dds_fsk
		Piggy_Ack2: out std_logic;	--dds_sh_key

		--backplane signals
		A2nSW8: in std_logic;
		A3nSW9: in std_logic;
		A0nSW10: in std_logic;
		A1nSW11: in std_logic;
		Sub_A0nIW6: in std_logic;
		Sub_A1nIW7: in std_logic;
		Sub_A2nIW4: in std_logic;
		Sub_A3nIW5: in std_logic;
		Sub_A4nSW14: in std_logic;
		Sub_A5nSW15: in std_logic;
	    Sub_A6nSW12: in std_logic;
		Sub_A7nSW13: in std_logic;
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
		
		VG_SK0nSWF6: in std_logic;     
		VG_SK1nSWF5: in std_logic;
		VG_SK2nSWF4: in std_logic;
		VG_SK3nSWF3: in std_logic;
		VG_SK4nSWF2: in std_logic;
		VG_SK5nSWF1: in std_logic;
		VG_SK6nSWF0: in std_logic;
		VG_SK7     : in std_logic;
		
		VG_ID0nRes: in std_logic;
		VG_ID1nIW3: in std_logic;
		VG_ID2nIW2: in std_logic;
		VG_ID3nIW1: in std_logic;
		VG_ID4nIW0: in std_logic;
		VG_ID5    : in std_logic;
		VG_ID6    : in std_logic;
		VG_ID7nSWF7: in std_logic;
		
		D0nIW14: inout std_logic;
		D1nIW15: inout std_logic;
		D2nIW12: inout std_logic;
		D3nIW13: inout std_logic;
		D4nIW10: inout std_logic;
		D5nIW11: inout std_logic;
		D6nIW8: inout std_logic;
		D7nIW9: inout std_logic;
		
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

		DSP_DIR_D: out std_logic;
		DSP_DIR_STRACK: out std_logic;
		DSP_DIR_REQRDY: out std_logic;

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
		VG_A2 : in std_logic; --only modulbus 
		VG_A0 : in std_logic; --only modulbus 

    --rs232
 	  rs232_rx_i		:	in  std_logic;
		rs232_tx_o		:	out std_logic;

		--flash device
		eeprom_data : in std_logic;
		eeprom_dclk : out std_logic;
		eeprom_ncs : out std_logic;
		eeprom_asdi : out std_logic;
		
		--Jumper:
		Testpin_J60 : out std_logic;
		
    --TCXO
    TCXO1_CNTRL       : out std_logic;
    TCXO2_CNTRL       : out std_logic;
    
    --mixed signal port
    nGPIO1_R          : in std_logic;
    nGPIO1_W          : out std_logic;
    nGPIO2_R          : in std_logic;
    nGPIO2_W          : out std_logic;
    nI2C_SCL          : out std_logic;
    nI2C_SDA          : out std_logic;
    nSPI_EN           : out std_logic;
    nSPI_MISO         : in std_logic;
    nSPI_MOSI         : out std_logic;
    nSPI_SCK          : out std_logic;
    
    --optical links
    opt1_los          : in std_logic;
    opt1_rx           : in std_logic;
    opt1_tx           : out std_logic;
    opt2_los          : in std_logic;
    opt2_rx           : in std_logic;
    opt2_tx           : out std_logic		
	);
	end component;

  signal clk: std_logic := '0';
  signal rst: std_logic := '0';
  
  signal rst1: std_logic := '0';

  signal rs232_tx: std_logic;
  signal nrs232_tx: std_logic;

	-- FUB RS232 DeMUX
	signal fub_rs232_demux_data		: std_logic_vector(7 downto 0);
	signal fub_rs232_demux_adr		: std_logic_vector(15 downto 0);
	signal fub_rs232_demux_str		: std_logic;
	signal fub_rs232_demux_busy		: std_logic;

	-- FUB RS232
	signal fub_rs232_data		: std_logic_vector(7 downto 0);
	signal fub_rs232_str		: std_logic;
	signal fub_rs232_busy		: std_logic;


  type par_data_array_type is array(0 to no_of_data_bytes-1) of
    std_logic_vector(7 downto 0);
  signal par_data_array : par_data_array_type;

  signal par_data : std_logic_vector(no_of_data_bytes*8-1 downto 0);

  type par_adr_array_type is array(0 to no_of_data_bytes-1) of
    std_logic_vector(adr_width-1 downto 0);
  signal par_adr_array : par_adr_array_type;

  signal par_adr : std_logic_vector(no_of_data_bytes*adr_width-1 downto 0);
  

begin
    
	fib_registerfile_top_inst: fib_registerfile_top
	generic map (
		clk_freq_in_hz 	 => clk_freq_in_hz,
		firmware_id      => 0,
		firmware_version => 0,
		no_of_registers  => 256,
		baud_rate_rs232  => sim_baud_rate,
		rs232_seq_timeout_in_us => 10.0E3
	)
	port map (
		--common signals
		trig1_in => '1',  --default is '1', trigger in is inverting
    trig1_out => open,
    trig2_in => '1',  --default is '1', trigger in is inverting
		trig2_out => open,

		clk0 => clk,
    clk1 => '0',
    
		hf1_in => '0',
		hf2_in => '0',

    --uC-Link signals
		uC_Link_D => open,
		uC_Link_A => open,

    nuC_Link_ACK_R    => '0',
    nuC_Link_ACK_W    => open,
    nuC_Link_MRQ_R    => '0',
    nuC_Link_MRQ_W    => open,
    nuC_Link_RnW_R    => '0',
    nuC_Link_RnW_W    => open,
    nuC_Link_STROBE_R => '0',
    nuC_Link_STROBE_W => open,

		--piggy signals
		Piggy_Clk1 => open,	--dds_clk
		Piggy_RnW1 => open,	--dds_wr
		Piggy_RnW2 => '0',		--dds_vout_comp
		Piggy_Strb2 => open,	--dds_rst
		Piggy_Strb1 => open,	--dds_update_o
		Piggy_Ack1 => open,	--dds_fsk
		Piggy_Ack2 => open,	--dds_sh_key

		--static dds-buffer signals
		uC_Link_DIR_D => open,
		uC_Link_DIR_A => open,
		nuC_Link_EN_CTRL_A => open,
		uC_Link_EN_DA => open,
		
		--backplane signals
		A2nSW8 => '0',
		A3nSW9 => '0',
		A0nSW10 => '0',
		A1nSW11 => '0',
		Sub_A0nIW6 => '0',
		Sub_A1nIW7 => '0',
		Sub_A2nIW4 => '0',
		Sub_A3nIW5 => '0',
		Sub_A6nSW12 => '0',
		Sub_A7nSW13 => '0',
		Sub_A4nSW14 => '0',
		Sub_A5nSW15 => '0',
		nResetnSW0 => '0',
		SW1 => '0',
		nDSnSW2 => '0',
		BClocknSW3 => '0',
		RnWnSW4 => '0',
		SW5 => '0',
		A4nSW6 => '0',
		SW7 => '0',
		NEWDATA => '0',
		FC_Str => '0',
		FC0 => '0',
		FC1 => '0',
		FC2 => '0',
		FC3 => '0',
		FC4 => '0',
		FC5 => '0',
		VG_A3nFC6 => '0',
		FC7 => '0',
		SD => '0',
		nDRQ2 => open,
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
		nBB_EN => open,

		--static backplane open-collector outputs
		DRDY => open,
		SRQ3 => open,
		DRQ => open,
		INTERL => open,
		DTACK => open,
		nDRDY2 => open,
		SEND_EN => open,
		SEND_STR => open,
		
		--dsp-link signals (read)
		DSP_CRDY_W => open,
		DSP_CREQ_W => open,
		DSP_CACK_R => '0',
		DSP_CSTR_R => '0',

		DSP_D_R0 => '0',
		DSP_D_R1 => '0',
		DSP_D_R2 => '0',
		DSP_D_R3 => '0',
		DSP_D_R4 => '0',
		DSP_D_R5 => '0',
		DSP_D_R6 => '0',
		DSP_D_R7 => '0',
		
		--dsp-link signals (write)		
		DSP_CRDY_R => '0',
		DSP_CREQ_R => '0',
		DSP_CACK_W => open,
		DSP_CSTR_W => open,
		
		DSP_D_W0 => open,
		DSP_D_W1 => open,
		DSP_D_W2 => open,
		DSP_D_W3 => open,
		DSP_D_W4 => open,
		DSP_D_W5 => open,
		DSP_D_W6 => open,
		DSP_D_W7 => open,

		-- leds
		led1 => open,
		led2 => open,
		led3 => open,
		led4 => open,
		
		-- only for debug
		piggy_io => open,
		
		--adressing pins via FC
		VG_A4  => '0', --FC(0)
		VG_A1  => '0', --FC(1)

    --rs232
 	  rs232_rx_i => nrs232_tx,
    rs232_tx_o =>	open,
		
	  eeprom_data => '0',		---------------------------
	  eeprom_dclk => open,
	  eeprom_ncs => open,
	  eeprom_asdi => open,

		Testpin_J60 => open,
		
    --TCXO
    TCXO1_CNTRL => open,
    TCXO2_CNTRL => open,

    --mixed signal port
    nGPIO1_R   => '0',
    nGPIO1_W   => open,
    nGPIO2_R   => '0',
    nGPIO2_W   => open,
    nI2C_SCL   => open,
    nI2C_SDA   => open,
    nSPI_EN    => open,
    nSPI_MISO  => '0',
    nSPI_MOSI  => open,
    nSPI_SCK   => open,

   --optical links
    opt1_los  => '0',
    opt1_rx   => '0',
    opt1_tx   => open,
    opt2_los  => '0',
    opt2_rx   => '0',
    opt2_tx   => open
	);	


--  rs232_fub_tx_master_inst : fub_tx_master
--    generic map (
--      addr_width       => 16,
--      data_width       => 8,
--      addr_start_value => 16#0000#,
--      data_start_value => 16#10#,
--      addr_stop_value  => 16#00FF#,
--      data_stop_value  => 16#0FF#,
--      addr_inc_value   => 16#1#,
--      data_inc_value   => 16#1#,
--      wait_clks        => 0)
--    port map (
--      rst_i      => rst,
--      clk_i      => clk,
--      fub_str_o  => fub_rs232_demux_str,
--      fub_busy_i => fub_rs232_demux_busy,
--      fub_addr_o => fub_rs232_demux_adr,
--      fub_data_o => fub_rs232_demux_data
--    );

  par_data_array(0) <= x"15";
  par_data_array(1) <= x"11";
  par_data_array(2) <= x"22";
  par_data_array(3) <= x"33";
  par_data_array(4) <= x"44";
  par_data_array(5) <= x"55";
  par_data_array(6) <= x"66";
  par_data_array(7) <= x"77";
  par_data_array(8) <= x"88";
  par_data_array(9) <= x"19";
  
  par_data_array(10) <= x"00"; -- REG_ADR_START_ADR_HIGH                                                    
  par_data_array(11) <= x"00"; -- REG_ADR_START_ADR_LOW                                                     
  par_data_array(12) <= x"00"; -- REG_ADR_END_ADR_HIGH                                                      
  par_data_array(13) <= x"08"; -- REG_ADR_END_ADR_LOW                                                       
  par_data_array(14) <= x"01"; -- REG_ADR_CMD (1=read single, 2=read block, 4=write flash, 8=read flash)    
  par_data_array(15) <= x"00"; 
  par_data_array(16) <= x"00"; 
  par_data_array(17) <= x"00"; 
  par_data_array(18) <= x"00"; 
  par_data_array(19) <= x"00"; 

  par_adr_array(0) <= x"0000";
  par_adr_array(1) <= x"0001";
  par_adr_array(2) <= x"0002";
  par_adr_array(3) <= x"0003";
  par_adr_array(4) <= x"0004";              
  par_adr_array(5) <= x"0005";
  par_adr_array(6) <= x"0006";
  par_adr_array(7) <= x"0007";
  par_adr_array(8) <= x"0008";
  par_adr_array(9) <= x"0009";
  
  par_adr_array(10) <= x"FFF1"; -- REG_ADR_START_ADR_HIGH		-- CARE 00F1 or FFF1 ...
  par_adr_array(11) <= x"FFF2"; -- REG_ADR_START_ADR_LOW 		-- 			"
  par_adr_array(12) <= x"FFF3"; -- REG_ADR_END_ADR_HIGH  		--			 "
  par_adr_array(13) <= x"FFF4"; -- REG_ADR_END_ADR_LOW   		--		 	"
  par_adr_array(14) <= x"FFF0"; -- REG_ADR_CMD					--			"
  par_adr_array(15) <= x"0000"; 
  par_adr_array(16) <= x"0000";
  par_adr_array(17) <= x"0000";
  par_adr_array(18) <= x"0000";
  par_adr_array(19) <= x"0000";

  array_to_parallel_gen : for i in 0 to no_of_data_bytes-1 generate
    par_data((i+1)*8-1 downto i*8)                <= par_data_array(i);
    par_adr((i+1)*adr_width-1 downto i*adr_width) <= par_adr_array(i);
  end generate;

reset_gen_inst1 : reset_gen
    generic map(
      reset_clks => 100000
      )
    port map (
      clk_i => clk,
      rst_o => rst1
      );


  parallel_to_fub_inst : parallel_to_fub
    generic map (
      no_of_data_bytes => no_of_data_bytes,
      adr_width        => adr_width
      )
    port map(
      rst_i      => rst1,
      clk_i      => clk,
      par_data_i => par_data,
      par_adr_i  => par_adr,
      par_str_i  => '1',
      par_busy_o => open,
      fub_data_o => fub_rs232_demux_data,
      fub_adr_o  => fub_rs232_demux_adr,
      fub_str_o  => fub_rs232_demux_str,
      fub_busy_i => fub_rs232_demux_busy
   );



  fub_seq_mux_inst : fub_seq_mux
    generic map (
      fub_address_width => 16,
      fub_data_width    => 8,
      clk_freq_in_hz    => clk_freq_in_hz,
      timeout_in_us     => 10.0E3
    )
    port map (
      clk_i      => clk,
      rst_i      => rst,
      fub_strb_i => fub_rs232_demux_str,
      fub_data_i => fub_rs232_demux_data,
      fub_addr_i => fub_rs232_demux_adr,
      fub_busy_o => fub_rs232_demux_busy,
      seq_busy_i => fub_rs232_busy,
      seq_data_o => fub_rs232_data,
      seq_strb_o => fub_rs232_str
    );
  
  nrs232_tx <= not rs232_tx;
		
  fub_rs232_tx_inst : fub_rs232_tx
	generic map (
		clk_freq_in_hz => clk_freq_in_hz,
		baud_rate => sim_baud_rate
	)
	port map (
		clk_i => clk,
		rst_i => rst,
		rs232_tx_o => rs232_tx,
		fub_str_i => fub_rs232_str,
		fub_busy_o => fub_rs232_busy,
		fub_data_i => fub_rs232_data
	);		
		

  clk <= not clk after 0.5 * freq_real_to_period_time(clk_freq_in_hz);
  rst <= '1', '0' after 20 ns;


end architecture fib_registerfile_top_tb_arch;