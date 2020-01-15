-------------------------------------------------------------------------------
--
-- M. Kumm
-- 
--
-------------------------------------------------------------------------------

-- Package Definition

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

package fub_demux_1_to_2_pkg is
  component fub_demux_1_to_2
    generic (
      fub_data_width     : integer;
      fub_adr_width      : integer;
      wait_for_both_busy : boolean := true -- true = both bussies have to be '0' for a strb='1' 
      );
    port (
      clk_i        :     std_logic;
      rst_i        :     std_logic;
      -- FUB input
      fub_data_i   : in  std_logic_vector(fub_data_width-1 downto 0);
      fub_adr_i    : in  std_logic_vector(fub_adr_width-1 downto 0);
      fub_str_i    : in  std_logic;
      fub_busy_o   : out std_logic;
      -- FUB channel A
      fub_a_data_o : out std_logic_vector(fub_data_width-1 downto 0);
      fub_a_adr_o  : out std_logic_vector(fub_adr_width-1 downto 0);
      fub_a_str_o  : out std_logic;
      fub_a_busy_i : in  std_logic;
      -- FUB channel B
      fub_b_data_o : out std_logic_vector(fub_data_width-1 downto 0);
      fub_b_adr_o  : out std_logic_vector(fub_adr_width-1 downto 0);
      fub_b_str_o  : out std_logic;
      fub_b_busy_i : in  std_logic
      );
  end component;
end fub_demux_1_to_2_pkg;


package body fub_demux_1_to_2_pkg is
end fub_demux_1_to_2_pkg;

-- Entity Definition

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity fub_demux_1_to_2 is
  generic (
    fub_data_width     : integer;
    fub_adr_width      : integer;
    wait_for_both_busy : boolean := true
    );
  port (
    clk_i        :     std_logic;
    rst_i        :     std_logic;
    -- FUB input
    fub_data_i   : in  std_logic_vector(fub_data_width-1 downto 0);
    fub_adr_i    : in  std_logic_vector(fub_adr_width-1 downto 0);
    fub_str_i    : in  std_logic;
    fub_busy_o   : out std_logic;
    -- FUB channel A
    fub_a_data_o : out std_logic_vector(fub_data_width-1 downto 0);
    fub_a_adr_o  : out std_logic_vector(fub_adr_width-1 downto 0);
    fub_a_str_o  : out std_logic;
    fub_a_busy_i : in  std_logic;
    -- FUB channel B
    fub_b_data_o : out std_logic_vector(fub_data_width-1 downto 0);
    fub_b_adr_o  : out std_logic_vector(fub_adr_width-1 downto 0);
    fub_b_str_o  : out std_logic;
    fub_b_busy_i : in  std_logic
    );
begin

end entity fub_demux_1_to_2;

architecture fub_demux_1_to_2_arch of fub_demux_1_to_2 is

  type states is (WAIT_FOR_STROBE, WAIT_FOR_BUSY, SENDING);
  signal state : states;
  
begin
  
  process (rst_i, clk_i)
  begin

    if (rst_i = '1') then
      fub_a_data_o <= (others => '0');
      fub_b_data_o <= (others => '0');
      fub_a_adr_o  <= (others => '0');
      fub_b_adr_o  <= (others => '0');
      fub_busy_o   <= '1';
      fub_a_str_o  <= '0';
      fub_b_str_o  <= '0';
      state        <= WAIT_FOR_STROBE;
    elsif (clk_i = '1' and clk_i'event) then
      case state is
        when WAIT_FOR_STROBE =>
          if (wait_for_both_busy = true and fub_a_busy_i = '0' and fub_b_busy_i = '0') or (wait_for_both_busy = false and (fub_a_busy_i = '0' or fub_b_busy_i = '0')) then
            fub_busy_o <= '0';
            if fub_str_i = '1' then
              fub_busy_o <= '1';
              if(fub_a_busy_i = '0') then  -- ( S.Schäfer) Bugfix : vorher stand da: if(wait_for_both_busy = false and fub_a_busy_i = '0') then
                fub_a_data_o <= fub_data_i;
                fub_a_adr_o  <= fub_adr_i;
                fub_a_str_o  <= '1';
              end if;
              if(fub_b_busy_i = '0') then -- ( S.Schäfer) Bugfix : vorher stand da: wait_for_both_busy = false and fub_b_busy_i = '0'
                fub_b_data_o <= fub_data_i;
                fub_b_adr_o  <= fub_adr_i;
                fub_b_str_o  <= '1';
              end if;
              state <= SENDING;
            end if;
          else
            fub_busy_o <= '1';
          end if;
        when SENDING =>
          fub_a_str_o <= '0';
          fub_b_str_o <= '0';
          state       <= WAIT_FOR_BUSY;
        when WAIT_FOR_BUSY =>
          if (wait_for_both_busy = true and fub_a_busy_i = '0' and fub_b_busy_i = '0') or (wait_for_both_busy = false and (fub_a_busy_i = '0' or fub_b_busy_i = '0')) then
            fub_busy_o <= '0';
            state      <= WAIT_FOR_STROBE;
          end if;
      end case;
    end if;
  end process;


end architecture fub_demux_1_to_2_arch;
