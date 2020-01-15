-- init rom package definition
library ieee;
use ieee.std_logic_1164.all;

package init_rom_pkg is

constant init_rom_size : integer := 40;
constant init_data_width : integer := 8;
type init_rom is array(0 to init_rom_size-1) of std_logic_vector(init_data_width-1 downto 0);

end init_rom_pkg;

package body init_rom_pkg is
end init_rom_pkg;


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

use work.reset_gen_pkg.all;
use work.id_info_pkg.all;
use work.fub_dds_pkg.all;
use work.fub_rom_tx_pkg.all;
use work.init_rom_pkg.all;

entity fib_dds_ini_top is
	generic(
		clk_freq_in_hz 			: real := 125.0E6;
		dds_clk_freq_in_hz : real := 200.0E6;
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
end entity fib_dds_ini_top;

architecture arch_fib_dds_ini_top of fib_dds_ini_top is

	-- common signals
	signal clk: std_logic;
	signal clk125,clk200: std_logic;
	signal rst,power_on_rst: std_logic;

	-- LED signals
	signal led_id_inf_i: std_logic_vector(3 downto 0);
	signal led_id_inf_o: std_logic_vector(3 downto 0);

  signal fub_data   : std_logic_vector(7 downto 0);
  signal fub_addr   : std_logic_vector(5 downto 0);
  signal fub_str    : std_logic;
  signal fub_busy   : std_logic;

  signal dds_rst    : std_logic;
  signal dds_data   : std_logic_vector(7 downto 0);
  signal dds_addr   : std_logic_vector(5 downto 0);
  signal dds_nwr    : std_logic;
  signal dds_update : std_logic;
  signal dds_fsk    : std_logic;
  signal dds_sh_key : std_logic;
  signal dds_clk : std_logic;
  

	constant init_data : init_rom := (
		"00010000", --00h phase adjust 1 (msb)
		"00000000", --01h phase adjust 1 (lsb)
		"00000000", --02h phase adjust 2 (msb)
		"00000000", --03h phase adjust 2 (lsb)
		-- ftw=2^32/fclk*f, fclk=20MHz, f=1MHz  -> ftw=0CCCCCCC0000
		-- ftw=2^48/fclk*f, fclk=50MHz, f=1MHz  -> ftw=051EB851EB85
		-- ftw=2^32/fclk*f, fclk=200MHz, f=1MHz -> ftw=0147AE140000
		conv_std_logic_vector(16#05#,8), --04h frequency tuning word 1 (msb)
		conv_std_logic_vector(16#1E#,8), --05h frequency tuning word 1
		conv_std_logic_vector(16#B8#,8), --06h frequency tuning word 1
		conv_std_logic_vector(16#51#,8), --07h frequency tuning word 1
		conv_std_logic_vector(16#EB#,8), --08h frequency tuning word 1
		conv_std_logic_vector(16#85#,8), --09h frequency tuning word 1 (lsb)
		"00000000",	--0ah frequency tuning word 2 (msb)
		"00000000",	--0bh frequency tuning word 3
		"00000000",	--0ch frequency tuning word 4
		"00000000",	--0dh frequency tuning word 5
		"00000000",	--0eh frequency tuning word 6
		"00000000",	--0fh frequency tuning word 7 (lsb)
		"00000000",	--10h delta frequency word (msb)
		"00000000",	--11h delta frequency word
		"00000000",	--12h delta frequency word
		"00000000",	--13h delta frequency word
		"00000000",	--14h delta frequency word
		"00000000",	--15h delta frequency word (lsb)
		"00000000",	--16h update clock (msb)
		"00000000",	--17h update clock
		"00000000",	--18h update clock
		"00000000",	--19h update clock (lsb)
		"00000000",	--1ah ramp rate clock (msb)
		"00000000",	--1bh ramp rate clock
		"00000000",	--1ch ramp rate clock (lsb)
		--"00010000", --1dh Comp-PD
		"00000000",	--1dh Comp ON
		"00100001",	--1eh PLL-Bypass on, PLL-Multiplier=4
		"00000000",	--1fh External Update, mode 0
		"01000000", --20h Bypass Inv Sinc
		"00000000",	--21h output shape key I mult (msb)
		"00000000",	--22h output shape key I mult (lsb)
		"00001000",	--23h output shape key Q mult (msb)
		"00000000",	--24h output shape key Q mult (lsb)
		"00000000",	--25h output shape key ramp rate
		"00000000",	--26h qdac (msb)
		"00000000" --27h qdac (lsb)
	);

	component pll0
	port
	(
		inclk0		: IN STD_LOGIC  := '0';
		c0		: OUT STD_LOGIC ;
		c1		: OUT STD_LOGIC ;
		locked		: OUT STD_LOGIC 
	);
	end component;

  begin

	reset_gen_inst: reset_gen
	generic map(
		reset_clks => 10
	)
	port map (
		clk_i => clk0,
		rst_o => power_on_rst
	);
	
	pll0_inst : pll0
	port map
	(
		inclk0	=> clk0,
		c0		  => clk125,
		c1		  => clk200,
		locked	=> led_id_inf_i(0)
	);
	
	id_info_inst: id_info
	generic map (
		clk_freq_in_hz     => clk_freq_in_hz,
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
	
	fub_dds_inst : fub_dds
	generic map (
		clk_freq_in_hz     => clk_freq_in_hz,
		dds_clk_freq_in_hz => dds_clk_freq_in_hz,
		fub_addr_width     => 6,
		update_adr         => 16#27#
	)
	port map(
		rst_i         => rst,
		clk_i         => clk,
		-- FUB ---    
		fub_data_i    => fub_data,
		fub_addr_i    => fub_addr,
		fub_str_i     => fub_str,
		fub_busy_o    => fub_busy,
		-- DDS ---
		dds_rst_o     => dds_rst,
		dds_data_o    => dds_data,
		dds_addr_o    => dds_addr,
		dds_nwr_o     => dds_nwr,
		dds_update_io => dds_update
	);
			
  init_rom_tx : fub_rom_tx
  generic map(
		wait_clks     => 0,
		addr_width    => 6,
		endless_loop  => false
	)
	port map(
		rst_i       => rst,
		clk_i       => clk,
		init_data_i => init_data,
		fub_data_o  => fub_data,
		fub_addr_o  => fub_addr,
		fub_str_o   => fub_str,
		fub_busy_i  => fub_busy
  );
	
	clk <= clk125;
  dds_clk <= clk200;

	led_id_inf_i(1) <= '0';
	led_id_inf_i(2) <= '1';
	led_id_inf_i(3) <= '1';

  rst <= power_on_rst or not trig1_in;

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
	uC_Link_EN_DA <= '0'; --EN: '1'=disabled, '0'=enabled !!
	
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
	
	--dds signal mapping
	uC_Link_D <= dds_data;
	uC_Link_A(5 downto 0) <= dds_addr;
	uC_Link_A(7 downto 6) <= (others => '0');
	
	Piggy_RnW1 <= dds_nwr;
	Piggy_Strb2 <= dds_rst;
	Piggy_Strb1 <= dds_update;
	Piggy_Ack1 <= dds_fsk;
	Piggy_Ack2 <= dds_sh_key;
  Piggy_Clk1 <= dds_clk;
	
	--static dds settings
	dds_fsk <= '0';
	dds_sh_key <= '0';
 
end architecture arch_fib_dds_ini_top;
  
  
  
  
  
  
  