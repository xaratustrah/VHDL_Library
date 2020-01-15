-------------------------------------------------------------------------------
--
-- Interface for the modul-bus.
-- S. Sanjari
--
-- 2010/05/25 ct: added architecture for 16 bit fub
-------------------------------------------------------------------------------

-- Package Definition

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.numeric_std.all;

package fub_modulbus_pkg is

  component fub_modulbus
    generic (
      clk_freq_in_hz    : real;
      led_on_time_in_ms : real;
      mb_id             : integer;
      mb_version        : std_logic_vector (7 downto 0);
      fub_addr_width    : integer;
      fub_data_width    : integer);
    port (
      rst_i                : in    std_logic;
      clk_i                : in    std_logic;
      fub_str_o            : out   std_logic;
      fub_busy_i           : in    std_logic;
      fub_addr_o           : out   std_logic_vector (fub_addr_width-1 downto 0);
      fub_data_o           : out   std_logic_vector (fub_data_width-1 downto 0);
      mb_RdnWr             : in    std_logic;
      mb_nDs               : in    std_logic;
      mb_nReset            : in    std_logic;
      mb_Mod_Adr           : in    std_logic_vector (4 downto 0);
      mb_Mod_Data          : inout std_logic_vector (7 downto 0);
      mb_Sub_Adr           : in    std_logic_vector (7 downto 0);
      mb_Vmod_Adr          : in    std_logic_vector(4 downto 0);
      mb_Vmod_ID           : in    std_logic_vector(7 downto 0);
      mb_Vmod_SK           : in    std_logic_vector (7 downto 0);
      mb_n_Ext_Data_Bus_EN : out   std_logic;
      mb_nDtAck            : out   std_logic;
      mb_nInterlock        : out   std_logic;
      mb_nID_OK_LED        : out   std_logic;
      mb_nDt_LED           : out   std_logic;
      mb_nSel_LED          : out   std_logic;
      mb_PowerUp_Reset_LED : out   std_logic);
  end component;

end fub_modulbus_pkg;

package body fub_modulbus_pkg is
end fub_modulbus_pkg;

-- Entity Definition

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.numeric_std.all;

use work.clk_detector_pkg.all;

--use work.parallel_to_fub_pkg.all;

entity fub_modulbus is
  
  generic (

    -- Modul Bus Generics
    clk_freq_in_hz    : real                          := 50.0E6;
    led_on_time_in_ms : real                          := 50.0;
    mb_id             : integer                       := 16#55#;
    mb_version        : std_logic_vector (7 downto 0) := "00000000";

    -- FUB Generics
    fub_addr_width : integer := 8;
    fub_data_width : integer := 8
    );

  port (
    -- FUB Interface
    rst_i      : in  std_logic;
    clk_i      : in  std_logic;
    fub_str_o  : out std_logic;
    fub_busy_i : in  std_logic;
    fub_addr_o : out std_logic_vector (fub_addr_width-1 downto 0);
    fub_data_o : out std_logic_vector (fub_data_width-1 downto 0);

    -- Backplane Signals

    mb_RdnWr    : in    std_logic;
    mb_nDs      : in    std_logic;
    mb_nReset   : in    std_logic;
    mb_Mod_Adr  : in    std_logic_vector (4 downto 0);
    mb_Mod_Data : inout std_logic_vector (7 downto 0);

    mb_Sub_Adr  : in std_logic_vector (7 downto 0);
    mb_Vmod_Adr : in std_logic_vector(4 downto 0);
    mb_Vmod_ID  : in std_logic_vector(7 downto 0);
    mb_Vmod_SK  : in std_logic_vector (7 downto 0);

    mb_n_Ext_Data_Bus_EN : out std_logic;
    mb_nDtAck            : out std_logic;
    mb_nInterlock        : out std_logic;

    mb_nID_OK_LED        : out std_logic;
    mb_nDt_LED           : out std_logic;
    mb_nSel_LED          : out std_logic;
    mb_PowerUp_Reset_LED : out std_logic
    );

end entity fub_modulbus;

architecture fub_modulbus_arch of fub_modulbus is

  component modulbus_v6
    generic (
      St_160_pol      : integer;
      Mod_Id          : integer;
      CLK_in_Hz       : integer;
      Loader_Base_Adr : integer;
      Res_Deb_in_ns   : integer;
      nDS_Deb_in_ns   : integer;
      Use_LPM         : integer;
      Test            : integer);
    port (
      Epld_Vers       : in    std_logic_vector(7 downto 0);
      VG_Mod_Id       : in    std_logic_vector(7 downto 0);
      VG_Mod_Adr      : in    std_logic_vector(4 downto 0);
      VG_Mod_Skal     : in    std_logic_vector(7 downto 0);
      St_160_Skal     : in    std_logic_vector(7 downto 0);
      St_160_Auxi     : in    std_logic_vector(5 downto 0);
      Stat_IN         : in    std_logic_vector(7 downto 2);
      Macro_Activ     : in    std_logic;
      Macro_Skal_OK   : in    std_logic;
      Mod_Adr         : in    std_logic_vector(4 downto 0);
      Sub_Adr         : in    std_logic_vector(7 downto 0);
      RDnWR           : in    std_logic;
      nDS             : in    std_logic;
      CLK             : in    std_logic;
      nMB_Reset       : in    std_logic;
      V_Data_Rd       : in    std_logic_vector(15 downto 0);
      nExt_Data_En    : out   std_logic;
      Mod_Data        : inout std_logic_vector(7 downto 0);
      nDt_Mod_Bus     : out   std_logic;
      Sub_Adr_La      : out   std_logic_vector(7 downto 1);
      Data_Wr_La      : out   std_logic_vector(15 downto 0);
      Extern_Wr_Activ : out   std_logic;
      Extern_Wr_Fin   : out   std_logic;
      Extern_Rd_Activ : out   std_logic;
      Extern_Rd_Fin   : out   std_logic;
      Extern_Dtack    : in    std_logic;
      Powerup_Res     : out   std_logic;
      nInterlock      : out   std_logic;
      Timeout         : out   std_logic;
      Id_OK           : out   std_logic;
      nID_OK_Led      : out   std_logic;
      Led_Ena         : out   std_logic;
      nPower_Up_Led   : out   std_logic;
      nSel_Led        : out   std_logic;
      nDt_Led         : out   std_logic);
  end component;

  --internal signals for modulbus
  signal mbint_data_in       : std_logic_vector(15 downto 0);
  signal mbint_data_out      : std_logic_vector(15 downto 0);
  signal mbint_adr_out       : std_logic_vector(6 downto 0);  --only 7 bit, bit0 from subadr selects the high/low byte
  signal mbint_data_in_act   : std_logic;
  signal mbint_data_out_act  : std_logic;
  signal mbint_data_ack      : std_logic;
  signal mbint_id_ok         : std_logic;
  signal mbint_PowerUp_Reset : std_logic;
  signal mbint_address_comp  : std_logic;
  signal mbint_select        : std_logic;

  signal mbint_led_ena : std_logic;

--  -- Parallel to FUB interface signale
  constant no_of_data_bytes : integer := 2;
  constant adr_width        : integer := 8;
  constant count_max 		: integer := 1;			-- (S.Schäfer) Bugfix due to timing problems

  constant clk_freq_in_hz_integer : integer := integer (clk_freq_in_hz);

  type par_data_array_type is array(0 to no_of_data_bytes-1) of
    std_logic_vector(7 downto 0);
  signal par_data_array : par_data_array_type;
  signal par_data       : std_logic_vector(no_of_data_bytes*8-1 downto 0);

  type par_adr_array_type is array(0 to no_of_data_bytes-1) of
    std_logic_vector(adr_width-1 downto 0);
  signal par_adr_array : par_adr_array_type;
  signal par_adr       : std_logic_vector(no_of_data_bytes*adr_width-1 downto 0);

  signal par_str  : std_logic;
  signal par_busy : std_logic;

  signal rst : std_logic;

  signal opn_drn_mb_nID_OK_LED : std_logic;
  signal opn_drn_mb_nDt_LED    : std_logic;
  signal opn_drn_mb_nSel_LED   : std_logic;

  type state_type is (SEND_LOW_BYTE, SEND_HIGH_BYTE, WAIT_FOR_ACK);
  signal state : state_type;
  
  signal count 					: integer; -- (S.Schäfer) Bugfix due to timing problems
  
begin  -- fub_modulbus_arch

  rst <= rst_i or not mb_nReset;

  modulbus_v6_inst : modulbus_v6
    generic map (
      CLK_in_Hz       => clk_freq_in_hz_integer,
      Loader_Base_Adr => 0,
      Mod_Id          => mb_id,
      nDS_Deb_in_ns   => 20,
      Res_Deb_in_ns   => 100,
      St_160_pol      => 0,
      Test            => 0,
      Use_LPM         => 0
      )
    port map (
      Macro_Activ   => '1',
      Macro_Skal_OK => '1',
      RDnWR         => mb_RdnWr,
      nDS           => mb_nDs,
      CLK           => clk_i,
      nMB_Reset     => mb_nReset,
      Extern_Dtack  => mbint_data_ack,
      Epld_Vers     => mb_version,
      Mod_Adr       => mb_Mod_Adr,

      Mod_Data => mb_Mod_Data,

      St_160_Skal     => (others => '0'),
      St_160_Auxi     => (others => '0'),
      Stat_IN         => (others => '0'),
      Sub_Adr         => mb_Sub_Adr,
      V_Data_Rd       => mbint_data_in,
      VG_Mod_Adr      => mb_Vmod_Adr,
      VG_Mod_Id       => mb_Vmod_ID,
      VG_Mod_Skal     => mb_Vmod_SK,
      nExt_Data_En    => mb_n_Ext_Data_Bus_EN,
      nDt_Mod_Bus     => mb_nDtAck,
      Extern_Wr_Activ => mbint_data_out_act,
      Extern_Wr_Fin   => open,
      Extern_Rd_Activ => mbint_data_in_act,
      Extern_Rd_Fin   => open,
      Powerup_Res     => mbint_PowerUp_Reset,
      nInterlock      => mb_nInterlock,
      Id_OK           => mbint_id_ok,
      nID_OK_Led      => open,          -- open drain LED
      Led_Ena         => mbint_led_ena,
      nPower_Up_Led   => open,
      nDt_Led         => open,          -- open drain LED
      Data_Wr_La      => mbint_data_out,
      Sub_Adr_La      => mbint_adr_out,
      Timeout         => open,
      nSel_Led        => open           -- open drain LED
      );

  mb_nID_OK_LED        <= mbint_id_ok;
  mb_PowerUp_Reset_LED <= not mbint_PowerUp_Reset;

  clk_detector_inst2 : clk_detector
    generic map (
      clk_freq_in_hz       => clk_freq_in_hz,
      output_on_time_in_ms => led_on_time_in_ms)
    port map (
      clk_i => clk_i,
      rst_i => rst,
      x_i   => mbint_data_ack,
      x_o   => mb_nDt_LED);

--  clk_detector_inst4 : clk_detector
--    generic map (
--      clk_freq_in_hz       => clk_freq_in_hz,
--      output_on_time_in_ms => led_on_time_in_ms)
--    port map (
--      clk_i => clk_i,
--      rst_i => rst,
--      x_i   => mbint_select,
--      x_o   => mb_nSel_LED);

  mb_nSel_LED <= mbint_select;
  
  array_to_parallel_gen : for i in 0 to no_of_data_bytes-1 generate
    par_data((i+1)*8-1 downto i*8)                <= par_data_array(i);
    par_adr((i+1)*adr_width-1 downto i*adr_width) <= par_adr_array(i);
  end generate;

  par_data_array (1) <= mbint_data_out (15 downto 8);
  par_data_array (0) <= mbint_data_out (7 downto 0);

  par_adr_array (1) (7 downto 1) <= mbint_adr_out (6 downto 0);
  par_adr_array (1) (0)          <= '1';

  par_adr_array (0) (7 downto 1) <= mbint_adr_out (6 downto 0);
  par_adr_array (0) (0)          <= '0';

  -- Data Ack signal muss betaetigt werden.

  mbint_data_ack <= mbint_data_in_act or mbint_data_out_act;

  -- Was rein geht is erstmal egal. Dieses Signal wird bei der zukuenftign Erweiterung benutzt.
  mbint_data_in <= x"abcd";

  -- Address Comparator
  mbint_address_comp <= '1' when mb_Vmod_Adr (4 downto 0) = mb_Mod_Adr (4 downto 0) else '0';

	p_main : process (clk_i, rst)
	begin  -- process p_main
		if rst = '1' then                   -- asynchronous reset (active high)

			fub_str_o  <= '0';
			fub_addr_o <= (others => '0');
			fub_data_o <= (others => '0');

			state <= SEND_LOW_BYTE;
			count <= 0; -- (S.Schäfer) Bugfix due to timing problems

		elsif rising_edge(clk_i) then
			if mbint_address_comp = '1' and mb_nDs = '1' then
				mbint_select <= '1';
			else
				mbint_select <= '0';
			end if;
			if count = 0 then						-- (S.Schäfer) Bugfix due to timing problems
				case state is
				when SEND_LOW_BYTE =>
					if mbint_data_out_act = '1' then
						if fub_busy_i = '0' then
							fub_str_o  <= '1';
							fub_addr_o <= par_adr_array (0);
							fub_data_o <= par_data_array (0);
							count <= count_max -1;	-- (S.Schäfer) Bugfix due to timing problems				  
							state      <= SEND_HIGH_BYTE;
						end if;
					end if;

				when SEND_HIGH_BYTE =>
					if fub_busy_i = '0' then
					fub_str_o  <= '1';
					fub_addr_o <= par_adr_array (1);
					fub_data_o <= par_data_array (1);
					state      <= WAIT_FOR_ACK;
					end if;

				when WAIT_FOR_ACK =>
					if fub_busy_i = '0' then
						fub_str_o <= '0';
						if mbint_data_out_act = '0' then
							state <= SEND_LOW_BYTE;
						end if;
					end if;

				when others => null;
				end case;
			else								-- (S.Schäfer) Bugfix due to timing problems
				count <= count - 1;				-- (S.Schäfer) Bugfix due to timing problems
				fub_str_o  <= '0';				-- (S.Schäfer) Bugfix due to timing problems
			end if;								-- (S.Schäfer) Bugfix due to timing problems  
		end if;
	end process p_main;

end fub_modulbus_arch;

architecture fub_modulbus16bit_arch of fub_modulbus is

  component modulbus_v6
    generic (
      St_160_pol      : integer;
      Mod_Id          : integer;
      CLK_in_Hz       : integer;
      Loader_Base_Adr : integer;
      Res_Deb_in_ns   : integer;
      nDS_Deb_in_ns   : integer;
      Use_LPM         : integer;
      Test            : integer);
    port (
      Epld_Vers       : in    std_logic_vector(7 downto 0);
      VG_Mod_Id       : in    std_logic_vector(7 downto 0);
      VG_Mod_Adr      : in    std_logic_vector(4 downto 0);
      VG_Mod_Skal     : in    std_logic_vector(7 downto 0);
      St_160_Skal     : in    std_logic_vector(7 downto 0);
      St_160_Auxi     : in    std_logic_vector(5 downto 0);
      Stat_IN         : in    std_logic_vector(7 downto 2);
      Macro_Activ     : in    std_logic;
      Macro_Skal_OK   : in    std_logic;
      Mod_Adr         : in    std_logic_vector(4 downto 0);
      Sub_Adr         : in    std_logic_vector(7 downto 0);
      RDnWR           : in    std_logic;
      nDS             : in    std_logic;
      CLK             : in    std_logic;
      nMB_Reset       : in    std_logic;
      V_Data_Rd       : in    std_logic_vector(15 downto 0);
      nExt_Data_En    : out   std_logic;
      Mod_Data        : inout std_logic_vector(7 downto 0);
      nDt_Mod_Bus     : out   std_logic;
      Sub_Adr_La      : out   std_logic_vector(7 downto 1);
      Data_Wr_La      : out   std_logic_vector(15 downto 0);
      Extern_Wr_Activ : out   std_logic;
      Extern_Wr_Fin   : out   std_logic;
      Extern_Rd_Activ : out   std_logic;
      Extern_Rd_Fin   : out   std_logic;
      Extern_Dtack    : in    std_logic;
      Powerup_Res     : out   std_logic;
      nInterlock      : out   std_logic;
      Timeout         : out   std_logic;
      Id_OK           : out   std_logic;
      nID_OK_Led      : out   std_logic;
      Led_Ena         : out   std_logic;
      nPower_Up_Led   : out   std_logic;
      nSel_Led        : out   std_logic;
      nDt_Led         : out   std_logic);
  end component;

--internal signals for modulbus
	signal mbint_data_in       : std_logic_vector(15 downto 0);
	signal mbint_data_out      : std_logic_vector(15 downto 0);
	signal mbint_adr_out       : std_logic_vector(6 downto 0);  --only 7 bit, bit0 from subadr selects the high/low byte
	signal mbint_data_in_act   : std_logic;
	signal mbint_data_out_act  : std_logic;
	signal mbint_data_ack      : std_logic;
	signal mbint_id_ok         : std_logic;
	signal mbint_PowerUp_Reset : std_logic;
	signal mbint_address_comp  : std_logic;
	signal mbint_select        : std_logic;

	signal mbint_led_ena : std_logic;

--  -- Parallel to FUB interface signale
	-- constant no_of_data_bytes		: integer := 2;
	-- constant adr_width				: integer := 8;
	-- constant count_max 				: integer := 1;			-- (S.Schäfer) Bugfix due to timing problems

	constant clk_freq_in_hz_integer	: integer := integer (clk_freq_in_hz);

	-- type par_data_array_type is array(0 to no_of_data_bytes-1) of std_logic_vector(7 downto 0);
	-- signal par_data_array : par_data_array_type;
	-- signal par_data       : std_logic_vector(no_of_data_bytes*8-1 downto 0);

	-- type par_adr_array_type is array(0 to no_of_data_bytes-1) of std_logic_vector(adr_width-1 downto 0);
	-- signal par_adr_array : par_adr_array_type;
	-- signal par_adr       : std_logic_vector(no_of_data_bytes*adr_width-1 downto 0);

	-- signal par_str  : std_logic;
	-- signal par_busy : std_logic;

	signal rst : std_logic;

	signal opn_drn_mb_nID_OK_LED : std_logic;
	signal opn_drn_mb_nDt_LED    : std_logic;
	signal opn_drn_mb_nSel_LED   : std_logic;

	type state_type is (SEND_DATA, WAIT_STATE1, WAIT_FOR_ACK);
	signal state : state_type;

--	signal count 					: integer; -- (S.Schäfer) Bugfix due to timing problems

begin  -- fub_modulbus_arch

	rst <= rst_i or not mb_nReset;

	modulbus_v6_inst : modulbus_v6
	generic map (
		CLK_in_Hz		=> clk_freq_in_hz_integer,
		Loader_Base_Adr	=> 0,
		Mod_Id			=> mb_id,
		nDS_Deb_in_ns	=> 20,
		Res_Deb_in_ns	=> 100,
		St_160_pol		=> 0,
		Test			=> 0,
		Use_LPM			=> 0
		)
	port map (
		Macro_Activ		=> '1',
		Macro_Skal_OK	=> '1',
		RDnWR			=> mb_RdnWr,
		nDS				=> mb_nDs,
		CLK				=> clk_i,
		nMB_Reset		=> mb_nReset,
		Extern_Dtack	=> mbint_data_ack,
		Epld_Vers		=> mb_version,
		Mod_Adr			=> mb_Mod_Adr,

		Mod_Data		=> mb_Mod_Data,

		St_160_Skal		=> (others => '0'),
		St_160_Auxi		=> (others => '0'),
		Stat_IN			=> (others => '0'),
		Sub_Adr			=> mb_Sub_Adr,
		V_Data_Rd		=> mbint_data_in,		-- data to modlbus
		VG_Mod_Adr		=> mb_Vmod_Adr,
		VG_Mod_Id		=> mb_Vmod_ID,
		VG_Mod_Skal		=> mb_Vmod_SK,
		nExt_Data_En	=> mb_n_Ext_Data_Bus_EN,
		nDt_Mod_Bus		=> mb_nDtAck,
		Extern_Wr_Activ	=> mbint_data_out_act,
		Extern_Wr_Fin	=> open,
		Extern_Rd_Activ	=> mbint_data_in_act,
		Extern_Rd_Fin	=> open,
		Powerup_Res		=> mbint_PowerUp_Reset,
		nInterlock		=> mb_nInterlock,
		Id_OK			=> mbint_id_ok,
		nID_OK_Led		=> open,          -- open drain LED
		Led_Ena			=> mbint_led_ena,
		nPower_Up_Led	=> open,
		nDt_Led			=> open,          -- open drain LED
		Data_Wr_La		=> mbint_data_out,		-- data from modulbus
		Sub_Adr_La		=> mbint_adr_out,		-- addr from modulbus
		Timeout			=> open,
		nSel_Led		=> open           -- open drain LED
		);

  mb_nID_OK_LED        <= mbint_id_ok;
  mb_PowerUp_Reset_LED <= not mbint_PowerUp_Reset;

  clk_detector_inst2 : clk_detector
    generic map (
      clk_freq_in_hz       => clk_freq_in_hz,
      output_on_time_in_ms => led_on_time_in_ms)
    port map (
      clk_i => clk_i,
      rst_i => rst,
      x_i   => mbint_data_ack,
      x_o   => mb_nDt_LED);

--  clk_detector_inst4 : clk_detector
--    generic map (
--      clk_freq_in_hz       => clk_freq_in_hz,
--      output_on_time_in_ms => led_on_time_in_ms)
--    port map (
--      clk_i => clk_i,
--      rst_i => rst,
--      x_i   => mbint_select,
--      x_o   => mb_nSel_LED);

  mb_nSel_LED <= mbint_select;
  
  -- array_to_parallel_gen : for i in 0 to no_of_data_bytes-1 generate
    -- par_data((i+1)*8-1 downto i*8)                <= par_data_array(i);
    -- par_adr((i+1)*adr_width-1 downto i*adr_width) <= par_adr_array(i);
  -- end generate;

  -- par_data_array (1) <= mbint_data_out (15 downto 8);
  -- par_data_array (0) <= mbint_data_out (7 downto 0);

  -- par_adr_array (1) (7 downto 1) <= mbint_adr_out (6 downto 0);
  -- par_adr_array (1) (0)          <= '1';

  -- par_adr_array (0) (7 downto 1) <= mbint_adr_out (6 downto 0);
  -- par_adr_array (0) (0)          <= '0';

  -- Data Ack signal muss betaetigt werden.

  mbint_data_ack <= mbint_data_in_act or mbint_data_out_act;

  -- data to modulbus will be processed in a later version...
  mbint_data_in <= x"abcd";

  -- Address Comparator
  mbint_address_comp <= '1' when mb_Vmod_Adr (4 downto 0) = mb_Mod_Adr (4 downto 0) else '0';

	p_main : process (clk_i, rst)
	begin  -- process p_main
		if rst = '1' then                   -- asynchronous reset (active high)

			fub_str_o  <= '0';
			fub_addr_o <= (others => '0');
			fub_data_o <= (others => '0');

			state <= SEND_DATA;
--			count <= 0; -- (S.Schäfer) Bugfix due to timing problems

		elsif rising_edge(clk_i) then
			if mbint_address_comp = '1' and mb_nDs = '1' then
				mbint_select <= '1';
			else
				mbint_select <= '0';
			end if;
--			if count = 0 then						-- (S.Schäfer) Bugfix due to timing problems
				case state is
				when SEND_DATA =>
					if mbint_data_out_act = '1' then
						if fub_busy_i = '0' then
							fub_str_o  <= '1';
							fub_addr_o <= mbint_adr_out & '0';
							fub_data_o <= mbint_data_out;
--							count <= count_max -1;	-- (S.Schäfer) Bugfix due to timing problems				  
							state      <= WAIT_STATE1;
						end if;
					end if;

				when WAIT_STATE1 =>
					state	<= WAIT_FOR_ACK;

				when WAIT_FOR_ACK =>
					if fub_busy_i = '0' then
						fub_str_o <= '0';
						if mbint_data_out_act = '0' then
							state <= SEND_DATA;
						end if;
					end if;

				when others => null;
				end case;
--			else								-- (S.Schäfer) Bugfix due to timing problems
--				count <= count - 1;				-- (S.Schäfer) Bugfix due to timing problems
--				fub_str_o  <= '0';				-- (S.Schäfer) Bugfix due to timing problems
--			end if;								-- (S.Schäfer) Bugfix due to timing problems  
		end if;
	end process p_main;

end architecture fub_modulbus16bit_arch;
