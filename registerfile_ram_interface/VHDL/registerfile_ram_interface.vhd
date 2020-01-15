-------------------------------------------------------------------------------
--
-- registerfile with same entity signals as altsyncram
-- M. Kumm
-- 
--
-------------------------------------------------------------------------------

-- Package Definition

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

package registerfile_ram_interface_pkg is
  component registerfile_ram_interface
    generic (
        adr_width  :     integer;
        data_width  :     integer;
        no_of_registers : integer
      );
    port (
      rst_i      : in  std_logic;
      clk_i      : in  std_logic;
      wren_a     : in  std_logic;
      adr_a      : in  std_logic_vector (adr_width-1 downto 0);
      dat_a      : in  std_logic_vector (data_width-1 downto 0);
      q_a        : out std_logic_vector (data_width-1 downto 0);
      register_o : out std_logic_vector (no_of_registers * data_width - 1 downto 0);
      register_i : in  std_logic_vector (no_of_registers * data_width - 1 downto 0)
      );
  end component;
end registerfile_ram_interface_pkg;


package body registerfile_ram_interface_pkg is
end registerfile_ram_interface_pkg;

-- Entity Definition


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity registerfile_ram_interface is
  generic (
      adr_width  :     integer := 16;
      data_width  :     integer := 8;
      no_of_registers : integer := 100
    );
  port (
    rst_i      : in  std_logic;
    clk_i      : in  std_logic;
    wren_a     : in  std_logic;
    adr_a      : in  std_logic_vector (adr_width-1 downto 0);
    dat_a      : in  std_logic_vector (data_width-1 downto 0);
    q_a        : out std_logic_vector (data_width-1 downto 0);
    register_o : out std_logic_vector (no_of_registers * data_width - 1 downto 0);
    register_i : in  std_logic_vector (no_of_registers * data_width - 1 downto 0)
    );
end registerfile_ram_interface;

architecture registerfile_ram_interface_arch of registerfile_ram_interface is
  
  type register_file_array_type is array(0 to no_of_registers-1) of std_logic_vector(data_width-1 downto 0);
  
  signal register_o_array : register_file_array_type;
  signal register_i_array : register_file_array_type;
    
begin

  parallel_to_array_gen : for i in 0 to no_of_registers-1 generate
    register_i_array(i) <= register_i((i+1)*8-1 downto i*8);
    register_o((i+1)*8-1 downto i*8) <= register_o_array(i);
  end generate;

  process(clk_i, rst_i)
  begin
    if rst_i = '1' then
      for i in 0 to no_of_registers-1 loop
        register_o_array(i) <= (others => '0');
      end loop;
    elsif clk_i = '1' and clk_i'event then
      if adr_a < no_of_registers then
        if wren_a = '1' then
          register_o_array(conv_integer(adr_a)) <= dat_a;
        end if;
        q_a <= register_i_array(conv_integer(adr_a));
      end if;
    end if;
  end process;
end registerfile_ram_interface_arch;
