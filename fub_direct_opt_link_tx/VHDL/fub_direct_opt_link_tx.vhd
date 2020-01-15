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

package fub_direct_opt_link_tx_pkg is
component fub_direct_opt_link_tx
	generic ( 	
				bitSize		: integer;
				adr_bitSize	: integer;		-- if use_adr <= 0 choose adr_bitSize = 0
				use_adr		: integer		-- if fub_adr_i not used : use_adr <= 0 || if used : use_adr <= 1
			) ;

	port (	
			clk_i			: in std_logic ;
			rst_i			: in std_logic ;
			fub_data_i		: in std_logic_vector( bitSize - 1 downto 0 ) ;
			fub_adr_i		: in std_logic_vector( use_adr * (adr_bitSize - 1) downto 0 ) ;
			fub_str_i		: in std_logic ;
			fub_busy_o		: out std_logic ;
			opt_data_o		: out std_logic
		 ) ;
end component; 
end fub_direct_opt_link_tx_pkg;

package body fub_direct_opt_link_tx_pkg is
end fub_direct_opt_link_tx_pkg;

-- Entity Definition

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE IEEE.STD_LOGIC_arith.all;
USE IEEE.STD_LOGIC_unsigned.all;

entity fub_direct_opt_link_tx is

generic ( 	
			bitSize		: integer := 8 ;
			adr_bitSize	: integer := 2 ;
			use_adr		: integer := 1		-- if use_adr <= 0 choose adr_bitSize = 0
		) ;

port (	
		clk_i			: in std_logic ;
		rst_i			: in std_logic ;
		fub_data_i		: in std_logic_vector( bitSize - 1 downto 0 ) ;
		fub_adr_i		: in std_logic_vector( use_adr * (adr_bitSize - 1) downto 0 ) ;
		fub_str_i		: in std_logic ;
		fub_busy_o		: out std_logic ;
		opt_data_o		: out std_logic
	 ) ;
	
end fub_direct_opt_link_tx ;

architecture fub_direct_opt_link_tx_arch of fub_direct_opt_link_tx is

component encoder

generic ( 
			packetSize	: integer 	:= 10 
		) ; 
									
port ( 	
		clk_i		: in std_logic;
		str_i		: in std_logic;
		rst_i		: in std_logic;
		data_i		: in std_logic;			--  data:
		opt_data_o	: out std_logic			--  frequency = 1/2 clk frequenz
	  );								
	
end component ;

component fub_input_adr_mux							
														
generic	( 
			bitSize				: integer := 8;				-- bitsize of the FuB package
		  	adr_bitSize			: integer := 2;				-- bitsize of the incomming address vector
			use_adr				: integer := 1
		) ;		
											
port ( 	
		rst_i			: in std_logic;
		clk_i			: in std_logic;
		fub_adr_i 		: in std_logic_vector( use_adr * (adr_bitSize - 1) downto 0 );
		fub_data_i		: in std_logic_vector( bitSize - 1 downto 0 );
		fub_str_i		: in std_logic;
		fub_busy_o		: out std_logic;
		data_o		: out std_logic_vector( bitSize + adr_bitSize - 1 downto 0 );
		str_o		: out std_logic;
		busy_i		: in std_logic
	 );
	
end component;

component parallel_seriell

generic ( 	
			packetSize 	: integer := 10 
		);

port ( 	
		clk_i	   		: in std_logic;
		rst_i	    	: in std_logic;
		data_i			: in std_logic_vector( packetSize - 1 downto 0 );
		str_i			: in std_logic;
		busy_o			: out std_logic;
		data_o			: out std_logic;
		str_o			: out std_logic
	 );
	
end component ;

signal parallel_seriell_str_o		: std_logic ;
signal parallel_seriell_data_o		: std_logic ;
signal parallel_seriell_busy_o		: std_logic ;

signal fub_input_add_mux_data_o		: std_logic_vector( adr_bitSize + bitSize - 1 downto 0 ) ;
signal fub_input_add_mux_str_o		: std_logic ;

begin

fub_input_adr_mux_inst : fub_input_adr_mux														
generic	map	( 
				bitSize				=> bitSize,			
			  	adr_bitSize			=> adr_bitSize,
				use_adr				=> use_adr 				
			)											
port map( 	
			rst_i			=> rst_i,
			clk_i			=> clk_i,
			fub_adr_i 		=> fub_adr_i,
			fub_data_i		=> fub_data_i,
			fub_str_i		=> fub_str_i,
			fub_busy_o		=> fub_busy_o,
			data_o			=> fub_input_add_mux_data_o,
			str_o		=> fub_input_add_mux_str_o,
			busy_i		=> parallel_seriell_busy_o
		 );

	parallel_seriell_inst : parallel_seriell	
	generic map (
					packetSize	=> (adr_bitSize + bitSize)
				)
	port map (
				clk_i		=> clk_i,
				rst_i		=> rst_i,
				data_i		=> fub_input_add_mux_data_o,
				str_i		=> fub_input_add_mux_str_o,
				busy_o		=> parallel_seriell_busy_o,
				data_o		=> parallel_seriell_data_o,
				str_o		=> parallel_seriell_str_o
			 ) ;
			
	encoder_inst : encoder	
	generic map ( 
					packetSize	=> (adr_bitSize + bitSize)
				)
	port map (
				clk_i		=> clk_i,
				rst_i		=> rst_i,
				str_i		=> parallel_seriell_str_o,
				data_i		=> parallel_seriell_data_o,
				opt_data_o	=> opt_data_o
			 ) ;
			
end fub_direct_opt_link_tx_arch ;
			