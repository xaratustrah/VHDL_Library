library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

use work.fub_dds_backplane_pkg.all;

entity dds_bp_tb is
	generic (
		clk_period : time := 20 ns
	);
end dds_bp_tb;

architecture dds_bp_tb_arch of dds_bp_tb is

	component dds_bp_gen
		generic (
			data_width: integer := 8;
			adr_width: integer := 8;
			fc_width: integer := 8;
			bp_fc_width: integer := 8;
			init_rom_size: integer := 40
		);
		port (
			bp_data_o: out std_logic_vector(data_width-1 downto 0);
			bp_adr_o: out std_logic_vector(adr_width-1 downto 0);
			bp_newdata_o: out std_logic;
			bp_fc_o: out std_logic_vector(fc_width-1 downto 0);
			bp_fc_valid_o: out std_logic
		);
	end component;

	signal	clk : std_logic := '0';
	signal	rst : std_logic := '0';

	signal bp_data: std_logic_vector(7 downto 0);
	signal bp_adr: std_logic_vector(7 downto 0);
	signal bp_newdata: std_logic;
	signal bp_fc: std_logic_vector(7 downto 0);
	signal bp_fc_valid: std_logic;

	signal fub_data: std_logic_vector(7 downto 0);
	signal fub_adr: std_logic_vector(7 downto 0);
	signal fub_str: std_logic;
	signal fub_busy: std_logic;
	
	signal update: std_logic := '0';
	
begin

	dds_bp_gen_inst: dds_bp_gen
	port map (
		bp_data_o => bp_data,
		bp_adr_o => bp_adr,
		bp_newdata_o => bp_newdata,
		bp_fc_o => bp_fc,
		bp_fc_valid_o => bp_fc_valid
	);
		
	fub_dds_backplane_inst: fub_dds_backplane
	generic map (
		data_width    => 8,
		adr_width    => 8,
		bp_fc_width   => 8,
		init_fc       => 16#B#				
	)
	port map (
		clk_i => clk,
		rst_i => rst,
		bp_data_i => bp_data,
		bp_adr_i => bp_adr,
		bp_newdata_i => bp_newdata,
		bp_fc_i => bp_fc,
		bp_fc_valid_i => bp_fc_valid,
		bp_fc_low_half_nibble_i => "01",
		fub_data_o => fub_data,
		fub_adr_o => fub_adr,
		fub_str_o => fub_str,
		fub_busy_i => '0'
	);


	clk <= not clk after clk_period/2;
	rst <= '1', '0' after 4*clk_period;
	
end dds_bp_tb_arch;