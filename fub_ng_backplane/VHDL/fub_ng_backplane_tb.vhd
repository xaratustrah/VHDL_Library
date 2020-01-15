library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.all;
use ieee.std_logic_unsigned.all;
use work.fub_ng_backplane_pkg.all;
use work.reset_gen_pkg.all;

entity fub_ng_backplane_tb is
	generic(
		rst_clk				:	integer :=	150
	);
end fub_ng_backplane_tb;

architecture struct_arch of fub_ng_backplane_tb is
	
	signal rst	:	std_logic;	
	
	--stimuli signals
	signal clk		:	std_logic		:=	'0';
	signal fub_busy :	std_logic		:=	'0';
	signal par_data	:	std_logic_vector(23 downto 0) := "101010101111111100000000";
	signal par_adr	:	std_logic_vector(5 downto 0) := "100100";
	
	--response signals
	signal data		:	std_logic_vector(23 downto 0);
	signal fub_data	:	std_logic_vector(7 downto 0);
	signal set		:	std_logic;
	signal par_busy :	std_logic;
	signal fub_adr	:	std_logic_vector(1 downto 0);
	signal fub_str	:	std_logic;
	
	
	begin
		
		clk <= not clk after 10 ns;
		
		reset_gen_inst	:	reset_gen		
		generic map(
			reset_clks	=>	rst_clk
		)
		port map(
			clk_i	=>	clk,
			rst_o	=>	rst
		);
		
		fub_ng_backplane_inst	:	fub_ng_backplane
		port map(
			rst_i		=>	rst,
			clk_i		=>	clk,
			par_data_i	=>	par_data,
			par_adr_i	=>	par_adr,
			fub_busy_i	=>	fub_busy,
			data_o		=>	data,
			fub_data_o	=>	fub_data,
			set_o		=>	set,
			par_busy_o	=>	par_busy,
			fub_adr_o	=>	fub_adr,
			fub_str_o	=>	fub_str
		);
		
end struct_arch;