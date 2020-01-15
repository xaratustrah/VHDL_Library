-------------------------------------------------------------------------------
--
-- FUB sender that transmit the content of parallel data words that are connected to the input port. 
-- The target fub addresses can be specified with a seperate input vector. 
--
-- M. Kumm
-------------------------------------------------------------------------------
-- Package Definition

library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_arith.all;
use IEEE.STD_LOGIC_unsigned.all;
use ieee.math_real.all;

--use work.init_rom_pkg.all;

package parallel_to_fub_pkg is

  component parallel_to_fub
    generic (
      no_of_data_bytes : integer;
      adr_width        : integer
      );
    port (
      rst_i      : in  std_logic;
      clk_i      : in  std_logic;
      par_data_i : in  std_logic_vector(no_of_data_bytes*8-1 downto 0);
      par_adr_i  : in  std_logic_vector(no_of_data_bytes*adr_width-1 downto 0);
      par_str_i  : in  std_logic;
      par_busy_o : out std_logic;
      fub_data_o : out std_logic_vector(7 downto 0);
      fub_adr_o  : out std_logic_vector(adr_width-1 downto 0);
      fub_str_o  : out std_logic;
      fub_busy_i : in  std_logic
      );
  end component;
end parallel_to_fub_pkg;

package body parallel_to_fub_pkg is
end parallel_to_fub_pkg;

-- Entity Definition

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;


entity parallel_to_fub is
  generic (
    no_of_data_bytes : integer := 10;
    adr_width        : integer := 8
    );
  port (
    rst_i      : in  std_logic;
    clk_i      : in  std_logic;
    par_data_i : in  std_logic_vector(no_of_data_bytes*8-1 downto 0);
    par_adr_i  : in  std_logic_vector(no_of_data_bytes*adr_width-1 downto 0);
    par_str_i  : in  std_logic;
    par_busy_o : out std_logic;
    fub_data_o : out std_logic_vector(7 downto 0);
    fub_adr_o  : out std_logic_vector(adr_width-1 downto 0);
    fub_str_o  : out std_logic;
    fub_busy_i : in  std_logic
    );
end parallel_to_fub;

architecture arch_parallel_to_fub of parallel_to_fub is

  signal cnt : integer range 0 to no_of_data_bytes;
	signal s_par_data_i : std_logic_vector(no_of_data_bytes*8-1 downto 0);
  signal s_par_adr_i  : std_logic_vector(no_of_data_bytes*adr_width-1 downto 0);

  type par_data_array_type is array(0 to no_of_data_bytes-1) of
    std_logic_vector(7 downto 0);
  signal par_data_array : par_data_array_type;

  type par_adr_array_type is array(0 to no_of_data_bytes-1) of
    std_logic_vector(adr_width-1 downto 0);
  signal par_adr_array : par_adr_array_type;

  type states is (
    WAIT_FOR_STR,
    SENDING_DATA
    );
  signal state : states;

begin
  parallel_to_array_gen : for i in 0 to no_of_data_bytes-1 generate
    par_data_array(i) <= s_par_data_i((i+1)*8-1 downto i*8);
    par_adr_array(i)  <= s_par_adr_i((i+1)*adr_width-1 downto i*adr_width);
  end generate;

  process (clk_i, rst_i)
  begin
    if rst_i = '1' then
      cnt        <= 0;
      fub_str_o  <= '0';
      fub_data_o <= (others => '0');
      fub_adr_o  <= (others => '0');
      par_busy_o <= '0';
      state      <= WAIT_FOR_STR;
      
    elsif clk_i = '1' and clk_i'event then
      case state is
        when WAIT_FOR_STR =>
          if par_str_i = '1' then
						s_par_data_i 	<= par_data_i;
						s_par_adr_i 	<= par_adr_i;
            par_busy_o <= '1';
            state      <= SENDING_DATA;
          end if;

        when SENDING_DATA =>
          if cnt < no_of_data_bytes then
            if fub_busy_i = '0' then
              fub_data_o <= par_data_array(cnt);
              fub_adr_o  <= par_adr_array(cnt);
              fub_str_o  <= '1';
              cnt        <= cnt + 1;
            end if;
          else
            if fub_busy_i = '0' then
              cnt        <= 0;
              fub_str_o  <= '0';
              par_busy_o <= '0';
              state      <= WAIT_FOR_STR;
            end if;
          end if;
      end case;
    end if;
  end process;

end arch_parallel_to_fub;
