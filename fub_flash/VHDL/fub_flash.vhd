-------------------------------------------------------------------------------
--
-- 2007 @ GSI
-- Th. Guthier
--
-------------------------------------------------------------------------------

-- Package Definition

library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_arith.all;
use IEEE.STD_LOGIC_unsigned.all;

package fub_flash_pkg is
component fub_flash
generic (
		    main_clk       				: real := 50.0E+6;
			priority_on_reading			: std_logic := '1';
		    my_delay_in_ns_for_reading 	: real := 25.0;		-- equal to 40 MHz // 25ns high 25ns low => 50ns equal to 20MHz CLK Signal
			my_delay_in_ns_for_writing 	: real := 20.0;		-- equal to 50 MHz // 20ns high 20ns low => 40ns equal to 25MHz CLK Signal
			erase_in_front_of_write		: std_logic := '1'
		);										
port (  
		clk_i			: in std_logic ;
		rst_i			: in std_logic ;
		fub_write_busy_o		: out std_logic ;
		fub_write_data_i		: in std_logic_vector( 7 downto 0 ) ;
		fub_write_adr_i			: in std_logic_vector( 23 downto 0 ) ;
		fub_write_str_i 		: in std_logic ;
		fub_read_busy_o		: out std_logic ;
		fub_read_data_o		: out std_logic_vector( 7 downto 0 ) ;
		fub_read_adr_i		: in std_logic_vector( 23 downto 0 ) ;
		fub_read_str_i 		: in std_logic ;
		erase_str_i					: in std_logic;
		erase_adr_i					: in std_logic_vector( 23 downto 0 ) ;
		nCS_o					: out std_logic;
		asdi_o					: out std_logic;
		dclk_o					: out std_logic;
		data_i					: in std_logic
	 );
end component; 
end fub_flash_pkg;

package body fub_flash_pkg is
end fub_flash_pkg;

-- Entity Definition


LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE IEEE.STD_LOGIC_arith.all;
USE IEEE.STD_LOGIC_unsigned.all;

USE work.real_time_calculator_pkg.all;

entity fub_flash is

generic (
		    main_clk       				: real := 50.0E+6;
			priority_on_reading			: std_logic := '1';
		    my_delay_in_ns_for_reading 	: real := 25.0;		-- equal to 40 MHz // 25ns high 25ns low => 50ns equal to 20MHz CLK Signal
			my_delay_in_ns_for_writing 	: real := 20.0;		-- equal to 50 MHz // 20ns high 20ns low => 40ns equal to 25MHz CLK Signal
			erase_in_front_of_write		: std_logic := '1'
		);

port (  
		clk_i			: in std_logic ;
		rst_i			: in std_logic ;
		fub_write_busy_o		: out std_logic ;
		fub_write_data_i		: in std_logic_vector( 7 downto 0 ) ;
		fub_write_adr_i			: in std_logic_vector( 23 downto 0 ) ;
		fub_write_str_i 		: in std_logic ;
		fub_read_busy_o		: out std_logic ;
		fub_read_data_o		: out std_logic_vector( 7 downto 0 ) ;
		fub_read_adr_i		: in std_logic_vector( 23 downto 0 ) ;
		fub_read_str_i 		: in std_logic ;
		erase_str_i					: in std_logic;
		erase_adr_i					: in std_logic_vector( 23 downto 0 ) ;
		nCS_o					: out std_logic;
		asdi_o					: out std_logic;
		dclk_o					: out std_logic;
		data_i					: in std_logic
	 );

end fub_flash;

architecture fub_flash_arch of fub_flash is

type state_type is ( START, START_READ_END, START_WRITE_END, ERASE_SET_ENABLE_OPCODE, ERASE_ENABLE_NCS_HIGH, ERASE_SET_ERASE_OPCODE, ERASE_SET_ADR, ERASE_NCS_HIGH, ERASE_SET_READ_STATUS_OPCODE, ERASE_READ_STATUS, ERASE_PROOF_STATUS, ERASE_END_NCS_HIGH, WRITE_READ_STATUS, WRITE_PROOF_STATUS, WRITE_SET_READ_STATUS_OPCODE, WRITE_NCS_HIGH, WRITE_PROOF_NEXT_ADR, WRITE_WAIT, WRITE_WAIT_PROOF, WRITE_DATA, WRITE_SET_ADR, WRITE_SET_WRITE_OPCODE, WRITE_ENABLE_NCS_HIGH, WRITE_SET_ENABLE_OPCODE, BYTE_TO_FLASH_STATE1, BYTE_TO_FLASH_STATE2, BYTE_FROM_FLASH_START, BYTE_FROM_FLASH_STATE1, BYTE_FROM_FLASH_STATE2, RESET_NCS, READ_SET_OPCODE, READ_SET_ADR, READ_START_READING, READ_RECEIVE_DATA, READ_STREAMING_WAIT, READ_STREAMING_PROOF ); 

signal state						: state_type ;
signal next_state					: state_type ;

type adr_byte_array_type is array(0 to 2) of std_logic_vector(7 downto 0);

signal adr_byte_array : adr_byte_array_type;

signal delay_in_ticks_ceil_for_reading : integer := get_delay_in_ticks_ceil(main_clk, my_delay_in_ns_for_reading);
signal delay_in_ticks_ceil_for_writing : integer := get_delay_in_ticks_ceil(main_clk, my_delay_in_ns_for_writing);

signal count_ticks_for_reading	: integer;
signal count_ticks_for_writing	: integer;

signal byte_to_flash_count		: integer range 7 downto 0;
signal byte_to_flash			: std_logic_vector(7 downto 0);

signal byte_from_flash_count	: integer range 7 downto 0;
signal byte_from_flash			: std_logic_vector(7 downto 0);

signal count_adr				: integer range 2 downto 0;

signal fub_read_adr_intern		: std_logic_vector(23 downto 0);
signal fub_read_adr_saved		: std_logic_vector(23 downto 0);
signal intern_read_str			: std_logic;

signal fub_write_adr_intern		: std_logic_vector(23 downto 0);
signal fub_write_data_intern	: std_logic_vector(7 downto 0); 
signal fub_write_adr_saved		: std_logic_vector(23 downto 0);
signal fub_write_data_saved		: std_logic_vector(7 downto 0); 
signal intern_write_str			: std_logic;

signal erase_adr_intern			: std_logic_vector(23 downto 0);

signal write_flag				: std_logic;
signal erase_flag				: std_logic;

signal calculate				: std_logic_vector(23 downto 0);

begin

	fub_flash_process : process( clk_i, rst_i )
	begin
		if rst_i = '1' then
			fub_read_data_o		<= (others => '0');
			fub_write_busy_o	<= '0';
			fub_read_busy_o		<= '0';
			state				<= START;
			next_state			<= START;
			count_adr					<= 2;
			count_ticks_for_writing		<= delay_in_ticks_ceil_for_writing - 1;
			count_ticks_for_reading		<= delay_in_ticks_ceil_for_reading - 1;
			byte_to_flash_count			<= 7;		-- start with MSB
			byte_from_flash_count		<= 7;		-- start with MSB
			byte_to_flash				<= (others => '0');
			byte_from_flash				<= (others => '0');
			fub_read_adr_intern			<= (others => '0');
			fub_write_adr_intern		<= (others => '0');
			fub_write_data_intern		<= (others => '0');
			fub_write_adr_saved			<= (others => '0');
			fub_write_data_saved		<= (others => '0');
			fub_read_adr_saved			<= (others => '0');
			adr_byte_array(0)			<= (others => '0');
			adr_byte_array(1)			<= (others => '0');
			adr_byte_array(2)			<= (others => '0');
			erase_adr_intern			<= (others => '0');
			erase_flag					<= '0';
			intern_write_str			<= '0';
			intern_read_str				<= '0';
			write_flag					<= '0';
			nCS_o						<= '1';
			asdi_o						<= '0';
			dclk_o						<= '1';
			calculate					<= (others => '0');
		elsif clk_i'event and clk_i = '1' then
			case state is
-------------------------------------------------------------------------------------------------					
---------------------------|| START  SEQUENZ ||--------------------------------------------------
-------------------------------------------------------------------------------------------------	
				when START =>
					if erase_str_i = '1' then
						nCS_o				<= '0';				--|| nCS_o reset
						state				<= ERASE_SET_ENABLE_OPCODE;
						erase_adr_intern	<= erase_adr_i;
						erase_flag			<= '1';
						fub_read_busy_o		<= '1';			--|| fub_read_busy set
						fub_write_busy_o	<= '1';			--|| fub_write_busy set
					elsif fub_read_str_i = '1' and fub_write_str_i = '1' then
						fub_write_adr_saved		<= fub_write_adr_i;		--// store adr
						fub_write_data_saved	<= fub_write_data_i;	--// store data
						fub_read_adr_saved		<= fub_read_adr_i;		--// store adr
						fub_read_busy_o			<= '1';					--|| fub_read_busy set
						fub_write_busy_o		<= '1';					--|| fub_write_busy set
						nCS_o					<= '0';				--|| nCS_o reset
						if priority_on_reading = '1' then	-- start READING
							state					<= READ_SET_OPCODE;
							fub_read_adr_intern		<= fub_read_adr_i;			-- read in adr
							intern_write_str		<= '1';					--// intern_read_str set
						else		-- start WRITING
							if erase_in_front_of_write = '1' then
								state				<= ERASE_SET_ENABLE_OPCODE;
								erase_adr_intern	<= fub_write_adr_i;
							else
								state				<= WRITE_SET_ENABLE_OPCODE;					
							end if;
							fub_write_adr_intern	<= fub_write_adr_i;			-- read in adr
							fub_write_data_intern	<= fub_write_data_i;
							intern_read_str			<= '1';					--// intern_read_str set
						end if;
					elsif fub_read_str_i = '1' then		-- start READING
						state					<= READ_SET_OPCODE;
						fub_read_adr_intern		<= fub_read_adr_i;			-- read in adr
						nCS_o					<= '0';				--|| nCS_o reset
						fub_read_busy_o			<= '1';					--|| fub_read_busy set
						fub_write_busy_o		<= '1';					--|| fub_write_busy set
					elsif fub_write_str_i = '1' then	-- start WRITING
						if erase_in_front_of_write = '1' then
							state				<= ERASE_SET_ENABLE_OPCODE;
							erase_adr_intern	<= fub_write_adr_i;
						else
							state				<= WRITE_SET_ENABLE_OPCODE;					
						end if;
						fub_write_adr_intern	<= fub_write_adr_i;			-- read in adr
						fub_write_data_intern	<= fub_write_data_i;
						nCS_o					<= '0';				--|| nCS_o reset
						fub_read_busy_o			<= '1';					--|| fub_read_busy set
						fub_write_busy_o		<= '1';					--|| fub_write_busy set
					else
						state					<= START;
					end if;
				when START_READ_END =>
					if fub_read_str_i = '1' then		-- again READ Data // possible because BUSY got reset last clk...
						next_state				<= READ_SET_OPCODE;
						state					<= RESET_NCS;
						fub_read_adr_intern		<= fub_read_adr_i;
					elsif intern_write_str = '1' then		-- START WRITING
						intern_write_str		<= '0';						--// reset intern_write_str
						nCS_o					<= '0';					--|| nCS_o reset
						if erase_in_front_of_write = '1' then
							state				<= ERASE_SET_ENABLE_OPCODE;
							erase_adr_intern	<= fub_write_adr_saved;
						else
							state				<= WRITE_SET_ENABLE_OPCODE;					
						end if;
						fub_write_adr_intern	<= fub_write_adr_saved;		--// restore saved adr
						fub_write_data_intern	<= fub_write_data_saved;	--// restore daved data
					else				-- finaly go to START again
						state				<= START;
						fub_read_busy_o		<= '0';				--|| fub_read_busy reset
						fub_write_busy_o	<= '0';				--|| fub_write_busy reset
					end if;
				when START_WRITE_END =>
					if intern_read_str = '1' then
						intern_read_str		<= '0';						--// reset intern_write_str
						fub_read_adr_intern	<= fub_read_adr_saved;		--// restore saved adr
						nCS_o				<= '0';					--|| nCS_o reset
						state				<= READ_SET_OPCODE;
					else				-- finaly go to START again
						state				<= START;
						fub_read_busy_o		<= '0';				--|| fub_read_busy reset
						fub_write_busy_o	<= '0';				--|| fub_write_busy reset
					end if;
-------------------------------------------------------------------------------------------------					
----------------------------|| READ  SEQUENZ ||------ all STATES longing to READ start with READ_
-------------------------------------------------------------------------------------------------				
				when READ_SET_OPCODE =>
					state				<= BYTE_TO_FLASH_STATE1;	-- set out the OPCODE
					next_state			<= READ_SET_ADR;			-- parameter for BYTE_TO_FLASH
					byte_to_flash		<= "00000011";				-- parameter for BYTE_TO_FLASH
					adr_byte_array(0)	<= fub_read_adr_intern(7 downto 0);
					adr_byte_array(1)	<= fub_read_adr_intern(15 downto 8);
					adr_byte_array(2)	<= fub_read_adr_intern(23 downto 16);
				when READ_SET_ADR =>				-- set out the 3 ADR BYTES with the MSB first
					state			<= BYTE_TO_FLASH_STATE1;	-- set out the ADR
					byte_to_flash	<= adr_byte_array(count_adr);	-- parameter for BYTE_TO_FLASH					
					if count_adr > 0 then
						count_adr		<= count_adr - 1;
						next_state		<= READ_SET_ADR;				-- parameter for BYTE_TO_FLASH
					else			-- last ADR BYTE
						count_adr		<= 2;
						next_state		<= READ_START_READING;			-- parameter for BYTE_TO_FLASH
					end if;
				when READ_START_READING =>
					state				<= BYTE_FROM_FLASH_START;
					next_state			<= READ_RECEIVE_DATA;
				when READ_RECEIVE_DATA =>
					fub_read_data_o		<= byte_from_flash;			--|| set out data
					fub_read_busy_o		<= '0';						--|| reset fub_read_busy_o 
					if fub_read_str_i = '1' then
						state	<= READ_STREAMING_PROOF;
					else
						state	<= READ_STREAMING_WAIT;
					end if;
				when READ_STREAMING_WAIT =>
					state		<= READ_STREAMING_PROOF;
				when READ_STREAMING_PROOF =>
					fub_read_busy_o			<= '1';					--|| set fub_read_busy_o
					if fub_read_str_i = '1' then
						fub_read_adr_intern		<= fub_read_adr_i;
						if fub_read_adr_i = (fub_read_adr_intern + "000000000000000000000001") then
							state				<= READ_START_READING;	-- STREAMING
						else											-- START NEW READING SEQUENCE
							next_state			<= READ_SET_OPCODE;
							state				<= RESET_NCS;
							nCS_o				<= '1';					--|| nCS_o set
						end if;
					else
						state	<= START_READ_END;		-- finished READING
						nCS_o	<= '1';									--|| nCS_o set
					end if;
----------// end of READ SEQUENZ
-----------------------------------------------------------------------------------------------
--------------------||| ERASE SECTOR SEQUENCE ||| all STATES longing to ERASE start with ERASE_
--------------------| ERASE THE SECTOR OF THE INPUT ADR 	|----------------------------------
--------------------| needed in front of every WRITE CYCLE  |----------------------------------
				when ERASE_SET_ENABLE_OPCODE =>
					state			<= BYTE_TO_FLASH_STATE1;		-- set out OPCODE
					next_state		<= ERASE_ENABLE_NCS_HIGH;		-- parameter for BYTE_TO_FLASH
					byte_to_flash	<= "00000110";					-- parameter for BYTE_TO_FLASH
				when ERASE_ENABLE_NCS_HIGH =>	-- set nCS <= '1' for some time // needed after WRITE_ENABLE
					nCS_o			<= '1';				--|| ncs_o set
					state			<= RESET_NCS;
					next_state		<= ERASE_SET_ERASE_OPCODE;
				when ERASE_SET_ERASE_OPCODE =>
					state				<= BYTE_TO_FLASH_STATE1;	-- set out OPCODE
					next_state			<= ERASE_SET_ADR;			-- parameter for BYTE_TO_FLASH
					byte_to_flash		<= "11011000";				-- parameter for BYTE_TO_FLASH
					adr_byte_array(0)	<= fub_write_adr_intern(7 downto 0);
					adr_byte_array(1)	<= fub_write_adr_intern(15 downto 8);
					adr_byte_array(2)	<= fub_write_adr_intern(23 downto 16);
				when ERASE_SET_ADR =>
					state			<= BYTE_TO_FLASH_STATE1;	-- set out the ADR
					byte_to_flash	<= adr_byte_array(count_adr);	-- parameter for BYTE_TO_FLASH
					if count_adr > 0 then
						count_adr		<= count_adr - 1;
						next_state		<= ERASE_SET_ADR;		-- parameter for BYTE_TO_FLASH
					else			-- last ADR BYTE
						count_adr		<= 2;
						next_state		<= ERASE_NCS_HIGH;		-- parameter for BYTE_TO_FLASH
					end if;
				when ERASE_NCS_HIGH =>
					ncs_o			<= '1';					--|| ncs_o set
					next_state		<= ERASE_SET_READ_STATUS_OPCODE;
					state			<= RESET_NCS;
				when ERASE_SET_READ_STATUS_OPCODE =>
					state				<= BYTE_TO_FLASH_STATE1;	-- set out opcode for read_status
					byte_to_flash		<= "00000101";					-- parameter for BYTE_TO_FLASH
					next_state			<= ERASE_READ_STATUS;			-- parameter for BYTE_TO_FLASH
				when ERASE_READ_STATUS =>
					state				<= BYTE_FROM_FLASH_START;
					next_state			<= ERASE_PROOF_STATUS;			
				when ERASE_PROOF_STATUS =>
					if byte_from_flash(0) = '0' then
						nCS_o		<= '1';			--|| ncs_o set
						state		<= ERASE_END_NCS_HIGH;			-- finished erasing
					else				-- erasing still in progress / proof again
						state		<= ERASE_READ_STATUS;
					end if;
				when ERASE_END_NCS_HIGH =>
					ncs_o			<= '1';					--|| ncs_o set
					if erase_flag = '1' then			-- just erasing
						erase_flag			<= '0';
						next_state			<= START;
						fub_read_busy_o		<= '0';			--|| fub_read_busy reset
						fub_write_busy_o	<= '0';			--|| fub_write_busy reset
					else
						next_state		<= WRITE_SET_ENABLE_OPCODE;		-- JUMP to WRITE SEQUENCE
					end if;
					state			<= RESET_NCS;
----------// end of ERASE SEQUENZ
-------------------------------------------------------------------------------------------------
---------------------|| WRITE SEQUENZ ||------	all STATES longing to WRITE start with WRITE_----					
-------------------------------------------------------------------------------------------------					
				when WRITE_SET_ENABLE_OPCODE =>
					state			<= BYTE_TO_FLASH_STATE1;		-- set out OPCODE
					next_state		<= WRITE_ENABLE_NCS_HIGH;		-- parameter for BYTE_TO_FLASH
					byte_to_flash	<= "00000110";					-- parameter for BYTE_TO_FLASH
				when WRITE_ENABLE_NCS_HIGH =>	-- set nCS <= '1' for some time // needed after WRITE_ENABLE
					nCS_o			<= '1';				--|| ncs_o set
					state			<= RESET_NCS;
					next_state		<= WRITE_SET_WRITE_OPCODE;
				when WRITE_SET_WRITE_OPCODE =>
					state				<= BYTE_TO_FLASH_STATE1;	-- set out OPCODE
					next_state			<= WRITE_SET_ADR;			-- parameter for BYTE_TO_FLASH
					byte_to_flash		<= "00000010";				-- parameter for BYTE_TO_FLASH
					adr_byte_array(0)	<= erase_adr_intern(7 downto 0);
					adr_byte_array(1)	<= erase_adr_intern(15 downto 8);
					adr_byte_array(2)	<= erase_adr_intern(23 downto 16);
				when WRITE_SET_ADR =>
					state			<= BYTE_TO_FLASH_STATE1;	-- set out the ADR
					byte_to_flash	<= adr_byte_array(count_adr);	-- parameter for BYTE_TO_FLASH
					if count_adr > 0 then
						count_adr		<= count_adr - 1;
						next_state		<= WRITE_SET_ADR;		-- parameter for BYTE_TO_FLASH
					else			-- last ADR BYTE
						count_adr		<= 2;
						next_state		<= WRITE_DATA;			-- parameter for BYTE_TO_FLASH
					end if;
				when WRITE_DATA =>
					state				<= BYTE_TO_FLASH_STATE1;	-- set out fub_write_data_i
					byte_to_flash		<= fub_write_data_intern;		-- parameter for BYTE_TO_FLASH
					next_state			<= WRITE_WAIT_PROOF;			-- parameter for BYTE_TO_FLASH				
				when WRITE_WAIT_PROOF => 
					fub_write_busy_o	<= '0';					--|| reset fub_write_busy_o
					if fub_write_str_i = '1' then
						state		<= WRITE_PROOF_NEXT_ADR;
					else
						state		<= WRITE_WAIT;
					end if;	
					calculate		<= (fub_write_adr_intern + "000000000000000000000001");
				when WRITE_WAIT =>
					state			<= WRITE_PROOF_NEXT_ADR;			-- this path might be critical if there will be a sudden str and again another str in the following clk	
				when WRITE_PROOF_NEXT_ADR =>
					fub_write_busy_o		<= '1';				--|| set fub_read_busy_o
					if fub_write_str_i = '1' then
						fub_write_adr_intern	<= fub_write_adr_i;
						fub_write_data_intern	<= fub_write_data_i;						
						if ( (fub_write_adr_intern(8) = calculate(8) ) and ( fub_write_adr_i = calculate ) ) then	-- needed cause of flash internal stream conditions
							state		<= WRITE_DATA;		-- STREAMING
						else								-- not STREAMING // but continue WRITING			
							write_flag	<= '1';						--// write_flag set
							state		<= WRITE_NCS_HIGH;
						end if;
					else								-- all written						
						state			<= WRITE_NCS_HIGH;
					end if;					
				when WRITE_NCS_HIGH =>
					ncs_o			<= '1';					--|| ncs_o set
					next_state		<= WRITE_SET_READ_STATUS_OPCODE;
					state			<= RESET_NCS;
				when WRITE_SET_READ_STATUS_OPCODE =>
					state				<= BYTE_TO_FLASH_STATE1;	-- set out opcode for read_status
					byte_to_flash		<= "00000101";					-- parameter for BYTE_TO_FLASH
					next_state			<= WRITE_READ_STATUS;			-- parameter for BYTE_TO_FLASH
				when WRITE_READ_STATUS =>
					state				<= BYTE_FROM_FLASH_START;
					next_state			<= WRITE_PROOF_STATUS;
				when WRITE_PROOF_STATUS =>
					if byte_from_flash(0) = '0' then
						nCS_o		<= '1';			--|| ncs_o set
						if write_flag = '1' then		-- continue WRITING
							write_flag		<= '0';			--// reset write_flag
							next_state		<= WRITE_SET_ENABLE_OPCODE;
							state			<= RESET_NCS;
						else							-- finished WRITING
							state					<= START_WRITE_END;
						end if;
					else					-- writing still in progress / proof again
						state			<= WRITE_READ_STATUS;
					end if;
----------// end of WRITE SEQUENZ
-----------------------------------------------------------------------------------------------						
--------------------||| BYTE_TO_FLASH SEQUENCE |||---------------------------------------------
--------------------| sends data saved in "byte_to_flash" to the flash |-----------------------
--------------------| and jumpes to state saved in "next_state" when finished |----------------					
				when BYTE_TO_FLASH_STATE1 =>			
					dclk_o					<= '0';						--|| reset dclk_o
					asdi_o					<= byte_to_flash(byte_to_flash_count); 
					if count_ticks_for_writing > 0 then		-- stay in state (needed cause of clk)
						state						<= BYTE_TO_FLASH_STATE1;
						count_ticks_for_writing		<= count_ticks_for_writing - 1;							
					else									-- change state
						count_ticks_for_writing		<= delay_in_ticks_ceil_for_writing - 1;
						state						<= BYTE_TO_FLASH_STATE2;							
					end if;					
				when BYTE_TO_FLASH_STATE2 =>
					dclk_o			<= '1';						--|| set dclk_o 
					if count_ticks_for_writing > 0 then		-- stay in state (needed cause of clk)
						state						<= BYTE_TO_FLASH_STATE2;
						count_ticks_for_writing		<= count_ticks_for_writing - 1;						
					else									-- change state
						count_ticks_for_writing		<= delay_in_ticks_ceil_for_writing - 1;
						if byte_to_flash_count > 0 then
							byte_to_flash_count		<= byte_to_flash_count - 1;
							state					<= BYTE_TO_FLASH_STATE1;								
						else								-- byte writen
							byte_to_flash_count		<= 7;			-- start next writing sequence with MSB
							state					<= next_state;	-- JUMP back to the main sequence
						end if;
					end if;
------------- // end of BYTE_TO_FLASH
-------------------------------------------------------------------------------------------------
--------------------||| BYTE_FROM_FLASH SEQUENCE |||---------------------------------------------
--------------------| receives data saved in flash |---------------------------------------------
--------------------| and jumpes to state saved in "next_state" when finished |------------------	
				when BYTE_FROM_FLASH_START =>
					dclk_o			<= '0';					--|| dclk_o reset
					if count_ticks_for_reading > 0 then 	-- stay in state (needed cause of clk)
						count_ticks_for_reading		<= count_ticks_for_reading - 1;
						state						<= BYTE_FROM_FLASH_START;
					else									-- change state
						count_ticks_for_reading		<= delay_in_ticks_ceil_for_reading - 1;
						state						<= BYTE_FROM_FLASH_STATE1;
					end if;				
				when BYTE_FROM_FLASH_STATE1 =>	
					dclk_o			<= '1';					--|| dclk_o set
					if count_ticks_for_reading > 0 then 	-- stay in state (needed cause of clk)
						count_ticks_for_reading		<= count_ticks_for_reading - 1;
						state						<= BYTE_FROM_FLASH_STATE1;
					else									-- change state
						count_ticks_for_reading		<= delay_in_ticks_ceil_for_reading - 1;
						state						<= BYTE_FROM_FLASH_STATE2;
					end if;				
				when BYTE_FROM_FLASH_STATE2 =>
					dclk_o									<= '0';			--|| dclk_o reset
					byte_from_flash(byte_from_flash_count)	<= data_i;		-- read in data from flash
					if count_ticks_for_reading > 0 then 	-- stay in state (needed cause of clk)
						count_ticks_for_reading		<= count_ticks_for_reading - 1;
						state						<= BYTE_FROM_FLASH_STATE2;
					else									-- change state
						count_ticks_for_reading		<= delay_in_ticks_ceil_for_reading - 1;
						if byte_from_flash_count > 0 then
							state					<= BYTE_FROM_FLASH_STATE1;
							byte_from_flash_count	<= byte_from_flash_count - 1;
						else
							state					<= next_state;	-- JUMP back to the main sequence
							byte_from_flash_count	<= 7;			-- start next writing sequence with MSB
						end if;
					end if;		
----------- // end of BYTE_FROM_FLASH
-------------------------------------------------------------------------------------------------
--------------------||| RESET NCS SEQUENCE |||---------------------------------------------------
--------------------| resets the nCS Signal to restart an operation |----------------------------
--------------------| and jumpes to state saved in "next_state" when finished |------------------
				when RESET_NCS =>
					if count_ticks_for_reading > 0 then 	-- stay in state (needed cause nCS delay) // using count_ticks_for_reading is a random choice
						count_ticks_for_reading		<= count_ticks_for_reading - 1;
						state						<= RESET_NCS;
					elsif count_ticks_for_writing > 0 then
						count_ticks_for_writing		<= count_ticks_for_writing - 1;
						state						<= RESET_NCS;
					else									-- change state
						count_ticks_for_reading		<= delay_in_ticks_ceil_for_reading - 1;
						count_ticks_for_writing		<= delay_in_ticks_ceil_for_writing - 1;
						state						<= next_state;
						nCS_o						<= '0';					--|| nCS_o reset
					end if;		
----------- // end of RESET NCS					
			end case;
		end if;
	end process;
	
end fub_flash_arch ;
			