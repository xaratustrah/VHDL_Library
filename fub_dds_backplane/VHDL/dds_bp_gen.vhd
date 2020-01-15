-- modified 2011/07/08 ct
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity dds_bp_gen is
	generic (
		data_width: integer := 8;
		adr_width: integer := 8;
		fc_width: integer := 8;
		bp_fc_width: integer := 8;
		init_rom_size: integer := 40
	);
	port (
		bp_data_o: out std_logic_vector(data_width-1 downto 0);
		bp_adr_o: out std_logic_vector(adr_width-1 downto 0);
		bp_newdata_o: out std_logic;
		bp_fc_o: out std_logic_vector(fc_width-1 downto 0);
		bp_fc_valid_o: out std_logic
	);
end entity dds_bp_gen;


architecture dds_bp_gen_arch of dds_bp_gen is
	type init_rom is array(0 to init_rom_size-1) of std_logic_vector(7 downto 0);
	constant init_data : init_rom := (
		"00000000", --00h phase adjust 1 (msb)
		"00000000", --01h phase adjust 1 (lsb)
		"00000000", --02h phase adjust 2 (msb)
		"00000000", --03h phase adjust 2 (lsb)
		-- ftw=2^32/fclk*f, fclk=20MHz,		f=1MHz  -> ftw=0CCCCCCC0000
		-- ftw=2^48/fclk*f, fclk=50MHz,		f=1MHz  -> ftw=051EB851EB85
		-- ftw=2^32/fclk*f, fclk=200MHz		f=1MHz -> ftw=0147AE140000
		X"01",		--04h frequency tuning word 1 (msb)
		X"47",		--05h frequency tuning word 1
		X"AE",		--06h frequency tuning word 1
		"00000000",	--07h frequency tuning word 1
		"00000000",	--08h frequency tuning word 1
		"00000000",	--09h frequency tuning word 1 (lsb)
		"00000000",	--0ah frequency tuning word 2 (msb)
		"00000000",	--0bh frequency tuning word 3
		"00000000",	--0ch frequency tuning word 4
		"00000000",	--0dh frequency tuning word 5
		"00000000",	--0eh frequency tuning word 6
		"00000000",	--0fh frequency tuning word 7 (lsb)
		"00000000",	--10h delta frequency word (msb)
		"00000000",	--11h delta frequency word
		"00000000",	--12h delta frequency word
		"00000000",	--13h delta frequency word
		"00000000",	--14h delta frequency word
		"00000000",	--15h delta frequency word (lsb)
		"00000000",	--16h update clock (msb)
		"00000000",	--17h update clock
		"00000000",	--18h update clock
		"01000000",	--19h update clock (lsb)
		"00000000",	--1ah ramp rate clock (msb)
		"00000000",	--1bh ramp rate clock
		"00000000",	--1ch ramp rate clock (lsb)
		"00000000",	--1dh Comp ON
		"00100000",	--1eh PLL-Bypass on
		"10000000",	--1fh External Update, mode 0
		"01000000",	--20h Bypass Inv Sinc
		"00000000",	--21h output shape key I mult (msb)
		"00000000",	--22h output shape key I mult (lsb)
		"00000000",	--23h output shape key Q mult (msb)
		"00000000",	--24h output shape key Q mult (lsb)
		"10000000",	--25h output shape key ramp rate
		"00000000",	--26h qdac (msb)
		"00000000"	--27h qdac (lsb)
	);

	signal count: integer := 0;
	type modes is (
		INIT_MODE,
		CTRL_REGISTER_MODE,
		RAMP_DATA_MODE
	);
--	signal mode: modes := INIT_MODE;
--	signal mode: modes := CTRL_REGISTER_MODE;
	signal mode: modes := RAMP_DATA_MODE;

begin

-- generate backplane signals
	P_backplane_gen: process is
	begin

		bp_fc_valid_o	<= '0';
		bp_newdata_o	<= '0';
		bp_data_o		<= (others => '0');
		bp_fc_o			<= (others => '0');
		bp_adr_o		<= X"80";

		wait for 100 ns;
		loop
		bp_fc_o <= conv_std_logic_vector(16#2d#, fc_width);

			case mode is
				when INIT_MODE =>
					wait for 2000 ns;
					if (count < init_rom_size) then
						bp_data_o <= init_data(count);
						bp_adr_o <= conv_std_logic_vector(count, adr_width);
						count <= count + 1;
					else
						bp_data_o <= conv_std_logic_vector(16#00#, data_width);
						bp_adr_o <= conv_std_logic_vector(16#80#, adr_width);
						mode <= CTRL_REGISTER_MODE;	--init complete
					end if;
					wait for 400 ns;
					bp_fc_valid_o <= '1';
					wait for 1000 ns;
					bp_fc_valid_o <= '0';
				when CTRL_REGISTER_MODE =>
					for i in 0 to 6 loop
						wait for 2000 ns;
						bp_data_o <= conv_std_logic_vector(16#00#, bp_data_o'length);
						case i rem 3 is
							when 0 => bp_adr_o <= conv_std_logic_vector(16#80#, bp_adr_o'length);
							when 1 => bp_adr_o <= conv_std_logic_vector(16#81#, bp_adr_o'length);
							when 2 => bp_adr_o <= conv_std_logic_vector(16#8A#, bp_adr_o'length);
							when others => null;
						end case;
						wait for 400 ns;
						bp_fc_valid_o <= '1';
						wait for 1000 ns;
						bp_fc_valid_o <= '0';
					end loop;
			--offset FTW:
					bp_data_o <= conv_std_logic_vector(16#12#, bp_data_o'length);
					bp_adr_o <= conv_std_logic_vector(16#94#, bp_adr_o'length);
					wait for 400 ns;
					bp_fc_valid_o <= '1';
					wait for 1000 ns;
					bp_fc_valid_o <= '0';
					
					bp_data_o <= conv_std_logic_vector(16#34#, bp_data_o'length);
					bp_adr_o <= conv_std_logic_vector(16#99#, bp_adr_o'length);
					wait for 400 ns;
					bp_fc_valid_o <= '1';
					wait for 1000 ns;
					bp_fc_valid_o <= '0';
			--burst trigger:
					bp_data_o <= conv_std_logic_vector(16#01#, bp_data_o'length);
					bp_adr_o <= conv_std_logic_vector(16#A0#, bp_adr_o'length);
					wait for 400 ns;
					bp_fc_valid_o <= '1';
					wait for 1000 ns;
					bp_fc_valid_o <= '0';
					bp_data_o <= conv_std_logic_vector(16#04#, bp_data_o'length);
					bp_adr_o <= conv_std_logic_vector(16#B0#, bp_adr_o'length);
					wait for 400 ns;
					bp_fc_valid_o <= '1';
					wait for 1000 ns;
					bp_fc_valid_o <= '0';
					mode <= RAMP_DATA_MODE;
				when RAMP_DATA_MODE =>
					wait for 2000 ns;
					for i in 0 to 3 loop
						case i is
							when 0 =>
								count <= count + 1;
								bp_data_o <= conv_std_logic_vector(count, data_width);
								bp_adr_o <= "00000100"; -- 4
							when 1 =>
								count <= count + 1;
								bp_data_o <= conv_std_logic_vector(count, data_width);
								bp_adr_o <= "00000101"; -- 5
							when 2 =>
								count <= count + 1;
								bp_data_o <= conv_std_logic_vector(count, data_width);
								bp_adr_o <= "00000110"; -- 6
							when 3 =>
								bp_adr_o <= "10000000";  -- 80 
						end case;
						wait for 84 ns;
						bp_newdata_o <= '1';
						wait for 84 ns;
						bp_newdata_o <= '0';
					end loop;
				when others => null;
			end case;
		end loop;
	end process P_backplane_gen;

end architecture dds_bp_gen_arch;