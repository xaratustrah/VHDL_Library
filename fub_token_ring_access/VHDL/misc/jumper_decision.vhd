LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE IEEE.STD_LOGIC_arith.all;
USE IEEE.STD_LOGIC_unsigned.all;

entity jumper_decision is

port (	
		-----------------------------------
		clk_i			: in std_logic ;
		rst_i			: in std_logic ;
		-----------------------------------|| JUMPER INPUT
		jump0_i			: in std_logic;
		jump1_i			: in std_logic;
		jump2_i			: in std_logic;
		jump3_i			: in std_logic;
		jump4_i			: in std_logic;
		jump5_i			: in std_logic;
		jump6_i			: in std_logic;
		jump7_i			: in std_logic;
		-----------------------------------
		master_o		: out integer;
		target_adr_o	: out std_logic_vector(7 downto 0);
		local_adr_o		: out std_logic_vector(7 downto 0);
		-----------------------------------|| DATA FROM AP
		fub_data_i		: in std_logic_vector(7 downto 0);
		fub_adr_i		: in std_logic_vector(7 downto 0);
		fub_str_i		: in std_logic;
		fub_busy_o		: out std_logic;
		-----------------------------------|| DATA TO AP
		fub_data_o		: out std_logic_vector(7 downto 0);
		fub_adr_o		: out std_logic_vector(7 downto 0);
		fub_str_o		: out std_logic;
		fub_busy_i		: in std_logic;
		-----------------------------------|| DATA FROM MLS
		mls_tx_fub_data_i	: in std_logic_vector(7 downto 0);
		mls_tx_fub_adr_i	: in std_logic_vector(7 downto 0);
		mls_tx_fub_str_i	: in std_logic;
		mls_tx_fub_busy_o	: out std_logic;
		-----------------------------------|| DATA TO MLS
		mls_rx_fub_data_o	: out std_logic_vector(7 downto 0);
		mls_rx_fub_adr_o	: out std_logic_vector(7 downto 0);
		mls_rx_fub_str_o	: out std_logic;
		mls_rx_fub_busy_i	: in std_logic;
		-----------------------------------|| DATA FROM RS232
		rs232_rx_fub_data_i	: in std_logic_vector(7 downto 0);
		rs232_rx_fub_adr_i	: in std_logic_vector(7 downto 0);
		rs232_rx_fub_str_i	: in std_logic;
		rs232_rx_fub_busy_o	: out std_logic;
		-----------------------------------|| DATA TO RS232
		rs232_tx_fub_data_o	: out std_logic_vector(7 downto 0);
		rs232_tx_fub_adr_o	: out std_logic_vector(7 downto 0);
		rs232_tx_fub_str_o	: out std_logic;
		rs232_tx_fub_busy_i	: in std_logic
	 );
	
end jumper_decision ;

architecture jumper_decision_arch of jumper_decision is

begin

	jumper_decision_process : process(clk_i, rst_i)
	begin
		if rst_i = '1' then
			master_o			<= 0;
			target_adr_o		<= (others => '0');
			local_adr_o			<= (others => '0');
			fub_busy_o			<= '1';
			fub_data_o			<= (others => '0');
			fub_adr_o			<= (others => '0');
			fub_str_o			<= '0';
			mls_tx_fub_busy_o	<= '1';
			mls_rx_fub_data_o	<= (others => '0');
			mls_rx_fub_adr_o	<= (others => '0');
			mls_rx_fub_str_o	<= '0';
			rs232_rx_fub_busy_o	<= '1';
			rs232_tx_fub_data_o	<= (others => '0');
			rs232_tx_fub_adr_o	<= (others => '0');
			rs232_tx_fub_str_o	<= '0';
		elsif clk_i'event and clk_i = '1' then
			if jump6_i = '1' then							-- MASTER
				master_o	<= 1;
			else
				master_o	<= 0;
			end if;
			if jump0_i = '1' then												-- AP1  --> AP2
				local_adr_o		<= "00000001";
				target_adr_o	<= "00000010";			
				-----------------------------------|| DATA FROM AP
				mls_rx_fub_data_o	<= fub_data_i;
				mls_rx_fub_adr_o	<= fub_adr_i;
				mls_rx_fub_str_o	<= fub_str_i;
				fub_busy_o			<= mls_rx_fub_busy_i;
				-----------------------------------|| DATA TO AP
				fub_data_o			<= mls_tx_fub_data_i;
				fub_adr_o			<= mls_tx_fub_adr_i;
				fub_str_o			<= mls_tx_fub_str_i;
				mls_tx_fub_busy_o	<= fub_busy_i;
			end if;			
			if jump1_i = '1' then												-- AP2  --> AP3
				local_adr_o		<= "00000010";
				target_adr_o	<= "00000100";			
				-----------------------------------|| DATA FROM AP
				mls_rx_fub_data_o	<= fub_data_i;
				mls_rx_fub_adr_o	<= fub_adr_i;
				mls_rx_fub_str_o	<= fub_str_i;
				fub_busy_o			<= mls_rx_fub_busy_i;
				-----------------------------------|| DATA TO AP
				fub_data_o			<= mls_tx_fub_data_i;
				fub_adr_o			<= mls_tx_fub_adr_i;
				fub_str_o			<= mls_tx_fub_str_i;					
				mls_tx_fub_busy_o	<= fub_busy_i;
			end if;	
			
			---------------------neue Belegung
			if jump2_i = '1' then												-- AP3  --> AP4
				local_adr_o		<= "00000100";
				target_adr_o	<= "00001000";			
				-----------------------------------|| DATA FROM AP
				mls_rx_fub_data_o	<= fub_data_i;
				mls_rx_fub_adr_o	<= fub_adr_i;
				mls_rx_fub_str_o	<= fub_str_i;
				fub_busy_o			<= mls_rx_fub_busy_i;
				-----------------------------------|| DATA TO AP
				fub_data_o			<= mls_tx_fub_data_i;
				fub_adr_o			<= mls_tx_fub_adr_i;
				fub_str_o			<= mls_tx_fub_str_i;									
				mls_tx_fub_busy_o	<= fub_busy_i;
			end if;				
			if jump3_i = '1' then												-- AP4  --> AP1
				local_adr_o		<= "00001000";
				target_adr_o	<= "00000001";			
				-----------------------------------|| DATA FROM AP
				mls_rx_fub_data_o	<= fub_data_i;
				mls_rx_fub_adr_o	<= fub_adr_i;
				mls_rx_fub_str_o	<= fub_str_i;
				fub_busy_o			<= mls_rx_fub_busy_i;
				-----------------------------------|| DATA TO AP
				fub_data_o			<= mls_tx_fub_data_i;
				fub_adr_o			<= mls_tx_fub_adr_i;
				fub_str_o			<= mls_tx_fub_str_i;								
				mls_tx_fub_busy_o	<= fub_busy_i;
			end if;				
			if jump4_i = '1' then												-- AP5 -> AP6
				local_adr_o		<= "00010000";
				target_adr_o	<= "00100000";			
				-----------------------------------|| DATA FROM AP		-- to rs232
				rs232_tx_fub_data_o	<= fub_data_i;
				rs232_tx_fub_adr_o	<= fub_adr_i;
				rs232_tx_fub_str_o	<= fub_str_i;
				fub_busy_o			<= rs232_tx_fub_busy_i;
				-----------------------------------|| DATA TO AP
				fub_data_o			<= mls_tx_fub_data_i;
				fub_adr_o			<= mls_tx_fub_adr_i;
				fub_str_o			<= mls_tx_fub_str_i;
				mls_tx_fub_busy_o	<= fub_busy_i;
			end if;				
			if jump5_i = '1' then												-- AP6 -> AP5
				local_adr_o		<= "00100000";
				target_adr_o	<= "00010000";			
				-----------------------------------|| DATA FROM AP
				mls_rx_fub_data_o	<= fub_data_i;
				mls_rx_fub_adr_o	<= fub_adr_i;
				mls_rx_fub_str_o	<= fub_str_i;
				fub_busy_o			<= mls_rx_fub_busy_i;
				-----------------------------------|| DATA TO AP		-- from rs232
				fub_data_o			<= rs232_rx_fub_data_i;
				fub_adr_o			<= "00000000";
				fub_str_o			<= rs232_rx_fub_str_i;
				rs232_rx_fub_busy_o	<= fub_busy_i;			
			end if;
			-------------------dummy-------------
			if jump7_i = '1' then
				local_adr_o		<= "10101010";
				target_adr_o	<= "01010101";
				-------------------------------|| DEAKTIVATE all OUTPUT
				--------- KEEP RST VALUES -----------------------------
			end if;
		end if;
	
	end process;
	
end jumper_decision_arch;