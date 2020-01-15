LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE IEEE.STD_LOGIC_arith.all;
USE IEEE.STD_LOGIC_unsigned.all;

entity decoder_ring is

port (	
		clk_i			: in std_logic ;
		rst_i			: in std_logic ;
		data_i			: in std_logic ;
		delete_all_i	: in std_logic ;
		observer_data	: out std_logic;	-----------------------------
		reset_detected_i	: in std_logic ;
		token_deleted_o		: out std_logic ;
		ring_got_data_o		: out std_logic ;
		ring_str_o			: out std_logic ;
		trigger_o			: out std_logic ;
		data_clk_o			: out std_logic ;
		no_more_data_o		: out std_logic ;
		sending_i			: in std_logic ;
		data_o				: out std_logic
	 );
	
end decoder_ring ;

architecture decoder_ring_arch of decoder_ring is

signal data_intern						: std_logic ;
signal set_intern						: std_logic ;
signal sending_sync						: std_logic ;
signal decoder_sync_reset_detected_o	: std_logic ;

component decoder_comparator_ring

port ( 	
		clk_i				: in std_logic;
		rst_i				: in std_logic;
		data_i				: in std_logic;
		observer_data		: out std_logic;	-----------------------------
		value_o				: out std_logic;
		set_o				: out std_logic
	 );
	
end component ;

component decoder_sync

port (  
		clk_i	: in std_logic ;
		rst_i	: in std_logic ;
		data_i				: in std_logic ;
		reset_detected_i	: in std_logic ;
		reset_detected_o	: out std_logic ;
		data_o 				: out std_logic
	 );
	
end component;

component decoder_main_ring	

generic	( 
		  wait_clk			: integer := 2 	-- depends on sampling frequency					
		) ;												
port ( 	
		rst_i			: in std_logic ;
		clk_i			: in std_logic ;
		set_i				: in std_logic ;
		value_i				: in std_logic ;
		delete_all_i		: in std_logic ;
		reset_detected_i	: in std_logic ;
		ring_got_data_o		: out std_logic ;
		sending_i			: in std_logic ;
		token_deleted_o		: out std_logic ;
		trigger_o			: out std_logic ;
		ring_str_o			: out std_logic ;
		data_clk_o			: out std_logic ;
		no_more_data_o		: out std_logic ;
		data_o				: out std_logic 
	 );
	
end component ;

begin

	decoder_comparator_inst_ring : decoder_comparator_ring
	port map (	
				clk_i 				=> clk_i,
				rst_i 				=> rst_i,
				data_i				=> data_i,
				observer_data		=> observer_data,	-----------------------------
				value_o				=> data_intern,
				set_o 				=> set_intern
			 ) ;
	
	decoder_sync_inst : decoder_sync
	port map (  
				clk_i	=> clk_i,
				rst_i	=> rst_i,
				data_i	=> sending_i,
				data_o 	=> sending_sync,
				reset_detected_i	=> reset_detected_i,
				reset_detected_o	=> decoder_sync_reset_detected_o
			 );
				
	decoder_main_inst_ring : decoder_main_ring
	generic map ( 
					wait_clk	=> 2 
				)
	port map ( 	
				clk_i 			=> clk_i,
				rst_i 			=> rst_i,
				set_i 				=> set_intern,
				value_i				=> data_intern,
				sending_i			=> sending_sync,
				delete_all_i		=> delete_all_i,
				reset_detected_i	=> decoder_sync_reset_detected_o,
				token_deleted_o		=> token_deleted_o,
				ring_got_data_o		=> ring_got_data_o,
				ring_str_o			=> ring_str_o,
				trigger_o			=> trigger_o,
				data_clk_O 			=> data_clk_o,
				no_more_data_o		=> no_more_data_o,
				data_o 				=> data_o
			 );
			
end decoder_ring_arch;