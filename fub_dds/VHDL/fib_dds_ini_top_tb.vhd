--
-- Testbench for fib_dds_ini_top
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

use work.real_time_calculator_pkg.all;

entity fib_dds_ini_top_tb is
	generic (
		clk_freq_in_hz 			: real := 125.0E6;
		dds_clk_freq_in_hz : real := 200.0E6
	);
end entity;

architecture fib_dds_ini_top_tb_arch of fib_dds_ini_top_tb is

	component fib_dds_ini_top
		generic(
			clk_freq_in_hz 			: real;
			firmware_id             : integer;         --ID of the firmware (is displayed first)
			firmware_version        : integer          --Version of the firmware (is displayed after)
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

begin
    
	fib_dds_ini_top_inst: fib_dds_ini_top
	generic map (
		clk_freq_in_hz 	 => clk_freq_in_hz,
		firmware_id      => 0,
		firmware_version => 0
	)
	port map (
		--common signals
		trig1_in => '1',
    trig1_out => open,
    trig2_in => '1',
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
 	  rs232_rx_i => '0',
    rs232_tx_o =>	open,
		
	  eeprom_data => '0',
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
  clk <= not clk after 0.5 * freq_real_to_period_time(clk_freq_in_hz);


end architecture fib_dds_ini_top_tb_arch;