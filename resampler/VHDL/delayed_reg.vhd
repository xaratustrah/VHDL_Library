-- simulation model for a register width fixed output delay

library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_arith.all;
use IEEE.STD_LOGIC_unsigned.all;

entity delayed_reg is
    generic(
        data_width : integer := 8;
        output_delay : time := 5 ns
        );
    port(
        clk_i : in std_logic;
        d_i : in std_logic_vector(data_width-1 downto 0);
        d_o : out std_logic_vector(data_width-1 downto 0)
        );
end delayed_reg;

architecture delayed_reg_arch of delayed_reg is

signal d_buf : std_logic_vector(data_width-1 downto 0);

begin

process
begin
  loop
    wait on clk_i;
    if clk_i = '1' then
      d_buf <= d_i; 
      d_o <= (others => 'X');  
      wait for output_delay;
      d_o <= d_buf;  
    end if;
  end loop; 
end process;	 
end delayed_reg_arch;