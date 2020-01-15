-------------------------------------------------------------------------------
--
-- N'th order lopass filter using N stages of iir_lp_filter_opt
-- 
-- M. Kumm
--
-------------------------------------------------------------------------------

-- Package Definition

library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_arith.all;

package iir_lp_filter_opt_nth_order_pkg is
component iir_lp_filter_opt_nth_order
	generic(
			data_width 	: integer;
			internal_data_width 	: integer; -- should be at least 2*f_3dB_div+data_width
      f_3dB_div      : integer;
      no_of_stages : integer
	);
	port(
			clk_i					:	in  std_logic;
			rst_i					:	in  std_logic;
			data_i        :	in std_logic_vector(data_width-1 downto 0);
			data_str_i    :	in std_logic;
			data_str_o    :	out std_logic;
			data_o        :	out std_logic_vector(data_width-1 downto 0)
	);
end component; 
end iir_lp_filter_opt_nth_order_pkg;

package body iir_lp_filter_opt_nth_order_pkg is
end iir_lp_filter_opt_nth_order_pkg;

-- Entity Definition
library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_arith.all;
use work.iir_lp_filter_opt_pkg.all;

entity iir_lp_filter_opt_nth_order is
	generic(
			data_width 	: integer  := 23;
			internal_data_width 	: integer  := 31; -- should be at least 2*f_3dB_div+data_width
      f_3dB_div      : integer := 6;
      no_of_stages : integer := 3
  );
	port(
			clk_i					:	in  std_logic;
			rst_i					:	in  std_logic;
			data_i        :	in std_logic_vector(data_width-1 downto 0);
			data_str_i    :	in std_logic;
			data_str_o    :	out std_logic;
			data_o        :	out std_logic_vector(data_width-1 downto 0)
	);
end iir_lp_filter_opt_nth_order; 

architecture iir_lp_filter_opt_nth_order_arch of iir_lp_filter_opt_nth_order is

  signal rst : std_logic;
  signal clk : std_logic;

	type internal_data_type is array (0 to no_of_stages-2) of std_logic_vector (data_width-1 downto 0);
	signal data_int						: internal_data_type;
	type internal_str_type is array (0 to no_of_stages-2) of std_logic;
	signal data_str						: internal_str_type;

  
begin
	clk <= clk_i;
	rst <= rst_i;
	

	first_stage: iir_lp_filter_opt
  generic map(
    input_data_width  => data_width,
    internal_data_width => internal_data_width,
    output_data_width => data_width,
    f_3dB_div => f_3dB_div
    )
  port map(
    rst_i           => rst,
    clk_i           => clk,
    data_i       		=> data_i,
    data_str_i    	=> data_str_i,
    data_str_o			=> data_str(0),
    data_o      		=> data_int(0)
    );

	n_minus_2_stages: 
	for i in 0 to no_of_stages-3 generate
		nth_stage: iir_lp_filter_opt
	  generic map(
	    input_data_width  => data_width,
	    internal_data_width => internal_data_width,
	    output_data_width => data_width,
	    f_3dB_div => f_3dB_div
	    )
	  port map(
	    rst_i           => rst,
	    clk_i           => clk,
	    data_i       		=> data_int(i),
	    data_str_i    	=> data_str(i),
	    data_str_o			=> data_str(i+1),
	    data_o      		=> data_int(i+1)
	    );
	end generate;
	
  last_stage : iir_lp_filter_opt
  generic map(
    input_data_width  => data_width,
    internal_data_width => internal_data_width,
    output_data_width => data_width,
    f_3dB_div => f_3dB_div
    )
  port map(
    rst_i           => rst,
    clk_i           => clk,
    data_i       		=> data_int(no_of_stages-2),
    data_str_i    	=> data_str(no_of_stages-2),
    data_str_o			=> data_str_o,
    data_o      		=> data_o
  );

end iir_lp_filter_opt_nth_order_arch;