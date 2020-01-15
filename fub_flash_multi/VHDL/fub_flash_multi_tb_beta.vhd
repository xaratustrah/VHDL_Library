-------------------------------------------------------------------------------
--
-- 2009 T.Wollmann
--
-------------------------------------------------------------------------------

-- Package Definition

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use work.reset_gen_pkg.all;
use work.fub_seq_demux_pkg.all;
use work.fub_seq_mux_pkg.all;
-- use work.fub_rx_master_pkg.all;
-- use work.fub_tx_master_pkg.all;
use	work.fub_registerfile_cntrl_pkg.all;
use work.fub_rx_slave_pkg.all;
use work.fub_io_expander_pkg.all;
use work.fub_flash_multi_pkg.all;
use	work.flash_tb_pkg.all;
use work.fub_mux_2_to_1_flash_pkg.all;
use work.fub_multi_spi_master_pkg.all;
use work.fub_tx_master_pkg.all;
use work.fub_vga_pkg.all;
use work.fub_mux_2_to_1_pkg.all;

entity fub_flash_multi_tb is

end fub_flash_multi_tb;

architecture beh_arch of fub_flash_multi_tb is

  constant addr_width       : integer := 24;
  constant data_width       : integer := 8;
  constant addr_start_value : integer := 16#0000#;
  constant addr_stop_value  : integer := 16#04#;
  constant addr_inc_value   : integer := 16#1#;
	constant boot_from_flash	:	boolean	:=	true;
	constant clk_freq_in_hz		:	real		:=	50.0E6;
	constant timeout_in_us   	: real    :=	1.0E3;
	constant busy_clks				:	integer	:=	1;
	constant width_for_spi_fub: integer :=	4;  -- berechnet sich aus der
                                              -- Anzahl der Vorhandenen SPI Teilnehmer

	constant slave0_byte_count : integer := 1;
  constant slave1_byte_count : integer := 3;
  constant slave2_byte_count : integer := 1;
  constant slave3_byte_count : integer := 0;
  constant slave4_byte_count : integer := 0;
  constant slave5_byte_count : integer := 0;
  constant slave6_byte_count : integer := 0;
  constant slave7_byte_count : integer := 0;
  constant slave8_byte_count : integer := 0;
  constant slave9_byte_count : integer := 8;
	
	constant default_io_data	 : std_logic_vector(15 downto 0) 			:= x"1100";
	constant default_setup_data: std_logic_vector (64-1 downto 0) 	:= x"0A200B20000001C3";
	         
  -- component generics
  constant data_start_value : integer := 16#00#;
  constant data_stop_value  : integer := 16#04#;
  constant data_inc_value   : integer := 16#1#;
	
	constant vga_default_gain	:	std_logic_vector(3 downto 0) := "0011";
  
	-- clock
  signal sim_clk : std_logic := '1';
  signal sim_rst : std_logic := '1';

	-- registerfile in
	signal	fub_reg_in_str					:	std_logic;
	signal	fub_reg_in_busy					:	std_logic;
	signal	fub_reg_in_data					:	std_logic_vector(data_width-1 downto 0);
	signal	fub_reg_in_adr					:	std_logic_vector(15 downto 0);
	signal	fub_reg_in_addr_intern	:	std_logic_vector(addr_width-1 downto 0);
	
	-- registerfile out
	signal	fub_reg_out_str		:	std_logic;
	signal	fub_reg_out_busy	:	std_logic;
	signal	fub_reg_out_data	:	std_logic_vector(data_width-1 downto 0);
	signal	fub_reg_out_adr		:	std_logic_vector(15 downto 0);
	signal	fub_reg_out_addr_intern	:	std_logic_vector(addr_width-1 downto 0);
	
	-- flash out
	signal	fub_flash_out_str		:	std_logic;
	signal	fub_flash_out_busy	:	std_logic;
	signal	fub_flash_out_data	:	std_logic_vector(data_width-1 downto 0);
	signal	fub_flash_out_addr	:	std_logic_vector(width_for_spi_fub-1 downto 0);
	
	-- flash in
	signal	fub_flash_in_str		:	std_logic;
	signal	fub_flash_in_busy		:	std_logic;
	signal	fub_flash_in_data		:	std_logic_vector(data_width-1 downto 0);
	
	-- multi_spi_master
	signal	error_fub_multi_spi_master	:	std_logic;
	
	signal	spi_mosi	:	std_logic;
	signal  spi_miso	:	std_logic	:=	'0';
	signal  spi_clk		:	std_logic;
	signal  spi_ss		:	std_logic_vector(9 downto 0);
	
	signal	flash_byte_cnt	:	integer;
	signal	mux_byte_cnt		:	integer;
	
	signal	fub_seq_demux_data	:	std_logic_vector(data_width-1 downto 0);
	signal  fub_seq_demux_addr	:	std_logic_vector(15 downto 0);	
	signal  fub_seq_demux_str		:	std_logic;
	signal  fub_seq_demux_busy	:	std_logic;
	
	signal	fub_seq_mux_data	:	std_logic_vector(data_width-1 downto 0);
	signal  fub_seq_mux_addr	:	std_logic_vector(15 downto 0);	
	signal  fub_seq_mux_str		:	std_logic;
	signal  fub_seq_mux_busy	:	std_logic;
	
	signal	fub_ram_out_addr	:	std_logic_vector(15 downto 0);
	signal  fub_ram_out_data	:	std_logic_vector(data_width-1 downto 0);
	signal  fub_ram_out_str		:	std_logic;
	signal  fub_ram_out_busy	:	std_logic;
	
	signal	fub_ram_in_addr		:	std_logic_vector(15 downto 0);
	signal  fub_ram_in_data		:	std_logic_vector(data_width-1 downto 0);
	signal  fub_ram_in_str		:	std_logic;
	signal  fub_ram_in_busy		:	std_logic	:=	'0';
	
	signal	fub_in_busy			:	std_logic;
	signal  fub_in_data			:	std_logic_vector(data_width-1 downto 0);
	signal  fub_in_str			:	std_logic;
	
	signal	fub_out_busy		:	std_logic;
	signal  fub_out_data		:	std_logic_vector(data_width-1 downto 0);
	signal  fub_out_str			:	std_logic;
	
	signal	fubA_busy				:	std_logic;
	signal	fubA_data				:	std_logic_vector(data_width-1 downto 0);
	signal	fubA_strb				:	std_logic;
	signal	fubA_addr				:	std_logic_vector(width_for_spi_fub-1 downto 0);
	
	signal	fubB_busy				:	std_logic;
	signal	fubB_data				:	std_logic_vector(data_width-1 downto 0);
	signal	fubB_strb				:	std_logic;
	signal	fubB_addr				:	std_logic_vector(width_for_spi_fub-1 downto 0);
	
	signal	fubC_busy				:	std_logic;
	signal	fubC_data				:	std_logic_vector(data_width-1 downto 0);
	signal	fubC_strb				:	std_logic;
	signal	fubC_addr				:	std_logic_vector(width_for_spi_fub-1 downto 0);
	
	signal	fubD_busy				:	std_logic;
	signal	fubD_data				:	std_logic_vector(data_width-1 downto 0);
	signal	fubD_strb				:	std_logic;
	signal	fubD_addr				:	std_logic_vector(width_for_spi_fub-1 downto 0);
	
	signal	fubE_busy				:	std_logic;
	signal	fubE_data				:	std_logic_vector(data_width-1 downto 0);
	signal	fubE_strb				:	std_logic;
	signal	fubE_addr				:	std_logic_vector(width_for_spi_fub-1 downto 0);
	
	signal	fubF_busy				:	std_logic;
	signal	fubF_data				:	std_logic_vector(data_width-1 downto 0);
	signal	fubF_strb				:	std_logic;
	signal	fubF_addr				:	std_logic_vector(width_for_spi_fub-1 downto 0);

	signal cnt							:	integer range 56 downto 0;
	
	signal	read_flag_flash			:	std_logic;
	signal	read_flag_spi_master:	std_logic;
	signal	streaming_cnt	:	integer;
	
	signal	fub_mux_str		:	std_logic;
	signal  fub_mux_busy	:	std_logic;
	signal  fub_mux_data	:	std_logic_vector(data_width-1 downto 0);
	        
	begin
	
		sim_clk <= not sim_clk after 20 ns;
	
		reset_gen_1 : reset_gen
    generic map (
      reset_clks => 20
		)
    port map (
      clk_i => sim_clk,
      rst_o => sim_rst
		);
		
		-- fub_rx_master_inst : fub_rx_master
    -- generic map (
      -- addr_width       => addr_width,
      -- data_width       => data_width,
      -- addr_start_value => addr_start_value,
      -- addr_stop_value  => addr_stop_value,
      -- addr_inc_value   => addr_inc_value
		-- )
    -- port map (
      -- fub_str_o  => fub_reg_in_str,
      -- fub_busy_i => fub_reg_in_busy,
      -- fub_data_i => fub_reg_in_data,
      -- fub_addr_o => fub_reg_in_adr,
      -- rst_i      => sim_rst,
      -- clk_i      => sim_clk,
      -- data_o     => open,
      -- addr_o     => open,
      -- str_o      => open
		-- );

	-- fub_tx_master_inst	:	fub_tx_master
	  -- generic map(
	    -- addr_width       => addr_width,
	    -- data_width       => data_width,
	    -- addr_start_value => addr_start_value,
	    -- data_start_value => data_start_value,
	    -- addr_stop_value  => addr_stop_value,
	    -- data_stop_value  => data_stop_value,
	    -- addr_inc_value   => addr_inc_value,
	    -- data_inc_value   => data_inc_value,
	    -- wait_clks        => 3
	  -- )
	  -- port map(
	    -- rst_i      => sim_rst,
	    -- clk_i      => sim_clk,
	    -- fub_str_o  => fub_reg_out_str,
	    -- fub_busy_i => fub_reg_out_busy,
	    -- fub_addr_o => fub_reg_out_adr,
	    -- fub_data_o => fub_reg_out_data
	  -- );
		
	fub_seq_demux_inst	:	fub_seq_demux
	generic map(
    fub_address_width 	=>	16,
    fub_data_width      =>	data_width,
    clk_freq_in_hz      =>	clk_freq_in_hz,
    timeout_in_us       =>	timeout_in_us
	)                   
  port map(
    clk_i          			=>	sim_clk,
    rst_i          			=>	sim_rst,
    fub_strb_o     			=>	fub_seq_demux_str,
    fub_data_o     			=>	fub_seq_demux_data,
    fub_addr_o     			=>	fub_seq_demux_addr,
    fub_busy_i     			=>	fub_seq_demux_busy,
    seq_busy_o     			=>	fub_in_busy,
    seq_data_i     			=>	fub_in_data,
    seq_strb_i     			=>	fub_in_str,
    crc_mismatch_o 			=>	open
	);
	
	fub_seq_mux_inst	:	fub_seq_mux
  generic map(
    fub_address_width =>	16,
    fub_data_width    =>	data_width,
    clk_freq_in_hz    =>	clk_freq_in_hz,
    timeout_in_us     =>	timeout_in_us
	)
  port map(
    clk_i							=>  sim_clk,
    rst_i      				=>	sim_rst,
    fub_strb_i 				=>	fub_seq_mux_str,
    fub_data_i        =>	fub_seq_mux_data,
    fub_addr_i        =>	fub_seq_mux_addr,
    fub_busy_o        =>	fub_seq_mux_busy,
    seq_busy_i        =>	fub_out_busy,
    seq_data_o        =>	fub_out_data,
    seq_strb_o        =>	fub_out_str
	);                
		
	fub_registerfile_cntrl_inst	:	fub_registerfile_cntrl	
	generic map(
    adr_width               =>	16,
    data_width              =>	data_width,
    default_start_adr       =>	16#0000#, 
    default_end_adr         =>	16#0003#,
    reg_adr_cmd             =>	16#fff0#,
    reg_adr_start_adr_high  =>	16#fff1#,
    reg_adr_start_adr_low   =>	16#fff2#,
    reg_adr_end_adr_high    =>	16#fff3#,
    reg_adr_end_adr_low     =>	16#fff4#,
    reg_adr_firmware_id			=>	16#fff5#,
    reg_adr_firmware_version=>	16#fff6#,
    reg_adr_firmware_config =>	16#fff7#,
    mask_adr                =>	16#ffff#,
    firmware_id             =>	0,
    firmware_version        =>	0,
    firmware_config         =>	0,
    boot_from_flash         =>	boot_from_flash
  )
  port map(
    rst_i                  	=>	sim_rst,
    clk_i                  	=>	sim_clk,
    fub_cfg_reg_in_dat_i   	=>	fub_seq_demux_data,
    fub_cfg_reg_in_adr_i   	=>	fub_seq_demux_addr,
    fub_cfg_reg_in_str_i   	=>	fub_seq_demux_str,
    fub_cfg_reg_in_busy_o  	=>	fub_seq_demux_busy,
    fub_cfg_reg_out_str_o  	=>	fub_seq_mux_str,
    fub_cfg_reg_out_dat_o  	=>	fub_seq_mux_data,
    fub_cfg_reg_out_adr_o  	=>	fub_seq_mux_addr,
    fub_cfg_reg_out_busy_i 	=>	fub_seq_mux_busy,
    fub_fr_busy_i          	=>	fub_reg_in_busy,
    fub_fr_dat_i           	=>	fub_reg_in_data,
    fub_fr_str_o           	=>	fub_reg_in_str,
    fub_fr_adr_o           	=>	fub_reg_in_adr,
		fub_fr_cnt_o						=>	streaming_cnt,
    fub_fw_str_o           	=>	fub_reg_out_str,
    fub_fw_busy_i          	=>	fub_reg_out_busy,
    fub_fw_dat_o           	=>	fub_reg_out_data,
    fub_fw_adr_o           	=>	fub_reg_out_adr,
    fub_out_data_o					=>	open,
    fub_out_adr_o   				=>	open,
    fub_out_str_o   				=>	open,
    fub_out_busy_i      		=>	'0',
    -----------------------RAM----------------------------------------------
		fub_ram_out_adr_o				=>	fub_ram_out_addr,
    fub_ram_out_data_o			=>	fub_ram_out_data,
    fub_ram_out_str_o				=>	fub_ram_out_str,
    fub_ram_out_busy_i			=>	fub_ram_out_busy,
    fub_ram_in_adr_o				=>	fub_ram_in_addr,
    fub_ram_in_data_i				=>	fub_ram_in_data,
    fub_ram_in_str_o				=>	fub_ram_in_str,
    fub_ram_in_busy_i				=>	fub_ram_in_busy
  );

	ram_out_inst	:	fub_rx_slave
	generic map(
	  addr_width	=>	16,
	  data_width	=>	data_width,
	  busy_clks		=>	busy_clks
	)
	port map(
	  rst_i				=>	sim_rst,
	  clk_i				=>	sim_clk,
	  fub_data_i	=>	fub_ram_out_data,
	  fub_str_i		=>	fub_ram_out_str,
	  fub_busy_o	=>	fub_ram_out_busy,
	  fub_addr_i	=>	fub_ram_out_addr,
	  data_o			=>	open,
	  addr_o			=>	open,
	  str_o				=>	open
	);
		
	DUT_inst	:	fub_flash_multi
	generic map(
		priority_on_reading				=> '1',
		erase_in_front_of_write		=> '1',
		read_block								=>	4,
		write_block								=>	4,
		spi_addr_width						=>	4
	)										
	port map(  
		clk_i											=>	sim_clk,
		rst_i											=>	sim_rst,
		-- to registerfile control 2.0
		fub_write_busy_o					=>	fub_reg_out_busy,
		fub_write_data_i					=>	fub_reg_out_data,
		fub_write_adr_i						=>	fub_reg_out_addr_intern,
		fub_write_str_i						=>	fub_reg_out_str,
		fub_read_busy_o						=>	fub_reg_in_busy,
		fub_read_data_o						=>	fub_reg_in_data,
		fub_read_adr_i						=>	fub_reg_in_addr_intern,--(others => '0'),
		fub_read_str_i						=>	fub_reg_in_str,--'0',
		stream_cnt_i							=>	streaming_cnt,
		erase_str_i								=>	'0',
		erase_adr_i								=>	(others => '0'),
		-- to multi_spi_master
		fub_spi_out_busy_i				=>	fub_flash_out_busy,
		fub_spi_out_str_o					=>	fub_flash_out_str,
		fub_spi_out_data_o				=>	fub_flash_out_data,
		flash_byte_count_o				=>	flash_byte_cnt,
		read_flag_o								=>	read_flag_flash,
		fub_spi_out_addr_o				=>	fub_flash_out_addr,
		-- from multi_spi_master
		fub_spi_in_busy_o					=>	fub_flash_in_busy,
		fub_spi_in_str_i					=>	fub_flash_in_str,
		fub_spi_in_data_i					=>	fub_flash_in_data
	);
	
	-- flash_tx_inst	:	fub_tx_master
  -- generic map(
    -- addr_width			=>	4,
    -- data_width     	=>	8,
    -- addr_start_value=>	16#00#,
    -- data_start_value=>	16#11#,
    -- addr_stop_value =>	16#03#,
    -- data_stop_value =>	16#44#,
    -- addr_inc_value	=>	16#1#,
    -- data_inc_value  =>	16#11#,
    -- wait_clks       =>	0
    -- )
  -- port map(
    -- rst_i				=>	sim_rst,
    -- clk_i				=>	sim_clk,
    -- fub_str_o		=>	fub_mux_str,
    -- fub_busy_i	=>	fub_mux_busy,
    -- fub_addr_o	=>	open,
    -- fub_data_o	=>	fub_mux_data
	-- );
	
	fub_multi_spi_master_inst1 : fub_multi_spi_master
  generic map (
    clk_freq_in_hz => clk_freq_in_hz,

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
    data_width        => data_width
	)
  port map (
    clk_i       				=>	sim_clk,
    rst_i       				=>	sim_rst,
		flash_byte_count_i	=>	mux_byte_cnt,--flash_byte_cnt,
		read_flag_i					=>	read_flag_spi_master,--read_flag_flash,
    fub_str_i   				=>	fubA_strb,--fub_flash_out_str,
    fub_busy_o  				=>	fubA_busy,--fub_flash_out_busy,
    fub_data_i  				=>	fubA_data,--fub_flash_out_data,
    fub_addr_i  				=>	fubA_addr,
    fub_error_o 				=>	error_fub_multi_spi_master,
    fub_str_o   				=>	fub_flash_in_str,
    fub_busy_i  				=>	fub_flash_in_busy,
    fub_data_o  				=>	fub_flash_in_data,
    spi_mosi_o  				=>	spi_mosi,
    spi_miso_i  				=>	spi_miso,
    spi_clk_o   				=>	spi_clk,
    spi_ss_o    				=>	spi_ss
	);
	
	-- flash_tb_inst	:	flash_tb
	-- generic map(
		-- number_of_slave_select	=> 	9
	-- )
	-- port map(
		-- clk_i			=>	sim_clk,
		-- rst_i			=>	sim_rst,
		-- spi_ss_i	=>	spi_ss,
		-- spi_clk_i	=>	spi_clk,
		-- spi_mosi_i=>	spi_mosi,
		-- spi_miso_o=>	spi_miso
	-- );
	
	fub_vga_inst1 : fub_vga
    generic map (
      default_gain   => vga_default_gain,
      spi_address    => 0,
      fub_addr_width => width_for_spi_fub,
      fub_data_width => 8)
    port map (
      clk_i      => sim_clk,
      rst_i      => sim_rst,
      vga_gain_i => vga_default_gain,
      vga_str_i  => '0',
      vga_busy_o => open,
      fub_data_o => fubE_data,
      fub_adr_o  => fubE_addr,
      fub_str_o  => fubE_strb,
      fub_busy_i => fubE_busy
		);

  fub_vga_inst2 : fub_vga
    generic map (
      default_gain   => vga_default_gain,
      spi_address    => 4,
      fub_addr_width => width_for_spi_fub,
      fub_data_width => 8)
    port map (
      clk_i      => sim_clk,
      rst_i      => sim_rst,
      vga_gain_i => vga_default_gain,
      vga_str_i  => '0',
      vga_busy_o => open,
      fub_data_o => fubF_data,
      fub_adr_o  => fubF_addr,
      fub_str_o  => fubF_strb,
      fub_busy_i => fubF_busy
		);


	fub_io_expander_inst	:	fub_io_expander
	generic map(
    default_io_data    =>	default_io_data,
    default_setup_data =>	default_setup_data,
    spi_address        =>	0,
    fub_addr_width     =>	width_for_spi_fub,
    fub_data_width     =>	data_width
	)                  
  port map(
    clk_i              =>	sim_clk,
    rst_i              =>	sim_rst,
    io_expander_data_i =>	(others	=>	'0'),
    io_expander_str_i  =>	'0',
    io_expander_busy_o =>	open,
    fub_data_o         =>	fubC_data,
    fub_adr_o          =>	fubC_addr,
    fub_str_o          =>	fubC_strb,
    fub_busy_i         =>	fubC_busy
	);
	
	  fub_mux_2_to_1_inst2 : fub_mux_2_to_1
    generic map (
      priority        => 0,
      fubA_data_width => 8,
      fubA_adr_width  => width_for_spi_fub,
      fubB_data_width => 8,
      fubB_adr_width  => width_for_spi_fub,
      fub_data_width  => 8,
      fub_adr_width   => width_for_spi_fub
		)
    port map (
      clk_i       => sim_clk,
      rst_i       => sim_rst,
      fubA_data_i => fubE_data,
      fubA_adr_i  => fubE_addr,
      fubA_str_i  => fubE_strb,
      fubA_busy_o => fubE_busy,
      fubB_data_i => fubF_data,
      fubB_adr_i  => fubF_addr,
      fubB_str_i  => fubF_strb,
      fubB_busy_o => fubF_busy,
      fub_data_o  => fubD_data,
      fub_adr_o   => fubD_addr,
      fub_str_o   => fubD_strb,
      fub_busy_i  => fubD_busy
		);

	
  fub_mux_2_to_1_inst1 : fub_mux_2_to_1
  generic map (
    priority        => 0,
    fubA_data_width => 8,
    fubA_adr_width  => width_for_spi_fub,
    fubB_data_width => 8,
    fubB_adr_width  => width_for_spi_fub,
    fub_data_width  => 8,
    fub_adr_width   => width_for_spi_fub
	)
  port map (
    clk_i       => sim_clk,
    rst_i       => sim_rst,
    fubA_data_i => fubC_data,
    fubA_adr_i  => fubC_addr,
    fubA_str_i  => fubC_strb,
    fubA_busy_o => fubC_busy,
    fubB_data_i => fubD_data,
    fubB_adr_i  => fubD_addr,
    fubB_str_i  => fubD_strb,
    fubB_busy_o => fubD_busy,
    fub_data_o  => fubB_data,
    fub_adr_o   => fubB_addr,
    fub_str_o   => fubB_strb,
    fub_busy_i  => fubB_busy
	);

	
  fub_mux_2_to_1_flash_inst : fub_mux_2_to_1_flash
  generic map(
    priority        	=> 0,
    fubA_data_width 	=> 8,
    fubA_adr_width  	=> width_for_spi_fub,
    fubB_data_width 	=> 8,
    fubB_adr_width  	=> width_for_spi_fub,
    fub_data_width  	=> 8,
    fub_adr_width   	=> width_for_spi_fub,
		spi_address_A			=> 5,
		spi_address_B			=> 1
	)
  port map(
    clk_i       			=>	sim_clk,
    rst_i       			=>	sim_rst,
    fubA_data_i 			=>	fub_flash_out_data,
    fubA_adr_i  			=>	fub_flash_out_addr,--"1010",
    fubA_str_i  			=>	fub_flash_out_str,
    fubA_busy_o				=>	fub_flash_out_busy,
		fubA_read_flag_i	=>	read_flag_flash,
		flash_byte_cnt_i	=>	flash_byte_cnt,
    fubB_data_i 			=>	fubB_data,
    fubB_adr_i  			=>	fubB_addr,
    fubB_str_i  			=>	fubB_strb,
    fubB_busy_o 			=>	fubB_busy,
    fub_data_o  			=>	fubA_data,
    fub_adr_o   			=>	fubA_addr,
    fub_str_o   			=>	fubA_strb,
    fub_busy_i  			=>	fubA_busy,
		read_flag_o				=>	read_flag_spi_master,
		flash_byte_cnt_o	=>	mux_byte_cnt
	);                
	
	process(sim_clk, sim_rst)
	begin
		if sim_rst = '1' then
			cnt					<=	0;
			fub_in_data	<=	(others => '0');
			fub_in_str	<=	'0';
		elsif rising_edge(sim_clk) then
			if fub_in_busy	<=	'0' then
				if cnt	< 56 then
					cnt						<=	cnt + 1;
					fub_in_str		<=	'1';	
				else
					fub_in_str		<=	'0';
				end if;
				if cnt < 2 then
					fub_in_data		<=	x"00";
				elsif cnt	< 4 then
					fub_in_data		<=	x"10";
				elsif	cnt	= 4 then
	        fub_in_data		<=	x"00";
				elsif cnt	= 5 then
	        fub_in_data		<=	x"01";
				elsif cnt	= 6 then
	        fub_in_data		<=	x"31";
				elsif	cnt	=	7 then
	        fub_in_data		<=	x"30";
				elsif	cnt	=	8 then
          fub_in_data		<=	x"00";
				elsif	cnt	=	9 then
				  fub_in_data		<=	x"02";
				elsif	cnt	=	10 then
				  fub_in_data		<=	x"00";
				elsif	cnt	=	11 then
				  fub_in_data		<=	x"02";	
				elsif	cnt	=	12 then
				  fub_in_data		<=	x"00";
				elsif	cnt	=	13 then	
				  fub_in_data		<=	x"03";
				elsif	cnt	=	14 then
          fub_in_data		<=	x"E1";
				elsif	cnt	=	15 then
				  fub_in_data		<=	x"E2";
				elsif cnt = 16 then
					fub_in_data		<=	x"FF";
				elsif cnt	= 17 then
					fub_in_data		<=	x"F1";
				elsif	cnt	= 18 then
				  fub_in_data		<=	x"00";
				elsif cnt	= 19 then
				  fub_in_data		<=	x"0E";
				elsif cnt	= 20 then
				  fub_in_data		<=	x"FF";
				elsif	cnt	=	21 then
				  fub_in_data		<=	x"F2";
				elsif	cnt	=	22 then
				  fub_in_data		<=	x"00";
				elsif	cnt	=	23 then
				  fub_in_data		<=	x"0D";
				elsif	cnt	=	24 then
				  fub_in_data		<=	x"FF";
				elsif	cnt	=	25 then
				  fub_in_data		<=	x"F3";
				elsif	cnt	=	26 then
				  fub_in_data		<=	x"00";
				elsif	cnt	=	27 then	
				  fub_in_data		<=	x"0C";	
				elsif	cnt	=	28 then
				  fub_in_data		<=	x"FF";
				elsif	cnt	=	29 then
				  fub_in_data		<=	x"F4";
				elsif	cnt	=	30 then
				  fub_in_data		<=	x"03";
				elsif	cnt	=	31 then
				  fub_in_data		<=	x"08";
				elsif	cnt	=	32 then
				  fub_in_data		<=	x"FF";
				elsif	cnt	=	33 then
				  fub_in_data		<=	x"F0";
				elsif	cnt	=	34 then
				  fub_in_data		<=	x"04";
				elsif	cnt	=	35 then
				  fub_in_data		<=	x"0B";
				elsif cnt = 36 then
					fub_in_data		<=	x"FF";
				elsif cnt	= 37 then
					fub_in_data		<=	x"F1";
				elsif	cnt	= 38 then
				  fub_in_data		<=	x"00";
				elsif cnt	= 39 then
				  fub_in_data		<=	x"0E";
				elsif cnt	= 40 then
				  fub_in_data		<=	x"FF";
				elsif	cnt	=	41 then
				  fub_in_data		<=	x"F2";
				elsif	cnt	=	42 then
				  fub_in_data		<=	x"00";
				elsif	cnt	=	43 then
				  fub_in_data		<=	x"0D";
				elsif	cnt	=	44 then
				  fub_in_data		<=	x"FF";
				elsif	cnt	=	45 then
				  fub_in_data		<=	x"F3";
				elsif	cnt	=	46 then
				  fub_in_data		<=	x"00";
				elsif	cnt	=	47 then	
				  fub_in_data		<=	x"0C";	
				elsif	cnt	=	48 then
				  fub_in_data		<=	x"FF";
				elsif	cnt	=	49 then
				  fub_in_data		<=	x"F4";
				elsif	cnt	=	50 then
				  fub_in_data		<=	x"03";
				elsif	cnt	=	51 then
				  fub_in_data		<=	x"09";
				elsif	cnt	=	52 then
				  fub_in_data		<=	x"FF";
				elsif	cnt	=	53 then
				  fub_in_data		<=	x"F0";
				elsif	cnt	=	54 then
				  fub_in_data		<=	x"08";
				elsif	cnt	=	55 then
				  fub_in_data		<=	x"07";
				end if;
			end if;
			if fub_ram_in_str	<= '1' then
				if fub_ram_in_addr	=	x"0000"then
				  fub_ram_in_data		<=	x"10";
				elsif fub_ram_in_addr	=	x"0001" then
				  fub_ram_in_data		<=	x"31";
				elsif	fub_ram_in_addr	=	x"0002" then
				  fub_ram_in_data		<=	x"00";
				elsif	fub_ram_in_addr	=	x"0003" then
				  fub_ram_in_data		<=	x"E1";
				end if;
			end if;
		end if;
	end process;

	fub_reg_in_addr_intern	<=	"00000000" & fub_reg_in_adr;
	fub_reg_out_addr_intern	<=	"00000000" & fub_reg_out_adr;
	-- rotz	<=	5+conv_integer(unsigned(fub_flash_out_addr));
	-- fubA_addr <= conv_std_logic_vector(rotz,4);
		
	end beh_arch;
