library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_arith.all;
use IEEE.STD_LOGIC_unsigned.all;

entity reg is
    generic(
        data_width : integer := 8
        );
    port(
        clk_i : in std_logic;
        d_i : in std_logic_vector(data_width-1 downto 0);
        d_o : out std_logic_vector(data_width-1 downto 0)
        );
end reg;

architecture reg_arch of reg is

signal d_buf : std_logic_vector(data_width-1 downto 0);

begin

process(clk_i)
begin
  if clk_i='1' and clk_i'event then
    d_o <= d_i;  
  end if;
end process;	 
end reg_arch;