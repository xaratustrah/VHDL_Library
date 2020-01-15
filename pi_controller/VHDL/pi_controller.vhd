-------------------------------------------------------------------------------
--
-- Digital implementation of a PI-controller 
-- The implementation is approximated by the rectangular law from the analouge transfer function
-- F(s)=K_P + K_I/s with s=(z-1)/(Ts*z) resulting in F(z)=(b0+b1*z^-1)/(1+a1*z^-1)=(b1+b0*z)/(z+a1)
-- (Ts:sampling time, K_P proportional gain, K_I integral gain)
-- where
-- a1=-1
-- b0=(K_P+K_I*Ts)
-- b1=-K_P
--
-- The implementation has two pipeline registers and has a total additional delay of one sample
-- i.e. the resulting F'(z)=F(z)*z^-1
--
-- The data values are normalized to the Range -1...+1-2^N, where N is the wordsize.
-- A 2'th complement fixed point format is used with the position of the comma at the 2nd highest 
-- order bit, i.e a data word of "01100001" means +0.1100001b=2^(-1)+2^(-2)+2^-(7)=0.7578125
-- The coefficients has to be multiplied by 2^(N-1) and must be rounded to the next integer.
--
-- M. Kumm
--
-------------------------------------------------------------------------------

-- Package Definition

library ieee;
use ieee.std_logic_1164.all;
--use IEEE.STD_LOGIC_arith.all;
use ieee.numeric_std.all;
use ieee.math_real.all;


package pi_controller_pkg is
component pi_controller
	generic(
			data_width 	: integer;
			internal_data_width 	: integer;
			sampling_frequency : real;
      kp : real;
      ki : real;
			use_altera_lpm					: boolean      
	);
	port(
			clk_i					:	in  std_logic;
			rst_i					:	in  std_logic;
			data_i        :	in std_logic_vector(data_width-1 downto 0);
			data_o        :	out std_logic_vector(data_width-1 downto 0)
	);
end component; 
end pi_controller_pkg;

package body pi_controller_pkg is
end pi_controller_pkg;

-- Entity Definition
library ieee;
use ieee.std_logic_1164.all;
--use IEEE.STD_LOGIC_arith.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

use work.resize_tools_pkg.all;

entity pi_controller is
	generic(
			data_width 						: integer :=	32;
			internal_data_width 	: integer := 64;
--			sampling_frequency : real := 60.0E6;
			sampling_frequency : real := 120.0E6;
      kp : real := 0.15162750334893968000;  --@fn=16kHz, fs=120MHz
      ki : real := 10780.239900496535;  --@fn=16kHz, fs=120MHz
--      kp : real := 0.18953437918617461000; --@fn=10kHz, fs=120MHz
--      ki : real := 8422.0624222629194;     --@fn=10kHz, fs=120MHz
--      kp : real := 0.00148073733739198910; --@fn=10kHz, fs=60MHz
--      ki : real := 65.797362673929058;     --@fn=10kHz, fs=60MHz
			use_altera_lpm					: boolean := true
	);
	port(
			clk_i							:	in  std_logic;
			rst_i							:	in  std_logic;
			data_i        :	in std_logic_vector(data_width-1 downto 0);
			data_o        :	out std_logic_vector(data_width-1 downto 0)
	);
	
end pi_controller; 

architecture pi_controller_arch of pi_controller is

  component pi_controller_mult
  	port
  	(
  		clock		: in std_logic ;
  		clken		: IN STD_LOGIC ;
  		dataa		: in std_logic_vector (data_width-1 downto 0);
  		datab		: in std_logic_vector (data_width-1 downto 0);
  		result		: out std_logic_vector (internal_data_width-1 downto 0)
  	);
  end component;

  constant b0_int : std_logic_vector(data_width-1 downto 0) := std_logic_vector(to_signed(integer(round((kp+ki/sampling_frequency) * 2.0**(data_width-1))),data_width));  
  constant b1_int : std_logic_vector(data_width-1 downto 0) := std_logic_vector(to_signed(integer(round(-1.0 * kp * 2.0**(data_width-1))),data_width));

  signal x : std_logic_vector(data_width-1 downto 0); --input
  signal x_res : std_logic_vector(internal_data_width/2-1 downto 0); --input
  signal y : std_logic_vector(internal_data_width-1 downto 0); --output

  signal b0_int_res : std_logic_vector(internal_data_width/2-1 downto 0); --input
  signal b1_int_res : std_logic_vector(internal_data_width/2-1 downto 0); --input

--  signal xmb0 : std_logic_vector(2*data_width-1 downto 0); --x multiplied with b0
--  signal xmb1 : std_logic_vector(2*data_width-1 downto 0); --x multiplied with b1
  signal xmb0 : std_logic_vector(internal_data_width-1 downto 0); --x multiplied with b0
  signal xmb1 : std_logic_vector(internal_data_width-1 downto 0); --x multiplied with b1
  signal xmb0d : std_logic_vector(internal_data_width-1 downto 0); --xmb0 delayed
  signal xmb1d : std_logic_vector(internal_data_width-1 downto 0); --xmb1 delayed
  signal xmb1day : std_logic_vector(internal_data_width-1 downto 0);  --xmb1d added with y
  signal xmb1dayd : std_logic_vector(internal_data_width-1 downto 0); --xmb1day delayed

begin

  x <= data_i;
  

  xmb1day <= std_logic_vector(signed(xmb1d) + signed(y));
  y <= std_logic_vector(signed(xmb0d) + signed(xmb1dayd));
  data_o <= y(internal_data_width-1 downto internal_data_width-data_width);

  x_res <= resize_to_msb_round(x,internal_data_width/2);
  b0_int_res <= resize_to_msb_round(b0_int,internal_data_width/2);
  b1_int_res <= resize_to_msb_round(b1_int,internal_data_width/2);
  
	mult_with_altera_lpm: if use_altera_lpm = true generate
    
    xmb0_inst : pi_controller_mult
  	port map
  	(
  		clock	 => clk_i,
      clken  => '1',
  		dataa	 => x_res,
  		datab	 => b0_int_res,
  		result => xmb0
  	);
    xmb1_inst : pi_controller_mult
  	port map
  	(
  		clock	 => clk_i,
      clken  => '1',
  		dataa	 => x_res,
  		datab	 => b1_int_res,
  		result => xmb1
  	);
  	xmb0d <= std_logic_vector(shift_left(signed(xmb0),1));
  	xmb1d <= std_logic_vector(shift_left(signed(xmb1),1));
	end generate mult_with_altera_lpm;

	mult_without_altera_lpm: if use_altera_lpm = false generate
    process (clk_i, rst_i)
    begin
      xmb0 <= std_logic_vector(shift_left(signed(x_res) * signed(b0_int_res),1));
      xmb1 <= std_logic_vector(shift_left(signed(x_res) * signed(b1_int_res),1));
    	if rst_i = '1' then
        xmb0d <= (others => '0');
        xmb1d <= (others => '0');
    	elsif clk_i'EVENT and clk_i = '1' then	
        xmb0d <= xmb0;
        xmb1d <= xmb1;
      end if;
    end process;    
	end generate mult_without_altera_lpm;



  pi_controller: process (clk_i, rst_i)
	--variables can be better debuged than constants and are identical implemented (like constants): 
--  variable b0_int : std_logic_vector(data_width-1 downto 0) := std_logic_vector(to_signed(integer(round((kp+ki/sampling_frequency) * 2.0**(data_width-1))),data_width));  
--  variable b1_int : std_logic_vector(data_width-1 downto 0) := std_logic_vector(to_signed(integer(round(-1.0 * kp * 2.0**(data_width-1))),data_width));

  begin
--  xmb0 <= conv_std_logic_vector(signed(x) * b0_int,2*data_width);
--  xmb1 <= conv_std_logic_vector(signed(x) * b1_int,2*data_width);
  
	  if rst_i = '1' then
      xmb1dayd <= (others => '0');
	  elsif clk_i'event and clk_i = '1' then	
--      xmb0d <= xmb0(2*data_width-1 downto 2*data_width-internal_data_width);
--      xmb1d <= xmb1(2*data_width-1 downto 2*data_width-internal_data_width);
      xmb1dayd <= xmb1day;
    end if;
  end process;    
  
end pi_controller_arch;