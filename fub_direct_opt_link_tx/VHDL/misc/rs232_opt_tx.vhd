
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

use work.reset_gen_pkg.all;
use work.id_info_pkg.all;
use work.fub_rs232_rx_pkg.all;
use work.input_sync_pkg.all;
use work.fub_direct_opt_link_tx_pkg.all;

entity rs232_opt_tx is
	generic(
		clk_freq_in_hz 			: real := 50.0E6;
		firmware_id             : integer := 1;         --ID of the firmware (is displayed first)
		firmware_version        : integer := 3          --Version of the firmware (is displayed after)
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
	
end entity rs232_opt_tx;

architecture rs232_opt_tx_arch of rs232_opt_tx is

component pll1
	PORT
	(
		inclk0		: IN STD_LOGIC  := '0';
		c0			: OUT STD_LOGIC ;
		locked		: OUT STD_LOGIC 
	);
END component;


	-- common signals
	signal clk: std_logic;
	signal rst: std_logic;

	-- LED signals
	signal led_id_inf_i: std_logic_vector(3 downto 0);
	signal led_id_inf_o: std_logic_vector(3 downto 0);
	
	signal clk100				: std_logic;
	
	signal rs232_rx_i_sync		: std_logic;
	
	signal fub_rs232_rx_fub_str_o		: std_logic;
	signal fub_rs232_rx_fub_data_o		: std_logic_vector(7 downto 0);
	
	signal fub_direct_opt_link_tx_fub_busy_o		: std_logic;

  begin

	clk <= clk0;
	
	reset_gen_inst: reset_gen
	generic map(
		reset_clks => 2
	)
	port map (
		clk_i => clk0,
		rst_o => rst
	);
	
	pll1_inst : pll1
	port map (
		inclk0		=> clk,
		c0			=> clk100,
		locked		=> led_id_inf_i(0)
	);
	
	id_info_inst: id_info
	generic map (
		clk_freq_in_hz     => 100.0E6,
		display_time_in_ms => 1.0,
		firmware_id        => firmware_id,   
		firmware_version   => firmware_version,   
		led_cnt            => 4    
	)
	port map (
		clk_i => clk100,
		rst_i => rst,
		led_i => led_id_inf_i,
		led_o => led_id_inf_o
	);
	
	input_sync_inst : input_sync
	port map(  
		clk_i	=> clk100,
		rst_i	=> rst,
		data_i	=> rs232_rx_i,
		data_o 	=> rs232_rx_i_sync
	 );
	
	fub_rs232_rx_inst : fub_rs232_rx
	generic map(
			clk_freq_in_hz 	=> 100.0E6,
			baud_rate  		=> 9600.0
	)
	port map(
		clk_i					=> clk100,
		rst_i					=> rst,
		rs232_rx_i				=> (not rs232_rx_i_sync),
		fub_str_o				=> fub_rs232_rx_fub_str_o,
		fub_busy_i				=> fub_direct_opt_link_tx_fub_busy_o,
		fub_data_o				=> fub_rs232_rx_fub_data_o,
		receive_error 			=> open
	);
	
	fub_direct_opt_link_tx_inst : fub_direct_opt_link_tx
	generic map( 	
				bitSize		=> 8,
				adr_bitSize	=> 0,
				use_adr		=> 0		-- if use_adr <= 0 choose adr_bitSize = 0
			) 
	port map(	
			clk_i			=> clk100,
			rst_i			=> rst,
			fub_data_i		=> fub_rs232_rx_fub_data_o,
			fub_adr_i		=> "0",
			fub_str_i		=> fub_rs232_rx_fub_str_o,
			fub_busy_o		=> fub_direct_opt_link_tx_fub_busy_o,
			opt_data_o		=> opt1_tx
		 ) ;
	

	--led signal mapping
	led4 <= led_id_inf_o(0);
	led3 <= led_id_inf_o(1);
	led2 <= led_id_inf_o(2);
	led1 <= led_id_inf_o(3);

--	led_id_inf_i <= "0101"; --connect any LED meaning to this vector

	--static backplane buffer settings
	BBA_DIR <= '0';
	BBB_DIR <= '0';
	BBC_DIR <= '0';
	BBD_DIR <= '0';
	BBE_DIR <= '0';
	BBG_DIR <= '0';
	BBH_DIR <= '0';
	nBB_EN <= '1'; --backplane buffers switched off!

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

	uC_Link_DIR_D <= '1'; --DIR: '1'=from FPGA (A->B side),'0'=to FPGA (B->A side)
	uC_Link_DIR_A <= '1'; --DIR: '1'=from FPGA (A->B side),'0'=to FPGA (B->A side)
	nuC_Link_EN_CTRL_A <= '1'; --EN: '1'=disabled, '0'=enabled
	uC_Link_EN_DA <= '1'; --EN: '1'=disabled, '0'=enabled !!
	
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
	DSP_DIR_D <= '1'; --DIR: '1'=to FPGA, '0'=from FPGA
	DSP_DIR_STRACK <= '1'; --DIR: '1'=to FPGA, '0'=from FPGA
	DSP_DIR_REQRDY <= '0'; --DIR: '1'=to FPGA, '0'=from FPGA
	
	

end architecture rs232_opt_tx_arch;