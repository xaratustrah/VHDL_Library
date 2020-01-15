-------------------------------------------------------------------------------
-- fub_adr_demux_1slrx_to_2matx
-- 
-- S. Sanjari
-- Strobe and busy parts added by T. Wollmann 02.12.2008
--
-------------------------------------------------------------------------------

-- Package Definition

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

package fub_adr_demux_1slrx_to_2matx_pkg is
  component fub_adr_demux_1slrx_to_2matx
    generic (
      fub_i_data_width : integer;
      fub_a_data_width : integer;
      fub_b_data_width : integer;
      fub_i_adr_width  : integer;
      fub_a_adr_width  : integer;
      fub_b_adr_width  : integer;
      use_output_adr   : integer := 1);
    port (
      clk_i        :     std_logic;
      rst_i        :     std_logic;
      -- FUB input
      fub_i_data_i : in  std_logic_vector(fub_i_data_width-1 downto 0);
      fub_i_adr_i  : in  std_logic_vector(fub_i_adr_width-1 downto 0);
      fub_i_str_i  : in  std_logic;
      fub_i_busy_o : out std_logic;
      -- FUB channel A
      fub_a_data_o : out std_logic_vector(fub_a_data_width-1 downto 0);
      fub_a_adr_o  : out std_logic_vector(use_output_adr*(fub_a_adr_width-1) downto 0);
      fub_a_str_o  : out std_logic;
      fub_a_busy_i : in  std_logic;
      -- FUB channel B
      fub_b_data_o : out std_logic_vector(fub_b_data_width-1 downto 0);
      fub_b_adr_o  : out std_logic_vector(use_output_adr*(fub_b_adr_width-1) downto 0);
      fub_b_str_o  : out std_logic;
      fub_b_busy_i : in  std_logic
      );
  end component;
  
end fub_adr_demux_1slrx_to_2matx_pkg;

-- Entity Definition

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity fub_adr_demux_1slrx_to_2matx is
  generic(
    fub_i_data_width : integer := 8;
    fub_a_data_width : integer := 8;
    fub_b_data_width : integer := 8;
    fub_i_adr_width  : integer := 6;
    fub_a_adr_width  : integer := 3;
    fub_b_adr_width  : integer := 5;
    use_output_adr   : integer := 1);
  port (
    clk_i        :     std_logic;
    rst_i        :     std_logic;
    -- FUB input
    fub_i_data_i : in  std_logic_vector(fub_i_data_width-1 downto 0);
    fub_i_adr_i  : in  std_logic_vector(fub_i_adr_width-1 downto 0);
    fub_i_str_i  : in  std_logic;
    fub_i_busy_o : out std_logic;
    -- FUB channel A
    fub_a_data_o : out std_logic_vector(fub_a_data_width-1 downto 0);
    fub_a_adr_o  : out std_logic_vector(use_output_adr*(fub_a_adr_width-1) downto 0);
    fub_a_str_o  : out std_logic;
    fub_a_busy_i : in  std_logic;
    -- FUB channel B
    fub_b_data_o : out std_logic_vector(fub_b_data_width-1 downto 0);
    fub_b_adr_o  : out std_logic_vector(use_output_adr*(fub_b_adr_width-1) downto 0);
    fub_b_str_o  : out std_logic;
    fub_b_busy_i : in  std_logic
    );

  signal fub_i_adr_tmp  : std_logic_vector(fub_i_adr_width-1 downto 0);
  signal fub_i_data_tmp : std_logic_vector(fub_i_data_width-1 downto 0);

  signal try_again_flag : std_logic;
    
begin

  assert fub_a_adr_width <= fub_i_adr_width
    report "fub_a_adr_width muss kleiner oder gleich als fub_i_adr_width sein!"
    severity error;

  assert fub_b_adr_width <= fub_i_adr_width
    report "fub_b_adr_width muss kleiner oder gleich als fub_i_adr_width sein!"
    severity error;

--  assert (fub_a_adr_width = fub_i_adr_width - 1) or (fub_b_adr_width = fub_i_adr_width - 1)
--    report "fub_i_adr_width muss 1 bit groesser als das groesste zwischen fub_a_adr_width und fub_b_adr_width sein."
--    severity failure;

  assert fub_a_data_width <= fub_i_data_width
                             report "fub_a_data_width muss kleiner gleich als fub_i_data_width sein!"
                             severity error;

  assert fub_b_data_width <= fub_i_data_width
                             report "fub_b_data_width muss kleiner gleich als fub_i_data_width sein!"
                             severity error;

end entity fub_adr_demux_1slrx_to_2matx;

architecture fub_adr_demux_1slrx_to_2matx_arch of fub_adr_demux_1slrx_to_2matx is

begin  -- fub_adr_demux_1slrx_to_2matx-arch
  
  process (rst_i, clk_i)
  begin

    if (rst_i = '1') then
      fub_a_data_o <= (others => '0');
      fub_b_data_o <= (others => '0');
      fub_a_adr_o  <= (others => '0');
      fub_b_adr_o  <= (others => '0');
      fub_i_busy_o <= '0';
      fub_a_str_o  <= '0';
      fub_b_str_o  <= '0';
      fub_i_adr_tmp  <= (others => '0');
      fub_i_data_tmp <= (others => '0');
      try_again_flag <= '0';
    elsif (clk_i = '1' and clk_i'event) then
      --if busy is set then try again sending tmp data  
      if try_again_flag = '1' then
        if fub_i_adr_tmp (fub_i_adr_width - 1) = '0' then
          if fub_a_busy_i = '0' then
            fub_a_str_o	<=	'1';
            fub_a_adr_o  <= fub_i_adr_tmp (fub_a_adr_o'range);
            fub_a_data_o <= fub_i_data_tmp (fub_a_data_o'range);
            fub_i_busy_o   <= '0';
            try_again_flag <= '0';              
          end if;
        else   
          if fub_b_busy_i = '0' then
            fub_b_str_o	<=	'1';
            fub_b_adr_o  <= fub_i_adr_tmp (fub_b_adr_o'range);
            fub_b_data_o <= fub_i_data_tmp (fub_b_data_o'range);
            fub_i_busy_o   <= '0';
            try_again_flag <= '0';              
          end if;
        end if;
      elsif fub_i_str_i = '1' then
        if fub_i_adr_i (fub_i_adr_width - 1) = '0' then
					fub_b_str_o	<=	'0';
          if fub_a_busy_i = '0' then
            --send directly
            fub_a_str_o	<=	'1';
            fub_a_adr_o  <= fub_i_adr_i (fub_a_adr_o'range);
            fub_a_data_o <= fub_i_data_i (fub_a_data_o'range);
            fub_i_busy_o   <= '0';  
          else
            --store
            fub_i_adr_tmp  <= fub_i_adr_i (fub_i_adr_i'range);
            fub_i_data_tmp <= fub_i_data_i (fub_i_data_i'range);
            fub_i_busy_o   <= '1';
            try_again_flag <= '1';
          end if;
        else
					fub_a_str_o	<=	'0';
          if fub_b_busy_i = '0' then
            --send directly
            fub_b_str_o	<=	'1';
            fub_b_adr_o  <= fub_i_adr_i (fub_b_adr_o'range);
            fub_b_data_o <= fub_i_data_i (fub_b_data_o'range);
            fub_i_busy_o   <= '0';  
          else
            --store
            fub_i_adr_tmp  <= fub_i_adr_i (fub_i_adr_i'range);
            fub_i_data_tmp <= fub_i_data_i (fub_i_data_i'range);
            fub_i_busy_o   <= '1';
            try_again_flag <= '1';
          end if;
        end if;
      else
        if fub_a_busy_i = '0' then
          fub_a_str_o	<=	'0';
        end if;
        if fub_b_busy_i = '0' then
          fub_b_str_o	<=	'0';
        end if;
      end if;
    end if;
  end process;
  
end fub_adr_demux_1slrx_to_2matx_arch;
