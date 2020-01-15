-------------------------------------------------------------------------------
--
-- This file was originally designed from F. Hartmann (master_fsm) and modified by M. Kumm
-- Version 2.0 by T. Wollmann, 29.10.08 with fub interface as RAM-output
--
-------------------------------------------------------------------------------

-- Package Definition

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

package fub_registerfile_cntrl_pkg is
  component fub_registerfile_cntrl
    generic (
      adr_width                 : integer := 16;
      data_width                : integer := 8;
      default_start_adr         : integer := 16#0000#; 
      default_end_adr           : integer := 16#0000#; 
      reg_adr_cmd               : integer := 16#fff0#;
      reg_adr_start_adr_high    : integer := 16#fff1#;
      reg_adr_start_adr_low     : integer := 16#fff2#;
      reg_adr_end_adr_high      : integer := 16#fff3#;
      reg_adr_end_adr_low       : integer := 16#fff4#;
      reg_adr_firmware_id       : integer := 16#fff5#;
      reg_adr_firmware_version  : integer := 16#fff6#;
      reg_adr_firmware_config   : integer := 16#fff7#;
      mask_adr                  : integer := 16#ffff#;
      firmware_id               : integer := 0;
      firmware_version          : integer := 0;
      firmware_config           : integer := 0;
      boot_from_flash           : boolean := true
    );                          
    port (
      rst_i                     : in  std_logic;
      clk_i                     : in  std_logic;
      fub_cfg_reg_in_dat_i      : in  std_logic_vector (data_width-1 downto 0);
      fub_cfg_reg_in_adr_i      : in  std_logic_vector (adr_width-1 downto 0);
      fub_cfg_reg_in_str_i      : in  std_logic;
      fub_cfg_reg_in_busy_o     : out std_logic;
      fub_cfg_reg_out_str_o     : out std_logic;
      fub_cfg_reg_out_dat_o     : out std_logic_vector (data_width-1 downto 0);
      fub_cfg_reg_out_adr_o     : out std_logic_vector (adr_width-1 downto 0);
      fub_cfg_reg_out_busy_i    : in  std_logic;
      fub_fr_busy_i             : in  std_logic;
      fub_fr_dat_i              : in  std_logic_vector (data_width-1 downto 0);
      fub_fr_str_o              : out std_logic;
      fub_fr_adr_o              : out std_logic_vector(adr_width-1 downto 0);
			fub_fr_cnt_o							:	out	integer;
      fub_fw_str_o              : out std_logic;
      fub_fw_busy_i             : in  std_logic;
      fub_fw_dat_o              : out std_logic_vector (data_width-1 downto 0);
      fub_fw_adr_o              : out std_logic_vector(adr_width-1 downto 0);
      fub_out_data_o            : out std_logic_vector(data_width-1 downto 0);
      fub_out_adr_o             : out std_logic_vector(adr_width-1 downto 0);
      fub_out_str_o             : out std_logic;
      fub_out_busy_i            : in std_logic;
      -------------------------RAM-----------------------------------------------
      fub_ram_out_adr_o					:	out	std_logic_vector (adr_width-1 downto 0);
      fub_ram_out_data_o				:	out	std_logic_vector (data_width-1 downto 0);
      fub_ram_out_str_o					:	out	std_logic;
      fub_ram_out_busy_i				:	in	std_logic;
      fub_ram_in_adr_o					:	out	std_logic_vector(adr_width-1 downto 0);
      fub_ram_in_data_i					:	in	std_logic_vector(data_width-1 downto 0);
      fub_ram_in_str_o					:	out	std_logic;
      fub_ram_in_busy_i					:	in	std_logic
      );
  end component;
end fub_registerfile_cntrl_pkg;


package body fub_registerfile_cntrl_pkg is
end fub_registerfile_cntrl_pkg;

-- Entity Definition


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;


entity fub_registerfile_cntrl is
  generic (
    adr_width               : integer := 16;
    data_width              : integer := 8;
    default_start_adr       : integer := 16#0000#; 
    default_end_adr         : integer := 16#0000#; 
    reg_adr_cmd             : integer := 16#fff0#;
    reg_adr_start_adr_high  : integer := 16#fff1#;
    reg_adr_start_adr_low   : integer := 16#fff2#;
    reg_adr_end_adr_high    : integer := 16#fff3#;
    reg_adr_end_adr_low     : integer := 16#fff4#;
    reg_adr_firmware_id     : integer := 16#fff5#;
    reg_adr_firmware_version: integer := 16#fff6#;
    reg_adr_firmware_config : integer := 16#fff7#;
    mask_adr                : integer := 16#ffff#;
    firmware_id             : integer := 0;
    firmware_version        : integer := 0;
    firmware_config         : integer := 0;
    boot_from_flash         : boolean := true
    );
  port (
    rst_i                  	: in  std_logic;
    clk_i                  	: in  std_logic;
    fub_cfg_reg_in_dat_i   	: in  std_logic_vector (data_width-1 downto 0);
    fub_cfg_reg_in_adr_i   	: in  std_logic_vector (adr_width-1 downto 0);
    fub_cfg_reg_in_str_i   	: in  std_logic;
    fub_cfg_reg_in_busy_o  	: out std_logic;
    fub_cfg_reg_out_str_o  	: out std_logic;
    fub_cfg_reg_out_dat_o  	: out std_logic_vector (data_width-1 downto 0);
    fub_cfg_reg_out_adr_o  	: out std_logic_vector (adr_width-1 downto 0);
    fub_cfg_reg_out_busy_i 	: in  std_logic;
    fub_fr_busy_i          	: in  std_logic;
    fub_fr_dat_i           	: in  std_logic_vector (data_width-1 downto 0);
    fub_fr_str_o           	: out std_logic;
    fub_fr_adr_o           	: out std_logic_vector(adr_width-1 downto 0);
		fub_fr_cnt_o						:	out	integer;
    fub_fw_str_o           	: out std_logic;
    fub_fw_busy_i          	: in  std_logic;
    fub_fw_dat_o           	: out std_logic_vector (data_width-1 downto 0);
    fub_fw_adr_o           	: out std_logic_vector(adr_width-1 downto 0);
    fub_out_data_o					: out std_logic_vector(data_width-1 downto 0);
    fub_out_adr_o   				: out std_logic_vector(adr_width-1 downto 0);
    fub_out_str_o   				: out std_logic;
    fub_out_busy_i      		: in std_logic;
    -----------------------RAM----------------------------------------------
		fub_ram_out_adr_o				:	out	std_logic_vector (adr_width-1 downto 0);
    fub_ram_out_data_o			:	out	std_logic_vector (data_width-1 downto 0);
    fub_ram_out_str_o				:	out	std_logic;
    fub_ram_out_busy_i			:	in	std_logic;
    fub_ram_in_adr_o				:	out	std_logic_vector(adr_width-1 downto 0);
    fub_ram_in_data_i				:	in	std_logic_vector(data_width-1 downto 0);
    fub_ram_in_str_o				:	out	std_logic;
    fub_ram_in_busy_i				:	in	std_logic
    );
end fub_registerfile_cntrl;

architecture fub_registerfile_cntrl_arch of fub_registerfile_cntrl is

	--STATES
	type MAINSTATES is (READ_CFG, WRITE_CFG_SINGLE, WRITE_CFG_BLOCK, WRITE_FLASH, READ_FLASH, FIRMWARE);
	signal mainstate					:	MAINSTATES;
	signal prevstate					:	MAINSTATES;
	signal start_adr, end_adr, act_adr	:	std_logic_vector(adr_width-1 downto 0);

	--Signals
	signal fub_out_adr_save      			:	std_logic_vector(adr_width-1 downto 0);
	signal fub_out_data_save      		:	std_logic_vector(data_width-1 downto 0);
	signal fub_out_flag        			:	std_logic;
	signal cnt							:	integer range 6 downto 0;
	signal fub_ram_out_data_save		:	std_logic_vector(fub_ram_out_data_o'range);		
    signal fub_ram_out_adr_save			:	std_logic_vector(fub_ram_out_adr_o'range);
	signal ram_flag						:	std_logic;
	
	signal	flash_read_flag	:	std_logic;	
	signal  flash_read_save	:	std_logic_vector(data_width-1 downto 0);
	
begin

  process(clk_i, rst_i)
  begin
    if rst_i = '1' then
      if boot_from_flash = true then
        mainstate                       <= READ_FLASH; -- READ_CFG;
      else
        mainstate                       <= READ_CFG;
      end if;
      cnt						<= 0;
      fub_cfg_reg_in_busy_o     <= '1';   -- cause of reset state READ_FLASH
      fub_cfg_reg_out_str_o     <= '0';
      fub_ram_out_data_o		<= (others => '0');
      fub_ram_out_adr_o         <= (others => '0');
      fub_ram_out_str_o			<=	'0';
      fub_ram_in_str_o			<=	'0';
      fub_ram_in_adr_o			<= (others => '0');
      fub_cfg_reg_out_dat_o     <= (others => '0');
      fub_cfg_reg_out_adr_o		<= (others => '0');
      fub_out_data_o          	<= (others => '0');
      fub_out_adr_o           	<= (others => '0');
      fub_out_str_o           	<= '0';
      start_adr           		<= conv_std_logic_vector(default_start_adr, adr_width);   	--(others => '0');
      end_adr                   <= conv_std_logic_vector(default_end_adr, adr_width);   	--(others => '0');
      act_adr                   <= conv_std_logic_vector(default_start_adr, adr_width); 	--(others => '0');
      fub_fr_str_o              <= '0';
      fub_fr_adr_o              <= (others => '0');
      fub_fw_str_o              <= '0';
      fub_fw_dat_o              <= (others => '0');
      fub_fw_adr_o              <= (others => '0');
      fub_out_flag            	<= '0';
      fub_out_adr_save          <= (others => '0');
      fub_out_data_save         <= (others => '0');
      fub_cfg_reg_in_busy_o     <= '0';
		ram_flag				<= '0';
		fub_ram_out_data_save	<=	(others => '0');
		fub_ram_out_adr_save	<=	(others => '0');
		--
		flash_read_flag				<=	'0';
		flash_read_save				<=	(others => '0');
    --
		elsif clk_i = '1' and clk_i'event then
			fub_ram_out_str_o		<=	'0';
      fub_out_str_o 			<=	'0';     						--|| fub_out_str_o reset
      if fub_out_flag = '1' then
        if fub_out_busy_i = '0' then
          fub_out_adr_o 		<= fub_out_adr_save;
          fub_out_data_o		<= fub_out_data_save;
          fub_out_str_o 		<= '1';         		--|| fub_out_str_o set
          fub_out_flag  		<= '0';       			-- fub_out_flag reset
          fub_cfg_reg_in_busy_o <= '0';
        end if;
      end if;
			if ram_flag = '1' then
				if fub_ram_out_busy_i = '0' then
					ram_flag							<=	'0';
					fub_ram_out_str_o			<=	'1';
					fub_ram_out_data_o		<=	fub_ram_out_data_save;
					fub_ram_out_adr_o			<=	fub_ram_out_adr_save;
					fub_cfg_reg_in_busy_o	<=	'0';
				end if;
			end if;
      case mainstate is
        when READ_CFG                              =>
					if fub_cfg_reg_out_busy_i = '0' then
						fub_cfg_reg_out_str_o         <= '0';
					end if;
					if fub_out_flag = '0' then
						fub_cfg_reg_in_busy_o         <= '0';      
					end if;          
					if fub_cfg_reg_in_str_i = '1' then
						act_adr                     <=	start_adr;
						case conv_integer(fub_cfg_reg_in_adr_i) is
							when REG_ADR_CMD                     =>
								if fub_cfg_reg_in_dat_i(0) = '1' then			--read single
									if fub_ram_out_busy_i = '0' then
										fub_ram_out_adr_o		<= start_adr;
										mainstate           	<= WRITE_CFG_SINGLE;
										fub_cfg_reg_in_busy_o	<= '1';
									end if;
									elsif fub_cfg_reg_in_dat_i(1) = '1' then		--read block
										mainstate             <= WRITE_CFG_BLOCK;
										fub_cfg_reg_in_busy_o <= '1';
									elsif fub_cfg_reg_in_dat_i(2) = '1' then		--update flash
										mainstate             <= WRITE_FLASH;
										fub_cfg_reg_in_busy_o <= '1';
									elsif fub_cfg_reg_in_dat_i(3) = '1' then		--read flash
										mainstate             <= READ_FLASH;
										fub_cfg_reg_in_busy_o <= '1';
									end if;
								cnt					<=	0;
							when REG_ADR_START_ADR_HIGH          =>
								start_adr(15 downto 8)  <= fub_cfg_reg_in_dat_i;
							when REG_ADR_START_ADR_LOW           =>
								start_adr(7 downto 0)   <= fub_cfg_reg_in_dat_i;
							when REG_ADR_END_ADR_HIGH            =>
								end_adr(15 downto 8)    <= fub_cfg_reg_in_dat_i;
							when REG_ADR_END_ADR_LOW             =>
								end_adr(7 downto 0)     <= fub_cfg_reg_in_dat_i;
							when others                          =>
								if fub_out_flag = '0' then
									if fub_out_busy_i = '0' then
										fub_out_str_o 	<= '1';     --|| fub_out_str_o set
										fub_out_data_o  <= fub_cfg_reg_in_dat_i;
										fub_out_adr_o 	<= fub_cfg_reg_in_adr_i;
									else
										fub_cfg_reg_in_busy_o <= '1';
										fub_out_flag    			<= '1';     -- fub_out_flag set
										fub_out_adr_save  		<= fub_cfg_reg_in_adr_i;
										fub_out_data_save 		<= fub_cfg_reg_in_dat_i;
					        end if;
				        end if;
								if fub_ram_out_busy_i = '0' then
									fub_ram_out_str_o		<=	'1';
									fub_ram_out_data_o	<=	fub_cfg_reg_in_dat_i;
									fub_ram_out_adr_o		<=	fub_cfg_reg_in_adr_i;
								else
									fub_cfg_reg_in_busy_o	<=	'1';
									ram_flag							<=	'1';
									fub_ram_out_data_save	<=	fub_cfg_reg_in_dat_i;
									fub_ram_out_adr_save	<=	fub_cfg_reg_in_adr_i;
								end if;
						end case;
					end if;
		    when WRITE_CFG_SINGLE	=>
					fub_cfg_reg_out_str_o		<=	'0';
					if cnt	= 0 then
		        if fub_ram_in_busy_i = '0' then
							fub_ram_in_adr_o	<=	act_adr;
							fub_ram_in_str_o	<=	'1';
							cnt 				<=	1;
		        end if;
					else
						prevstate 			<=	WRITE_CFG_SINGLE;
						mainstate 			<=	FIRMWARE;
						cnt					<=	0;
					end if;
		    when WRITE_CFG_BLOCK	=>
					fub_cfg_reg_out_str_o		<=	'0';
					if cnt = 0 then
						if fub_ram_in_busy_i = '0' then
							fub_ram_in_adr_o			<=	act_adr;
							fub_ram_in_str_o			<=	'1';
							cnt							<=	1;
						end if;
					else
						prevstate			<=	WRITE_CFG_BLOCK;
						mainstate			<=	FIRMWARE;
						cnt					<=	0;
					end if;
				when FIRMWARE	=>
					case conv_integer(act_adr) is
						when reg_adr_firmware_id   =>
							if fub_cfg_reg_out_busy_i = '0' then
								fub_cfg_reg_out_adr_o   <= conv_std_logic_vector(reg_adr_firmware_id,adr_width);
								fub_cfg_reg_out_dat_o   <= conv_std_logic_vector(firmware_id,data_width);
								fub_cfg_reg_out_str_o	<= '1';
							end if;
						when reg_adr_firmware_version    =>
							if fub_cfg_reg_out_busy_i = '0' then
								fub_cfg_reg_out_adr_o   <= conv_std_logic_vector(reg_adr_firmware_version,adr_width);
								fub_cfg_reg_out_dat_o   <= conv_std_logic_vector(firmware_version,data_width);
								fub_cfg_reg_out_str_o	<= '1';
							end if;
						when reg_adr_firmware_config   =>
							if fub_cfg_reg_out_busy_i = '0' then
								fub_cfg_reg_out_adr_o   <= conv_std_logic_vector(reg_adr_firmware_config,adr_width);
								fub_cfg_reg_out_dat_o   <= conv_std_logic_vector(firmware_config,data_width);
								fub_cfg_reg_out_str_o	<= '1';
							end if;
				when others =>
					if prevstate = WRITE_CFG_BLOCK then
						fub_ram_in_str_o	<=	'0';
						if fub_ram_in_busy_i = '0' then
							if fub_cfg_reg_out_busy_i = '0' then
								fub_cfg_reg_out_adr_o   <=	act_adr;
								fub_cfg_reg_out_dat_o   <=	fub_ram_in_data_i;
								fub_cfg_reg_out_str_o	<= '1';
								act_adr                 <= 	act_adr+1;
								if act_adr = end_adr then
									mainstate	<= 	READ_CFG;
								else
									mainstate	<=	WRITE_CFG_BLOCK;
								end if;
							end if;
						end if;
					elsif prevstate = WRITE_CFG_SINGLE then
						fub_ram_in_str_o	<=	'0';
						if fub_ram_in_busy_i = '0' then
							if fub_cfg_reg_out_busy_i = '0' then
								fub_cfg_reg_out_adr_o		<=	start_adr;
								fub_cfg_reg_out_dat_o		<=	fub_ram_in_data_i;
								fub_cfg_reg_out_str_o		<= '1';
								mainstate					<= 	READ_CFG;
							end if;
						end if;
					end if;
			end case;
		when WRITE_FLASH	 =>
			if cnt = 0 then
				fub_fw_str_o		<=	'0';
				if fub_ram_in_busy_i = '0' then
					fub_ram_in_adr_o	<=	act_adr;
					fub_ram_in_str_o	<=	'1';
					cnt					<=	1;
				end if;
			elsif cnt = 1 then
				fub_ram_in_str_o	<=	'0';
				cnt	<=	2;
			elsif cnt = 2 then
				if fub_ram_in_busy_i = '0' then
					if fub_fw_busy_i = '0' then
						fub_fw_str_o  	<= '1';
						fub_fw_adr_o	<=	act_adr;
						fub_fw_dat_o	<=	fub_ram_in_data_i;
						cnt				<=	2;
						act_adr       	<=	act_adr+1;  --wirkt am Ende des Taktes
						if act_adr = end_adr then  -- end_adr wird noch geschrieben
							cnt	<=	3;
						else
							cnt	<=	0;
						end if;
					end if;
				end if;
			else
				fub_fw_str_o	<=	'0';
				cnt				<=	0;
				mainstate     	<=	READ_CFG;
			end if;            
		when READ_FLASH                            =>
			fub_cfg_reg_in_busy_o <= '1';
			--fub_ram_out_str_o		<= '0';
			if cnt = 0 then
				if fub_out_flag = '0' then
					if fub_fr_busy_i = '0' then
						cnt					<=	1;
						fub_fr_adr_o        <=	act_adr;
						fub_fr_str_o        <=	'1';
					end if;
				end if;
			elsif cnt = 1 then
				fub_fr_str_o			<= '0';
				cnt						<=	2;
			elsif cnt = 2 then								-- comment of t.guthier 21.12.07
				if fub_fr_busy_i = '0' then               	-- not fub optimized!
					if fub_ram_out_busy_i = '0' then					-- may lead to problems with fub_flash
						fub_ram_out_str_o		<=	'1';
						fub_ram_out_adr_o		<=	act_adr;
						if flash_read_flag = '0' then
							fub_ram_out_data_o		<=	fub_fr_dat_i;-- str_o is one clk to late for a good working block transfer
						else
							fub_ram_out_data_o		<= 	flash_read_save;
							flash_read_flag				<=	'0';
						end if;
						act_adr             	<=	act_adr+1;
						cnt						<=	0;
						if act_adr /= mask_adr+1 then
							if fub_out_busy_i = '0' then
								fub_out_str_o	<= '1';     			--|| fub_out_str_o set
								fub_out_adr_o	<= act_adr;
								fub_out_data_o  <= fub_fr_dat_i;
							else
								fub_out_flag    	<= '1';     			-- fub_out_flag set
								fub_out_adr_save  	<= act_adr;
								fub_out_data_save 	<= fub_fr_dat_i;
							end if;
						end if;
						if act_adr = end_adr then
							mainstate     <= READ_CFG;
						end if;
					else
						flash_read_flag <= '1';
						flash_read_save	<=	fub_fr_dat_i;
					end if;
				end if;
			else
				cnt	<=	cnt +1;
			end if;
	    end case;
    end if;
end process;

	fub_fr_cnt_o	<=	conv_integer(end_adr - start_adr);
	
end fub_registerfile_cntrl_arch;