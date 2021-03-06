-------------------------------------------------------------------
-------------- PI CONTROLLER WITH FEED FORWARD --------------------
-------------------------------------------------------------------
--- 9.6.08 @ GSI
--- T.GUTHIER
-------------------------------------------------------------------


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



package pid_controller_and_feed_forward_pkg is
component pid_controller_and_feed_forward
	generic(
			use_negative_adc_input			: std_logic;
			data_width 						: integer;
			int_data_width_before_dot 		: integer;
			int_data_width_after_dot 		: integer;
			intern_data_width				: integer;	-- sum of int_data_width_before_dot + int_data_width_after_dot
			number_of_pipelines_for_mult	: integer;
			sampling_frequency 				: real    
	);
	port(
			clk_i					:	in  std_logic;
			rst_i					:	in  std_logic;			
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


entity pid_controller_and_feed_forward is
	generic(
		use_negative_adc_input			: std_logic := '0';	-- depends on the adc board input. if it is optimized to use positiv and negativ input set <= '1'
		data_width 						: integer := 14;
		int_data_width_before_dot 		: integer := 21;
		int_data_width_after_dot 		: integer := 25;	-- has to be higher then data_width
		intern_data_width				: integer := 46;	-- sum of int_data_width_before_dot + int_data_width_after_dot
		number_of_pipelines_for_mult	: integer := 23;	-- half of intern_data_width is "good"
		sampling_frequency 				: real := 30.0E6    
	);
	port(
			clk_i							:	in  std_logic;
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
			dataa	: IN STD_LOGIC_VECTOR (27 DOWNTO 0);
			datab	: IN STD_LOGIC_VECTOR (27 DOWNTO 0);
			clock	: IN STD_LOGIC ;
			result	: OUT STD_LOGIC_VECTOR (55 DOWNTO 0)
	);
	END COMPONENT;

signal	w		:	std_logic_vector(data_width-1 downto 0);
signal	y		:	std_logic_vector(data_width-1 downto 0);
signal	nl		:	std_logic_vector(data_width-1 downto 0);

signal	e		:   std_logic_vector(data_width-1 downto 0);

signal	e_int	:   std_logic_vector(intern_data_width-1 downto 0);
signal	w_int	:   std_logic_vector(intern_data_width-1 downto 0);
signal	nl_int	:   std_logic_vector(intern_data_width-1 downto 0);

signal	w_mult_k_v	:   std_logic_vector((2*intern_data_width)-1 downto 0);
signal	e_mult_k_p	:   std_logic_vector((2*intern_data_width)-1 downto 0);
signal	e_mult_k_i	:   std_logic_vector((2*intern_data_width)-1 downto 0);
signal	e_mult_k_d	:   std_logic_vector((2*intern_data_width)-1 downto 0);
signal	e_mult_k_i_Ts :	std_logic_vector((2*intern_data_width)-1 downto 0);
signal	e_mult_k_d_K1 :	std_logic_vector((2*intern_data_width)-1 downto 0);
signal	e_mult_k_d_K2 : std_logic_vector((2*intern_data_width)-1 downto 0);
signal	e_mult_k_d_K2_vz_Z1 : std_logic_vector((2*intern_data_width)-1 downto 0);

signal	w_mult_k_v_int	:   std_logic_vector(intern_data_width-1 downto 0);
signal	e_mult_k_p_int	:   std_logic_vector(intern_data_width-1 downto 0);
signal	e_mult_k_i_int	:   std_logic_vector(intern_data_width-1 downto 0);
signal e_mult_k_i_int_2	:	std_logic_vector(intern_data_width-1 downto 0);
signal	e_mult_k_d_int	:   std_logic_vector(intern_data_width-1 downto 0);

signal	e_mult_k_i_int_vz	: std_logic_vector(intern_data_width-1 downto 0);
signal	e_mult_k_i_int_2_vz	: std_logic_vector(intern_data_width-1 downto 0);
signal	e_mult_k_d_int_vz	: std_logic_vector(intern_data_width-1 downto 0);
signal	e_mult_k_d_int_vz_2	: std_logic_vector(intern_data_width-1 downto 0);
signal	e_mult_k_d_int_2	: std_logic_vector(intern_data_width-1 downto 0);
signal	e_mult_k_d_int_2_vz	: std_logic_vector(intern_data_width-1 downto 0);

signal	e_mult_k_i_int_Ts	:	std_logic_vector(intern_data_width-1 downto 0);
signal	e_mult_k_d_int_K1	:	std_logic_vector(intern_data_width-1 downto 0);
signal	e_mult_k_d_int_K2	:	std_logic_vector(intern_data_width-1 downto 0);
signal	e_mult_k_d_int_K2_vz_Z1	:	std_logic_vector(intern_data_width-1 downto 0);

constant zeroes	:	std_logic_vector((intern_data_width - 2) downto int_data_width_after_dot) := (others => '0');

signal	u_i_add_int			: std_logic_vector(intern_data_width-1 downto 0);
signal	u_i_1_int			: std_logic_vector(intern_data_width-1 downto 0);
signal	u_i_1_int_vz		: std_logic_vector(intern_data_width-1 downto 0);
signal	u_i_int				: std_logic_vector(intern_data_width-1 downto 0);

signal	u_d_add_int			: std_logic_vector(intern_data_width-1 downto 0);
signal	u_d_add_int_vz		: std_logic_vector(intern_data_width-1 downto 0);
signal	u_p_v_int			: std_logic_vector(intern_data_width-1 downto 0);
signal	u_p_v_int_vz		: std_logic_vector(intern_data_width-1 downto 0);
signal	u_int				: std_logic_vector(intern_data_width-1 downto 0);

signal	u	: std_logic_vector(data_width-1 downto 0);


begin

	
	-- Mappen der Eing�nge
	w	<= data_w_i;
	y	<= data_y_i;
	nl	<= data_nl_i;
	
	-- Regeldifferenz erzeugen
	e	<= std_logic_vector(signed(w) - signed(y));	
	
	-- w und e auf die interne Wortbreite erweitern
			-- Unterscheidung ob w oder nl f�r die Vorsteuerung verwendet wird
	register_in_front_of_mult_process : process (clk_i, rst_i)
	begin
	if rst_i = '1' then
		w_int	<= (others => '0');
		e_int	<= (others => '0');
	elsif clk_i'event and clk_i = '1' then	
		
		if use_nl_feed_forward = '0' then		-- use w
			w_int((int_data_width_after_dot - data_width) downto 0)										<= (others => '0');
			w_int((int_data_width_after_dot - 1) downto (int_data_width_after_dot - (data_width - 1)))	<= w((data_width - 2) downto 0);
			w_int((intern_data_width - 1) downto int_data_width_after_dot)								<= (others => w(data_width - 1));
		else			-- use nl
			w_int((int_data_width_after_dot - data_width) downto 0)										<= (others => '0');
			w_int((int_data_width_after_dot - 1) downto (int_data_width_after_dot - (data_width - 1)))	<= nl((data_width - 2) downto 0);
			w_int((intern_data_width - 1) downto int_data_width_after_dot)								<= (others => nl(data_width - 1));
		end if;
			
		e_int((int_data_width_after_dot - data_width) downto 0)										<= (others => '0');
		e_int((int_data_width_after_dot - 1) downto (int_data_width_after_dot - (data_width - 1)))	<= e((data_width - 2) downto 0);
		e_int((intern_data_width - 1) downto int_data_width_after_dot)								<= (others => e(data_width - 1));
		
	end if;
	end process;
	
	
	
	-- multiplikation von 1.) w_int mit k_v 2.) e_int mit k_p und 3.) e_int mit k_i_T/2 und 4.)ediff_int mit k_d_2/T
	-- es entstehen: 1.) w_mult_k_v 2.) e_mult_k_p 3.) e_mult_k_i 4.) e_mult_k_d
	
	mult_inst_for_k_v : lpm_mult
	GENERIC MAP (
		lpm_hint => "MAXIMIZE_SPEED=5",
		lpm_pipeline => number_of_pipelines_for_mult,
		lpm_representation => "SIGNED",
		lpm_type => "LPM_MULT",
		lpm_widtha => intern_data_width,
		lpm_widthb => intern_data_width,
		lpm_widthp => (2*intern_data_width)
	)
	PORT MAP (
		dataa => w_int,
		datab => k_v,
		clock => clk_i,
		result => w_mult_k_v
	);
	
	mult_inst_for_k_p : lpm_mult
	GENERIC MAP (
		lpm_hint => "MAXIMIZE_SPEED=5",
		lpm_pipeline => number_of_pipelines_for_mult,
		lpm_representation => "SIGNED",
		lpm_type => "LPM_MULT",
		lpm_widtha => intern_data_width,
		lpm_widthb => intern_data_width,
		lpm_widthp => (2*intern_data_width)
	)
	PORT MAP (
		dataa => e_int,
		datab => k_p,
		clock => clk_i,
		result => e_mult_k_p
	);	
	
	mult_inst_for_k_i : lpm_mult
	GENERIC MAP (
		lpm_hint => "MAXIMIZE_SPEED=5",
		lpm_pipeline => number_of_pipelines_for_mult,
		lpm_representation => "SIGNED",
		lpm_type => "LPM_MULT",
		lpm_widtha => intern_data_width,
		lpm_widthb => intern_data_width,
		lpm_widthp => (2*intern_data_width)
	)
	PORT MAP (
		dataa => e_int,
		datab => k_i,
		clock => clk_i,
		result => e_mult_k_i
	);
	
	mult_inst_for_k_d : lpm_mult
	GENERIC MAP (
		lpm_hint => "MAXIMIZE_SPEED=5",
		lpm_pipeline => number_of_pipelines_for_mult,
		lpm_representation => "SIGNED",
		lpm_type => "LPM_MULT",
		lpm_widtha => intern_data_width,
		lpm_widthb => intern_data_width,
		lpm_widthp => (2*intern_data_width)
	)
	PORT MAP (
		dataa => e_int,
		datab => k_d,
		clock => clk_i,
		result => e_mult_k_d
	);
	
	mult_inst_for_e_mult_k_i_Ts : lpm_mult
	GENERIC MAP (
		lpm_hint => "MAXIMIZE_SPEED=5",
		lpm_pipeline => number_of_pipelines_for_mult,
		lpm_representation => "SIGNED",
		lpm_type => "LPM_MULT",
		lpm_widtha => intern_data_width,
		lpm_widthb => intern_data_width,
		lpm_widthp => (2*intern_data_width)
	)
	PORT MAP (
		dataa => e_mult_k_i_int,
		datab => Ts,
		clock => clk_i,
		result => e_mult_k_i_Ts
	);
	
mult_inst_for_e_mult_k_d_K1 : lpm_mult
	GENERIC MAP (
		lpm_hint => "MAXIMIZE_SPEED=5",
		lpm_pipeline => number_of_pipelines_for_mult,
		lpm_representation => "SIGNED",
		lpm_type => "LPM_MULT",
		lpm_widtha => intern_data_width,
		lpm_widthb => intern_data_width,
		lpm_widthp => (2*intern_data_width)
	)
	PORT MAP (
		dataa => e_mult_k_d_int,
		datab => K1,
		clock => clk_i,
		result => e_mult_k_d_K1
	);
	
	mult_inst_for_e_mult_k_d_K2 : lpm_mult
	GENERIC MAP (
		lpm_hint => "MAXIMIZE_SPEED=5",
		lpm_pipeline => number_of_pipelines_for_mult,
		lpm_representation => "SIGNED",
		lpm_type => "LPM_MULT",
		lpm_widtha => intern_data_width,
		lpm_widthb => intern_data_width,
		lpm_widthp => (2*intern_data_width)
	)
	PORT MAP (
		dataa => e_mult_k_d_int,
		datab => K2,
		clock => clk_i,
		result => e_mult_k_d_K2
	);
	
	
	mult_inst_for_e_mult_k_d_K2_vz_Z1 : lpm_mult
	GENERIC MAP (
		lpm_hint => "MAXIMIZE_SPEED=5",
		lpm_pipeline => number_of_pipelines_for_mult,
		lpm_representation => "SIGNED",
		lpm_type => "LPM_MULT",
		lpm_widtha => intern_data_width,
		lpm_widthb => intern_data_width,
		lpm_widthp => (2*intern_data_width)
	)
	PORT MAP (
		dataa => e_mult_k_d_int_2_vz,
		datab => Z1,
		clock => clk_i,
		result => e_mult_k_d_K2_vz_Z1
	);
	
	-- w_mult_k_v, e_mult_k_p und e_mult_k_i e_mult_k_d auf interne Wortbreite verk�rzen
	register_behind_mult_process : process (clk_i, rst_i)
	begin
	if rst_i = '1' then
		w_mult_k_v_int	<= (others => '0');
		e_mult_k_p_int	<= (others => '0');
		e_mult_k_i_int	<= (others => '0');
		e_mult_k_d_int	<= (others => '0');
		e_mult_k_i_int_Ts	<= (others => '0');
	elsif clk_i'event and clk_i = '1' then	
		w_mult_k_v_int	<= w_mult_k_v((2*int_data_width_after_dot + int_data_width_before_dot - 1) downto int_data_width_after_dot);
		e_mult_k_p_int	<= e_mult_k_p((2*int_data_width_after_dot + int_data_width_before_dot - 1) downto int_data_width_after_dot);
		e_mult_k_i_int	<= e_mult_k_i((2*int_data_width_after_dot + int_data_width_before_dot - 1) downto int_data_width_after_dot);
		e_mult_k_d_int	<= e_mult_k_d((2*int_data_width_after_dot + int_data_width_before_dot - 1) downto int_data_width_after_dot);
		e_mult_k_i_int_Ts	<= e_mult_k_i_Ts((2*int_data_width_after_dot + int_data_width_before_dot - 1) downto int_data_width_after_dot);
		e_mult_k_d_int_K1	<= e_mult_k_d_K1((2*int_data_width_after_dot + int_data_width_before_dot - 1) downto int_data_width_after_dot);
		e_mult_k_d_int_K2	<= e_mult_k_d_K2((2*int_data_width_after_dot + int_data_width_before_dot - 1) downto int_data_width_after_dot);
		e_mult_k_d_int_K2_vz_Z1	<=e_mult_k_d_K2_vz_Z1((2*int_data_width_after_dot + int_data_width_before_dot - 1) downto int_data_width_after_dot);
		
	end if;
	end process;

	-- verz�gertes(vz) Signal erzeugen
	register_delay_process : process (clk_i, rst_i)
	begin
	if rst_i = '1' then
		e_mult_k_i_int_vz	<= (others => '0');
		e_mult_k_i_int_2_vz	<= (others => '0');
		e_mult_k_d_int_vz	<= (others => '0');
		e_mult_k_d_int_2_vz	<= (others => '0');
	elsif clk_i'event and clk_i = '1' then	
		e_mult_k_i_int_vz	<= e_mult_k_i_int;
		e_mult_k_i_int_2_vz	<= e_mult_k_i_int_2;
		e_mult_k_d_int_vz	<= e_mult_k_d_int;
		e_mult_k_d_int_2_vz	<=	e_mult_k_d_int_2;
	end if;
	end process;	

	--P-Strecke
	u_p_v_int	<= std_logic_vector(signed(e_mult_k_p_int));
	
	
	
	-- die erste Additionen im K_I Pfad ausf�hren:         
	e_mult_k_i_int_2	<=	e_mult_k_i_int_Ts;				--*0.5					--signed(e_mult_k_i_int)*Ts;
	u_i_add_int	<=	std_logic_vector((signed(e_mult_k_i_int_Ts)/2) + (signed(e_mult_k_i_int_Ts) + signed(e_mult_k_i_int_2_vz)));
	--u_i_add_int		<= std_logic_vector(signed(e_mult_k_i_int) + signed(e_mult_k_i_int_vz));
	
	-- Addition von u_i_1_vz und u_i_add_int
	u_i_1_int		<= std_logic_vector(signed(u_i_add_int) + signed(u_i_1_int_vz));
	
	
	
  --die Additionen im K_D Pfad ausf�hren: 
	e_mult_k_d_int_2	<=	e_mult_k_d_int_K2;									--signed(e_mult_k_d_int)*K2;
	u_d_add_int	<=	std_logic_vector(signed(e_mult_k_d_int_K1) - (signed(e_mult_k_d_int_K2) + signed(e_mult_k_d_int_K2_vz_Z1)));
  --u_d_add_int		<= std_logic_vector(signed(e_mult_k_d_int) - (signed(e_mult_k_d_int_vz)+signed(e_mult_k_d_int_vz)) + signed(e_mult_k_d_int_vz_2));
																--^2*                                                -
	
	
	-- verz�gertes(vz) Signal u_i_1_vz erzeugen
		-- ANTI WINDUP
	register_delay_u_i_1_process : process (clk_i, rst_i)
	begin
	if rst_i = '1' then
		u_i_1_int_vz	<= (others => '0');
	elsif clk_i'event and clk_i = '1' then	
		if u_i_1_int(intern_data_width - 1) = '1' then	
			-- �berlauf ins negative
			if use_negative_adc_input = '1' then
				u_i_1_int_vz													<= u_i_1_int;
				u_i_1_int_vz((int_data_width_after_dot - data_width) downto 0)	<= (others => '0');
			else
				u_i_1_int_vz					<= (others => '0');
			end if;	
		elsif u_i_1_int((intern_data_width - 2) downto int_data_width_after_dot) = zeroes then	
			-- KEIN �berlauf
			u_i_1_int_vz					<= u_i_1_int;
		else	
			-- �berlauf nach oben
			u_i_1_int_vz((intern_data_width - 1) downto int_data_width_after_dot)	<= (others => '0');				-- VZ positiv
			u_i_1_int_vz((int_data_width_after_dot - 1) downto 0)					<= (others => '1'); -- Maximalwert einstellen
		end if;
	end if;
	end process;
	
	
	
	-- verz�gertes Signal u_i_int_vz erzeugen
	register_delay_u_i_process : process (clk_i, rst_i)
	begin
	if rst_i = '1' then
		u_i_int		<= (others => '0');
	elsif clk_i'event and clk_i = '1' then	
		u_i_int		<= u_i_1_int;
	end if;
	end process;
	
	-- verz�gertes Signal u_d_add_int_vz erzeugen
	register_delay_u_d_process : process (clk_i, rst_i)
	begin
	if rst_i = '1' then
		u_d_add_int_vz		<= (others => '0');
	elsif clk_i'event and clk_i = '1' then	
		u_d_add_int_vz		<= u_d_add_int;
	end if;
	end process;

	-- Addition von e_mult_k_p_int und w_mult_k_v_int
	--u_p_v_int	<= std_logic_vector(signed(e_mult_k_p_int) + signed(w_mult_k_v_int));

	-- verz�gertes Signal u_p_v_vz erzeugen
	register_delay_u_p_v_process : process (clk_i, rst_i)
	begin
	if rst_i = '1' then
		u_p_v_int_vz		<= (others => '0');
	elsif clk_i'event and clk_i = '1' then	
		u_p_v_int_vz		<= u_p_v_int;
	end if;
	end process;
	
	-- Addition von u_p_v_int_vz und u_i_int und u_d_add_int_vz
	u_int	<= std_logic_vector(signed(u_i_int) + signed(u_p_v_int_vz) + signed(u_d_add_int_vz));
	
	-- �berlaufkontrolle am Ende
	register_u_process : process (clk_i, rst_i)
	begin
	if rst_i = '1' then
		u		<= (others => '0');
	elsif clk_i'event and clk_i = '1' then	
		if u_int(intern_data_width - 1) = '1' then	
			-- �berlauf ins negative
			if use_negative_adc_input = '1' then
				u(data_width - 1)				<= '1';				-- VZ negativ
				u((data_width - 2) downto 0)	<= u_int((int_data_width_after_dot - 1) downto (int_data_width_after_dot - (data_width - 1)));
			else
				u				<= (others => '0');
			end if;
		elsif u_int((intern_data_width - 2) downto int_data_width_after_dot) = zeroes then	
			-- KEIN �berlauf
			u(data_width - 1)				<= '0';				-- VZ positiv
			u((data_width - 2) downto 0)	<= u_int((int_data_width_after_dot - 1) downto (int_data_width_after_dot - (data_width - 1)));
		else	
			-- �berlauf nach oben
			u(data_width - 1)				<= '0';				-- VZ positiv
			u((data_width - 2) downto 0)	<= (others => '1'); -- Maximalwert einstellen
		end if;		
	end if;
	end process;
	
	data_u_o	<= u;	
  
end pid_controller_and_feed_forward_arch;

