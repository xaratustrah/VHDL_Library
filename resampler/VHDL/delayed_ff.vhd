-- simulation model for a register width fixed output delay

library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_arith.all;
use IEEE.STD_LOGIC_unsigned.all;

entity delayed_ff is
    generic(
        output_delay : time := 5 ns
        );
    port(
        clk_i : in std_logic;
        d_i : in std_logic;
        d_o : out std_logic
        );
end delayed_ff;

architecture delayed_ff_arch of delayed_ff is

signal d_buf : std_logic;

begin

process
begin
  loop
    wait on clk_i;
    if clk_i = '1' then
      d_buf <= d_i; 
      d_o <= 'X';  
      wait for output_delay;
      d_o <= d_buf;  
    end if;
  end loop; 
end process;	 
end delayed_ff_arch;