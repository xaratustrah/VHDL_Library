-------------------------------------------------------------------------------
--
-- Implementation of an optimized IIR Low-Pass Filter
--
-- The optimization is done in that way that no multiplier are used - with the drawback that 
-- only a limited set of cut-off frequencies can be used. This limitation is quite fair for
-- a lot of applications. 
-- The 3dB cut-off frequency is determined by
-- 
-- f3dB = fs/(2^f_3dB_div-1)
-- 
-- where fs is the sampling frequency and f_3dB_div is an integer number.
-- For f_3dB_div=2 the resulting filter is a third-band filter, for f_3dB_div=3 a 7th-band, 
-- for f_3dB_div=4 a 15th-band filter an so on.
-- Only two adders and two delays are use. The operations are all 
-- pipelined. The latency of the low-pass transfer function is delayed by 1.
-- The implementation is approximated by the rectangular law from the analouge transfer function
-- F(s)=1/(1+Ts) with s=(z-1)/(Ts*z) resulting in F(z)=(b0)/(1+a1*z^(-1)) with Ts as sampling time, 
-- T=1/f3dB, b0=1/(1+T/Ts)=2^(-f_3dB_div) and a1=-1/(1+Ts/T)=1-2^(-f_3dB_div).
--
-- internal_data_width should be at least 2*f_3dB_div+input_data_width
-- 
-- M. Kumm
--
-------------------------------------------------------------------------------

-- Package Definition

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

package iir_lp_filter_opt_pkg is
component iir_lp_filter_opt
	generic(
			input_data_width 	: integer;
			output_data_width 	: integer;
			internal_data_width 	: integer; -- should be at least 2*f_3dB_div+input_data_width
      f_3dB_div      : integer
	);
	port(
			clk_i					:	in  std_logic;
			rst_i					:	in  std_logic;
			data_i        :	in std_logic_vector(input_data_width-1 downto 0);
			data_str_i    :	in std_logic;
			data_str_o    :	out std_logic;
			data_o        :	out std_logic_vector(output_data_width-1 downto 0)
	);
end component; 
end iir_lp_filter_opt_pkg;

package body iir_lp_filter_opt_pkg is
end iir_lp_filter_opt_pkg;

-- Entity Definition
library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_arith.all;


entity iir_lp_filter_opt is
	generic(
			input_data_width 	: integer := 32;
			output_data_width 	: integer  := 32;
			internal_data_width 	: integer  := 48; -- should be at least 2*f_3dB_div+input_data_width
      f_3dB_div      : integer := 5
	);
	port(
			clk_i					:	in  std_logic;
			rst_i					:	in  std_logic;
			data_i        :	in std_logic_vector(input_data_width-1 downto 0);
			data_str_i    :	in std_logic;
			data_str_o    :	out std_logic;
			data_o        :	out std_logic_vector(output_data_width-1 downto 0)
	);
end iir_lp_filter_opt; 

architecture iir_lp_filter_opt_arch of iir_lp_filter_opt is

  signal x : std_logic_vector(input_data_width-1 downto 0); --input
  signal y : std_logic_vector(output_data_width-1 downto 0); --output

  signal xmb : std_logic_vector(internal_data_width-1 downto 0); --x multiplied with b (shifted)
  signal xmbat : std_logic_vector(internal_data_width-1 downto 0); --xmb added with t
  signal u : std_logic_vector(internal_data_width-1 downto 0); --xmbat shifted by f_3dB_div
  signal v : std_logic_vector(internal_data_width-1 downto 0); --xmbat added with u
  signal t : std_logic_vector(internal_data_width-1 downto 0); --t is u delayed by one clock
  
begin

  x <= data_i;
  data_o <= y;

	--division by 2^f_3dB_div:
	xmb(internal_data_width-1 downto internal_data_width-f_3dB_div-1) <= (others => x(input_data_width-1)); --sign extension
	xmb(internal_data_width-f_3dB_div-2 downto internal_data_width-input_data_width-f_3dB_div) <= x(input_data_width-2 downto 0);
	xmb(internal_data_width-input_data_width-f_3dB_div-1 downto 0) <= (others => '0');
	
	u(internal_data_width-1 downto internal_data_width-f_3dB_div-1) <= (others => xmbat(internal_data_width-1)); --sign extension
	u(internal_data_width-f_3dB_div-2 downto 0) <= xmbat(internal_data_width-2 downto f_3dB_div);
	
	xmbat <= conv_std_logic_vector(signed(xmb) + signed(t), internal_data_width); 	
	v <= conv_std_logic_vector(signed(xmbat) - signed(u), internal_data_width);
	

  iir_lp_filter_opt: process (clk_i, rst_i)
  begin
	  if rst_i = '1' then
	  	y <= (others => '0');
	  	t <= (others => '0');
			data_str_o <= '0';
	  elsif clk_i'event and clk_i = '1' then
	  	if data_str_i = '1' then	
				y <= xmbat(internal_data_width-1 downto internal_data_width-output_data_width);
				data_str_o <= '1';
				t <= v;
			else
				data_str_o <= '0';
			end if;
    end if;
  end process;    
  
end iir_lp_filter_opt_arch;