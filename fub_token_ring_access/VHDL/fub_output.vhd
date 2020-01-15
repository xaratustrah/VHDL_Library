LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE IEEE.STD_LOGIC_arith.all;
USE IEEE.STD_LOGIC_unsigned.all;

entity fub_output is

generic	(
			bitSize				: integer := 8;
			adr_bitSize			: integer := 8;
			bitSize_input		: integer := 8;
			adr_bitSize_input	: integer := 8;
			use_adr				: integer			
		);
		
port	(
			---------------------------------------------------------------------
			local_adr			: in std_logic_vector( 7 downto 0 );
			target_adr			: in std_logic_vector( 7 downto 0 );
			---------------------------------------------------------------------
			clk_i			: in std_logic;
			rst_i			: in std_logic;
			fub_str_o					: out std_logic;
			fub_data_o					: out std_logic_vector(bitSize - 1 downto 0 );
			fub_adr_o					: out std_logic_vector(use_adr * (adr_bitSize - 1) downto 0 );
			fub_busy_i					: in std_logic;
			data_for_error_detection_i	: in std_logic_vector(bitSize_input + adr_bitSize_input - 1 downto 0);
			delete_all_o				: out std_logic;
			token_deleted_i				: in std_logic;
			ring_str_i					: in std_logic;
			data_i						: in std_logic;
			data_clk_i					: in std_logic;
			no_more_data_i				: in std_logic
		);

end fub_output;

architecture fub_output_arch of fub_output is

component fub_output_adr_demux_ring 								
														
generic	( 
			bitSize				: integer := 8;				-- bitsize of the FuB package
			use_adr				: integer;
			adr_bitSize			: integer := 8
		) ;	
														
port ( 	
		rst_i			: in std_logic;
		clk_i			: in std_logic;
		fub_adr_o 		: out std_logic_vector( use_adr * (adr_bitSize - 1) downto 0 );
		data_i			: in std_logic_vector( bitSize + adr_bitSize - 1 downto 0 );
		str_i			: in std_logic;
		fub_data_o		: out std_logic_vector( bitSize - 1 downto 0 );
		fub_str_o		: out std_logic;
		fub_busy_i		: in std_logic
	 );
	
end component;

component fub_output_seriell_parallel

generic ( 
			bitSize				: integer := 8;
			bitSize_input		: integer := 8;
			adr_bitSize			: integer := 8;
			adr_bitSize_input	: integer := 8
		) ;
port (  
		--------------------------------------------------------
		local_adr			: in std_logic_vector(7 downto 0);
		target_adr			: in std_logic_vector(7 downto 0);
		--------------------------------------------------------
		rst_i						: in std_logic;
		clk_i						: in std_logic;
		data_i						: in std_logic;
		token_deleted_i				: in std_logic;
		data_clk_i					: in std_logic;
		no_more_data_i				: in std_logic;
		ring_str_i					: in std_logic;
		data_for_error_detection_i	: in std_logic_vector(bitSize_input + adr_bitSize_input - 1 downto 0); 
		delete_all_o				: out std_logic;
		data_o						: out std_logic_vector( bitSize + adr_bitSize - 1 downto 0 );
		str_o						: out std_logic
	 );
	
end component;

signal seriell_parallel_str_o			: std_logic;
signal seriell_parallel_data_o			: std_logic_vector( bitSize + adr_bitSize - 1 downto 0 );

begin

	fub_output_seriell_parallel_inst : fub_output_seriell_parallel
	generic map	( 
					bitSize				=> bitSize,
					bitSize_input		=> bitSize_input,
					adr_bitSize			=> adr_bitSize,
					adr_bitSize_input	=> adr_bitSize_input
				)
	port map	(	
					--------------------------------------------------------
					local_adr			=> local_adr,
					target_adr			=> target_adr,
					--------------------------------------------------------
					rst_i				=> rst_i,
					clk_i				=> clk_i,
					data_for_error_detection_i	=> data_for_error_detection_i,
					data_i						=> data_i,
					data_clk_i					=> data_clk_i,
					token_deleted_i				=> token_deleted_i,
					no_more_data_i				=> no_more_data_i,
					ring_str_i					=> ring_str_i,
					delete_all_o				=> delete_all_o,
					data_o						=> seriell_parallel_data_o,
					str_o						=> seriell_parallel_str_o
		 		);
		
	fub_output_adr_demux_ring_inst : fub_output_adr_demux_ring															
	generic	map	( 
					bitSize			=> bitSize,
					use_adr			=> use_adr,
					adr_bitSize		=> adr_bitSize			  		
				)													
	port map	( 						
					rst_i				=> rst_i,
					clk_i				=> clk_i,
					fub_adr_o 			=> fub_adr_o,
					data_i			=> seriell_parallel_data_o,
					str_i			=> seriell_parallel_str_o,
					fub_data_o		=> fub_data_o,
					fub_str_o		=> fub_str_o,
					fub_busy_i		=> fub_busy_i
				 );	

end fub_output_arch;	