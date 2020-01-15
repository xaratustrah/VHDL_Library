-------------------------------------------------------------------------------
--
-- FUB-VGA for AD8369 Variable Gain Amplifier.
-- S. Sanjari
-- 
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

-- Package Definition

package fub_vga_pkg is

  component fub_vga
    generic (
      default_gain   : std_logic_vector (3 downto 0);
      spi_address    : integer;
      fub_addr_width : integer;
      fub_data_width : integer);
    port (
      clk_i      : in  std_logic;
      rst_i      : in  std_logic;
      vga_gain_i : in  std_logic_vector(3 downto 0);
      vga_str_i  : in  std_logic;
      vga_busy_o : out std_logic;
      fub_data_o : out std_logic_vector(fub_data_width - 1 downto 0);
      fub_adr_o  : out std_logic_vector(fub_addr_width - 1 downto 0);
      fub_str_o  : out std_logic;
      fub_busy_i : in  std_logic);
  end component;

end fub_vga_pkg;

package body fub_vga_pkg is
end fub_vga_pkg;

-- Entity Definition


library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_arith.all;

entity fub_vga is
  
  generic (
    default_gain   : std_logic_vector (3 downto 0) := "0010";
    spi_address    : integer                       := 2;  -- depends on Multi-SPI-Master
    fub_addr_width : integer                       := 4;  -- dpends on Multi-SPI-Master
    fub_data_width : integer                       := 8
    );

  port (
    clk_i : in std_logic;
    rst_i : in std_logic;

    vga_gain_i : in  std_logic_vector(3 downto 0);
    vga_str_i  : in  std_logic;
    vga_busy_o : out std_logic;

    fub_data_o : out std_logic_vector(fub_data_width - 1 downto 0);
    fub_adr_o  : out std_logic_vector(fub_addr_width - 1 downto 0);
    fub_str_o  : out std_logic;
    fub_busy_i : in  std_logic

    );

end fub_vga;

architecture fub_vga_arch of fub_vga is

  type states is (INIT_VGA, WAIT_FOR_STR, SEND_TO_VGA);
  signal state : states;
  
begin  -- fub_vga_arch

  p_main : process (clk_i, rst_i)
  begin  -- process p_main
    if rst_i = '1' then                 -- asynchronous reset (active high
      vga_busy_o <= '1';
      fub_str_o  <= '0';
      fub_adr_o  <= (others => '0');
      fub_data_o <= (others => '0');
      state      <= INIT_VGA;
      
    elsif clk_i'event and clk_i = '1' then  -- rising clock edge
      case state is
        
        when INIT_VGA =>
          if fub_busy_i = '0' then
            fub_data_o (7 downto 4) <= default_gain;
            fub_data_o (3 downto 0) <= default_gain;
            fub_adr_o               <= conv_std_logic_vector (spi_address, fub_addr_width);
            fub_str_o               <= '1';
            vga_busy_o              <= '0';
            state                   <= WAIT_FOR_STR;
          else
            fub_str_o <= '0';
          end if;

        when WAIT_FOR_STR =>
          fub_str_o <= '0';
          if vga_str_i = '1' then
            vga_busy_o <= '1';
            state      <= SEND_TO_VGA;
          end if;
          
        when SEND_TO_VGA =>
          if fub_busy_i = '0' then
            fub_data_o (7 downto 4) <= vga_gain_i;
            fub_data_o (3 downto 0) <= vga_gain_i;
            fub_adr_o               <= conv_std_logic_vector (spi_address, fub_addr_width);
            fub_str_o               <= '1';
            vga_busy_o              <= '0';
            state                   <= WAIT_FOR_STR;
          else
            fub_str_o <= '0';
          end if;
        when others => null;
      end case;
    end if;
  end process p_main;

end fub_vga_arch;
