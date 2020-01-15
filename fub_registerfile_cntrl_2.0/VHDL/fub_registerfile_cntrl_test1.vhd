library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use work.fub_registerfile_cntrl_pkg.all;
use work.fub_rx_slave_pkg.all;
use work.fub_tx_slave_pkg.all;
use work.fub_tx_master_pkg.all;
use work.reset_gen_pkg.all;
use work.fub_seq_demux_pkg.all;
use work.fub_flash_pkg.all;
use work.fub_multi_spi_master_pkg.all;
use work.flash_tb_pkg.all;


entity fub_registerfile_cntrl_test1 is
	generic (
		rst_clk					:	integer		:=	150;
		adr_width               :	integer := 16;
		data_width              :	integer := 8;
		default_start_adr       :	integer := 16#0000#; 
		default_end_adr         :	integer := 16#0003#; 
		reg_adr_cmd             :	integer := 16#fff0#;
		reg_adr_start_adr_high  :	integer := 16#fff1#;
		reg_adr_start_adr_low   :	integer := 16#fff2#;
		reg_adr_end_adr_high    :	integer := 16#fff3#;
		reg_adr_end_adr_low     :	integer := 16#fff4#;
		reg_adr_firmware_id     :	integer := 16#fff5#;
		reg_adr_firmware_version:	integer := 16#fff6#;
		reg_adr_firmware_config :	integer := 16#fff7#;
		mask_adr                :	integer := 16#ffff#;
		firmware_id             :	integer := 0;
		firmware_version        :	integer := 0;
		firmware_config         :	integer := 0;
		boot_from_flash         :	boolean := true;
		data_start_value		:	integer := 16#10#;
		data_stop_value			:	integer := 16#60#;
		data_inc_value			:	integer := 16#1#;
		busy_clks				:	integer := 0;
		adr_inc_value   		:	integer := 16#1#;
		wait_clks        		:	integer := 0;
		timeout_in_us   		: real    :=	1.0E3  -- delay in us, 1.0E3 = 1ms
    );
end fub_registerfile_cntrl_test1;

architecture struct_arch of fub_registerfile_cntrl_test1 is
	
	-- Signals
	signal	rst					:	std_logic;
	signal	clk					:	std_logic	:=	'0';
	-- cfg in
    signal	fub_cfg_reg_in_data     :	std_logic_vector (data_width-1 downto 0);
    signal	fub_cfg_reg_in_adr		:	std_logic_vector (adr_width-1 downto 0);
    signal	fub_cfg_reg_in_str		:	std_logic;
    signal	fub_cfg_reg_in_busy     :	std_logic;
    -- cfg out
    signal	fub_cfg_reg_out_str     :	std_logic;
    signal	fub_cfg_reg_out_data    :	std_logic_vector (data_width-1 downto 0);
    signal	fub_cfg_reg_out_adr     :	std_logic_vector (adr_width-1 downto 0);
    signal	fub_cfg_reg_out_busy    :	std_logic;
    -- flash in
    signal	fub_fr_busy             :	std_logic	:=	'0';
    signal	fub_fr_data             :	std_logic_vector (data_width-1 downto 0);
    signal	fub_fr_str              :	std_logic;
    signal	fub_fr_adr              :	std_logic_vector(adr_width-1 downto 0);
    -- flash out
    signal	fub_fw_str              :	std_logic;
    signal	fub_fw_busy             :	std_logic;
    signal	fub_fw_data             :	std_logic_vector (data_width-1 downto 0);
    signal	fub_fw_adr              :	std_logic_vector(adr_width-1 downto 0);
    -- FUB out
    signal	fub_out_data            :	std_logic_vector(data_width-1 downto 0);
    signal	fub_out_adr             :	std_logic_vector(adr_width-1 downto 0);
    signal	fub_out_str             :	std_logic;
    signal	fub_out_busy            :	std_logic;
    -- RAM out
	signal	fub_ram_out_adr			:	std_logic_vector (adr_width-1 downto 0);
    signal	fub_ram_out_data		:	std_logic_vector (data_width-1 downto 0);
    signal	fub_ram_out_str			:	std_logic;
    signal	fub_ram_out_busy		:	std_logic;
    -- RAM in
    signal	fub_ram_in_adr			:	std_logic_vector(adr_width-1 downto 0);
    signal	fub_ram_in_data			:	std_logic_vector(data_width-1 downto 0);
    signal	fub_ram_in_str			:	std_logic;
    signal	fub_ram_in_busy			:	std_logic;
		
		signal	fub_in_busy	:	std_logic;
		signal  fub_in_data	:	std_logic_vector(data_width-1 downto 0);
		signal  fub_in_str	:	std_logic;
		
		signal	fub_write_addr_intern	:	std_logic_vector(23 downto 0);
		signal	fub_read_addr_intern	:	std_logic_vector(23 downto 0);
		
	signal	cnt						:	integer range 36 downto 0;
    				
		signal	spi_mosi	:	std_logic;
		signal  spi_miso	:	std_logic	:= '0';
		signal  spi_clk		:	std_logic;
		signal  spi_ss		:	std_logic_vector(8 downto 0);
						
		signal	nCS	:	std_logic;
		
    begin
	
		clk <=	not clk after 10 ns;
		
		reset_gen_inst	:	reset_gen		
		generic map(
			reset_clks	=>	rst_clk
		)
		port map(
			clk_i	=>	clk,
			rst_o	=>	rst
		);
		
		cntrl_inst	:	fub_registerfile_cntrl
		generic map(
			adr_width					=>	adr_width,
			data_width					=>	data_width,
			default_start_adr			=>	default_start_adr, 
			default_end_adr				=>	default_end_adr,
			reg_adr_cmd					=>	reg_adr_cmd,
			reg_adr_start_adr_high		=>	reg_adr_start_adr_high,
			reg_adr_start_adr_low		=>	reg_adr_start_adr_low,
			reg_adr_end_adr_high		=>	reg_adr_end_adr_high,
			reg_adr_end_adr_low			=>	reg_adr_end_adr_low,
			reg_adr_firmware_id			=>	reg_adr_firmware_id,
			reg_adr_firmware_version	=>	reg_adr_firmware_version,
			reg_adr_firmware_config		=>	reg_adr_firmware_config,
			mask_adr					=>	mask_adr,
			firmware_id					=>	firmware_id,
			firmware_version			=>	firmware_version,
			firmware_config				=>	firmware_config,
			boot_from_flash				=>	boot_from_flash
		)
		port map(
			rst_i					=>	rst,
			clk_i                  	=>	clk,
			fub_cfg_reg_in_dat_i	=>	fub_cfg_reg_in_data,
			fub_cfg_reg_in_adr_i	=>	fub_cfg_reg_in_adr,
			fub_cfg_reg_in_str_i	=>	fub_cfg_reg_in_str,
			fub_cfg_reg_in_busy_o	=>	fub_cfg_reg_in_busy,
			fub_cfg_reg_out_str_o	=>	fub_cfg_reg_out_str,
			fub_cfg_reg_out_dat_o	=>	fub_cfg_reg_out_data,
			fub_cfg_reg_out_adr_o	=>	fub_cfg_reg_out_adr,
			fub_cfg_reg_out_busy_i	=>	fub_cfg_reg_out_busy,
			fub_fr_busy_i			=>	fub_fr_busy,
			fub_fr_dat_i			=>	fub_fr_data,
			fub_fr_str_o			=>	fub_fr_str,
			fub_fr_adr_o			=>	fub_fr_adr,
			fub_fw_str_o			=>	fub_fw_str,
			fub_fw_busy_i			=>	fub_fw_busy,
			fub_fw_dat_o			=>	fub_fw_data,
			fub_fw_adr_o			=>	fub_fw_adr,
			fub_out_data_o			=>	fub_out_data,
			fub_out_adr_o			=>	fub_out_adr,
			fub_out_str_o			=>	fub_out_str,
			fub_out_busy_i			=>	fub_out_busy,
			-----------------------RAM----------------------------------------------
			fub_ram_out_adr_o		=>	fub_ram_out_adr,
			fub_ram_out_data_o		=>	fub_ram_out_data,
			fub_ram_out_str_o		=>	fub_ram_out_str,
			fub_ram_out_busy_i		=>	fub_ram_out_busy,
			fub_ram_in_adr_o		=>	fub_ram_in_adr,
			fub_ram_in_data_i		=>	fub_ram_in_data,
			fub_ram_in_str_o		=>	fub_ram_in_str,
			fub_ram_in_busy_i		=>	'0'--fub_ram_in_busy
		);
	
		-- ram_in_inst	:	fub_tx_slave
		-- generic map(
		  -- addr_width		=>	adr_width,
		  -- data_width		=>	data_width,
		  -- data_start_value	=>	data_start_value,
		  -- data_stop_value	=>	data_stop_value,
		  -- data_inc_value	=>	data_inc_value
		-- )
		-- port map(
		  -- fub_str_i		=>	fub_ram_in_str,
		  -- fub_busy_o	=>	fub_ram_in_busy,
		  -- fub_data_o	=>	fub_ram_in_data,
		  -- fub_addr_i	=>	fub_ram_in_adr,
		  -- rst_i			=>	rst,
		  -- clk_i			=>	clk,
		  -- data_o		=>	open,
		  -- addr_o		=>	open,
		  -- str_o			=>	open
		-- );
	
		ram_out_inst	:	fub_rx_slave
		generic map(
		  addr_width	=>	adr_width,
		  data_width	=>	data_width,
		  busy_clks		=>	busy_clks
		)
		port map(
		  rst_i			=>	rst,
		  clk_i			=>	clk,
		  fub_data_i	=>	fub_ram_out_data,
		  fub_str_i		=>	fub_ram_out_str,
		  fub_busy_o	=>	fub_ram_out_busy,
		  fub_addr_i	=>	fub_ram_out_adr,
		  data_o		=>	open,
		  addr_o		=>	open,
		  str_o			=>	open
		);
		
		-- cfg_in_inst	:	fub_tx_master
		-- generic map(
		  -- addr_width		=>	adr_width,
		  -- data_width		=>	data_width,
		  -- addr_start_value	=>	adr_start_value,
		  -- data_start_value	=>	data_start_value,
		  -- addr_stop_value	=>	adr_stop_value,
		  -- data_stop_value   =>	data_stop_value,
		  -- addr_inc_value	=>	adr_inc_value,
		  -- data_inc_value	=>	data_inc_value,
		  -- wait_clks			=>	wait_clks
		  -- )
		-- port map(
		  -- rst_i				=>	rst,
		  -- clk_i				=>	clk,
		  -- fub_str_o			=>	fub_cfg_reg_in_str,
		  -- fub_busy_i		=>	fub_cfg_reg_in_busy,
		  -- fub_addr_o		=>	fub_cfg_reg_in_adr,
		  -- fub_data_o		=>	fub_cfg_reg_in_data
		 -- );
		  
		cfg_out_inst	:	fub_rx_slave
		generic map(
		  addr_width	=>	adr_width,
		  data_width	=>	data_width,
		  busy_clks		=>	busy_clks
		)
		port map(
		  rst_i			=>	rst,
		  clk_i			=>	clk,
		  fub_data_i	=>	fub_cfg_reg_out_data,
		  fub_str_i		=>	fub_cfg_reg_out_str,
		  fub_busy_o	=>	fub_cfg_reg_out_busy,
		  fub_addr_i	=>	fub_cfg_reg_out_adr,
		  data_o		=>	open,
		  addr_o		=>	open,
		  str_o			=>	open
		);
		
		fub_flash_inst	:	fub_flash
		generic map(
			main_clk											=>	50.0E+6,
			priority_on_reading						=>	 '1',
		  my_delay_in_ns_for_reading		=>	25.0,		-- equal to 40 MHz // 25ns high 25ns low => 50ns equal to 20MHz CLK Signal
			my_delay_in_ns_for_writing		=>	20.0,		-- equal to 50 MHz // 20ns high 20ns low => 40ns equal to 25MHz CLK Signal
			erase_in_front_of_write				=>	'1'
		)										
		port map(  
			clk_i													=>	clk,
			rst_i													=>	rst,
			fub_write_busy_o							=>	fub_fw_busy,
			fub_write_data_i							=>	fub_fw_data,
			fub_write_adr_i								=>	fub_write_addr_intern,
			fub_write_str_i								=>	fub_fw_str,
			fub_read_busy_o								=>	fub_fr_busy,
			fub_read_data_o								=>	fub_fr_data,
			fub_read_adr_i								=>	fub_read_addr_intern,
			fub_read_str_i								=>	fub_fr_str,
			erase_str_i										=>	'0',
			erase_adr_i										=>	(others => '0'),
			nCS_o													=>	nCS,
			asdi_o												=>	spi_mosi,
			dclk_o												=>	spi_clk,
			data_i												=>	spi_miso
		);
		
		-- flash_out_inst	:	fub_rx_slave
		-- generic map(
		  -- addr_width	=>	adr_width,
		  -- data_width	=>	data_width,
		  -- busy_clks		=>	busy_clks
		-- )
		-- port map(
		  -- rst_i			=>	rst,
		  -- clk_i			=>	clk,
		  -- fub_data_i	=>	fub_fw_data,
		  -- fub_str_i		=>	fub_fw_str,
		  -- fub_busy_o	=>	fub_fw_busy,
		  -- fub_addr_i	=>	fub_fw_adr,
		  -- data_o		=>	open,
		  -- addr_o		=>	open,
		  -- str_o			=>	open
		-- );
		
		-- flash_in_inst	:	fub_tx_slave
		-- generic map(
		  -- addr_width		=>	adr_width,
		  -- data_width		=>	data_width,
		  -- data_start_value	=>	data_start_value,
		  -- data_stop_value	=>	data_stop_value,
		  -- data_inc_value	=>	data_inc_value
		-- )
		-- port map(
		  -- fub_str_i		=>	fub_fr_str,
		  -- fub_busy_o	=>	fub_fr_busy,
		  -- fub_data_o	=>	fub_fr_data,
		  -- fub_addr_i	=>	fub_fr_adr,
		  -- rst_i			=>	rst,
		  -- clk_i			=>	clk,
		  -- data_o		=>	open,
		  -- addr_o		=>	open,
		  -- str_o			=>	open
		-- );
		
		flash_tb_inst	:	flash_tb
		generic map(
			number_of_slave_select	=> 9
		)
		port map(
			rst_i					=>	rst,
			spi_clk_i			=>	spi_clk,
			spi_ss_i			=>	spi_ss,
			spi_mosi_i		=>	spi_mosi,
			spi_miso_o		=>	spi_miso
		);

		 
		fub_out_inst	:	fub_rx_slave
		generic map(
		  addr_width	=>	adr_width,
		  data_width	=>	data_width,
		  busy_clks		=>	busy_clks
		)
		port map(
		  rst_i			=>	rst,
		  clk_i			=>	clk,
		  fub_data_i	=>	fub_out_data,
		  fub_str_i		=>	fub_out_str,
		  fub_busy_o	=>	fub_out_busy,
		  fub_addr_i	=>	fub_out_adr,
		  data_o		=>	open,
		  addr_o		=>	open,
		  str_o			=>	open
		);
		
		fub_rs232_seq_demux_inst	:	fub_seq_demux
    generic map(
      fub_address_width	=>	adr_width,
      fub_data_width		=>	data_width,
      clk_freq_in_hz		=>	50.0E6,
      timeout_in_us			=>	timeout_in_us
		)
    port map(
      clk_i           	=>	clk,
      rst_i           	=>	rst,
      fub_strb_o      	=>	fub_cfg_reg_in_str,
      fub_data_o      	=>	fub_cfg_reg_in_data,
      fub_addr_o 				=>	fub_cfg_reg_in_adr,
      fub_busy_i 				=>	fub_cfg_reg_in_busy,
      seq_busy_o				=>	fub_in_busy,
      seq_data_i				=>	(others => '0'),--fub_in_data,
      seq_strb_i				=>	'0',--fub_in_str,
      crc_mismatch_o		=>	open
		);

		
		process(clk, rst)
		begin
			if rst = '1' then
				cnt					<=	0;
			elsif rising_edge(clk) then
				-- if fub_fr_str	=	'1' then
					-- if cnt	< 5 then
						-- cnt						<=	cnt + 1;
						-- fub_in_adr		<=	"00010";
						-- fub_fr_busy		<=	'0';	
					-- else
						-- fub_fr_busy		<=	'1';
					-- end if;
					-- if cnt = 0 then
						-- fub_fr_data		<=	x"10";
					-- elsif cnt	= 1 then
	          -- fub_fr_data		<=	x"31";
					-- elsif	cnt	=	2 then 
					  -- fub_fr_data		<=	x"00";
					-- elsif	cnt	=	3 then
            -- fub_fr_data		<=	x"E1";
					-- end if;
				-- end if;
				if fub_ram_in_str	<= '1' then
					if fub_ram_in_adr	=	x"0000"then
					  fub_ram_in_data		<=	x"10";
					elsif fub_ram_in_adr	=	x"0001" then
					  fub_ram_in_data		<=	x"31";
					elsif	fub_ram_in_adr	=	x"0002" then
					  fub_ram_in_data		<=	x"00";
					elsif	fub_ram_in_adr	=	x"0003" then
					  fub_ram_in_data		<=	x"E1";
					end if;
				end if;
			end if;
			fub_write_addr_intern	<=	"00000000" & fub_fw_adr;
			fub_read_addr_intern	<=	"00000000" & fub_fr_adr;
			spi_ss								<=	nCS & "11111111";
		end process;


end struct_arch;