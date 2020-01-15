LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE IEEE.STD_LOGIC_arith.all;
USE IEEE.STD_LOGIC_unsigned.all;

entity fub_input is

generic		(
				bitSize			: integer := 8;
				adr_bitSize		: integer := 8;
				use_adr			: integer
			);

port		(
				--------------------------------------------------------------------
				target_adr		: in std_logic_vector( 7 downto 0 );
				--------------------------------------------------------------------
				clk_i		: in std_logic;
				rst_i		: in std_logic;
				fub_adr_i			: in std_logic_vector( use_adr * (adr_bitSize - 1) downto 0 );
				fub_data_i			: in std_logic_vector( bitSize - 1 downto 0 );
				fub_str_i			: in std_logic;
				fub_busy_o			: out std_logic;
				block_transfer_i	: in std_logic;
				data_for_error_detection_o	: out std_logic_vector( bitSize + adr_bitSize - 1 downto 0 );
				input_got_data_o			: out std_logic;
				block_transfer_o			: out std_logic;
				no_more_input_data_o		: out std_logic;
				need_data_i					: in std_logic;
				data_o						: out std_logic
			);
			
end entity;

architecture fub_input_arch of fub_input is

component fub_input_adr_mux_ring 	

generic	( 
			bitSize				: integer := 8;		-- bitsize of the FuB package
			use_adr				: integer;
			adr_bitSize			: integer := 8
		) ;		
											
port ( 	
		rst_i			: in std_logic;
		clk_i			: in std_logic;
		fub_adr_i 			: in std_logic_vector( use_adr * (adr_bitSize - 1) downto 0 );
		fub_data_i			: in std_logic_vector( bitSize - 1 downto 0 );
		fub_str_i			: in std_logic;
		fub_busy_o			: out std_logic;
		block_transfer_i	: in std_logic;
		data_o					: out std_logic_vector( adr_bitSize + bitSize - 1 downto 0 );
		str_o					: out std_logic;
		block_transfer_o		: out std_logic;
		busy_i					: in std_logic
	 );
	
end component;

component fub_input_parallel_seriell

generic ( 	
			packetSize 				: integer := 16			
		 );		

port ( 	
		--------------------------------------------------------------------
		target_adr		: in std_logic_vector(7 downto 0);	
		--------------------------------------------------------------------
		clk_i		 		: in std_logic;
		rst_i		 		: in std_logic;
		data_i		 		: in std_logic_vector( bitSize + adr_bitSize - 1 downto 0 );
		str_i		 		: in std_logic;
		need_data_i	 		: in std_logic;
		block_transfer_i	: in std_logic;
		data_for_error_detection_o	: out std_logic_vector( bitSize + adr_bitSize - 1 downto 0 );
		input_got_data_o			: out std_logic;
		block_transfer_o			: out std_logic;
		no_more_input_data_o		: out std_logic;
		busy_o		 				: out std_logic;
		data_o						: out std_logic
	 );
	
end component;

signal adr_mux_data_o			: std_logic_vector( bitSize + adr_bitSize - 1 downto 0 );
signal adr_mux_str_o			: std_logic;
signal adr_mux_block_transfer_o	: std_logic;

signal parallel_seriell_busy_o				: std_logic;

begin

	fub_input_adr_mux_ring_inst : fub_input_adr_mux_ring
	generic	map( 
					bitSize				=> bitSize,
					adr_bitSize			=> adr_bitSize,
					use_adr				=> use_adr			  		
				) 												
	port map	( 	
					rst_i				=> rst_i,
					clk_i				=> clk_i,
					fub_adr_i 			=> fub_adr_i,			
					fub_data_i			=> fub_data_i,			
					fub_str_i			=> fub_str_i,
					block_transfer_i	=> block_transfer_i,		
					fub_busy_o			=> fub_busy_o,			
					data_o				=> adr_mux_data_o,			
					str_o				=> adr_mux_str_o,
					block_transfer_o	=> adr_mux_block_transfer_o,
					busy_i				=> parallel_seriell_busy_o
				 );
	

	fub_input_parallel_seriell_inst : fub_input_parallel_seriell
	generic map(
				 	packetSize 				=> (bitSize + adr_bitSize)
			 	)
	port map	(
					--------------------------------------
					target_adr				=> target_adr,
					--------------------------------------
				 	clk_i		   	 	=> clk_i,
					rst_i		      	=> rst_i,
					data_i		 		=> adr_mux_data_o,
					str_i  	 			=> adr_mux_str_o,
					block_transfer_i	=> adr_mux_block_transfer_o,
					need_data_i	  		=> need_data_i,
					data_for_error_detection_o	=> data_for_error_detection_o,
					input_got_data_o			=> input_got_data_o,
					block_transfer_o			=> block_transfer_o,
					no_more_input_data_o		=> no_more_input_data_o,
					busy_o		 				=> parallel_seriell_busy_o,
					data_o						=> data_o
				 );
						
end fub_input_arch;