-------------------------------------------------------------------------------
--
-- Direct optical link
-- T. Guthier
--
-------------------------------------------------------------------------------

-- Package Definition

library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_arith.all;
use IEEE.STD_LOGIC_unsigned.all;

package fub_direct_opt_link_rx_pkg is
component fub_direct_opt_link_rx
	generic ( 
			bitSize		: integer ;
			adr_bitSize	: integer ;
			use_adr		: integer 			-- if adr is not used <= 0 || if adr is used <= 1
		) ;

	port (	
			clk_i			: in std_logic ;
			rst_i			: in std_logic ;
			opt_data_i		: in std_logic ;
			fub_busy_i		: in std_logic ;
			fub_data_o		: out std_logic_vector( bitSize - 1 downto 0 ) ;
			fub_adr_o		: out std_logic_vector( use_adr * (adr_bitSize - 1) downto 0 ) ;
			fub_str_o		: out std_logic
		 ) ;

end component; 
end fub_direct_opt_link_rx_pkg;

package body fub_direct_opt_link_rx_pkg is
end fub_direct_opt_link_rx_pkg;

-- Entity Definition

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE IEEE.STD_LOGIC_arith.all;
USE IEEE.STD_LOGIC_unsigned.all;

entity fub_direct_opt_link_rx is

generic ( 
			bitSize		: integer := 8 ;
			adr_bitSize	: integer := 2 ;
			use_adr		: integer := 1
		) ;

port (	
		clk_i			: in std_logic ;
		rst_i			: in std_logic ;
		opt_data_i		: in std_logic ;
		fub_busy_i		: in std_logic ;
		fub_data_o		: out std_logic_vector( bitSize - 1 downto 0 ) ;
		fub_adr_o		: out std_logic_vector( use_adr * (adr_bitSize - 1) downto 0 ) ;
		fub_str_o		: out std_logic
	 ) ;
	
end fub_direct_opt_link_rx ;

architecture fub_direct_opt_link_rx_arch of fub_direct_opt_link_rx is

component decoder

generic ( 
			packetSize 	: integer := 10 
		);

port (	
		clk_i			: in std_logic ;
		rst_i			: in std_logic ;
		data_i			: in std_logic ;
		data_clk_o		: out std_logic ;
		data_o			: out std_logic
	 );
	
end component ;

component seriell_parallel

generic ( 
			packetSize	: integer := 10 
		) ;

port (  
		rst_i			: in std_logic;
		clk_i			: in std_logic;
		data_i			: in std_logic;
		data_clk_i		: in std_logic;
		data_o			: out std_logic_vector( (bitSize + adr_bitSize) - 1 downto 0 );
		str_o			: out std_logic
	 );

end component;

component fub_output_adr_demux 			
														
generic	( 
			bitSize				: integer := 8;				-- bitsize of the FuB package
		  	adr_bitSize			: integer := 2;				-- bitsize of the outgoing address vector
			use_adr				: integer
		) ;		
											
port ( 	
		rst_i			: in std_logic;
		clk_i			: in std_logic;
		fub_adr_o 		: out std_logic_vector( use_adr * (adr_bitSize - 1) downto 0 );
		data_i			: in std_logic_vector( adr_bitSize + bitSize - 1 downto 0 );
		str_i			: in std_logic;
		fub_data_o		: out std_logic_vector( bitSize - 1 downto 0 );
		fub_str_o		: out std_logic;
		fub_busy_i		: in std_logic
	 );
	
end component;

signal	data_clk_intern		: std_logic ;
signal	data_seriell_intern	: std_logic ;

signal	seriell_parallel_data_o		: std_logic_vector( (bitSize + adr_bitSize) - 1 downto 0 );
signal 	seriell_parallel_str_o		: std_logic;

begin
			
	decoder_inst : decoder
	generic map ( 	
					packetSize	=> (bitSize + adr_bitSize)
				)
	port map (  
				clk_i		=> clk_i,
				rst_i		=> rst_i,
				data_i		=> opt_data_i,
				data_clk_o	=> data_clk_intern,
				data_o		=> data_seriell_intern
			 );
				
				
	seriell_parallel_inst : seriell_parallel
	generic map (	
					packetSize	=> (bitSize + adr_bitSize)
				)
	port map (  
				rst_i		=> rst_i,
				clk_i 		=> clk_i,
				data_i		=> data_seriell_intern,
				data_clk_i	=> data_clk_intern,
				data_o		=> seriell_parallel_data_o,
				str_o		=> seriell_parallel_str_o
			 );
			
	fub_output_adr_demux_inst : fub_output_adr_demux														
	generic	map	( 
					bitSize				=> bitSize,		
				  	adr_bitSize			=> adr_bitSize,
					use_adr				=> use_adr 	
				)												
	port map( 	
				rst_i			=> rst_i,
				clk_i			=> clk_i,
				fub_adr_o 		=> fub_adr_o,
				data_i			=> seriell_parallel_data_o,
				str_i			=> seriell_parallel_str_o,
				fub_data_o		=> fub_data_o,
				fub_str_o		=> fub_str_o,
				fub_busy_i		=> fub_busy_i
			 );
			
			
end fub_direct_opt_link_rx_arch ;