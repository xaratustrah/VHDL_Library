-------------------------------------------------------------------------------
--
-- This file was originally designed from F. Hartmann (master_fsm) and modified by M. Kumm
-- 
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
      use_update_adr            : boolean := false;
      update_adr                : integer := 16#ffff#;
      update_data               : integer := 16#00#;
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
      fub_fw_str_o              : out std_logic;
      fub_fw_busy_i             : in  std_logic;
      fub_fw_dat_o              : out std_logic_vector (data_width-1 downto 0);
      fub_fw_adr_o              : out std_logic_vector(adr_width-1 downto 0);
      fub_out_data_o            : out std_logic_vector(data_width-1 downto 0);
      fub_out_adr_o             : out std_logic_vector(adr_width-1 downto 0);
      fub_out_str_o             : out std_logic;
      fub_out_busy_i            : in std_logic;
      ram_wren_o                : out std_logic;
      ram_adr_o                 : out std_logic_vector (adr_width-1 downto 0);
      ram_dat_o                 : out std_logic_vector (data_width-1 downto 0);
      ram_q_i                   : in  std_logic_vector (data_width-1 downto 0)
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
    adr_width                 :     integer := 16;
    data_width                :     integer := 8;
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
    use_update_adr            : boolean := false;
    update_adr                : integer := 16#ffff#;
    update_data               : integer := 16#00#;
    firmware_id               : integer := 0;
    firmware_version          : integer := 0;
    firmware_config           : integer := 0;
    boot_from_flash           : boolean := true
    );
  port (
    rst_i                  : in  std_logic;
    clk_i                  : in  std_logic;
    fub_cfg_reg_in_dat_i   : in  std_logic_vector (data_width-1 downto 0);
    fub_cfg_reg_in_adr_i   : in  std_logic_vector (adr_width-1 downto 0);
    fub_cfg_reg_in_str_i   : in  std_logic;
    fub_cfg_reg_in_busy_o  : out std_logic;
    fub_cfg_reg_out_str_o  : out std_logic;
    fub_cfg_reg_out_dat_o  : out std_logic_vector (data_width-1 downto 0);
    fub_cfg_reg_out_adr_o  : out std_logic_vector (adr_width-1 downto 0);
    fub_cfg_reg_out_busy_i : in  std_logic;
    fub_fr_busy_i          : in  std_logic;
    fub_fr_dat_i           : in  std_logic_vector (data_width-1 downto 0);
    fub_fr_str_o           : out std_logic;
    fub_fr_adr_o           : out std_logic_vector(adr_width-1 downto 0);
    fub_fw_str_o           : out std_logic;
    fub_fw_busy_i          : in  std_logic;
    fub_fw_dat_o           : out std_logic_vector (data_width-1 downto 0);
    fub_fw_adr_o           : out std_logic_vector(adr_width-1 downto 0);
    fub_out_data_o       : out std_logic_vector(data_width-1 downto 0);
    fub_out_adr_o      : out std_logic_vector(adr_width-1 downto 0);
    fub_out_str_o      : out std_logic;
    fub_out_busy_i       : in std_logic;
    ram_wren_o             : out std_logic;
    ram_adr_o              : out std_logic_vector (adr_width-1 downto 0);
    ram_dat_o              : out std_logic_vector (data_width-1 downto 0);
    ram_q_i                : in  std_logic_vector (data_width-1 downto 0)
    );
end fub_registerfile_cntrl;

architecture fub_registerfile_cntrl_arch of fub_registerfile_cntrl is

  type MAINSTATES is (READ_CFG, WRITE_CFG_SINGLE, WRITE_CFG_BLOCK, WRITE_FLASH, READ_FLASH);
  signal mainstate                   : MAINSTATES;
  type SUBSTATES is (ONE, TWO, TWO_TWO, THREE, FOUR);
  signal substate                    : SUBSTATES;
  signal start_adr, end_adr, act_adr : std_logic_vector(adr_width-1 downto 0);

  signal fub_out_adr_save      : std_logic_vector(adr_width-1 downto 0);
  signal fub_out_data_save       : std_logic_vector(data_width-1 downto 0);
  signal fub_out_flag        : std_logic;

begin
  process(clk_i, rst_i)
  begin
    if rst_i = '1' then
      if boot_from_flash = true then
        mainstate                       <= READ_FLASH; -- READ_CFG;
      else
        mainstate                       <= READ_CFG;
      end if;
      substate                          <= ONE;
      fub_cfg_reg_in_busy_o             <= '1';   -- cause of reset state READ_FLASH
      fub_cfg_reg_out_str_o             <= '0';
      ram_wren_o                        <= '0';
      ram_dat_o                         <= (others => '0');
      ram_adr_o                         <= (others => '0');
      fub_cfg_reg_out_dat_o             <= (others => '0');
      fub_cfg_reg_out_adr_o             <= (others => '0');
      fub_out_data_o          <= (others => '0');
      fub_out_adr_o           <= (others => '0');
      fub_out_str_o           <= '0';
      start_adr                         <= conv_std_logic_vector(default_start_adr, adr_width);   --(others => '0');
      end_adr                           <= conv_std_logic_vector(default_end_adr, adr_width);   --(others => '0');
      act_adr                           <= conv_std_logic_vector(default_start_adr, adr_width); --(others => '0');
      fub_fr_str_o                      <= '0';
      fub_fr_adr_o                      <= (others => '0');
      fub_fw_str_o                      <= '0';
      fub_fw_dat_o                      <= (others => '0');
      fub_fw_adr_o                      <= (others => '0');
      fub_out_flag            <= '0';
      fub_out_adr_save          <= (others => '0');
      fub_out_data_save         <= (others => '0');
      fub_cfg_reg_in_busy_o         <= '0';      
    elsif clk_i = '1' and clk_i'event then
      ram_wren_o                        <= '0';
      fub_out_str_o <= '0';     --|| fub_out_str_o reset
      if fub_out_flag = '1' then
        if fub_out_busy_i = '0' then
          fub_out_adr_o   <= fub_out_adr_save;
          fub_out_data_o    <= fub_out_data_save;
          fub_out_str_o   <= '1';         --|| fub_out_str_o set
          fub_out_flag    <= '0';       -- fub_out_flag reset
          fub_cfg_reg_in_busy_o <= '0';
        end if;
      end if;
      case mainstate is
        when READ_CFG                              =>
          ram_wren_o                    <= '0';
          fub_cfg_reg_out_str_o         <= '0';
          if fub_out_flag = '0' then
            fub_cfg_reg_in_busy_o         <= '0';      
          end if;          
          if fub_cfg_reg_in_str_i = '1' then
            case conv_integer(fub_cfg_reg_in_adr_i) is
              when REG_ADR_CMD                     =>
                if fub_cfg_reg_in_dat_i(0) = '1' then  --read single
                  ram_adr_o             <= start_adr;
                  mainstate             <= WRITE_CFG_SINGLE;
                  fub_cfg_reg_in_busy_o <= '1';
                elsif fub_cfg_reg_in_dat_i(1) = '1' then  --read block
                  mainstate             <= WRITE_CFG_BLOCK;
                  fub_cfg_reg_in_busy_o <= '1';
                elsif fub_cfg_reg_in_dat_i(2) = '1' then  --update flash
                  mainstate             <= WRITE_FLASH;
                  fub_cfg_reg_in_busy_o <= '1';
                elsif fub_cfg_reg_in_dat_i(3) = '1' then  --read flash
                  mainstate             <= READ_FLASH;
                  fub_cfg_reg_in_busy_o <= '1';
                end if;
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
                      fub_out_str_o <= '1';     --|| fub_out_str_o set
                      fub_out_data_o  <= fub_cfg_reg_in_dat_i;
                      fub_out_adr_o <= fub_cfg_reg_in_adr_i;
                  else
                    fub_cfg_reg_in_busy_o <= '1';
                    fub_out_flag    <= '1';     -- fub_out_flag set
                    fub_out_adr_save  <= fub_cfg_reg_in_adr_i;
                    fub_out_data_save <= fub_cfg_reg_in_dat_i;
                  end if;
                end if;
                ram_dat_o               <= fub_cfg_reg_in_dat_i;
                ram_adr_o               <= fub_cfg_reg_in_adr_i;
                ram_wren_o              <= '1';
            end case;
            act_adr                     <= start_adr;
          end if;
        when WRITE_CFG_SINGLE                      =>
          case substate is
            when ONE                               =>
              substate                  <= TWO;  --wait one clock cycle for dat
            when TWO                               =>
              if fub_cfg_reg_out_busy_i = '0' then
                case conv_integer(start_adr) is
                  when reg_adr_firmware_id   =>
                      fub_cfg_reg_out_adr_o   <= conv_std_logic_vector(reg_adr_firmware_id,adr_width);
                      fub_cfg_reg_out_dat_o   <= conv_std_logic_vector(firmware_id,data_width);
                  when reg_adr_firmware_version    =>
                      fub_cfg_reg_out_adr_o   <= conv_std_logic_vector(reg_adr_firmware_version,adr_width);
                      fub_cfg_reg_out_dat_o   <= conv_std_logic_vector(firmware_version,data_width);
                  when reg_adr_firmware_config   =>
                      fub_cfg_reg_out_adr_o   <= conv_std_logic_vector(reg_adr_firmware_config,adr_width);
                      fub_cfg_reg_out_dat_o   <= conv_std_logic_vector(firmware_config,data_width);
                  when others =>  
                      fub_cfg_reg_out_adr_o   <= start_adr;
                      fub_cfg_reg_out_dat_o   <= ram_q_i;
                end case;
                fub_cfg_reg_out_str_o   <= '1';
                mainstate               <= READ_CFG;
                substate                <= ONE;
              end if;
            when others                            =>
          end case;
        when WRITE_CFG_BLOCK                       =>
          case substate is
            when ONE                               =>
              ram_adr_o                 <= act_adr;
              substate                  <= TWO;
              fub_cfg_reg_out_str_o     <= '0';
            when TWO                               =>
				substate				<= TWO_TWO;
			when TWO_TWO						   =>	-- EINGEFÜGT // EVENTUELL überdenken
				substate                  <= THREE;
            when THREE                             =>
              if fub_cfg_reg_out_busy_i = '0' then
                case conv_integer(act_adr) is
                  when reg_adr_firmware_id   =>
                      fub_cfg_reg_out_adr_o   <= conv_std_logic_vector(reg_adr_firmware_id,adr_width);
                      fub_cfg_reg_out_dat_o   <= conv_std_logic_vector(firmware_id,data_width);
                  when reg_adr_firmware_version    =>
                      fub_cfg_reg_out_adr_o   <= conv_std_logic_vector(reg_adr_firmware_version,adr_width);
                      fub_cfg_reg_out_dat_o   <= conv_std_logic_vector(firmware_version,data_width);
                  when reg_adr_firmware_config   =>
                      fub_cfg_reg_out_adr_o   <= conv_std_logic_vector(reg_adr_firmware_config,adr_width);
                      fub_cfg_reg_out_dat_o   <= conv_std_logic_vector(firmware_config,data_width);
                  when others =>  
                      fub_cfg_reg_out_adr_o   <= act_adr;
                      fub_cfg_reg_out_dat_o   <= ram_q_i;
                end case;
                fub_cfg_reg_out_str_o   <= '1';
                act_adr                 <= act_adr+1;  --wirkt am ende des Taktes
                if act_adr = end_adr then
                  mainstate             <= READ_CFG;
                end if;
                substate                <= ONE;
              end if;
            when others                            =>
          end case;
        when WRITE_FLASH                           =>
          case substate is
            when ONE                               =>
              ram_adr_o                 <= act_adr;
              substate                  <= TWO;
              fub_fw_str_o              <= '0';
            when TWO                               =>
              substate                  <= THREE;
            when THREE                             =>
              if fub_fw_busy_i = '0' then
                fub_fw_adr_o            <= act_adr;
                fub_fw_dat_o            <= ram_q_i;
                fub_fw_str_o            <= '1';
                act_adr                 <= act_adr+1;  --wirkt am Ende des Taktes
                if act_adr = end_adr then  -- end_adr wird noch geschrieben
                  substate                <= FOUR;
                else
                  substate                <= ONE;
                end if;
              end if;
            when FOUR                             =>
              fub_fw_str_o            <= '0';
              substate                <= ONE;
              mainstate             <= READ_CFG;              
            when others                            =>
          end case;
        when READ_FLASH                            =>
          fub_cfg_reg_in_busy_o <= '1';
          case substate is
            when ONE                               =>
              if fub_out_flag = '0' then
                if fub_fr_busy_i = '0' then
                  ram_wren_o              <= '0';
                  ram_adr_o               <= act_adr;
                  fub_fr_adr_o            <= act_adr;
                  fub_fr_str_o            <= '1';
                  act_adr                 <= act_adr+1;
                  substate                <= TWO;
                end if;
              end if;
            when TWO                               =>
              fub_fr_str_o            <= '0';
              substate   <= THREE;
            when THREE                               =>   -- comment of t.guthier 21.12.07
              if fub_fr_busy_i = '0' then                 -- not fub optimized!
                ram_wren_o              <= '1';           -- may lead to problems with fub_flash
                ram_dat_o               <= fub_fr_dat_i;  -- str_o is one clk to late for a good working block transfer
                if act_adr /= mask_adr+1 then
                  if fub_out_busy_i = '0' then
                    fub_out_str_o <= '1';     --|| fub_out_str_o set
                    fub_out_adr_o <= act_adr - 1;
                    fub_out_data_o  <= fub_fr_dat_i;
                  else
                    fub_out_flag    <= '1';     -- fub_out_flag set
                    fub_out_adr_save  <= act_adr - 1;
                    fub_out_data_save <= fub_fr_dat_i;
                  end if;
                end if;
                substate        <= ONE;
                if act_adr = end_adr+1 then
                	if use_update_adr = true then
		                substate        <= FOUR;
                	else
                  	mainstate       <= READ_CFG;
                	end if;
                end if;
              end if;
            when FOUR =>
            	ram_wren_o <= '0';
              if fub_out_busy_i = '0' then
                fub_out_str_o 	<= '1';
                fub_out_adr_o 	<= conv_std_logic_vector(update_adr,adr_width);
                fub_out_data_o  <= conv_std_logic_vector(update_data,data_width);
		            substate        <= ONE;
		          	mainstate       <= READ_CFG;
		          end if;
            when others                            =>
          end case;
      end case;
    end if;
  end process;
end fub_registerfile_cntrl_arch;

