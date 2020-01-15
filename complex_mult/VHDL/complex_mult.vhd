-------------------------------------------------------------------------------
--
-- Implementation of a complex multiplier
--
-- The result is i_o+j*q_o=(i1+j*q1)*(i2+j*q2) (j=sqrt(-1)). The binary point is located at MSB-1 
-- (value range -1...1-2^-(N-1))). The internal data width can be set with internal_data_width to 
-- influence the precision/space tradeoff. This should be max. 2*input_data_width for full precision 
-- or less for lower precision.
--
-- M. Kumm
--
-------------------------------------------------------------------------------

-- Package Definition

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package complex_mult_pkg is
  component complex_mult
  	generic(
  		input_data_width  : integer;
  		internal_data_width  : integer;  --should be max. 2*input_data_width for full precision
  		output_data_width  : integer;
			use_altera_lpm					: boolean
  	);
  	port(
  			clk_i							:	in  std_logic;
  			rst_i							:	in  std_logic;
  			i1_i      				:	in std_logic_vector(input_data_width-1 downto 0);
  			q1_i      				:	in std_logic_vector(input_data_width-1 downto 0);
  			i2_i      				:	in std_logic_vector(input_data_width-1 downto 0);
  			q2_i      				:	in std_logic_vector(input_data_width-1 downto 0);
  		  iq_str_i				  :	in std_logic;
  			i_o				        :	out std_logic_vector(output_data_width-1 downto 0);
  			q_o				        :	out std_logic_vector(output_data_width-1 downto 0);
   			iq_str_o  				:	out std_logic
  	);
  end component;
end complex_mult_pkg;

package body complex_mult_pkg is
end complex_mult_pkg;

-- Entity Definition

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.resize_tools_pkg.all;

entity complex_mult is
  	generic(
  		input_data_width  : integer := 16;
  		internal_data_width  : integer := 32;   --should be max. 2*input_data_width for full precision
  		output_data_width  : integer := 16;
			use_altera_lpm					: boolean := true
  	);
  	port(
  			clk_i							:	in  std_logic;
  			rst_i							:	in  std_logic;
  			i1_i      				:	in std_logic_vector(input_data_width-1 downto 0);
  			q1_i      				:	in std_logic_vector(input_data_width-1 downto 0);
  			i2_i      				:	in std_logic_vector(input_data_width-1 downto 0);
  			q2_i      				:	in std_logic_vector(input_data_width-1 downto 0);
  		  iq_str_i				  :	in std_logic;
  			i_o				        :	out std_logic_vector(output_data_width-1 downto 0);
  			q_o				        :	out std_logic_vector(output_data_width-1 downto 0);
   			iq_str_o  				:	out std_logic
  	);
end complex_mult; 

architecture complex_mult_arch of complex_mult is

component complex_mult_mult
	port
	(
		clock		: in std_logic ;
		clken		: IN STD_LOGIC ;
		dataa		: in std_logic_vector (15 downto 0);
		datab		: in std_logic_vector (15 downto 0);
		result		: out std_logic_vector (31 downto 0)
	);
end component;


signal i1_int  			: std_logic_vector (internal_data_width-1 downto 0);
signal q1_int  			: std_logic_vector (internal_data_width-1 downto 0);
signal i2_int  			: std_logic_vector (internal_data_width-1 downto 0);
signal q2_int  			: std_logic_vector (internal_data_width-1 downto 0);
signal q1d  			: std_logic_vector (internal_data_width-1 downto 0);
signal i2d  			: std_logic_vector (internal_data_width-1 downto 0);
signal q2d  			: std_logic_vector (internal_data_width-1 downto 0);

signal q1d_res  	: std_logic_vector (internal_data_width/2-1 downto 0);
signal i2d_res  	: std_logic_vector (internal_data_width/2-1 downto 0);
signal q2d_res  	: std_logic_vector (internal_data_width/2-1 downto 0);

signal i1aq1			: std_logic_vector (internal_data_width-1 downto 0);
signal i1sq1			: std_logic_vector (internal_data_width-1 downto 0);
signal i1aq1d			: std_logic_vector (internal_data_width-1 downto 0);
signal i1sq1d			: std_logic_vector (internal_data_width-1 downto 0);
signal i2aq2			: std_logic_vector (internal_data_width-1 downto 0);
signal i2aq2d			: std_logic_vector (internal_data_width-1 downto 0);

signal i1aq1d_res	: std_logic_vector (internal_data_width/2-1 downto 0);
signal i1sq1d_res	: std_logic_vector (internal_data_width/2-1 downto 0);
signal i2aq2d_res	: std_logic_vector (internal_data_width/2-1 downto 0);

signal i1aq1mi2 	: std_logic_vector (internal_data_width-1 downto 0);
signal i1sq1mq2		: std_logic_vector (internal_data_width-1 downto 0);
signal i2aq2mq1		: std_logic_vector (internal_data_width-1 downto 0);
signal i1aq1mi2d 	: std_logic_vector (internal_data_width-1 downto 0);
signal i1sq1mq2d	: std_logic_vector (internal_data_width-1 downto 0);
signal i2aq2mq1d	: std_logic_vector (internal_data_width-1 downto 0);
signal i_res			: std_logic_vector (internal_data_width-1 downto 0);
signal q_res			: std_logic_vector (internal_data_width-1 downto 0);
signal i_resd			: std_logic_vector (internal_data_width-1 downto 0);
signal q_resd			: std_logic_vector (internal_data_width-1 downto 0);


begin
  --the input values have to be shifted by 1 (divided by two) to avoid add/sub overflow
  i1_int <= resize_to_msb_trunc(std_logic_vector(shift_right(signed(i1_i),1)),internal_data_width);
  q1_int <= resize_to_msb_trunc(std_logic_vector(shift_right(signed(q1_i),1)),internal_data_width);
  i2_int <= resize_to_msb_trunc(std_logic_vector(shift_right(signed(i2_i),1)),internal_data_width);
  q2_int <= resize_to_msb_trunc(std_logic_vector(shift_right(signed(q2_i),1)),internal_data_width);

  i1aq1 <= resize_to_msb_trunc(std_logic_vector(signed(i1_int) + signed(q1_int)),internal_data_width);
  i1sq1 <= resize_to_msb_trunc(std_logic_vector(signed(i1_int) - signed(q1_int)),internal_data_width);
  i2aq2 <= resize_to_msb_trunc(std_logic_vector(signed(i2_int) + signed(q2_int)),internal_data_width);

  i1aq1d_res <= resize_to_msb_trunc(i1aq1d,internal_data_width/2);
  i1sq1d_res <= resize_to_msb_trunc(i1sq1d,internal_data_width/2);
  i2aq2d_res <= resize_to_msb_trunc(i2aq2d,internal_data_width/2);
  i2d_res    <= resize_to_msb_trunc(i2d,internal_data_width/2);
  q2d_res    <= resize_to_msb_trunc(q2d,internal_data_width/2);
  q1d_res    <= resize_to_msb_trunc(q1d,internal_data_width/2);

	mult_with_altera_lpm: if use_altera_lpm = true generate
    
    i1aq1mi2_inst : complex_mult_mult
  	port map
  	(
  		clock	 => clk_i,
      clken  => iq_str_i,
  		dataa	 => i1aq1d_res,
  		datab	 => i2d_res,
  		result => i1aq1mi2d
  	);
    i1sq1mq2_inst : complex_mult_mult
  	port map
  	(
  		clock	 => clk_i,
      clken  => iq_str_i,
  		dataa	 => i1sq1d_res,
  		datab	 => q2d_res,
  		result => i1sq1mq2d
  	);
    i2aq2mq1_inst : complex_mult_mult
  	port map
  	(
  		clock	 => clk_i,
      clken  => iq_str_i,
  		dataa	 => i2aq2d_res,
  		datab	 => q1d_res,
  		result => i2aq2mq1d
  	);
	end generate mult_with_altera_lpm;

	mult_without_altera_lpm: if use_altera_lpm = false generate
    i1aq1mi2 <= std_logic_vector(signed(i1aq1d_res) * signed(i2d_res));
    i1sq1mq2 <= std_logic_vector(signed(i1sq1d_res) * signed(q2d_res));
    i2aq2mq1 <= std_logic_vector(signed(i2aq2d_res) * signed(q1d_res));

    process (clk_i, rst_i)
    begin
    	if rst_i = '1' then
        i1aq1mi2d <= (others => '0');
        i1sq1mq2d <= (others => '0');
        i2aq2mq1d <= (others => '0');
    	elsif clk_i'EVENT and clk_i = '1' then	
        if iq_str_i='1' then
          i1aq1mi2d <= i1aq1mi2;
          i1sq1mq2d <= i1sq1mq2;
          i2aq2mq1d <= i2aq2mq1;
        end if;
      end if;
    end process;    
	end generate mult_without_altera_lpm;

  --result of two signed mult. must be multiplied by two to get the correct binary point 
  --the result is shifted back (multiplied by 4)
  --so the final shift multiplication is 8
  i_res  <= resize_to_msb_trunc(std_logic_vector(shift_left(signed(i1aq1mi2d) - signed(i2aq2mq1d),3)),internal_data_width);
  q_res  <= resize_to_msb_trunc(std_logic_vector(shift_left(signed(i1sq1mq2d) + signed(i2aq2mq1d),3)),internal_data_width);

  i_o <= resize_to_msb_trunc(i_resd,output_data_width);
  q_o <= resize_to_msb_trunc(q_resd,output_data_width);


process (clk_i, rst_i)
begin

	if rst_i = '1' then

    i2d <= (others => '0');
    q2d <= (others => '0');
    q1d <= (others => '0');
    
    i1aq1d <= (others => '0');
    i1sq1d <= (others => '0');
    i2aq2d <= (others => '0');
        
    i_resd <= (others => '0');
    q_resd <= (others => '0');

    iq_str_o<= '0';
    
	elsif clk_i'EVENT and clk_i = '1' then	
    if iq_str_i='1' then
      i2d <= i2_int;
      q2d <= q2_int;
      q1d <= q1_int;
      
      i1aq1d <= i1aq1;
      i1sq1d <= i1sq1;
      i2aq2d <= i2aq2;

      i_resd <= i_res;
      q_resd <= q_res;
      
      iq_str_o<= '1';
    else
      iq_str_o<= '0';  
    end if;
  end if;
end process;


end complex_mult_arch;


