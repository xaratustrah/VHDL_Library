-------------------------------------------------------------------------------
--
-- M. Kumm
-- 
-- FUB interface to the "Netzgeräte"-backplane on which the DDS-Backplane protocoll is used 
-- (marked by the red interface card)
--
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity fub_dds_backplane is
	generic (
		data_width		: integer := 8;
		addr_width		: integer := 8;
		bp_fc_width		: integer := 8;
		init_fc			: integer := 16#B# --top 6 bits of adressed FC
	);
	port (
		clk_i					: in std_logic;
		rst_i					: in std_logic;
		-- Backplane signals
		bp_data_i				: in std_logic_vector(data_width-1 downto 0);
		bp_addr_i				: in std_logic_vector(addr_width-1 downto 0);
		bp_newdata_i			: in std_logic;
		bp_fc_i					: in std_logic_vector(bp_fc_width-1 downto 0);
		bp_fc_valid_i			: in std_logic;
		bp_fc_low_half_nibble_i	: in std_logic_vector(1 downto 0);
		-- FUB tx signals
		fub_data_o				: out std_logic_vector(data_width-1 downto 0);
		fub_addr_o				: out std_logic_vector(addr_width-1 downto 0);
		fub_strb_o				: out std_logic;
		fub_busy_i				: in std_logic;
		init_phase_o			: out std_logic -- '1': init phase; '0': newdata phase
	);
end entity fub_dds_backplane;

architecture fub_dds_backplane_arch of fub_dds_backplane is

	type states is (WAIT_STATE, SEND_STATE);
	signal state			: states;
	signal bp_fc_valid_prev	: std_logic;
	signal bp_newdata_prev	: std_logic;

begin

	process(clk_i, rst_i, bp_data_i, bp_addr_i, bp_newdata_i, bp_fc_i, bp_fc_valid_i, fub_busy_i,bp_fc_low_half_nibble_i)
		variable send: boolean;
		variable card_fc: std_logic_vector(bp_fc_width-1 downto 0);
	begin
 	 	if (rst_i = '1') then
			bp_fc_valid_prev	<= bp_fc_valid_i;
			bp_newdata_prev		<= bp_newdata_i;
			fub_data_o			<= (others => '0');
			fub_addr_o			<= (others => '0');
			fub_strb_o			<= '0';
			state				<= WAIT_STATE;
			init_phase_o		<= '0'; -- ?
			send				:= false;
		elsif rising_edge(clk_i) then
			bp_fc_valid_prev	<= bp_fc_valid_i;
			bp_newdata_prev		<= bp_newdata_i;
			case state is
				when WAIT_STATE =>
					send				:= false;
					card_fc(7 downto 2)	:= conv_std_logic_vector(init_fc,6);
					card_fc(1 downto 0)	:= bp_fc_low_half_nibble_i; -- 	bp_fc_low_half_nibble <= "01"; --static setting without backplane configuration (lower half nibble of "2d")
					if (bp_fc_valid_i = '1' and bp_fc_valid_prev = '0' and bp_fc_i = card_fc) then
						send			:= true;
						init_phase_o	<= '1';
					elsif (bp_newdata_i = '1' and bp_newdata_prev = '0') then
						send			:= true;
						init_phase_o	<= '0'; -- not used
					end if;
					if (send = true) then
						if (fub_busy_i = '0') then
							send		:= false;
							fub_data_o	<= bp_data_i;
							fub_addr_o	<= bp_addr_i;
							fub_strb_o	<= '1';
							state		<= SEND_STATE;
						end if;
					end if;
				when SEND_STATE =>
					state		<= WAIT_STATE;
					fub_strb_o	<= '0';
			end case; 
		end if;
	end process;

end architecture fub_dds_backplane_arch;