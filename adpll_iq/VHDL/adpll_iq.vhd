-------------------------------------------------------------------------------
--
-- M. Kumm
--
-------------------------------------------------------------------------------

-- Package Definition

library ieee;
use ieee.std_logic_1164.all;
--use ieee.std_logic_arith.all;
use ieee.numeric_std.all;

use work.sine_lut_pkg.all;

package adpll_iq_pkg is
component adpll_iq
	generic(
	  --data width of I/O and different components
		iq_data_width : integer;  --data width of i/q input, fixed to 16 bit at the moment
		lpf_internal_data_width : integer;  --internal data width of the lowpass filter, should be at least 2*f_3dB_div+iq_data_width+no_of_unwrapp_bits
		pi_cntrl_data_width : integer;  --data width of the pi controller
		pi_cntrl_internal_data_width : integer;  --internal data width of the pi controller
		dds_ftw_data_width : integer;  --data width of dds frequency tuning word (phase res. and ampl. res. are defined by choosing the right sine LUT)
		no_of_unwrapp_bits : integer;  --no of bits for extra phase resolution, output_data_width=input_data_width+unwrapp_width

		-- PLL parameters ---
    f_n : real; --eigenfrequency of PLL in Hz
    zeta : real;  --damping factor of PLL
		sampling_frequency : real; --sampling frequency of the PLL in Hz
    delta_phase_lock_detect_in_degrees : real;
		dds_ftw_0 : integer; --free running frequency when controll loop is open
		dds_ftw_min : integer; --minimum operating frequency 
		dds_ftw_max : integer; --maximum operating frequency 
		dds_phase_0 : integer; --initial phase of dds
    --lowpass filter specific parameters
    lpf_f_3dB_div      : integer;  --cutoff frequency is f3dB = fs/(2^lpf_f_3dB_div-1)
    lpf_no_of_stages : integer;    --attenuation is 20dB/decade/stage
    --feedback delay
    fbd_delay_in_clks  : integer --feedback delay may be used to compensate forward delays, but can make the loop unstable!
	);
	port(
    clk_i : in std_logic;
    rst_i : in std_logic;
    i_data_i : in std_logic_vector(iq_data_width-1 downto 0);
    q_data_i : in std_logic_vector(iq_data_width-1 downto 0);
    iq_data_str_i : in std_logic;
    pll_mag_o : out std_logic_vector(AMPL_WIDTH-1 downto 0);
    close_pll_i : in std_logic;
    pll_locked_o : out std_logic;
    --monitor outputs
    pll_ftw_o : out std_logic_vector(dds_ftw_data_width-1 downto 0);
    delta_phase_filt_o : out std_logic_vector(iq_data_width+no_of_unwrapp_bits-1 downto 0);
    delta_phase_o  : out std_logic_vector(iq_data_width-1 downto 0);    	
    pi_cntrl_o : out std_logic_vector(pi_cntrl_data_width-1 downto 0);
    cordic_phase_o : out std_logic_vector(iq_data_width-1 downto 0);
    cordic_mag_o : out std_logic_vector(iq_data_width-1 downto 0)
	);
end component;
end adpll_iq_pkg;

package body adpll_iq_pkg is
end adpll_iq_pkg;

-- Entity Definition

library ieee;
use ieee.std_logic_1164.all;
--use ieee.std_logic_arith.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

use work.cordic_16bit_pkg.all;
use work.iir_lp_filter_opt_nth_order_pkg.all;
use work.pi_controller_pkg.all;
use work.sine_lut_pkg.all;
use work.dds_synthesizer_pkg.all;
use work.const_delay_pkg.all;
use work.resize_tools_pkg.all;
use work.pll_phase_unwrapp_pkg.all;

entity adpll_iq is
	generic(
	  --data width of I/O and different components
		iq_data_width : integer                := 16;  --data width of i/q input, fixed to 16 bit at the moment
		no_of_unwrapp_bits : integer           := 7;   --no of bits for extra phase resolution, output_data_width=input_data_width+unwrapp_width
		lpf_internal_data_width : integer      := 33;  --internal data width of the lowpass filter, should be at least 2*f_3dB_div+iq_data_width + no_of_unwrapp_bits
		pi_cntrl_data_width : integer          := 32;  --data width of the pi controller
		pi_cntrl_internal_data_width : integer := 64;  --internal data width of the pi controller
		dds_ftw_data_width : integer           := 32;  --data width of dds frequency tuning word (phase res. and ampl. res. are defined by choosing the right sine LUT)
    
		-- PLL parameters ---
    f_n : real                             := 10.0e3; --eigenfrequency of PLL
    zeta : real                            := 0.707; --damping factor of PLL
		sampling_frequency : real 	 					 := 60.0E6; --sampling frequency of the PLL in Hz
    delta_phase_lock_detect_in_degrees : real  := 10.0;
		dds_ftw_0 : integer					 					 := 71582788; --free running frequency when controll loop is open
		dds_ftw_min : integer                  := 0; --minimum operating frequency 
		dds_ftw_max : integer                  := 2147483648; --maximum operating frequency 
		dds_phase_0 : integer				 					 := 0; --initial phase of dds
    --lowpass filter specific parameters
    lpf_f_3dB_div      : integer           := 4;  --cutoff frequency is f3dB = fs/(2^lpf_f_3dB_div-1)
    lpf_no_of_stages : integer	           := 3;  --attenuation is 20dB/decade/stage
    --feedback delay                       
    fbd_delay_in_clks  : integer           := 1  --feedback delay may be used to compensate forward delays, but can make the loop unstable!
	);
	port(
    clk_i : in std_logic;
    rst_i : in std_logic;
    i_data_i : in std_logic_vector(iq_data_width-1 downto 0);
    q_data_i : in std_logic_vector(iq_data_width-1 downto 0);
    iq_data_str_i : in std_logic;
    pll_mag_o : out std_logic_vector(AMPL_WIDTH-1 downto 0);
    close_pll_i : in std_logic;
    pll_locked_o : out std_logic;
    --monitor outputs
    pll_ftw_o : out std_logic_vector(dds_ftw_data_width-1 downto 0);
    delta_phase_filt_o : out std_logic_vector(iq_data_width+no_of_unwrapp_bits-1 downto 0);
    delta_phase_o  : out std_logic_vector(iq_data_width-1 downto 0);
    pi_cntrl_o : out std_logic_vector(pi_cntrl_data_width-1 downto 0);
    cordic_phase_o : out std_logic_vector(iq_data_width-1 downto 0);
    cordic_mag_o : out std_logic_vector(iq_data_width-1 downto 0)
	);
end adpll_iq; 

architecture adpll_iq_arch of adpll_iq is

  --pi controller specific constants
  constant omega_n : real := 2.0*MATH_PI*f_n; --eigenfrequency
  constant K0 : real := 2.0*MATH_PI*sampling_frequency; --gain of dds
  constant Kd : real := 1.0/(2.0*MATH_PI*2.0**no_of_unwrapp_bits); --gain of phase detector

  constant pi_cntrl_kp : real := (2.0*zeta*omega_n)/(K0*Kd); --proportional gain of pi controller
  constant pi_cntrl_ki : real := (omega_n**2.0)/(K0*Kd);  --integral gain of pi controller

	constant delta_phase_lock_detect_int : integer := integer(round(delta_phase_lock_detect_in_degrees/180.0*2.0**(iq_data_width-1)));


  signal clk : std_logic;
  signal rst : std_logic;
  
  signal cordic_phase : std_logic_vector(iq_data_width-1 downto 0);
  signal dds_phase : std_logic_vector(PHASE_WIDTH-1 downto 0);
  signal dds_phase_del : std_logic_vector(PHASE_WIDTH-1 downto 0);
  signal dds_phase_del_res : std_logic_vector(iq_data_width-1 downto 0);
  signal delta_phase : std_logic_vector(iq_data_width-1 downto 0);
  signal delta_phase_unwrapped : std_logic_vector(iq_data_width+no_of_unwrapp_bits-1 downto 0);
  
  signal delta_phase_filt : std_logic_vector(iq_data_width+no_of_unwrapp_bits-1 downto 0);
  signal delta_phase_filt_res : std_logic_vector(pi_cntrl_data_width-1 downto 0);
  signal delta_phase_filt_res_switched : std_logic_vector(pi_cntrl_data_width-1 downto 0);
  signal cntrl_out : std_logic_vector(pi_cntrl_data_width-1 downto 0);
  signal cntrl_out_res : std_logic_vector(dds_ftw_data_width-1 downto 0);
  signal cntrl_out_res_del : std_logic_vector(dds_ftw_data_width-1 downto 0);
  signal cntrl_out_res_plus_ftw_0 : std_logic_vector(dds_ftw_data_width-1 downto 0);
  signal cntrl_out_res_plus_ftw_0_limited : std_logic_vector(dds_ftw_data_width-1 downto 0);


begin
  clk <= clk_i;
  rst <= rst_i;

  cordic_16bit_inst : cordic_16bit
    port map(
  		clk_i => clk,
  		rst_i => rst,
  		i_i  => i_data_i,
  		q_i  => q_data_i,
  		magnitude_o => cordic_mag_o,
  		phase_o => cordic_phase
    );

	cordic_phase_o <= cordic_phase;
  delta_phase <= std_logic_vector(signed(cordic_phase) - signed(dds_phase_del_res));
  delta_phase_o <= delta_phase;
  
  use_phase_unwrapp: if no_of_unwrapp_bits > 0 generate

    pll_phase_unwrapp_inst : pll_phase_unwrapp
  	generic map(
  		input_data_width   => iq_data_width,
  		no_of_unwrapp_bits => no_of_unwrapp_bits
  	)
  	port map(
  			clk_i				=> clk,
  			rst_i				=> rst,
  			phase_i			=> delta_phase,
  		  phase_str_i	=> '1',
  			phase_o			=> delta_phase_unwrapped,
   			phase_str_o	=> open
  	);
  end generate;

  use_no_phase_unwrapp: if no_of_unwrapp_bits = 0 generate
    delta_phase_unwrapped <= resize_to_msb_round(delta_phase, iq_data_width) when close_pll_i='1' else (others => '0');
  end generate;
    
	iir_lp_filter_opt_nth_order_inst : iir_lp_filter_opt_nth_order
  generic map(
    data_width  => iq_data_width+no_of_unwrapp_bits,
    internal_data_width => lpf_internal_data_width,
    f_3dB_div => lpf_f_3dB_div,
    no_of_stages => lpf_no_of_stages
    )
  port map(
    rst_i           => rst,
    clk_i           => clk,
    data_i       => delta_phase_unwrapped,
    data_str_i    => '1',
		data_str_o    => open,
    data_o      => delta_phase_filt
  );	
    
  delta_phase_filt_o <= delta_phase_filt;
  delta_phase_filt_res <= resize_to_msb_round(delta_phase_filt,pi_cntrl_data_width);
	delta_phase_filt_res_switched <= delta_phase_filt_res when close_pll_i='1' else (others => '0');

  pi_controller_inst : pi_controller
  generic map(
    data_width  => pi_cntrl_data_width,
    internal_data_width => pi_cntrl_internal_data_width,
    sampling_frequency => sampling_frequency,
    kp => pi_cntrl_kp,
    ki => pi_cntrl_ki,
    use_altera_lpm	=> true
    )
  port map(
    rst_i           => rst,
    clk_i           => clk,
    data_i       => delta_phase_filt_res_switched,
    data_o      => cntrl_out
    );
  
	p_lock_detect: process(rst,clk)
	begin
		if rst = '1' then
			pll_locked_o <= '0';
		elsif clk='1' and clk'event then
	  	if(abs(to_integer(signed(delta_phase_filt))) < delta_phase_lock_detect_int) then
				pll_locked_o <= '1';
			else
				pll_locked_o <= '0';
	  	end if;
		end if;
	end process p_lock_detect;
	  
  pi_cntrl_o <= cntrl_out;
  cntrl_out_res <= resize_to_msb_round(cntrl_out,dds_ftw_data_width);

	process(rst,clk)
	begin
		if rst = '1' then
			cntrl_out_res_plus_ftw_0 <= (others => '0');
			cntrl_out_res_del <= (others => '0');
		elsif clk='1' and clk'event then
		  cntrl_out_res_del <= cntrl_out_res;
			cntrl_out_res_plus_ftw_0 <= std_logic_vector(signed(cntrl_out_res_del) + to_signed(dds_ftw_0, dds_ftw_data_width));
		end if;
	end process;


 	p_limit_cntrl_output: process(rst,clk)
	begin
		if rst = '1' then
			cntrl_out_res_plus_ftw_0_limited <= (others => '0');
		elsif clk='1' and clk'event then
			if to_integer(signed(cntrl_out_res_plus_ftw_0)) < dds_ftw_min then
				cntrl_out_res_plus_ftw_0_limited <= std_logic_vector(to_signed(dds_ftw_min, dds_ftw_data_width));
			elsif to_integer(signed(cntrl_out_res_plus_ftw_0)) > dds_ftw_max then
				cntrl_out_res_plus_ftw_0_limited <= std_logic_vector(to_signed(dds_ftw_max, dds_ftw_data_width));
			else
				cntrl_out_res_plus_ftw_0_limited <= cntrl_out_res_plus_ftw_0;
			end if;
		end if;
	end process p_limit_cntrl_output;
	
	pll_ftw_o <= cntrl_out_res_plus_ftw_0_limited;
		
	dds_synth: dds_synthesizer
  generic map(
		ftw_width   => dds_ftw_data_width
  )
  port map(
		clk_i => clk,
		rst_i => rst,
		ftw_i    => cntrl_out_res_plus_ftw_0_limited,
		phase_i  => std_logic_vector(to_unsigned(dds_phase_0,PHASE_WIDTH)),
		phase_o  => dds_phase,
		ampl_o => pll_mag_o
  );	
	
	feedback_delay_inst : const_delay
	generic map(
		data_width    => PHASE_WIDTH,
		delay_in_clks => fbd_delay_in_clks
	)
	port map(
	    clk_i => clk,
	    rst_i => rst,
	    data_i => dds_phase,
	    data_str_i => '1',
	    data_o => dds_phase_del,
	    data_str_o => open
	);	
	
  dds_phase_del_res <= resize_to_msb_round(dds_phase_del,iq_data_width);

end adpll_iq_arch; 