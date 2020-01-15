--
-- VHDL-Template for FIB-FPGA - starting point for all FIB applications
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

use work.reset_gen_pkg.all;
use work.id_info_pkg.all;
use work.fub_token_ring_access_pkg.all;
use work.fub_mls_rx_pkg.all;
use work.fub_mls_tx_pkg.all;
use work.fub_rs232_rx_pkg.all;
use work.fub_rs232_tx_pkg.all;
use work.input_sync_pkg.all;
use work.fub_two_clk_sync_pkg.all;

entity token_ring_ap6 is
	generic(
		clk_freq_in_hz 			: real := 80.0E6;
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
--		piggy_io0		: out std_logic;
--		piggy_io1		: out std_logic;
--		piggy_io2		: out std_logic;
--		piggy_io3		: out std_logic;	---------
--		piggy_io4		: in std_logic;	---------
--		piggy_io5		: out std_logic;	---------
--		piggy_io6		: in std_logic;	---------
--		piggy_io7		: out std_logic;
				
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
end entity token_ring_ap6;

architecture token_ring_ap6_arch of token_ring_ap6 is

component pll1
	port
	(
		inclk0		: IN STD_LOGIC  := '0';
		c0		: OUT STD_LOGIC ;
		c1		: OUT STD_LOGIC ;
		locked		: OUT STD_LOGIC 
	);
end component;

component jumper_decision

port (	
		-----------------------------------
		clk_i			: in std_logic ;
		rst_i			: in std_logic ;
		-----------------------------------|| JUMPER INPUT
		jump0_i			: in std_logic;
		jump1_i			: in std_logic;
		jump2_i			: in std_logic;
		jump3_i			: in std_logic;
		jump4_i			: in std_logic;
		jump5_i			: in std_logic;
		jump6_i			: in std_logic;
		jump7_i			: in std_logic;
		-----------------------------------
		master_o		: out integer;
		target_adr_o	: out std_logic_vector(7 downto 0);
		local_adr_o		: out std_logic_vector(7 downto 0);
		-----------------------------------|| DATA FROM AP
		fub_data_i		: in std_logic_vector(7 downto 0);
		fub_adr_i		: in std_logic_vector(7 downto 0);
		fub_str_i		: in std_logic;
		fub_busy_o		: out std_logic;
		-----------------------------------|| DATA TO AP
		fub_data_o		: out std_logic_vector(7 downto 0);
		fub_adr_o		: out std_logic_vector(7 downto 0);
		fub_str_o		: out std_logic;
		fub_busy_i		: in std_logic;
		-----------------------------------|| DATA FROM MLS
		mls_tx_fub_data_i	: in std_logic_vector(7 downto 0);
		mls_tx_fub_adr_i	: in std_logic_vector(7 downto 0);
		mls_tx_fub_str_i	: in std_logic;
		mls_tx_fub_busy_o	: out std_logic;
		-----------------------------------|| DATA TO MLS
		mls_rx_fub_data_o	: out std_logic_vector(7 downto 0);
		mls_rx_fub_adr_o	: out std_logic_vector(7 downto 0);
		mls_rx_fub_str_o	: out std_logic;
		mls_rx_fub_busy_i	: in std_logic;
		-----------------------------------|| DATA FROM RS232
		rs232_rx_fub_data_i	: in std_logic_vector(7 downto 0);
		rs232_rx_fub_adr_i	: in std_logic_vector(7 downto 0);
		rs232_rx_fub_str_i	: in std_logic;
		rs232_rx_fub_busy_o	: out std_logic;
		-----------------------------------|| DATA TO RS232
		rs232_tx_fub_data_o	: out std_logic_vector(7 downto 0);
		rs232_tx_fub_adr_o	: out std_logic_vector(7 downto 0);
		rs232_tx_fub_str_o	: out std_logic;
		rs232_tx_fub_busy_i	: in std_logic
	 );
	
end component ;


	-- common signals
	signal clk: std_logic;
	signal rst: std_logic;

	signal clk100 		: std_logic;
	signal clk250		: std_logic;

	-- LED signals
	signal led_id_inf_i: std_logic_vector(3 downto 0);
	signal led_id_inf_o: std_logic_vector(3 downto 0);

	signal opt1_rx_sync1		: std_logic;
	signal opt1_rx_sync2		: std_logic;
	
	signal rs232_rx_i_sync1		: std_logic;
	signal rs232_rx_i_sync2		: std_logic;
	
	signal jumper_decision_fub_data_o		: std_logic_vector(7 downto 0);
	signal jumper_decision_fub_adr_o		: std_logic_vector(7 downto 0);
	signal jumper_decision_fub_str_o		: std_logic;
	signal ap1_fub_busy_o					: std_logic;	
	
	
	signal fub_mls_tx1_fub_data_o				: std_logic_vector(7 downto 0);
	signal fub_mls_tx1_fub_adr_o				: std_logic_vector(7 downto 0);
	signal fub_mls_tx1_fub_str_o				: std_logic;
	signal jumper_decision_mls_tx_fub_busy_o	: std_logic;
	
	signal ap1_fub_data_o				: std_logic_vector(7 downto 0);	
	signal ap1_fub_adr_o				: std_logic_vector(7 downto 0);	
	signal ap1_fub_str_o				: std_logic;
	signal fub_two_clk_sync1_fub_busy_o	: std_logic;
	
	signal fub_two_clk_sync1_fub_str_o	: std_logic;
	signal fub_two_clk_sync1_fub_data_o	: std_logic_vector(7 downto 0);
	signal fub_two_clk_sync1_fub_adr_o	: std_logic_vector(7 downto 0);	
	signal jumper_decision_fub_busy_o	: std_logic;
	
	signal fub_mls_rx1_fub_busy_o				: std_logic;
	signal jumper_decision_mls_rx_fub_data_o	: std_logic_vector(7 downto 0);
	signal jumper_decision_mls_rx_fub_adr_o		: std_logic_vector(7 downto 0);
	signal jumper_decision_mls_rx_fub_str_o		: std_logic;
	
	signal fub_rs232_tx_fub_busy_o				: std_logic;
	signal jumper_decision_rs232_tx_fub_data_o	: std_logic_vector(7 downto 0);
	signal jumper_decision_rs232_tx_fub_str_o	: std_logic;
	
	signal fub_rs232_rx_fub_str_o				: std_logic;
	signal fub_rs232_rx_fub_data_o				: std_logic_vector(7 downto 0);
	signal jumper_decision_rs232_rx_fub_busy_o	: std_logic;
	
	signal jumper_decision_local_adr_o		: std_logic_vector(7 downto 0);
	signal jumper_decision_target_adr_o		: std_logic_vector(7 downto 0);
	signal jumper_decision_master_o			: integer;
	
	signal DSP_D_R0_sync		: std_logic;
	signal DSP_D_R1_sync		: std_logic;
	signal DSP_D_R2_sync		: std_logic;
	signal DSP_D_R3_sync		: std_logic;
	signal DSP_D_R4_sync		: std_logic;
	signal DSP_D_R5_sync		: std_logic;
	signal DSP_D_R6_sync		: std_logic;
	signal DSP_D_R7_sync		: std_logic;
	
	signal rst_intern			: std_logic;
	
	
  begin

	reset_gen_inst: reset_gen
	generic map(
		reset_clks => 2
	)
	port map (
		clk_i => clk100,
		rst_o => rst_intern
	);
	
	rst 	<= rst_intern or (not trig1_in);
	
	id_info_inst: id_info
	generic map (
		clk_freq_in_hz     => 80.0E6,
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
		
	pll1_inst : pll1
	port map(
		inclk0		=> clk,
		c0			=> clk100,
		c1			=> clk250,
		locked		=> open 
	);	
	
	input_sync_inst_for_DSP_D_R0 : input_sync
	port map(  
			clk_i	=> clk100,
			rst_i	=> rst,
			data_i	=> DSP_D_R0,			
			data_o 	=> DSP_D_R0_sync
		 );
		
	input_sync_inst_for_DSP_D_R1 : input_sync
	port map(  
			clk_i	=> clk100,
			rst_i	=> rst,
			data_i	=> DSP_D_R1,			
			data_o 	=> DSP_D_R1_sync
		 );
	
	input_sync_inst_for_DSP_D_R2 : input_sync
	port map(  
			clk_i	=> clk100,
			rst_i	=> rst,
			data_i	=> DSP_D_R2,			
			data_o 	=> DSP_D_R2_sync
		 );
		
	input_sync_inst_for_DSP_D_R3 : input_sync
	port map(  
			clk_i	=> clk100,
			rst_i	=> rst,
			data_i	=> DSP_D_R3,			
			data_o 	=> DSP_D_R3_sync
		 );
	
	input_sync_inst_for_DSP_D_R4 : input_sync
	port map(  
			clk_i	=> clk100,
			rst_i	=> rst,
			data_i	=> DSP_D_R4,			
			data_o 	=> DSP_D_R4_sync
		 );
	input_sync_inst_for_DSP_D_R5 : input_sync
	port map(  
			clk_i	=> clk100,
			rst_i	=> rst,
			data_i	=> DSP_D_R5,			
			data_o 	=> DSP_D_R5_sync
		 );
	input_sync_inst_for_DSP_D_R6 : input_sync
	port map(  
			clk_i	=> clk100,
			rst_i	=> rst,
			data_i	=> DSP_D_R6,			
			data_o 	=> DSP_D_R6_sync
		 );
	
	input_sync_inst_for_DSP_D_R7 : input_sync
	port map(  
			clk_i	=> clk100,
			rst_i	=> rst,
			data_i	=> DSP_D_R7,			
			data_o 	=> DSP_D_R7_sync
		 );
		
	fub_mls_tx_inst_for_ap1 : fub_mls_tx
	port map(  
		clk_i			=> clk100,
		rst_i			=> rst,
		fub_busy_i		=> jumper_decision_mls_tx_fub_busy_o,
		fub_data_o		=> fub_mls_tx1_fub_data_o,
		fub_adr_o		=> fub_mls_tx1_fub_adr_o,
		fub_str_o 		=> fub_mls_tx1_fub_str_o
	 );
	
	input_sync_inst1 : input_sync
	port map(  
			clk_i	=> clk250,
			rst_i	=> rst,
			data_i	=> opt1_rx,
			data_o 	=> opt1_rx_sync1
		 );

	input_sync_inst2 : input_sync
	port map(  
			clk_i	=> clk250,
			rst_i	=> rst,
			data_i	=> opt1_rx_sync1,
			data_o 	=> opt1_rx_sync2
		 );
	
	fub_token_ring_access_inst1 : fub_token_ring_access
	generic map	(
				bitSize_input		=> 8,
				bitSize_output		=> 8,
				adr_bitSize_input	=> 8,
				use_adr_input		=> 1,
				adr_bitSize_output	=> 8,
				use_adr_output		=> 1
				)		
	port map(	
				-------------------------------------------------------
				target_adr			=> jumper_decision_target_adr_o,
				local_adr			=> jumper_decision_local_adr_o,
				master				=> jumper_decision_master_o,		--|| one access has to be master <= 1 
				-------------------------------------------------------
				rst_i			=> rst,
				clk100_i		=> clk100,
				clk250_i		=> clk250,
				data_i			=> opt1_rx_sync2,
				data_o			=> opt1_tx,
				observer_data	=> Testpin_J60,	-------------------------
				fub_data_i			=> jumper_decision_fub_data_o,
				fub_busy_o			=> ap1_fub_busy_o,
				fub_str_i			=> jumper_decision_fub_str_o,
				fub_adr_i			=> jumper_decision_fub_adr_o,
				block_transfer_i	=> '0',
				fub_data_o		=> ap1_fub_data_o,
				fub_str_o		=> ap1_fub_str_o,
				fub_adr_o		=> ap1_fub_adr_o,
				fub_busy_i		=> fub_two_clk_sync1_fub_busy_o
			);
				
	jumper_decision_inst : jumper_decision
	port map	(	
				-----------------------------------
				clk_i			=> clk100,
				rst_i			=> rst,
				-----------------------------------|| JUMPER INPUT
				jump0_i			=> (DSP_D_R0_sync),
				jump1_i			=> (DSP_D_R1_sync),
				jump2_i			=> (DSP_D_R2_sync),
				jump3_i			=> (DSP_D_R3_sync),
				jump4_i			=> (DSP_D_R4_sync),
				jump5_i			=> (DSP_D_R5_sync),
				jump6_i			=> (DSP_D_R6_sync),
				jump7_i			=> (DSP_D_R7_sync),
				-----------------------------------
				master_o		=> jumper_decision_master_o,
				target_adr_o	=> jumper_decision_target_adr_o,
				local_adr_o		=> jumper_decision_local_adr_o,
				-----------------------------------|| DATA FROM AP
				fub_data_i		=> fub_two_clk_sync1_fub_data_o,
				fub_adr_i		=> fub_two_clk_sync1_fub_adr_o,
				fub_str_i		=> fub_two_clk_sync1_fub_str_o,
				fub_busy_o		=> jumper_decision_fub_busy_o,
				-----------------------------------|| DATA TO AP
				fub_data_o		=> jumper_decision_fub_data_o,
				fub_adr_o		=> jumper_decision_fub_adr_o,
				fub_str_o		=> jumper_decision_fub_str_o,
				fub_busy_i		=> ap1_fub_busy_o,
				-----------------------------------|| DATA FROM MLS
				mls_tx_fub_data_i	=> fub_mls_tx1_fub_data_o,
				mls_tx_fub_adr_i	=> fub_mls_tx1_fub_adr_o,
				mls_tx_fub_str_i	=> fub_mls_tx1_fub_str_o,
				mls_tx_fub_busy_o	=> jumper_decision_mls_tx_fub_busy_o,
				-----------------------------------|| DATA TO MLS
				mls_rx_fub_data_o	=> jumper_decision_mls_rx_fub_data_o,
				mls_rx_fub_adr_o	=> jumper_decision_mls_rx_fub_adr_o,
				mls_rx_fub_str_o	=> jumper_decision_mls_rx_fub_str_o,
				mls_rx_fub_busy_i	=> fub_mls_rx1_fub_busy_o,
				-----------------------------------|| DATA FROM RS232
				rs232_rx_fub_data_i	=> fub_rs232_rx_fub_data_o,
				rs232_rx_fub_adr_i	=> "00000000",
				rs232_rx_fub_str_i	=> fub_rs232_rx_fub_str_o,
				rs232_rx_fub_busy_o	=> jumper_decision_rs232_rx_fub_busy_o,
				-----------------------------------|| DATA TO RS232
				rs232_tx_fub_data_o	=> jumper_decision_rs232_tx_fub_data_o,
				rs232_tx_fub_adr_o	=> open,
				rs232_tx_fub_str_o	=> jumper_decision_rs232_tx_fub_str_o,
				rs232_tx_fub_busy_i	=> fub_rs232_tx_fub_busy_o
			 );	
				
	fub_two_clk_sync_inst_for_ap1 : fub_two_clk_sync
	generic map(	
				bitSize		=> 8,
				adrSize		=> 8
			)
	port map(	
			rst_i			=> rst,
			clk_input_i		=> clk250,
			clk_output_i	=> clk100,
			fub_str_i		=> ap1_fub_str_o,
			fub_data_i		=> ap1_fub_data_o,
			fub_adr_i		=> ap1_fub_adr_o,
			fub_busy_i		=> jumper_decision_fub_busy_o,
			fub_str_o		=> fub_two_clk_sync1_fub_str_o,
			fub_busy_o		=> fub_two_clk_sync1_fub_busy_o,
			fub_data_o		=> fub_two_clk_sync1_fub_data_o,
			fub_adr_o		=> fub_two_clk_sync1_fub_adr_o
		);
	
	fub_mls_rx_inst_for_ap_1 : fub_mls_rx
	generic map	(
					use_adr	=> '1'
				)
	port map(  
		clk_i				=> clk100,
		rst_i				=> rst,
		fub_busy_o			=> fub_mls_rx1_fub_busy_o,
		fub_data_i			=> jumper_decision_mls_rx_fub_data_o,
		fub_adr_i			=> jumper_decision_mls_rx_fub_adr_o,
		fub_str_i 			=> jumper_decision_mls_rx_fub_str_o,
		failure_vector_o	=> piggy_io,
		failure_o			=> led_id_inf_i(2),
		failure_overflow_o	=> led_id_inf_i(1),
		locked_o			=> led_id_inf_i(0)
	 );
	
	fub_rs232_tx_inst : fub_rs232_tx
	generic map	(
	    clk_freq_in_hz => 80.0E6,
	    baud_rate      => 9600.0
	   			 )
	port map(
	    clk_i      => clk100,
	    rst_i      => rst,
	    rs232_tx_o => rs232_tx_o,
	    fub_str_i  => jumper_decision_rs232_tx_fub_str_o,
	    fub_busy_o => fub_rs232_tx_fub_busy_o,
	    fub_data_i => jumper_decision_rs232_tx_fub_data_o
	    	);
	
	input_sync_inst3 : input_sync
	port map(  
			clk_i	=> clk100,
			rst_i	=> rst,
			data_i	=> rs232_rx_i,
			data_o 	=> rs232_rx_i_sync1
		 );
		
	input_sync_inst4 : input_sync
	port map(  
			clk_i	=> clk100,
			rst_i	=> rst,
			data_i	=> rs232_rx_i_sync1,
			data_o 	=> rs232_rx_i_sync2
		 );
	
	fub_rs232_rx_inst : fub_rs232_rx
	generic map	(
			clk_freq_in_hz 	=> 80.0E6,
			baud_rate  		=> 9600.0
				)
	port map(
				clk_i			=> clk100,
				rst_i			=> rst,
				rs232_rx_i		=> (not rs232_rx_i_sync2),
				fub_str_o		=> fub_rs232_rx_fub_str_o,
				fub_busy_i		=> jumper_decision_rs232_rx_fub_busy_o,
				fub_data_o		=> fub_rs232_rx_fub_data_o,
				receive_error  	=> open
			);


	clk 			<= clk0;
	
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
	
	

end architecture token_ring_ap6_arch;