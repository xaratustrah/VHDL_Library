-------------------------------------------------------------------------------
--
-- This filter produces a pole pair at +/-zp on the real axis 
--
-- The filter transfer function is F(z)=1/((z-zp)(z+zp))=z^-2/(1-zp^2*z^-2)
--
-- zp^2 is given with generic pole_value
--
-- M. Kumm
--
-------------------------------------------------------------------------------

-- Package Definition

library ieee;
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

package real_pole_filter_pkg is
  component real_pole_filter
  	generic(
  		data_width  : integer;
  		internal_data_width : integer;
  		pole_value  : real
  	);
  	port(
  			clk_i							:	in  std_logic;
  			rst_i							:	in  std_logic;
  			data_i				:	in std_logic_vector(data_width-1 downto 0);
  		  data_str_i				:	in std_logic;
  			data_o				:	out std_logic_vector(data_width-1 downto 0);
   			data_str_o				:	out std_logic
  	);
  end component;
end real_pole_filter_pkg;

package body real_pole_filter_pkg is
end real_pole_filter_pkg;

-- Entity Definition

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

use work.resize_tools_pkg.all;

entity real_pole_filter is
	generic(
  		data_width  : integer := 16;
  		internal_data_width : integer := 16;
  		pole_value  : real := 0.5
	);
	port(
			clk_i							:	in  std_logic;
			rst_i							:	in  std_logic;
			data_i				:	in std_logic_vector(data_width-1 downto 0);
  	  data_str_i				:	in std_logic;
			data_o				:	out std_logic_vector(data_width-1 downto 0);
 			data_str_o				:	out std_logic
	);
end real_pole_filter; 

architecture real_pole_filter_arch of real_pole_filter is

  constant b0_int : std_logic_vector(data_width-1 downto 0) := std_logic_vector(to_signed(integer(round((pole_value) * 2.0**(data_width-1))),data_width));  

  signal x_res : std_logic_vector(internal_data_width-1 downto 0);
  signal b0_int_res : std_logic_vector(internal_data_width-1 downto 0);
  signal xaydmb0 : std_logic_vector(internal_data_width-1 downto 0);
  signal ydmb0 : std_logic_vector(internal_data_width-1 downto 0); 
  signal y					: std_logic_vector (internal_data_width-1 downto 0);
  signal yd					: std_logic_vector (internal_data_width-1 downto 0);

begin

  x_res <= resize_to_msb_round(data_i,internal_data_width);
  b0_int_res <= resize_to_msb_round(b0_int,internal_data_width);
  xaydmb0 <= resize_to_msb_round(std_logic_vector(signed(x_res) + signed(ydmb0)),internal_data_width);
  ydmb0 <= resize_to_msb_round(std_logic_vector(shift_left(signed(yd) * signed(b0_int_res),1)),internal_data_width);

process (clk_i, rst_i)
begin
	if rst_i = '1' then
    y <= (others => '0');
    yd <= (others => '0');
    data_str_o <= '0';
    data_o <= (others => '0');
	elsif clk_i'EVENT and clk_i = '1' then	
    data_str_o <= data_str_i;
    data_o <= y;
    if data_str_i='1' then
      y <= xaydmb0;
      yd <= y;
    end if;
  end if;
end process;


end real_pole_filter_arch;


