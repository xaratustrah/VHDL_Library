-------------------------------------------------------------------------------
--
-- 2007 @ GSI Th. Guthier
-- modified 17.11.2009 for compatibility to fub_multi_spi_master
-- by T.Wollmann
--
-------------------------------------------------------------------------------

-- Package Definition

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

package fub_flash_multi_pkg is

	component fub_flash_multi
		generic (
			priority_on_reading						: std_logic 		:= '1';
			erase_in_front_of_write				: std_logic 		:= '1';
			read_block										:	integer				:= 	1;
			write_block										:	integer				:=	1;
			spi_address										:	integer				:=	5;
			spi_addr_width								:	integer				:=	4
		);										
		port (  
			clk_i								: in	std_logic ;
			rst_i								: in	std_logic ;
			-- to registerfile control 2.0
			fub_write_busy_o		: out	std_logic ;
			fub_write_data_i		: in	std_logic_vector( 7 downto 0 ) ;
			fub_write_adr_i			: in	std_logic_vector( 23 downto 0 ) ;
			fub_write_str_i 		: in	std_logic ;
			fub_read_busy_o			: out	std_logic ;
			fub_read_data_o			: out	std_logic_vector( 7 downto 0 ) ;
			fub_read_adr_i			: in	std_logic_vector( 23 downto 0 ) ;
			fub_read_str_i 			: in	std_logic ;
			stream_cnt_i				:	in	integer;
			erase_str_i					: in	std_logic;
			erase_adr_i					: in	std_logic_vector( 23 downto 0 ) ;
			-- to multi_spi_master
			fub_spi_out_busy_i	:	in	std_logic;
			fub_spi_out_str_o		:	out	std_logic;
			fub_spi_out_data_o	:	out	std_logic_vector(7 downto 0);
			flash_byte_count_o	:	out	integer;
			read_flag_o					:	out	std_logic;
			fub_spi_out_addr_o	:	out	std_logic_vector(spi_addr_width-1 downto 0);
			-- from multi_spi_master
			fub_spi_in_busy_o		:	out	std_logic;
			fub_spi_in_str_i		:	in	std_logic;
			fub_spi_in_data_i		:	in	std_logic_vector(7 downto 0)
		);
	end component;
 
end fub_flash_multi_pkg;

package body fub_flash_multi_pkg is
end fub_flash_multi_pkg;

-- Entity Definition


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity fub_flash_multi is

	generic (
		priority_on_reading						: std_logic 		:= '1';
		erase_in_front_of_write				: std_logic 		:= '1';
		read_block										:	integer				:=	1;
		write_block										:	integer				:=	4;
		spi_address										:	integer				:=	5;
		spi_addr_width								:	integer				:=	4
	);										
	port (  
		clk_i								: in	std_logic ;
		rst_i								: in	std_logic ;
		-- to registerfile control 2.0
		fub_write_busy_o		: out	std_logic ;
		fub_write_data_i		: in	std_logic_vector( 7 downto 0 ) ;
		fub_write_adr_i			: in	std_logic_vector( 23 downto 0 ) ;
		fub_write_str_i 		: in	std_logic ;
		fub_read_busy_o			: out	std_logic ;
		fub_read_data_o			: out	std_logic_vector( 7 downto 0 ) ;
		fub_read_adr_i			: in	std_logic_vector( 23 downto 0 ) ;
		fub_read_str_i 			: in	std_logic ;
		stream_cnt_i				:	in	integer;
		erase_str_i					: in	std_logic;
		erase_adr_i					: in	std_logic_vector( 23 downto 0 ) ;
		-- to multi_spi_master
		fub_spi_out_busy_i	:	in	std_logic;
		fub_spi_out_str_o		:	out	std_logic;
		fub_spi_out_data_o	:	out	std_logic_vector(7 downto 0);
		flash_byte_count_o	:	out	integer;
		read_flag_o					:	out	std_logic;
		fub_spi_out_addr_o	:	out	std_logic_vector(spi_addr_width-1 downto 0);
		-- from multi_spi_master
		fub_spi_in_busy_o		:	out	std_logic;
		fub_spi_in_str_i		:	in	std_logic;
		fub_spi_in_data_i		:	in	std_logic_vector(7 downto 0)
	);

end fub_flash_multi;

architecture fub_flash_multi_arch of fub_flash_multi is

type state_type is ( START, START_READ_END, START_WRITE_END, ERASE_SET_ENABLE_OPCODE, ERASE_SET_ERASE_OPCODE, ERASE_SET_ADR, ERASE_SET_READ_STATUS_OPCODE, ERASE_READ_STATUS, ERASE_PROOF_STATUS, ERASE_END, WRITE_READ_STATUS, WRITE_PROOF_STATUS, WRITE_SET_READ_STATUS_OPCODE, WRITE_PROOF_NEXT_ADR, WRITE_WAIT, WRITE_WAIT_PROOF, WRITE_DATA, WRITE_SET_ADR, WRITE_SET_WRITE_OPCODE, WRITE_SET_ENABLE_OPCODE, BYTE_TO_FLASH_STATE1, BYTE_TO_FLASH_STATE2, BYTE_FROM_FLASH_STATE1, BYTE_FROM_FLASH_STATE2, READ_SET_OPCODE, READ_SET_ADR, READ_RECEIVE_DATA, READ_STREAMING_WAIT, READ_STREAMING_PROOF ); 

signal state						: state_type ;
signal next_state					: state_type ;

type adr_byte_array_type is array(0 to 2) of std_logic_vector(7 downto 0);

signal adr_byte_array : adr_byte_array_type;

signal byte_to_flash			: std_logic_vector(7 downto 0);

signal byte_from_flash			: std_logic_vector(7 downto 0);

signal count_adr				: integer range 3 downto 0;

signal fub_read_adr_intern		: std_logic_vector(23 downto 0);
signal fub_read_adr_saved		: std_logic_vector(23 downto 0);
signal intern_read_str			: std_logic;

signal fub_write_adr_intern		: std_logic_vector(23 downto 0);
signal fub_write_data_intern	: std_logic_vector(7 downto 0); 
signal fub_write_adr_saved		: std_logic_vector(23 downto 0);
signal fub_write_data_saved		: std_logic_vector(7 downto 0); 
signal intern_write_str				: std_logic;

signal erase_adr_intern			: std_logic_vector(23 downto 0);

signal write_flag				: std_logic;
signal erase_flag				: std_logic;

signal calculate				: std_logic_vector(23 downto 0);

signal internal_byte_cnt	:	integer range 0 to 11;

signal count						:	integer	range 7+write_block downto 0;

signal stream_cnt			:	integer;

begin

	fub_flash_process : process( clk_i, rst_i )
	begin
		if rst_i = '1' then
			fub_read_data_o						<=	(others => '0');
			fub_write_busy_o					<=	'0';
			fub_read_busy_o						<=	'0';
			state											<=	START;
			next_state								<=	START;
			count_adr									<=	3;
			byte_to_flash							<=	(others => '0');
			byte_from_flash						<=	(others => '0');
			fub_read_adr_intern				<=	(others => '0');
			fub_write_adr_intern			<=	(others => '0');
			fub_write_data_intern			<=	(others => '0');
			fub_write_adr_saved				<=	(others => '0');
			fub_write_data_saved			<=	(others => '0');
			fub_read_adr_saved				<=	(others => '0');
			adr_byte_array(0)					<=	(others => '0');
			adr_byte_array(1)					<=	(others => '0');
			adr_byte_array(2)					<=	(others => '0');
			erase_adr_intern					<=	(others => '0');
			erase_flag								<=	'0';
			intern_write_str					<=	'0';
			intern_read_str						<=	'0';
			write_flag								<=	'0';
			calculate									<=	(others => '0');
			fub_spi_out_str_o					<=	'0';
			fub_spi_out_data_o				<=	(others => '0');
			fub_spi_out_addr_o				<=	(others => '0');
			fub_spi_in_busy_o					<=	'1';
			internal_byte_cnt					<=	0;
			flash_byte_count_o				<=	0;
			read_flag_o								<=	'0';
			count											<=	4;
			stream_cnt								<=	0;
		elsif clk_i'event and clk_i = '1' then
			case state is
-------------------------------------------------------------------------------------------------					
---------------------------|| START  SEQUENZ ||--------------------------------------------------
-------------------------------------------------------------------------------------------------	
				when START =>
					if erase_str_i = '1' then
						--nCS_o				<= '0';				--|| nCS_o reset
						state										<= ERASE_SET_ENABLE_OPCODE;
						erase_adr_intern				<= erase_adr_i;
						erase_flag							<= '1';
						fub_read_busy_o					<= '1';			--|| fub_read_busy set
						fub_write_busy_o				<= '1';			--|| fub_write_busy set
					elsif fub_read_str_i = '1' and fub_write_str_i = '1' then
						fub_write_adr_saved			<= fub_write_adr_i;		--// store adr
						fub_write_data_saved		<= fub_write_data_i;	--// store data
						fub_read_adr_saved			<= fub_read_adr_i;		--// store adr
						fub_read_busy_o					<= '1';					--|| fub_read_busy set
						fub_write_busy_o				<= '1';					--|| fub_write_busy set
						if priority_on_reading = '1' then	-- start READING
							state									<= READ_SET_OPCODE;
							fub_read_adr_intern		<= fub_read_adr_i;			-- read in adr
							intern_write_str			<= '1';					--// intern_read_str set
						else		-- start WRITING
							if erase_in_front_of_write = '1' then
								state								<= ERASE_SET_ENABLE_OPCODE;
								erase_adr_intern		<= fub_write_adr_i;
							else
								state								<= WRITE_SET_ENABLE_OPCODE;					
							end if;
							fub_write_adr_intern	<= fub_write_adr_i;			-- read in adr
							fub_write_data_intern	<= fub_write_data_i;
							intern_read_str				<= '1';					--// intern_read_str set
						end if;
					elsif fub_read_str_i = '1' then		-- start READING
						state					<= READ_SET_OPCODE;
						fub_read_adr_intern		<= fub_read_adr_i;			-- read in adr
						fub_read_busy_o				<= '1';					--|| fub_read_busy set
						fub_write_busy_o			<= '1';					--|| fub_write_busy set
					elsif fub_write_str_i = '1' then	-- start WRITING
						if erase_in_front_of_write = '1' then
							state				<= ERASE_SET_ENABLE_OPCODE;
							erase_adr_intern		<= fub_write_adr_i;
						else
							state								<= WRITE_SET_ENABLE_OPCODE;					
						end if;
						fub_write_adr_intern	<= fub_write_adr_i;			-- read in adr
						fub_write_data_intern	<= fub_write_data_i;
						fub_read_busy_o				<= '1';					--|| fub_read_busy set
						fub_write_busy_o			<= '1';					--|| fub_write_busy set
					else
						state									<= START;
					end if;
				when START_READ_END =>
					if fub_read_str_i = '1' then		-- again READ Data // possible because BUSY got reset last clk...
						state									<= READ_SET_OPCODE;
						fub_read_adr_intern		<= fub_read_adr_i;
					elsif intern_write_str = '1' then		-- START WRITING
						intern_write_str			<= '0';						--// reset intern_write_str
						if erase_in_front_of_write = '1' then
							state								<= ERASE_SET_ENABLE_OPCODE;
							erase_adr_intern		<= fub_write_adr_saved;
						else
							state								<= WRITE_SET_ENABLE_OPCODE;					
						end if;
						fub_write_adr_intern	<= fub_write_adr_saved;		--// restore saved adr
						fub_write_data_intern	<= fub_write_data_saved;	--// restore daved data
					else				-- finally go to START again
						state							<= START;
						fub_read_busy_o		<= '0';				--|| fub_read_busy reset
						fub_write_busy_o	<= '0';				--|| fub_write_busy reset
					end if;
				when START_WRITE_END =>
					if intern_read_str = '1' then
						intern_read_str		<= '0';						--// reset intern_write_str
						fub_read_adr_intern	<= fub_read_adr_saved;		--// restore saved adr
						state							<= READ_SET_OPCODE;
					else				-- finally go to START again
						state							<= START;
						fub_read_busy_o		<= '0';				--|| fub_read_busy reset
						fub_write_busy_o	<= '0';				--|| fub_write_busy reset
					end if;
-------------------------------------------------------------------------------------------------					
----------------------------|| READ  SEQUENZ ||------ all STATES longing to READ start with READ_
-------------------------------------------------------------------------------------------------				
				when READ_SET_OPCODE =>
					internal_byte_cnt	<=	4 + read_block;
					count							<=	4 + read_block;
					state							<= BYTE_TO_FLASH_STATE1;	-- set out the OPCODE
					next_state				<= READ_SET_ADR;			-- parameter for BYTE_TO_FLASH
					byte_to_flash			<= "00000011";				-- parameter for BYTE_TO_FLASH
					adr_byte_array(0)	<= fub_read_adr_intern(7 downto 0);
					adr_byte_array(1)	<= fub_read_adr_intern(15 downto 8);
					adr_byte_array(2)	<= fub_read_adr_intern(23 downto 16);
				when READ_SET_ADR =>				-- set out the 3 ADR BYTES with the MSB first
					if count_adr > 0 then
						count_adr				<= count_adr - 1;
						state						<= BYTE_TO_FLASH_STATE1;	-- set out the ADR
						next_state			<= READ_SET_ADR;				-- parameter for BYTE_TO_FLASH
						byte_to_flash		<= adr_byte_array(count_adr-1);	-- parameter for BYTE_TO_FLASH					
					else			-- last ADR BYTE
						count_adr				<= 3;
						state						<=	BYTE_FROM_FLASH_STATE1;
						next_state			<= 	READ_RECEIVE_DATA;			-- parameter for BYTE_TO_FLASH
						byte_to_flash		<=	(others => byte_to_flash(0));
						stream_cnt			<=	stream_cnt_i+1;
					end if;
				when READ_RECEIVE_DATA =>
					fub_read_data_o		<= byte_from_flash;			--|| set out data
					fub_read_busy_o		<= '0';						--|| reset fub_read_busy_o 
					stream_cnt				<=	stream_cnt-1;
					if fub_read_str_i = '1' then
						state						<=	READ_STREAMING_PROOF;
					else
						state						<=	READ_STREAMING_WAIT;
					end if;
				when READ_STREAMING_WAIT =>
					state							<=	READ_STREAMING_PROOF;
				when READ_STREAMING_PROOF =>
					fub_read_busy_o		<=	'1';					--|| set fub_read_busy_o
					if fub_read_str_i = '1' then
						fub_read_adr_intern		<= fub_read_adr_i;
						if fub_read_adr_i = (fub_read_adr_intern + "000000000000000000000001") then
							state						<=	BYTE_FROM_FLASH_STATE1;
							next_state			<= 	READ_RECEIVE_DATA;			-- parameter for BYTE_TO_FLASH
							byte_to_flash		<=	(others => byte_to_flash(0));
						else											-- START NEW READING SEQUENCE
							state					<= READ_SET_OPCODE;
						end if;
					elsif stream_cnt	=	0 then
						state						<= START_READ_END;		-- finished READING
					end if;
----------// end of READ SEQUENZ
-----------------------------------------------------------------------------------------------
--------------------||| ERASE SECTOR SEQUENCE ||| all STATES longing to ERASE start with ERASE_
--------------------| ERASE THE SECTOR OF THE INPUT ADR 	|----------------------------------
--------------------| needed in front of every WRITE CYCLE  |----------------------------------
				when ERASE_SET_ENABLE_OPCODE =>
					internal_byte_cnt	<=	1;
					count							<=	1;					
					state							<= BYTE_TO_FLASH_STATE1;		-- set out OPCODE
					next_state				<= ERASE_SET_ERASE_OPCODE;		-- parameter for BYTE_TO_FLASH
					byte_to_flash			<= "00000110";					-- parameter for BYTE_TO_FLASH
				when ERASE_SET_ERASE_OPCODE =>
					internal_byte_cnt	<=	4;
					count							<=	4;					
					state							<= BYTE_TO_FLASH_STATE1;	-- set out OPCODE
					next_state				<= ERASE_SET_ADR;			-- parameter for BYTE_TO_FLASH
					byte_to_flash			<= "11011000";				-- parameter for BYTE_TO_FLASH
					adr_byte_array(0)	<= fub_write_adr_intern(7 downto 0);
					adr_byte_array(1)	<= fub_write_adr_intern(15 downto 8);
					adr_byte_array(2)	<= fub_write_adr_intern(23 downto 16);
				when ERASE_SET_ADR =>
					state							<= BYTE_TO_FLASH_STATE1;	-- set out the ADR
					byte_to_flash			<= adr_byte_array(count_adr-1);	-- parameter for BYTE_TO_FLASH
					if count_adr > 1 then
						count_adr				<= count_adr - 1;
						next_state			<= ERASE_SET_ADR;		-- parameter for BYTE_TO_FLASH
					else			-- last ADR BYTE
						count_adr				<= 3;
						next_state			<= ERASE_SET_READ_STATUS_OPCODE;		-- parameter for BYTE_TO_FLASH
					end if;
				when ERASE_SET_READ_STATUS_OPCODE =>
					internal_byte_cnt	<=	2;
					count							<=	2;					
					state							<= BYTE_TO_FLASH_STATE1;	-- set out opcode for read_status
					byte_to_flash			<= "00000101";					-- parameter for BYTE_TO_FLASH
					next_state				<= ERASE_READ_STATUS;			-- parameter for BYTE_TO_FLASH
				when ERASE_READ_STATUS =>
					state							<= BYTE_FROM_FLASH_STATE1;
					byte_to_flash			<=	(others => byte_to_flash(0));
					next_state				<= ERASE_PROOF_STATUS;			
				when ERASE_PROOF_STATUS =>
					if byte_from_flash(0) = '0' then
						state						<= ERASE_END;			-- finished erasing
					else				-- erasing still in progress / proof again
						state						<= ERASE_SET_READ_STATUS_OPCODE;
					end if;
				when ERASE_END =>
					if erase_flag = '1' then			-- just erasing
						erase_flag				<= '0';
						state							<= START;
						fub_read_busy_o		<= '0';			--|| fub_read_busy reset
						fub_write_busy_o	<= '0';			--|| fub_write_busy reset
					else
						state		<= WRITE_SET_ENABLE_OPCODE;		-- JUMP to WRITE SEQUENCE
					end if;
----------// end of ERASE SEQUENZ
-------------------------------------------------------------------------------------------------
---------------------|| WRITE SEQUENZ ||------	all STATES longing to WRITE start with WRITE_----					
-------------------------------------------------------------------------------------------------					
				when WRITE_SET_ENABLE_OPCODE =>
					internal_byte_cnt	<=	1;
					count							<=	1;
					state							<= BYTE_TO_FLASH_STATE1;		-- set out OPCODE
					next_state				<= WRITE_SET_WRITE_OPCODE;		-- parameter for BYTE_TO_FLASH
					byte_to_flash			<= "00000110";					-- parameter for BYTE_TO_FLASH
				when WRITE_SET_WRITE_OPCODE =>
					internal_byte_cnt	<=	4 + write_block;
					count							<=	4 + write_block;
					state							<= BYTE_TO_FLASH_STATE1;	-- set out OPCODE
					next_state				<= WRITE_SET_ADR;			-- parameter for BYTE_TO_FLASH
					byte_to_flash			<= "00000010";				-- parameter for BYTE_TO_FLASH
					adr_byte_array(0)	<= erase_adr_intern(7 downto 0);
					adr_byte_array(1)	<= erase_adr_intern(15 downto 8);
					adr_byte_array(2)	<= erase_adr_intern(23 downto 16);
				when WRITE_SET_ADR =>
					state							<= BYTE_TO_FLASH_STATE1;	-- set out the ADR
					byte_to_flash			<= adr_byte_array(count_adr-1);	-- parameter for BYTE_TO_FLASH
					if count_adr > 1 then
						count_adr				<= count_adr - 1;
						next_state			<= WRITE_SET_ADR;		-- parameter for BYTE_TO_FLASH
					else			-- last ADR BYTE
						count_adr				<= 3;
						next_state			<= WRITE_DATA;			-- parameter for BYTE_TO_FLASH
					end if;
				when WRITE_DATA =>
					state							<= BYTE_TO_FLASH_STATE1;	-- set out fub_write_data_i
					byte_to_flash			<= fub_write_data_intern;		-- parameter for BYTE_TO_FLASH
					next_state				<= WRITE_WAIT_PROOF;			-- parameter for BYTE_TO_FLASH				
				when WRITE_WAIT_PROOF => 
					fub_write_busy_o	<= '0';					--|| reset fub_write_busy_o
					if fub_write_str_i = '1' then
						state						<= WRITE_PROOF_NEXT_ADR;
					else
						state						<= WRITE_WAIT;
					end if;	
					calculate					<= (fub_write_adr_intern + "000000000000000000000001");
				when WRITE_WAIT =>
					state							<= WRITE_PROOF_NEXT_ADR;			-- this path might be critical if there will be a sudden str and again another str in the following clk	
				when WRITE_PROOF_NEXT_ADR =>
					fub_write_busy_o				<= '1';				--|| set fub_read_busy_o
					if fub_write_str_i = '1' then
						fub_write_adr_intern	<= fub_write_adr_i;
						fub_write_data_intern	<= fub_write_data_i;						
						if ( (fub_write_adr_intern(8) = calculate(8) ) and ( fub_write_adr_i = calculate ) ) then	-- needed cause of flash internal stream conditions
							state								<= WRITE_DATA;		-- STREAMING
						else								-- not STREAMING // but continue WRITING			
							write_flag					<= '1';						--// write_flag set
							state								<= WRITE_SET_READ_STATUS_OPCODE;
						end if;
					else								-- all written						
						state									<= WRITE_SET_READ_STATUS_OPCODE;
					end if;					
				when WRITE_SET_READ_STATUS_OPCODE =>
					internal_byte_cnt				<=	2;
					count										<=	2;
					state										<= BYTE_TO_FLASH_STATE1;	-- set out opcode for read_status
					byte_to_flash						<= "00000101";					-- parameter for BYTE_TO_FLASH
					next_state							<= WRITE_READ_STATUS;			-- parameter for BYTE_TO_FLASH
				when WRITE_READ_STATUS =>
					state										<= BYTE_FROM_FLASH_STATE1;
					byte_to_flash			<=	(others => byte_to_flash(0));
					next_state							<= WRITE_PROOF_STATUS;
				when WRITE_PROOF_STATUS =>
					if byte_from_flash(0) = '0' then
						if write_flag = '1' then		-- continue WRITING
							write_flag		<= '0';			--// reset write_flag
							state					<= WRITE_SET_ENABLE_OPCODE;
						else							-- finished WRITING
							state					<= START_WRITE_END;
						end if;
					else					-- writing still in progress / proof again
						state			<= WRITE_SET_READ_STATUS_OPCODE;
					end if;
----------// end of WRITE SEQUENZ
-----------------------------------------------------------------------------------------------						
--------------------||| BYTE_TO_FLASH SEQUENCE |||---------------------------------------------
--------------------| sends data saved in "byte_to_flash" to the flash |-----------------------
--------------------| and jumpes to state saved in "next_state" when finished |----------------					
				when BYTE_TO_FLASH_STATE1 =>
					if fub_spi_out_busy_i = '0' then
						flash_byte_count_o	<=	internal_byte_cnt;
						fub_spi_out_str_o		<=	'1';
						fub_spi_out_data_o	<=	byte_to_flash;
						fub_spi_in_busy_o		<=	'1';
						fub_spi_out_addr_o	<=	conv_std_logic_vector(spi_address+count-1, spi_addr_width);
						count								<=	count - 1;
						state								<=	BYTE_TO_FLASH_STATE2;
					end if;				
				when BYTE_TO_FLASH_STATE2	=>
					-- if count = 0 then
						-- count								<=	4;
					-- end if;
					fub_spi_out_str_o			<=	'0';
					state									<=	next_state;				
------------- // end of BYTE_TO_FLASH
-------------------------------------------------------------------------------------------------
--------------------||| BYTE_FROM_FLASH SEQUENCE |||---------------------------------------------
--------------------| receives data saved in flash |---------------------------------------------
--------------------| and jumpes to state saved in "next_state" when finished |------------------	
				when BYTE_FROM_FLASH_STATE1	=>
					if fub_spi_out_busy_i = '0' then
						fub_spi_out_str_o		<=	'1';
						fub_spi_out_data_o	<=	byte_to_flash;
						fub_spi_in_busy_o		<=	'1';
						state								<=	BYTE_FROM_FLASH_STATE2;
						read_flag_o					<=	'1';
						fub_spi_out_addr_o	<=	conv_std_logic_vector(count-1, spi_addr_width);
						count								<=	count - 1;
					end if;
				when BYTE_FROM_FLASH_STATE2 =>
					fub_spi_out_str_o		<=	'0';
					fub_spi_in_busy_o		<=	'0';
					read_flag_o					<=	'0';
					if fub_spi_in_str_i	= '1' then
						fub_spi_in_busy_o	<=	'1';
						byte_from_flash		<=	fub_spi_in_data_i;
						state							<=	next_state;
					end if;
----------- // end of BYTE_FROM_FLASH
			end case;
		end if;
	end process;
	
end fub_flash_multi_arch ;
