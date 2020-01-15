-------------------------------------------------------------------------------
--
-- M. Kumm
--
-------------------------------------------------------------------------------

-- Package Definition

library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_arith.all;

package analytic_filter_pkg is
component analytic_filter
	generic(
		input_data_width : integer;
		output_data_width : integer;
		filter_delay_in_clks : integer  --delay of hilbert filter
	);
	port(
    clk_i : in std_logic;
    rst_i : in std_logic;
    data_str_i : in std_logic;
    data_i : in std_logic_vector(input_data_width-1 downto 0);
    i_data_o : out std_logic_vector(output_data_width-1 downto 0);
    q_data_o : out std_logic_vector(output_data_width-1 downto 0);
    data_str_o : out std_logic
	);
end component; 
end analytic_filter_pkg;

package body analytic_filter_pkg is
end analytic_filter_pkg;

-- Entity Definition

library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_arith.all;
use work.const_delay_pkg.all;

entity analytic_filter is
	generic(
		input_data_width : integer := 16;
		output_data_width : integer := 16;
		filter_delay_in_clks : integer  := 7 --delay of hilbert filter (including pipeline delay)
	);
	port(
	    clk_i : in std_logic;
	    rst_i : in std_logic;
	    data_str_i : in std_logic;
	    data_i : in std_logic_vector(input_data_width-1 downto 0);
	    i_data_o : out std_logic_vector(output_data_width-1 downto 0);
	    q_data_o : out std_logic_vector(output_data_width-1 downto 0);
	    data_str_o : out std_logic
	);
end analytic_filter; 

architecture analytic_filter_arch of analytic_filter is

component hilbert_filter is
   port( clk                             :   in    std_logic; 
         clk_enable                      :   in    std_logic; 
         reset                           :   in    std_logic; 
         filter_in                       :   in    std_logic_vector(input_data_width-1 downto 0);
         filter_out                      :   out   std_logic_vector(output_data_width-1 downto 0)
         );
end component;

  function maximum_int(
    x1 : integer;
    x2 : integer
    ) return integer is
  begin
    if x1 > x2 then
      return x1;
    else
      return x2;
    end if;
  end maximum_int;

constant max_data_width : integer := maximum_int(input_data_width,output_data_width);
signal const_delay_data_i, const_delay_data_o : std_logic_vector(max_data_width-1 downto 0);

begin

const_delay_data_i(max_data_width-1 downto max_data_width-input_data_width) <= data_i;

zero_pad: if max_data_width-input_data_width > 0 generate
	const_delay_data_i(max_data_width-input_data_width-1 downto 0) <= (others => '0');
end generate;

i_data_o <= const_delay_data_o(max_data_width-1 downto max_data_width-output_data_width);

in_phase_channel : const_delay
	generic map(
		data_width    => max_data_width,
		delay_in_clks => filter_delay_in_clks
	)
	port map(
	    clk_i => clk_i,
	    rst_i => rst_i,
	    data_i => const_delay_data_i,
	    data_str_i => data_str_i,
	    data_o => const_delay_data_o,
	    data_str_o => data_str_o
	);
	
quadrature_phase_channel : hilbert_filter
   port map( 
	   clk        => clk_i,
	   clk_enable => data_str_i,
	   reset      => rst_i,
	   filter_in  => data_i,
	   filter_out => q_data_o
   );

	
end analytic_filter_arch;