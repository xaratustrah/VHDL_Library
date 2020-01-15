library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_arith.all;
use IEEE.STD_LOGIC_unsigned.all;

entity resampler_delayed_reg_tb is
	generic(
		clk1_period : time := 20 ns;
		clk2_period : time := 36 ns;
		data_width : integer := 8;
		register_output_delay : time := 5 ns
	);
end resampler_delayed_reg_tb; 

architecture resampler_delayed_reg_tb_arch of resampler_delayed_reg_tb is

component delayed_reg
    generic(
        data_width : integer := data_width;
        output_delay : time := register_output_delay
        );
    port(
        clk_i : in std_logic;
        d_i : in std_logic_vector(data_width-1 downto 0);
        d_o : out std_logic_vector(data_width-1 downto 0)
        );
end component;

component delayed_ff
    generic(
        output_delay : time := 5 ns
        );
    port(
        clk_i : in std_logic;
        d_i : in std_logic;
        d_o : out std_logic
        );
end component;

signal clk1,clk2 : std_logic := '0';
signal nclk1 : std_logic;
signal data_clk1: std_logic_vector(data_width-1 downto 0) := (others => '0');
signal data_pos_clk1, data_neg_clk1: std_logic_vector(data_width-1 downto 0);
signal data_pos_clk2, data_neg_clk2: std_logic_vector(data_width-1 downto 0);
signal select_neg  : std_logic;
signal data_mux,data_sync : std_logic_vector(data_width-1 downto 0);

begin

	clk1 <= not clk1 after clk1_period / 2; -- clk generator
	clk2 <= not clk2 after clk2_period / 2; -- clk generator
  
  nclk1 <= not clk1;
    
  reg_pos_clk1 : delayed_reg
  port map(
    clk_i => clk1,
    d_i => data_clk1,
    d_o => data_pos_clk1
    );

  reg_neg_clk1 : delayed_reg
  port map(
    clk_i => nclk1,
    d_i => data_pos_clk1,
    d_o => data_neg_clk1
    );

  reg_pos_clk2 : delayed_reg
  port map(
    clk_i => clk2,
    d_i => data_pos_clk1,
    d_o => data_pos_clk2
    );

  reg_neg_clk2 : delayed_reg
  port map(
    clk_i => clk2,
    d_i => data_neg_clk1,
    d_o => data_neg_clk2
    );

  ff_clk1 : delayed_ff
  port map(
    clk_i => clk2,
    d_i => clk1,
    d_o => select_neg
    );

  data_mux <= data_neg_clk2 when select_neg = '1' else data_pos_clk2;

  sync_output_data : delayed_reg
  port map(
    clk_i => clk2,
    d_i => data_mux,
    d_o => data_sync
    );
        
gen_input_data : process(clk1)
begin
	if	clk1 = '1' and clk1'event then
	    data_clk1 <= data_clk1 + 1;
	end if;
end process;



end resampler_delayed_reg_tb_arch;
