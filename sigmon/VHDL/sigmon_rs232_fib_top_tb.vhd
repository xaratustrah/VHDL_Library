library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.math_real.all;

use work.real_time_calculator_pkg.all;
use work.fub_rs232_tx_pkg.all;

entity sigmon_rs232_fib_top_tb is
	generic (
		clk_freq_in_hz          : real := 100.0E6;  --50 MHz system clock frequency
		fib_clk_freq_in_hz          : real := 50.0E6;  --100 MHz system clock frequency
		rst_clks: integer := 2;
		baud_rate    : real := 10.0E6 --higher speed for simulation
	);
end entity;

architecture sigmon_rs232_fib_top_tb_arch of sigmon_rs232_fib_top_tb is

component sigmon_rs232_fib_top
	generic(
		clk_freq_in_hz          : real;
		baud_rate       : real; 
		data_width : integer
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
	end component;


signal clk,clk0,rst: std_logic := '0';
signal data_bus : std_logic_vector(15 downto 0) := (others => '0');
signal rs232_rx : std_logic;
signal nrs232_rx : std_logic;

signal fub_rx_str : std_logic;
signal fub_rx_busy : std_logic;
signal fub_rx_data : std_logic_vector(7 downto 0);

begin
    
  clk <= not clk after 0.5 * freq_real_to_period_time(clk_freq_in_hz);
  clk0 <= not clk0 after 0.5 * freq_real_to_period_time(fib_clk_freq_in_hz);
  
	nrs232_rx <= not rs232_rx;

	sigmon_rs232_fib_top_inst: sigmon_rs232_fib_top
	generic map (
		clk_freq_in_hz => clk_freq_in_hz,
		baud_rate      => baud_rate,
		data_width     => 16
	)
	port map (
		--common signals
		trig1_in => '1',  --for external reset
		trig2_out => open,
		clk0 => clk0,
		hf_in => '0',

		--dds signals
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
 	  rs232_rx_i => nrs232_rx,
		rs232_tx_o =>	open,
		
	  uC_Link_D => data_bus (7 downto 0),
	  uC_Link_A => data_bus (15 downto 8)
		
	);

  fub_rs232_tx_inst : fub_rs232_tx
	generic map(
 		clk_freq_in_hz => clk_freq_in_hz,
	  baud_rate => baud_rate
	)
	port map (
		clk_i => clk,
		rst_i => rst,
		rs232_tx_o => rs232_rx,
		fub_str_i => fub_rx_str,
		fub_busy_o => fub_rx_busy,
		fub_data_i => fub_rx_data
	);
		

	rst <= '1','0' after 50 ns;

	process
  begin
    loop
      fub_rx_str <= '0';
      --wait on rst='0'
      wait on rst until rst='0';
      loop
        if fub_rx_busy = '0' then
          fub_rx_str <= '1';
          fub_rx_data <= x"03"; --single shot command
          exit;
        end if;
      end loop;
      wait on clk until clk='1';
      fub_rx_str <= '0';
      wait for 1 ms;
    end loop;
	end process;
	
end architecture sigmon_rs232_fib_top_tb_arch;