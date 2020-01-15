-------------------------------------------------------------------------------
--
-- Backplane to FPGA Universal Bus interface
--
-- Synchronizes the Backplane parallel data, ensures that there are no instable
-- states and converts the parallel data to fub data for transmition
--
-------------------------------------------------------------------------------

-- Package Definition

library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.all;
use ieee.std_logic_unsigned.all;
use work.parallel_to_fub_pkg.all;

package fub_ng_backplane_pkg is
	
	component fub_ng_backplane
		port(
			rst_i		:	in	std_logic;
			clk_i		:	in	std_logic;
			par_data_i	:	in	std_logic_vector(23 downto 0);
			par_adr_i	:	in	std_logic_vector(5 downto 0);
			fub_busy_i	:	in	std_logic;
			data_o		:	out	std_logic_vector(23 downto 0);	-- synchronized parallel data output
			fub_data_o	:	out	std_logic_vector(7 downto 0);
			set_o		:	out	std_logic;
			par_busy_o	:	out std_logic;
			fub_adr_o	:	out std_logic_vector(1 downto 0);
			fub_str_o	:	out std_logic
		);
	end component;
	
end fub_ng_backplane_pkg;

package body fub_ng_backplane_pkg is
end fub_ng_backplane_pkg;

-- Entity Definition

library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.all;
use ieee.std_logic_unsigned.all;
use work.parallel_to_fub_pkg.all;

entity fub_ng_backplane is
	port(
		rst_i		:	in	std_logic;
		clk_i		:	in	std_logic;
		par_data_i	:	in	std_logic_vector(23 downto 0);
		par_adr_i	:	in	std_logic_vector(5 downto 0);
		fub_busy_i	:	in	std_logic;
		data_o		:	out	std_logic_vector(23 downto 0);
		fub_data_o	:	out	std_logic_vector(7 downto 0);
		set_o		:	out	std_logic;
		par_busy_o	:	out std_logic;
		fub_adr_o	:	out std_logic_vector(1 downto 0);
		fub_str_o	:	out std_logic
	);
end fub_ng_backplane;

architecture beh_arch of fub_ng_backplane is
	signal store_1	:	std_logic_vector(23 downto 0);
	signal store_2	:	std_logic_vector(23 downto 0);
	signal store_3	:	std_logic_vector(23 downto 0);
	signal store_4	:	std_logic_vector(23 downto 0);
	signal par_data	:	std_logic_vector(23 downto 0);
	signal strobe	:	std_logic;
	signal par_busy	:	std_logic;
	signal send_flag:	std_logic;
	
	begin
		
		shift	:	process(clk_i, rst_i)
		begin
			if rst_i = '1' then
				store_1		<= ( others => '0');
				store_2		<= ( others => '0');
				store_3		<= ( others => '0');
				store_4		<= ( others => '0');
				send_flag	<= '0';
				strobe 	<= '0';
				par_data	<= ( others => '0');
			elsif clk_i'event and clk_i = '1' then
				store_4 <= store_3;
				store_3 <= store_2;
				store_2 <= store_1;
				store_1 <= par_data_i;
				strobe 	<= '0';
				if store_4 = store_3 and store_4 = store_2 and store_4 = store_1 then
					if par_busy = '0' and send_flag = '0' then
						strobe <= '1';
						par_data <= store_4;
						send_flag <= '1';
					end if;
				else
					send_flag <= '0';
				end if;
			end if;
		end process shift;
		
		parallel_to_fub_inst	:	parallel_to_fub
		generic map(
			no_of_data_bytes	=>	3,
			adr_width			=>	2
		)
		port map(
			rst_i      =>	rst_i,
			clk_i      =>	clk_i,
			par_data_i =>	par_data,
			par_adr_i  =>	par_adr_i,
			par_str_i  =>	strobe,
			par_busy_o =>	par_busy,
			fub_data_o =>	fub_data_o,
			fub_adr_o  =>	fub_adr_o,
			fub_str_o  =>	fub_str_o,
			fub_busy_i =>	fub_busy_i
		);
		
		set_o		<=	strobe;
		data_o		<=	par_data;
		par_busy_o	<=	par_busy;

end beh_arch;