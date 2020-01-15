LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE IEEE.STD_LOGIC_arith.all;
USE IEEE.STD_LOGIC_unsigned.all;

entity decoder is

generic ( 
			packetSize 	: integer := 10
		);

port (	
		clk_i		: in std_logic ;
		rst_i		: in std_logic ;
		data_i		: in std_logic ;
		data_clk_o	: out std_logic ;
		data_o		: out std_logic
	 );
	
end decoder ;

architecture decoder_arch of decoder is

signal data_intern			: std_logic ;
signal set_intern			: std_logic ;

component decoder_comparator

port ( 	
		clk_i	: in std_logic;
		rst_i	: in std_logic;
		data_i	: in std_logic;
		value_o	: out std_logic;
		set_o	: out std_logic
	 );
	
end component ;

component decoder_main

generic	( 
			wait_clk		: integer := 2; 		-- depends on sampling frequency
		 	packetSize		: integer := 10 			--  [ f decoder(real, including delta f ) / f clk ] >> [ wait_clk + 1 ] >=  [ 1/2 f decoder(real) / f clk ]
		) ;		
											
port ( 	
		rst_i		: in std_logic ;
		clk_i		: in std_logic ;
		set_i		: in std_logic ;
		value_i		: in std_logic ;
		data_clk_o	: out std_logic ;
		data_o		: out std_logic 
	 );
	
end component ;

begin

	decoder_comparator_inst : decoder_comparator
	port map (	
				clk_i 	=> clk_i,
				rst_i 	=> rst_i,
				data_i	=> data_i,
				value_o	=> data_intern,
				set_o 	=> set_intern
			 ) ;
			
	decoder_main_inst : decoder_main
	generic map (
					wait_clk	=> 2, 
					packetSize	=> packetSize
				)
	port map ( 	
				clk_i 		=> clk_i,
				rst_i 		=> rst_i,
				set_i 		=> set_intern,
				value_i		=> data_intern,
				data_clk_O 	=> data_clk_o,
				data_o 		=> data_o
			 );
			
end decoder_arch;