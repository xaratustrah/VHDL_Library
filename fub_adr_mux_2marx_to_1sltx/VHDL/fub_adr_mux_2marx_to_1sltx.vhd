-------------------------------------------------------------------------------
--
-- Written by T. Wollmann
--
-------------------------------------------------------------------------------

-- Package Definition

library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_arith.all;
use IEEE.STD_LOGIC_unsigned.all;

package fub_adr_mux_2marx_to_1sltx_pkg is
  component fub_adr_mux_2marx_to_1sltx
    generic (
			fub_data_width      : integer :=  8;
			fub_in_adr_width    : integer :=  9;
			fub_out_adr_width   : integer :=  8
      );
    port (
      clk_i       :     std_logic;
      rst_i       :     std_logic;
      -- FUB channel A
      fubA_data_i : in  std_logic_vector(fub_data_width-1 downto 0);
      fubA_adr_o  : out std_logic_vector(fub_out_adr_width-1 downto 0);
      fubA_str_o  : out std_logic;
      fubA_busy_i : in  std_logic;
      -- FUB channel B
      fubB_data_i : in  std_logic_vector(fub_data_width-1 downto 0);
      fubB_adr_o  : out std_logic_vector(fub_out_adr_width-1 downto 0);
      fubB_str_o  : out std_logic;
      fubB_busy_i : in  std_logic;
      -- FUB output
      fub_data_o  : out std_logic_vector(fub_data_width-1 downto 0);
      fub_adr_i   : in  std_logic_vector(fub_in_adr_width-1 downto 0);
      fub_str_i   : in  std_logic;
      fub_busy_o  : out std_logic
      );
  end component;
end fub_adr_mux_2marx_to_1sltx_pkg;

package body fub_adr_mux_2marx_to_1sltx_pkg is
end fub_adr_mux_2marx_to_1sltx_pkg;

-- Entity Definition

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity fub_adr_mux_2marx_to_1sltx is
  generic (
    fub_data_width      : integer :=  8;
    fub_in_adr_width    : integer :=  9;
    fub_out_adr_width   : integer :=  8
    );
  port (
      clk_i       :     std_logic;
      rst_i       :     std_logic;
      -- FUB channel A
      fubA_data_i : in  std_logic_vector(fub_data_width-1 downto 0);
      fubA_adr_o  : out std_logic_vector(fub_out_adr_width-1 downto 0);
      fubA_str_o  : out std_logic;
      fubA_busy_i : in  std_logic;
      -- FUB channel B
      fubB_data_i : in  std_logic_vector(fub_data_width-1 downto 0);
      fubB_adr_o  : out std_logic_vector(fub_out_adr_width-1 downto 0);
      fubB_str_o  : out std_logic;
      fubB_busy_i : in  std_logic;
      -- FUB output
      fub_data_o  : out std_logic_vector(fub_data_width-1 downto 0);
      fub_adr_i   : in  std_logic_vector(fub_in_adr_width-1 downto 0);
      fub_str_i   : in  std_logic;
      fub_busy_o  : out std_logic
    );
begin

  assert fub_in_adr_width-1 = fub_out_adr_width
    report "fub_out_adr_width muss 1 Bit kleiner als fub_in_adr_width sein!"
    severity error;
  
end entity fub_adr_mux_2marx_to_1sltx;

architecture fub_adr_mux_2marx_to_1sltx_arch of fub_adr_mux_2marx_to_1sltx is

  type  states is (
    IDLE,
    DATA_A,
    DATA_B
  );
    
  signal  state     : states;
  signal  old_data  : std_logic_vector(fubA_data_i'range);

begin

  process(clk_i, rst_i)
    begin
      if rst_i = '1' then
        fubA_adr_o  <=  (others => '0');
        fubA_str_o  <=  '0';
        fubB_adr_o  <=  (others => '0');
        fubB_str_o  <=  '0';
        fub_data_o  <=  (others => '0');
        fub_busy_o  <=  '0';
        state       <=  IDLE;
      elsif clk_i'event and clk_i = '1' then

        case state is
          when IDLE =>
            if fub_str_i = '1' then
              fub_busy_o    <=  '1';
              if fub_adr_i(fub_in_adr_width-1) = '0' then
                state       <=  DATA_A;
                old_data    <=  fubA_data_i;
                fubA_str_o  <=  '1';
                fubA_adr_o  <=  fub_adr_i(fubA_adr_o'range);
              elsif fub_adr_i(fub_in_adr_width-1) = '1' then
                state       <=  DATA_B;
                old_data    <=  fubB_data_i;
                fubB_str_o  <=  '1';
                fubB_adr_o  <=  fub_adr_i(fubB_adr_o'range);
              end if;
            end if;

          when DATA_A  =>
            if fubA_busy_i = '0' and old_data /=  fubA_data_i then
              fub_data_o    <=  fubA_data_i;
              fub_busy_o    <=  '0';
              fubA_str_o    <=  '0';
              state         <=  IDLE;  
            end if;
            
          when DATA_B =>
            if fubB_busy_i  = '0' and old_data /=  fubB_data_i then
              fub_data_o    <=  fubB_data_i;
              fub_busy_o    <=  '0';
              fubB_str_o    <=  '0';
              state         <=  IDLE;    
            end if;
            
          when others =>  null;
        
        end case;
        
      end if;
  end process;


end architecture fub_adr_mux_2marx_to_1sltx_arch;
