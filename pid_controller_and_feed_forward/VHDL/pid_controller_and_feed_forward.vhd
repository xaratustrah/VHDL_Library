-------------------------------------------------------------------
-------------- PID CONTROLLER WITH FEED FORWARD --------------------
-------------------------------------------------------------------
--- 06.01.2011 @ GSI
--- T.GUTHIER & Ali Zafar & Stefan Schäfer
-------------------------------------------------------------------
-- to do:
-- e*KI und Ts*(e*KI) zusammenfassen
-- Umstellung auf Floating Point mit 14 Bit Mattisse


-- Package Definition
LIBRARY lpm;
USE lpm.all;

library ieee;
use ieee.std_logic_1164.all;
--use IEEE.STD_LOGIC_arith.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
--use IEEE.STD_LOGIC_ARITH.ALL;
--use IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.clk_divider_pkg.all;





package pid_controller_and_feed_forward_pkg is
component pid_controller_and_feed_forward
	generic(
			use_negative_adc_input			: std_logic;
			data_width 						: integer;
			int_data_width_before_dot 		: integer;
			int_data_width_after_dot 		: integer;
			intern_data_width				: integer;	-- sum of int_data_width_before_dot + int_data_width_after_dot
			sampling_frequency 				: real    
	);
	port(
			clk_i				: in  std_logic;
			adcclk              : in  std_logic;
			rst_i				: in  std_logic;			
			k_v					: in std_logic_vector(intern_data_width-1 downto 0);
			k_p					: in std_logic_vector(intern_data_width-1 downto 0);	--P-Anteil
			k_i					: in std_logic_vector(intern_data_width-1 downto 0);	--I_Anteil
			k_d					: in std_logic_vector(intern_data_width-1 downto 0);	--D-Anteil
			Ts					: in std_logic_vector(intern_data_width-1 downto 0);	-- Sampling Time
			Z1					: in std_logic_vector(intern_data_width-1 downto 0);
			K1					: in std_logic_vector(intern_data_width-1 downto 0);
			K2					: in std_logic_vector(intern_data_width-1 downto 0);
			use_nl_feed_forward		: in std_logic;
			data_nl_i		:	in std_logic_vector(data_width-1 downto 0);
			data_w_i        :	in std_logic_vector(data_width-1 downto 0);				--Sollwert
			data_y_i        :	in std_logic_vector(data_width-1 downto 0);				--Istwert
			data_u_o        :	out std_logic_vector(data_width-1 downto 0)				--Ausgang des Regelkreises
			
	);
end component; 
end pid_controller_and_feed_forward_pkg;

package body pid_controller_and_feed_forward_pkg is
end pid_controller_and_feed_forward_pkg;

-- Entity Definition
LIBRARY lpm;
USE lpm.all;

library ieee;
use ieee.std_logic_1164.all;
--use IEEE.STD_LOGIC_arith.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use work.clk_divider_pkg.all;


entity pid_controller_and_feed_forward is
	generic(
		use_negative_adc_input			: std_logic := '0';	-- depends on the adc board input. if it is optimized to use positiv and negativ input set <= '1'
		data_width 						: integer := 14;
		int_data_width_before_dot 		: integer := 21;
		int_data_width_after_dot 		: integer := 25;	-- has to be higher then data_width
		intern_data_width				: integer := 64;	-- sum of int_data_width_before_dot + int_data_width_after_dot
		number_of_pipelines_for_mult	: integer := 23;	-- half of intern_data_width is "good"
		sampling_frequency 				: real := 25.0E6   -- Samplefrequency of ADC/DAC is one halfe = 25MHz, used for calculation ts  
	);
	port(
			clk_i							:	in  std_logic;
			adcclk  			            : in  std_logic;
			rst_i							:	in  std_logic;
			k_v					: in std_logic_vector(intern_data_width-1 downto 0);
			--k_p					: real;
			--k_i					: real;
			--k_d					: real;
			k_p					: in std_logic_vector(intern_data_width-1 downto 0);
			k_i					: in std_logic_vector(intern_data_width-1 downto 0);
			k_d					: in std_logic_vector(intern_data_width-1 downto 0);
			Ts					: in std_logic_vector(intern_data_width-1 downto 0);  -- Sampling Time
			Z1					: in std_logic_vector(intern_data_width-1 downto 0);
			K1					: in std_logic_vector(intern_data_width-1 downto 0);
			K2					: in std_logic_vector(intern_data_width-1 downto 0);
			use_nl_feed_forward		: in std_logic;
			data_nl_i		:	in std_logic_vector(data_width-1 downto 0);
			data_w_i        :	in std_logic_vector(data_width-1 downto 0);
			data_y_i        :	in std_logic_vector(data_width-1 downto 0);
			data_u_o        :	out std_logic_vector(data_width-1 downto 0)
			
	);
	
end pid_controller_and_feed_forward; 

architecture pid_controller_and_feed_forward_arch of pid_controller_and_feed_forward is

	-- -- adding PLL component  
	-- component pll1 is
	-- port
		-- (
		-- inclk0			: IN STD_LOGIC  := '0';
		-- c0				: OUT STD_LOGIC ;
		-- c1				: OUT STD_LOGIC ;
		-- locked			: OUT STD_LOGIC 
		-- );
	-- end component;

	COMPONENT lpm_mult
	GENERIC (
		lpm_hint		: STRING;
		lpm_pipeline		: NATURAL;
		lpm_representation		: STRING;
		lpm_type		: STRING;
		lpm_widtha		: NATURAL;
		lpm_widthb		: NATURAL;
		lpm_widthp		: NATURAL
	);
	PORT (
			dataa	: IN STD_LOGIC_VECTOR (intern_data_width-1 DOWNTO 0);
			datab	: IN STD_LOGIC_VECTOR (intern_data_width-1 DOWNTO 0);
			clock	: IN STD_LOGIC ;
			result	: OUT STD_LOGIC_VECTOR (2*intern_data_width-1 DOWNTO 0)
	);
	END COMPONENT;

signal	w		:	std_logic_vector(data_width-1 downto 0);
signal	y		:	std_logic_vector(data_width-1 downto 0);
signal	nl		:	std_logic_vector(data_width-1 downto 0);

signal	e		:   std_logic_vector(data_width-1 downto 0);

signal	e_int	:   std_logic_vector(intern_data_width-1 downto 0);
signal	w_int	:   std_logic_vector(intern_data_width-1 downto 0);


signal	w_mult_k_v		:   std_logic_vector((2*intern_data_width)-1 downto 0);
signal	e_mult_k_p		:   std_logic_vector((2*intern_data_width)-1 downto 0);
signal	e_mult_k_i		:   std_logic_vector((2*intern_data_width)-1 downto 0);
signal	e_mult_k_d		:   std_logic_vector((2*intern_data_width)-1 downto 0);
signal	e_mult_k_i_Ts 	:	std_logic_vector((2*intern_data_width)-1 downto 0);
signal	e_mult_k_d_K1 	:	std_logic_vector((2*intern_data_width)-1 downto 0);
signal	e_mult_k_d_K2 	: std_logic_vector((2*intern_data_width)-1 downto 0);
signal	e_mult_k_d_K2_vz_Z1 : std_logic_vector((2*intern_data_width)-1 downto 0):= (others => '0');

signal	w_mult_k_v_int	:   std_logic_vector(intern_data_width-1 downto 0);
signal	e_mult_k_p_int	:   std_logic_vector(intern_data_width-1 downto 0);
signal	e_mult_k_i_int	:   std_logic_vector(intern_data_width-1 downto 0);
signal	e_mult_k_d_int	:   std_logic_vector(intern_data_width-1 downto 0);
signal  e_mult_k_d_int_test	:   std_logic_vector(intern_data_width-1 downto 0);


signal	e_mult_k_d_int_K2_vz		: std_logic_vector(intern_data_width-1 downto 0):= (others => '0');
signal	e_mult_k_d_int_K2_vz2		: std_logic_vector(intern_data_width-1 downto 0):= (others => '0');


signal	e_mult_k_i_int_Ts			:	std_logic_vector(intern_data_width-1 downto 0);
signal	e_mult_k_d_int_K1			:	std_logic_vector(intern_data_width-1 downto 0);
signal	e_mult_k_d_int_K2			:	std_logic_vector(intern_data_width-1 downto 0);
signal	e_mult_k_d_int_K2_vz_Z1	:	std_logic_vector(intern_data_width-1 downto 0):= (others => '0');

constant zeroes	:	std_logic_vector((intern_data_width - 2) downto int_data_width_after_dot) := (others => '0');

signal	e_mult_k_i_int_Ts_and_vz	: std_logic_vector(intern_data_width-1 downto 0);	
signal	e_mult_k_i_int_Ts_vz		  : std_logic_vector(intern_data_width-1 downto 0);
signal	u_i_int						        : std_logic_vector(intern_data_width-1 downto 0);

signal	w_mult_k_v_int_2clk			        : std_logic_vector(intern_data_width-1 downto 0);
signal	w_mult_k_v_int_3clk			        : std_logic_vector(intern_data_width-1 downto 0);
signal	e_mult_k_p_int_2clk			        : std_logic_vector(intern_data_width-1 downto 0);
signal	e_mult_k_p_int_3clk						  : std_logic_vector(intern_data_width-1 downto 0);
signal	u_i_int_3clk						        : std_logic_vector(intern_data_width-1 downto 0);

signal	u_d_int				: std_logic_vector(intern_data_width-1 downto 0);
signal	u_p_v_int			: std_logic_vector(intern_data_width-1 downto 0);
signal	u_int				: std_logic_vector(intern_data_width-1 downto 0);

signal	u	: std_logic_vector(data_width-1 downto 0);

signal clk100 				: std_logic; 
signal clk200				: std_logic; 
signal clk200_int			: std_logic; 

begin

   -- pll1_inst : pll1 
	-- PORT MAP
	-- (
		-- inclk0			=> clk_i,
		-- c0				=> clk100, 
		-- c1				=> clk200,
		-- locked			=> open
	-- );

  -- ckl200_clk_divider_inst : clk_divider
    -- generic map (
      -- clk_divider_width => 16)

    -- port map (
      -- clk_div_i => x"0001",
      -- rst_i     => rst_i,
      -- clk_i     => clk200,
      -- clk_o     => clk200_int);	
	
	
	-- Mappen der Eingänge
	w	  <= data_w_i;
	y	  <= data_y_i;
	nl	<= data_nl_i;
	
	-- Regeldifferenz erzeugen
	e	<= std_logic_vector(signed(w) - signed(y));	
	
	-- w und e auf die interne Wortbreite erweitern
			-- Unterscheidung ob w oder nl für die Vorsteuerung verwendet wird
	register_in_front_of_mult_process : process (adcclk, rst_i)
	begin
	if rst_i = '1' then
		w_int	<= (others => '0');
		e_int	<= (others => '0');
	elsif adcclk'event and adcclk = '1' then	
		
		if use_nl_feed_forward = '0' then		-- use w
			w_int((int_data_width_after_dot - data_width) downto 0)										<= (others => '0');
			w_int((int_data_width_after_dot - 1) downto (int_data_width_after_dot - (data_width - 1)))	<= w((data_width - 2) downto 0);
			w_int((intern_data_width - 1) downto int_data_width_after_dot)								<= (others => w(data_width - 1));
		else			-- use nl
			w_int((int_data_width_after_dot - data_width) downto 0)										<= (others => '0');
			w_int((int_data_width_after_dot - 1) downto (int_data_width_after_dot - (data_width - 1)))	<= nl((data_width - 2) downto 0);
			w_int((intern_data_width - 1) downto int_data_width_after_dot)								<= (others => nl(data_width - 1));
		end if;
		-- nach dem Komma werden 14 Stellen e (Regelabweichung) eingetragen rechts wird mit Nullen aufgefüllt. Das Vorzeichen wird auf alle Stellen vor dem Komma gesetzt. 
		e_int((int_data_width_after_dot - data_width) downto 0)										<= (others => '0'); -- 
		e_int((int_data_width_after_dot - 1) downto (int_data_width_after_dot - (data_width - 1)))	<= e((data_width - 2) downto 0);
		e_int((intern_data_width - 1) downto int_data_width_after_dot)								<= (others => e(data_width - 1));
		
	end if;
	end process;
	
	
-- ************************************************************************************  P-Anteil , V-Anteil ***************************************************************************************************

	
	mult_inst_for_k_v : lpm_mult
	GENERIC MAP (
		lpm_hint => "DEDICATED_MULTIPLIER_CIRCUITRY=NO,MAXIMIZE_SPEED=9",
		lpm_pipeline => 1,
		lpm_representation => "SIGNED",
		lpm_type => "LPM_MULT",
		lpm_widtha => intern_data_width,
		lpm_widthb => intern_data_width,
		lpm_widthp => (2*intern_data_width)
	)
	PORT MAP (
		dataa => w_int,
		datab => k_v,
		clock => adcclk,
		result => w_mult_k_v
	);
	
	mult_inst_for_k_p : lpm_mult
	GENERIC MAP (
		lpm_hint => "DEDICATED_MULTIPLIER_CIRCUITRY=NO,MAXIMIZE_SPEED=9",  -- DEDICATED_MULTIPLIER_CIRCUITRY=NO
		lpm_pipeline => 1,
		lpm_representation => "SIGNED",
		lpm_type => "LPM_MULT",
		lpm_widtha => intern_data_width,
		lpm_widthb => intern_data_width,
		lpm_widthp => (2*intern_data_width)
	)
	PORT MAP (
		dataa => e_int,
		datab => k_p,
		clock => adcclk,
		result => e_mult_k_p
	);	
	
	-- w_mult_k_v <= (others => '0');
	-- e_mult_k_p <= (others => '0');
-- ************************************************************************************  I-Anteil ***************************************************************************************************
	mult_inst_for_k_i : lpm_mult
	GENERIC MAP (
		lpm_hint => "DEDICATED_MULTIPLIER_CIRCUITRY=NO,MAXIMIZE_SPEED=9",
		lpm_pipeline => 1,
		lpm_representation => "SIGNED",
		lpm_type => "LPM_MULT",
		lpm_widtha => intern_data_width,
		lpm_widthb => intern_data_width,
		lpm_widthp => (2*intern_data_width)
	)
	PORT MAP (
		dataa => e_int,
		datab => k_i,
		clock => adcclk,
		result => e_mult_k_i
	);
	
		e_mult_k_i_int	<= e_mult_k_i((2*int_data_width_after_dot + int_data_width_before_dot - 1) downto int_data_width_after_dot);
	
	mult_inst_for_e_mult_k_i_Ts : lpm_mult
	GENERIC MAP (
		lpm_hint => "DEDICATED_MULTIPLIER_CIRCUITRY=NO,MAXIMIZE_SPEED=9",
		lpm_pipeline => 1,
		lpm_representation => "SIGNED",
		lpm_type => "LPM_MULT",
		lpm_widtha => intern_data_width,
		lpm_widthb => intern_data_width,
		lpm_widthp => (2*intern_data_width)
	)
	PORT MAP (
		dataa => e_mult_k_i_int,
		datab => Ts,
		clock => adcclk,
		result => e_mult_k_i_Ts
	);

                                                                                           e_mult_k_i_int_Ts	<= e_mult_k_i_Ts((2*int_data_width_after_dot + int_data_width_before_dot - 1) downto int_data_width_after_dot);
       e_mult_k_i_int_Ts_and_vz	<=	std_logic_vector(signed(e_mult_k_i_int_Ts_vz) + signed(e_mult_k_i_int_Ts));	

		-- ANTI WINDUP - I-Anteil
	register_delay_u_i_1_process : process (adcclk, rst_i)
	begin
	if rst_i = '1' then
		e_mult_k_i_int_Ts_vz	<= (others => '0');
	elsif adcclk'event and adcclk = '1' then	
		if e_mult_k_i_int_Ts_and_vz(intern_data_width - 1) = '1' then	
			-- Überlauf ins negative
			if use_negative_adc_input = '1' then
				e_mult_k_i_int_Ts_vz													<= e_mult_k_i_int_Ts_and_vz;
				e_mult_k_i_int_Ts_vz((int_data_width_after_dot - data_width) downto 0)	<= (others => '0');
			else
				e_mult_k_i_int_Ts_vz					<= (others => '0');
			end if;	
		elsif e_mult_k_i_int_Ts_and_vz((intern_data_width - 2) downto int_data_width_after_dot) = zeroes then	
			-- KEIN Überlauf
			e_mult_k_i_int_Ts_vz					<= e_mult_k_i_int_Ts_and_vz;
		else	
			-- Überlauf nach oben
			e_mult_k_i_int_Ts_vz((intern_data_width - 1) downto int_data_width_after_dot)	<= (others => '0');				-- VZ positiv
			e_mult_k_i_int_Ts_vz((int_data_width_after_dot - 1) downto 0)					<= (others => '1'); -- Maximalwert einstellen
		end if;
	end if;
	end process;
                                     -- /2 kann vielleicht effizenter mit einem Bitshift gelößt werden. !!!
	u_i_int	<=	std_logic_vector((signed(e_mult_k_i_int_Ts)/2) + (signed(e_mult_k_i_int_Ts_vz))); 


	-- u_i_int <= (others => '0');
	
--******************************************************************************************* D-Anteil ******************************************************************************************	
	mult_inst_for_k_d : lpm_mult
	GENERIC MAP (
		lpm_hint => "DEDICATED_MULTIPLIER_CIRCUITRY=No,MAXIMIZE_SPEED=9",
		lpm_pipeline => 1,
		lpm_representation => "SIGNED",
		lpm_type => "LPM_MULT",
		lpm_widtha => intern_data_width,
		lpm_widthb => intern_data_width,
		lpm_widthp => (2*intern_data_width)
	)
	PORT MAP (
		dataa => e_int,
		datab => k_d,
		clock => adcclk,
		result => e_mult_k_d
	);
  e_mult_k_d_int	<= e_mult_k_d((2*int_data_width_after_dot + int_data_width_before_dot - 1) downto int_data_width_after_dot);
  
	-- Test_process : process (adcclk, rst_i)
	-- begin
		-- if rst_i = '1' then
			-- e_mult_k_d_int_test	<= (others => '0');
		-- elsif adcclk'event and adcclk = '1' then	
			-- e_mult_k_d_int_test <= e_mult_k_d_int;
		-- end if;
	-- end process;  
  
  
  
  
  
  

  
	mult_inst_for_e_mult_k_d_K2 : lpm_mult
	GENERIC MAP (
		lpm_hint => "DEDICATED_MULTIPLIER_CIRCUITRY=no,MAXIMIZE_SPEED=9",
		lpm_pipeline => 1,
		lpm_representation => "SIGNED",
		lpm_type => "LPM_MULT",
		lpm_widtha => intern_data_width,
		lpm_widthb => intern_data_width,
		lpm_widthp => (2*intern_data_width)
	)
	PORT MAP (
		dataa => e_mult_k_d_int,
		datab => K2,
		clock => adcclk,
		result => e_mult_k_d_K2
	);

                                                                                                                          e_mult_k_d_int_K2	<= e_mult_k_d_K2((2*int_data_width_after_dot + int_data_width_before_dot - 1) downto int_data_width_after_dot);
  e_mult_k_d_int_K2_vz <= (others => '0') when rst_i = '1' else std_logic_vector(signed(e_mult_k_d_int_K2_vz_Z1) + signed(e_mult_k_d_int_K2));
                                                                                        e_mult_k_d_int_K2_vz_Z1	<= e_mult_k_d_K2_vz_Z1((2*int_data_width_after_dot + int_data_width_before_dot - 1) downto int_data_width_after_dot);
                                           
	mult_inst_for_e_mult_k_d_K2_vz_Z1 : lpm_mult
	GENERIC MAP (
		lpm_hint => "DEDICATED_MULTIPLIER_CIRCUITRY=no,MAXIMIZE_SPEED=9",
		lpm_pipeline => 1,
		lpm_representation => "SIGNED",
		lpm_type => "LPM_MULT",
		lpm_widtha => intern_data_width,
		lpm_widthb => intern_data_width,
		lpm_widthp => (2*intern_data_width)
	)
	PORT MAP (
		dataa => e_mult_k_d_int_K2_vz,
		datab => Z1,
		clock => adcclk,
		result => e_mult_k_d_K2_vz_Z1
	);
  
    -- ANTI WINDUP - D-Anteil
    register_delay_u_d_1_process : process (adcclk, rst_i)
    begin
    if rst_i = '1' then
      e_mult_k_d_int_K2_vz2	<= (others => '0');
    elsif adcclk'event and adcclk = '1' then
      e_mult_k_d_int_K2_vz2	<= e_mult_k_d_int_K2_vz;	
    end if;
    end process;
				
  mult_inst_for_e_mult_k_d_K1 : lpm_mult
    GENERIC MAP (
      lpm_hint => "DEDICATED_MULTIPLIER_CIRCUITRY=no,MAXIMIZE_SPEED=9",
      lpm_pipeline => 1,
      lpm_representation => "SIGNED",
      lpm_type => "LPM_MULT",
      lpm_widtha => intern_data_width,
      lpm_widthb => intern_data_width,
      lpm_widthp => (2*intern_data_width)
    )
    PORT MAP (
      dataa => e_mult_k_d_int,
      datab => K1,
      clock => adcclk,
      result => e_mult_k_d_K1
    );
 
                                        e_mult_k_d_int_K1	<= e_mult_k_d_K1((2*int_data_width_after_dot + int_data_width_before_dot - 1) downto int_data_width_after_dot);
	u_d_int	<=	std_logic_vector(signed(e_mult_k_d_int_K1) - signed(e_mult_k_d_int_K2_vz2)); 

  
 --******************************************************************************************* register_behind_mult_process ******************************************************************************************	
 -- Dieses Register stellt sicher, dass die Delayfront für alle Pfade konsistent ist. 
  
	-- w_mult_k_v, e_mult_k_p und e_mult_k_i e_mult_k_d auf interne Wortbreite verkürzen
	register_behind_mult_process : process (adcclk, rst_i)
	begin
	if rst_i = '1' then
		w_mult_k_v_int				<= (others => '0');
    w_mult_k_v_int_3clk	  <= (others => '0');
    w_mult_k_v_int_2clk	  <= (others => '0');
    
		e_mult_k_p_int				<= (others => '0');
    e_mult_k_p_int_2clk	  <= (others => '0');
    e_mult_k_p_int_3clk	  <= (others => '0');
    
    u_i_int_3clk    	    <= (others => '0');
	
	elsif adcclk'event and adcclk = '1' then
-- alles was größer als int_data_width_before_dot wird abgeschnitten, alles was kleiner als int_data_width_after_dot wird abgeschnitten  
-- !!Das ist Problematisch weil beim überschreiten von int_data_width_before_dot klein Anschlag erzeugt wird.
-- Ist aber villeicht nicht so tragisch, weil die 14 ADC nach dem Komma eingetragen werden  und ein Wert größer int_data_width_before_dot auch nicht erreicht wird wenn Kp max ist.	

		w_mult_k_v_int	      <=  w_mult_k_v((2*int_data_width_after_dot + int_data_width_before_dot - 1) downto int_data_width_after_dot);
    w_mult_k_v_int_2clk   <=  w_mult_k_v_int;
    w_mult_k_v_int_3clk   <=  w_mult_k_v_int_2clk;
    
		e_mult_k_p_int	      <=  e_mult_k_p((2*int_data_width_after_dot + int_data_width_before_dot - 1) downto int_data_width_after_dot);
    e_mult_k_p_int_2clk   <=  e_mult_k_p_int;
    e_mult_k_p_int_3clk   <=  e_mult_k_p_int_2clk;
		-- I-Anteil
    u_i_int_3clk          <=  u_i_int; 
	
	end if;
	end process;

		-- Addition von e_mult_k_p_int und w_mult_k_v_int
	u_p_v_int	<= std_logic_vector(signed(e_mult_k_p_int_2clk) + signed(w_mult_k_v_int_2clk));


	
-- ****************************************      Addition von u_p_v_int und u_i_int und u_d_int      *******************************************************************************************************

	-- u_int	<=  std_logic_vector(signed(u_p_v_int) + signed(u_d_int)); -- !! signed(u_d_add_int_vz)) ersetzen durch signed(u_d_add_int));;
	u_int	<= std_logic_vector(signed(u_i_int_3clk) + signed(u_p_v_int) + signed(u_d_int)); -- !! signed(u_d_add_int_vz)) ersetzen durch signed(u_d_add_int));;
	
	-- Überlaufkontrolle am Ende - Es werden nur 14 Nachkommastellen genommen. 
	register_u_process : process (adcclk, rst_i)
	begin
	if rst_i = '1' then
		u		<= (others => '0');
	elsif adcclk'event and adcclk = '1' then	
		if u_int(intern_data_width - 1) = '1' then	
			-- Überlauf ins negative
			if use_negative_adc_input = '1' then
				u(data_width - 1)				<= '1';				-- VZ negativ
				u((data_width - 2) downto 0)	<= u_int((int_data_width_after_dot - 1) downto (int_data_width_after_dot - (data_width - 1)));
			else
				u				<= (others => '0');
			end if;
		elsif u_int((intern_data_width - 2) downto int_data_width_after_dot) = zeroes then -- alles was vor dem Komma steht ohne Vorzeichen ist Null	
			-- KEIN Überlauf
			u(data_width - 1)				<= '0';				-- VZ positiv
			u((data_width - 2) downto 0)	<= u_int((int_data_width_after_dot - 1) downto (int_data_width_after_dot - (data_width - 1))); -- Begrenzung auf 14 Nachkommastellen binär - 14 Bit DAC
		else	
			-- Überlauf nach oben
			u(data_width - 1)				<= '0';				-- VZ positiv
			u((data_width - 2) downto 0)	<= (others => '1'); -- Maximalwert einstellen
		end if;		
	end if;
	end process;
	
	data_u_o	<= u;	
  
end pid_controller_and_feed_forward_arch;

