library ieee;
library ieee;
use ieee.std_logic_1164.all;
--use ieee.std_logic_arith.all;

use ieee.numeric_std.all;
use ieee.math_real.all;

use work.adpll_iq_pkg.all;
use work.sine_lut_pkg.all;
use work.dds_synthesizer_pkg.all;
use work.analytic_filter_pkg.all;

entity adpll_iq_tb is
	generic(
		clk_period : time := 8 ns;
--		test_ftw : integer := 35791394; --1MHz
--		test_ftw : integer := 36149308; --1.01MHz
		test_ftw : integer := 39370533; --1.1MHz
	  --data width of I/O and different components                                                                                           
		iq_data_width : integer                := 16;  --data width of i/q input, fixed to 16 bit at the moment                                
		lpf_internal_data_width : integer      := 33;  --internal data width of the lowpass filter, should be at least 2*f_3dB_div+iq_data_width+no_of_unwrapp_bits
		pi_cntrl_data_width : integer          := 32;  --data width of the pi controller                                                       
		pi_cntrl_internal_data_width : integer := 32;  --internal data width of the pi controller                                              
		dds_ftw_data_width : integer           := 32;  --data width of dds frequency tuning word (phase res. and ampl. res. are defined by choo
 		no_of_unwrapp_bits : integer           := 7;   --no of bits for extra phase resolution, output_data_width=input_data_width+unwrapp_width
                                                                                                                                      
		-- PLL parameters ---                                                                                                                  
		sampling_frequency : real 	 					 := 120.0E6; --sampling frequency of the PLL in Hz                                               
		dds_ftw_0 : integer					 					 := 35791394; --free running frequency when controll loop is open                                
		dds_phase_0 : integer				 					 := 0; --initial phase of dds                                                                    
    --pi controller specific parameters                                                                                                    
    pi_cntrl_kp : real					           := 0.00740368668695994510; --proportional gain of pi controller                                 
    pi_cntrl_ki : real					           := 1644.9340668482262;  --integral gain of pi controller                                        
    --lowpass filter specific parameters                                                                                                   
    lpf_f_3dB_div      : integer           := 5;  --cutoff frequency is f3dB = fs/(2^lpf_f_3dB_div-1)                                      
    lpf_no_of_stages : integer	           := 3;  --attenuation is 20dB/decade/stage                                                       
    --feedback delay                                                                                                                       
    fbd_delay_in_clks  : integer           := 1  --feedback delay may be used to compensate forward delays, but can make the loop unstable!
	);
end adpll_iq_tb; 

architecture adpll_iq_tb_arch of adpll_iq_tb is
  signal x : std_logic_vector(iq_data_width-1 downto 0);
  signal i,q : std_logic_vector(iq_data_width-1 downto 0);
  signal i_adpll,q_adpll : std_logic_vector(iq_data_width-1 downto 0);
    
  signal x_real : real;
  signal i_real,q_real : real;
  signal f_dds : real;
  signal phase_dds : real;

  signal clk : std_logic := '0';
  signal rst : std_logic;

  signal pll_mag    : std_logic_vector(AMPL_WIDTH-1 downto 0);
  signal pll_ftw    : std_logic_vector(dds_ftw_data_width-1 downto 0);
  signal pll_phase  : std_logic_vector(iq_data_width+no_of_unwrapp_bits-1 downto 0);
  signal pi_cntrl   : std_logic_vector(pi_cntrl_data_width-1 downto 0);
  signal cordic_mag : std_logic_vector(iq_data_width-1 downto 0);
  signal cordic_phase : std_logic_vector(iq_data_width-1 downto 0);

begin

  adpll_iq_inst : adpll_iq
	generic map(
		iq_data_width                => iq_data_width,
		lpf_internal_data_width      => lpf_internal_data_width,
		pi_cntrl_data_width          => pi_cntrl_data_width,
		pi_cntrl_internal_data_width => pi_cntrl_internal_data_width,
		dds_ftw_data_width           => dds_ftw_data_width,
		no_of_unwrapp_bits           => no_of_unwrapp_bits,
		sampling_frequency           => sampling_frequency,
		dds_ftw_0                    => dds_ftw_0,
		dds_phase_0                  => dds_phase_0,
    pi_cntrl_kp                  => pi_cntrl_kp,
    pi_cntrl_ki                  => pi_cntrl_ki,
    lpf_f_3dB_div                => lpf_f_3dB_div,
    lpf_no_of_stages             => lpf_no_of_stages,
    fbd_delay_in_clks            => fbd_delay_in_clks           
	)
	port map(
    clk_i          => clk,
    rst_i          => rst,
    i_data_i       => i_adpll,
    q_data_i       => q_adpll,
    iq_data_str_i  => '1',
    pll_mag_o     =>  pll_mag,
    close_pll_i 	=> '1',
    pll_locked_o => open,
    pll_ftw_o      => pll_ftw,
    pll_phase_o    => pll_phase,
    pi_cntrl_o     => pi_cntrl,
    cordic_phase_o   => cordic_phase,
    cordic_mag_o   => cordic_mag
  );

	dds_synth: dds_synthesizer
  generic map(
		ftw_width   => dds_ftw_data_width
  )
  port map(
		clk_i => clk,
		rst_i => rst,
		ftw_i    => std_logic_vector(to_unsigned(test_ftw,dds_ftw_data_width)),
		phase_i  => (others => '0'),
		phase_o  => open,
		ampl_o => x
  );
  
  analytic_filter_inst : analytic_filter
  generic map(
    input_data_width  => iq_data_width,
    output_data_width => iq_data_width,
		filter_delay_in_clks => 5
  )
  port map(
    rst_i           => rst,
    clk_i           => clk,
    data_str_i 	=> '1',
    data_i 			=> x,
    i_data_o 		=> i,
    q_data_o 		=> q,
    data_str_o 	=> open
  );
	clk <= not clk after clk_period/2;
	rst <= '1', '0' after 15 ns;
	
--  i <= (others => '0');
--  i <= q;
	--divide by 2
  i_adpll <= std_logic_vector(resize(shift_right(signed(i),1), iq_data_width));
  q_adpll <= std_logic_vector(resize(shift_right(signed(q),1), iq_data_width));
  
	x_real <= real(to_integer(signed(x)))/ 2.0**(iq_data_width-1);
	i_real <= real(to_integer(signed(i_adpll)))/ 2.0**(iq_data_width-1);
	q_real <= real(to_integer(signed(q_adpll)))/ 2.0**(iq_data_width-1);

	f_dds <= real(to_integer(unsigned(pll_ftw)))/ 2.0**(dds_ftw_data_width)*sampling_frequency;
	phase_dds <= real(to_integer(signed(pll_phase)))/ 2.0**(iq_data_width+no_of_unwrapp_bits-1)*360.0;


end adpll_iq_tb_arch;