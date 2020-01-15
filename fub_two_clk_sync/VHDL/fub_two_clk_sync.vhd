-------------------------------------------------------------------------------
--
-- two clk sync
-- T. Guthier
-- 2011-07-29 /ct added synchronization of resets for output clock
-------------------------------------------------------------------------------

-- Package Definition

library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_arith.all;
use IEEE.STD_LOGIC_unsigned.all;

package fub_two_clk_sync_pkg is
	component fub_two_clk_sync
		generic(	
			bitSize		: integer := 8;
			adrSize		: integer := 2
		);
		port(	
			rst_i			: in std_logic;
			clk_input_i		: in std_logic;
			clk_output_i	: in std_logic;
			fub_str_i		: in std_logic;
			fub_data_i		: in std_logic_vector( bitSize - 1 downto 0 );
			fub_adr_i		: in std_logic_vector( adrSize - 1 downto 0 );
			fub_busy_i		: in std_logic;
			fub_str_o		: out std_logic;
			fub_busy_o		: out std_logic;
			fub_data_o		: out std_logic_vector( bitSize - 1 downto 0 );
			fub_adr_o		: out std_logic_vector( adrSize - 1 downto 0 )
		);
	end component fub_two_clk_sync; 
end package fub_two_clk_sync_pkg;

package body fub_two_clk_sync_pkg is
end fub_two_clk_sync_pkg;

-- Entity Definition

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE IEEE.STD_LOGIC_arith.all;
USE IEEE.STD_LOGIC_unsigned.all;

entity fub_two_clk_sync is
	generic(	
		bitSize		: integer := 8;
		adrSize		: integer := 2
	);
	port(	
		rst_i			: in std_logic;
		clk_input_i		: in std_logic;
		clk_output_i	: in std_logic;
		fub_str_i		: in std_logic;
		fub_data_i		: in std_logic_vector( bitSize - 1 downto 0 );
		fub_adr_i		: in std_logic_vector( adrSize - 1 downto 0 );
		fub_busy_i		: in std_logic;
		fub_str_o		: out std_logic;
		fub_busy_o		: out std_logic;
		fub_data_o		: out std_logic_vector( bitSize - 1 downto 0 );
		fub_adr_o		: out std_logic_vector( adrSize - 1 downto 0 )
	);
end entity fub_two_clk_sync;

architecture fub_two_clk_sync_arch of fub_two_clk_sync is

	component input_vector_sync
		generic(	
			bitSize		: integer := 8 
		);
		port (  
			clk_i	: in std_logic;
			rst_i	: in std_logic;
			data_i	: in std_logic_vector( bitSize - 1 downto 0 );
			data_o 	: out std_logic_vector( bitSize - 1 downto 0 )
		);
	end component input_vector_sync;

	component input_synchron
		port (
			clk_i	: in std_logic ;
			rst_i	: in std_logic ;
			data_i	: in std_logic ;
			data_o 	: out std_logic
		);
	end component input_synchron;

	component clk_sync_input
		generic(	
			bitSize		: integer := 8; 
			adrSize		: integer := 2
		);
		port(	
			rst_i				: in std_logic;
			clk_i				: in std_logic;
			fub_data_i			: in std_logic_vector( bitSize - 1 downto 0 );
			fub_adr_i			: in std_logic_vector( adrSize - 1 downto 0 );
			fub_str_i			: in std_logic;
			fub_busy_o			: out std_logic;
			data_set_intern_i	: in std_logic;
			str_intern_o		: out std_logic;
			data_intern_o		: out std_logic_vector( bitSize - 1 downto 0 );
			adr_intern_o		: out std_logic_vector( adrSize - 1 downto 0 )
		);
	end component clk_sync_input;

	component clk_sync_output
		generic(	
			bitSize		: integer := 8; 
			adrSize		: integer := 8
		);
		port(	
			rst_i				: in std_logic;
			clk_i				: in std_logic;
			str_intern_i		: in std_logic;
			data_intern_i		: in std_logic_vector( bitSize - 1 downto 0 );
			adr_intern_i		: in std_logic_vector( adrSize - 1 downto 0 );
			fub_data_o			: out std_logic_vector( bitSize - 1 downto 0 );
			fub_adr_o			: out std_logic_vector( adrSize - 1 downto 0 );
			fub_str_o			: out std_logic;
			fub_busy_i			: in std_logic;
			data_set_intern_o	: out std_logic
		);
	end component clk_sync_output;

signal	rst_output				: std_logic := '1';
signal	rst_output_help			: std_logic := '1';

signal	data_set_intern			: std_logic;
signal	data_set_intern_sync	: std_logic;
signal	str_intern_sync			: std_logic;
signal	str_intern				: std_logic;
signal	data_intern				: std_logic_vector( bitSize - 1 downto 0 );
signal	data_intern_sync		: std_logic_vector( bitSize - 1 downto 0 );
signal	adr_intern				: std_logic_vector( adrSize - 1 downto 0 );
signal	adr_intern_sync			: std_logic_vector( adrSize - 1 downto 0 );

begin

	input_synchron_inst2 : input_synchron
	port map( 	
				clk_i	 	=> clk_input_i,
				rst_i	 	=> rst_i,
				data_i		=> data_set_intern,
				data_o 		=> data_set_intern_sync
			 );
	
	clk_sync_input_inst : clk_sync_input
	generic map	(	
					bitSize			=> bitSize,
					adrSize			=> adrSize 
				)
	port map(	
				rst_i				=> rst_i,
				clk_i				=> clk_input_i,
				fub_data_i			=> fub_data_i,
				fub_adr_i			=> fub_adr_i,
				fub_str_i			=> fub_str_i,
				fub_busy_o			=> fub_busy_o,
				data_set_intern_i	=> data_set_intern_sync,
				str_intern_o		=> str_intern,
				data_intern_o		=> data_intern,
				adr_intern_o		=> adr_intern
			);

	rst_output_help	<= rst_i			when rising_edge(clk_output_i);
	rst_output		<= rst_output_help	when rising_edge(clk_output_i);

	input_vector_sync_inst1 : input_vector_sync
	generic map	(	
					bitSize		=> bitSize 
				)
	port map(  	
				clk_i		=> clk_output_i,
				rst_i		=> rst_output,
				data_i		=> data_intern,
				data_o 	 	=> data_intern_sync
			 );

	input_vector_sync_inst2 : input_vector_sync
	generic map(
		bitSize		=> adrSize 
	)
	port map(
		clk_i		=> clk_output_i,
		rst_i		=> rst_output,
		data_i		=> adr_intern,
		data_o 	 	=> adr_intern_sync
	 );

	input_synchron_inst1 : input_synchron
	port map(
		clk_i	 	=> clk_output_i,
		rst_i	 	=> rst_output,
		data_i		=> str_intern,
		data_o 		=> str_intern_sync
	 );

	clk_sync_output_inst : clk_sync_output
	generic map(
		bitSize			=> bitSize,
		adrSize			=> adrSize 
	)
	port map(
		clk_i				=> clk_output_i,
		rst_i				=> rst_output,
		str_intern_i		=> str_intern_sync,
		data_intern_i		=> data_intern_sync,
		adr_intern_i		=> adr_intern_sync,
		fub_data_o			=> fub_data_o,
		fub_adr_o			=> fub_adr_o,
		fub_str_o			=> fub_str_o,
		fub_busy_i			=> fub_busy_i,
		data_set_intern_o	=> data_set_intern
	);
end architecture fub_two_clk_sync_arch;