-------------------------------------------------------------------------------
--
-- FUB receiver that transmit the content of fub data words in parallel to the output. 
-- The target fub addresses can be specified with a seperate input vector. 
-- This component is the counterpart to parallel_to_fub
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

package fub_to_parallel_pkg is

  component fub_to_parallel
    generic (
      no_of_data_bytes : integer;
      adr_width        : integer;
      update_adr       : integer
      );
    port (
      rst_i      : in  std_logic;
      clk_i      : in  std_logic;
      par_data_o : out std_logic_vector(no_of_data_bytes*8-1 downto 0);
      par_adr_i  : in  std_logic_vector(no_of_data_bytes*adr_width-1 downto 0);
      par_str_o  : out std_logic;
      par_busy_i : in  std_logic;
      fub_data_i : in  std_logic_vector(7 downto 0);
      fub_adr_i  : in  std_logic_vector(adr_width-1 downto 0);
      fub_str_i  : in  std_logic;
      fub_busy_o : out std_logic
      );
  end component;
end fub_to_parallel_pkg;

package body fub_to_parallel_pkg is
end fub_to_parallel_pkg;

-- Entity Definition

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;


entity fub_to_parallel is
  generic (
    no_of_data_bytes : integer := 10;
    adr_width        : integer := 8;
    update_adr       : integer := 0
    );
    port (
      rst_i      : in  std_logic;
      clk_i      : in  std_logic;
      par_data_o : out std_logic_vector(no_of_data_bytes*8-1 downto 0);
      par_adr_i  : in  std_logic_vector(no_of_data_bytes*adr_width-1 downto 0);
      par_str_o  : out std_logic;
      par_busy_i : in  std_logic;
      fub_data_i : in  std_logic_vector(7 downto 0);
      fub_adr_i  : in  std_logic_vector(adr_width-1 downto 0);
      fub_str_i  : in  std_logic;
      fub_busy_o : out std_logic
    );
end fub_to_parallel;

architecture arch_fub_to_parallel of fub_to_parallel is

  signal cnt : integer range 0 to no_of_data_bytes;

  type par_data_array_type is array(0 to no_of_data_bytes-1) of std_logic_vector(7 downto 0);
  signal par_data_array : par_data_array_type;

  type par_adr_array_type is array(0 to no_of_data_bytes-1) of std_logic_vector(adr_width-1 downto 0);
  signal par_adr_array : par_adr_array_type;

begin
  parallel_to_array_gen : for i in 0 to no_of_data_bytes-1 generate
    par_data_o((i+1)*8-1 downto i*8) <= par_data_array(i);
    par_adr_array(i)  <= par_adr_i((i+1)*adr_width-1 downto i*adr_width);
  end generate;

  fub_busy_o <= par_busy_i;
  
  process (clk_i, rst_i)
  begin
    if rst_i = '1' then
      for i in 0 to no_of_data_bytes-1 loop
        par_data_array(i) <= (others => '0');
      end loop;
      par_str_o <= '0';
    elsif clk_i = '1' and clk_i'event then
      if par_busy_i='0' then
        par_str_o <= '0';
      end if;
      if fub_str_i = '1' then
        for i in 0 to no_of_data_bytes-1 loop
          if fub_adr_i = par_adr_array(i) then
            par_data_array(i) <= fub_data_i;
          end if;
        end loop ;            
        if conv_integer(fub_adr_i) = update_adr then
          par_str_o <= '1';
        end if;
      end if;
    end if;
  end process;

end arch_fub_to_parallel;
