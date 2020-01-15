-------------------------------------------------------------------------------
--
-- Multi SPI Master Component. S. Sanjari
-- Extended for flash by T.Wollmann
-- 
-- Based on a Version of SPI Master component by M. Kumm
-- Inspired by: O. Bitterling
--
-------------------------------------------------------------------------------

-- Package Definition

library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_unsigned.all;
use ieee.math_real.all;

package fub_multi_spi_master_pkg is

  component fub_multi_spi_master
    generic (
      clk_freq_in_hz        : real;
      spi_clk_perid_in_ns   : real;
      spi_setup_delay_in_ns : real;
      slave0_byte_count     : integer;
      slave1_byte_count     : integer;
      slave2_byte_count     : integer;
      slave3_byte_count     : integer;
      slave4_byte_count     : integer;
      slave5_byte_count     : integer;
      slave6_byte_count     : integer;
      slave7_byte_count     : integer;
      slave8_byte_count     : integer;
			data_width            : integer;
			-- max. flash byte count
			slave9_byte_count 		: integer

		);
    port (
      clk_i       			: in  std_logic;
      rst_i       			: in  std_logic;
			flash_byte_count_i:	in	integer;
			read_flag_i				:	in	std_logic;
      fub_str_i   			: in  std_logic;
      fub_busy_o  			: out std_logic;
      fub_data_i  			: in  std_logic_vector(7 downto 0);
      fub_addr_i  			: in  std_logic_vector(integer(ceil(log2(real(slave0_byte_count + slave1_byte_count + slave2_byte_count + slave3_byte_count + slave4_byte_count + slave5_byte_count + slave6_byte_count + slave7_byte_count + slave8_byte_count + slave9_byte_count)))) - 1 downto 0);
      fub_error_o 			: out std_logic;
      fub_str_o   			: out std_logic;
      fub_busy_i  			: in  std_logic;
      fub_data_o  			: out std_logic_vector(7 downto 0);
      spi_mosi_o  			: out std_logic;
      spi_miso_i  			: in  std_logic;
      spi_clk_o   			: out std_logic;
      spi_ss_o    			: out std_logic_vector (9 downto 0)
		);
  end component;

end fub_multi_spi_master_pkg;
package body fub_multi_spi_master_pkg is

end fub_multi_spi_master_pkg;

-- Entity Definition


library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_arith.all;
use IEEE.STD_LOGIC_unsigned.all;
use ieee.math_real.all;

use work.real_time_calculator_pkg.all;

entity fub_multi_spi_master is
  generic (
    clk_freq_in_hz        : real := 50.0e6;
    spi_clk_perid_in_ns   : real := 1000.0;
    spi_setup_delay_in_ns : real := 1000.0;

    slave0_byte_count : integer := 3;
    slave1_byte_count : integer := 1;
    slave2_byte_count : integer := 1;
    slave3_byte_count : integer := 0;
    slave4_byte_count : integer := 0;
    slave5_byte_count : integer := 0;
    slave6_byte_count : integer := 0;
    slave7_byte_count : integer := 0;
    slave8_byte_count : integer := 0;
    data_width 				: integer := 8;
		-- max. flash byte count
		slave9_byte_count : integer := 10
    );

  port (
    clk_i      				: in  std_logic;
    rst_i      				: in  std_logic;
		flash_byte_count_i:	in	integer;
		read_flag_i				:	in	std_logic;
    fub_str_i  				: in  std_logic;
    fub_busy_o 				: out std_logic;
    fub_data_i 				: in  std_logic_vector(7 downto 0);
		
    fub_addr_i  			: in  std_logic_vector(integer(ceil(log2(real(slave0_byte_count + slave1_byte_count + slave2_byte_count + slave3_byte_count + slave4_byte_count + slave5_byte_count + slave6_byte_count + slave7_byte_count + slave8_byte_count + slave9_byte_count)))) - 1 downto 0);
    fub_error_o 			: out std_logic;
    fub_str_o   			: out std_logic;
    fub_busy_i  			: in  std_logic;
    fub_data_o  			: out std_logic_vector(7 downto 0);

    spi_mosi_o 				: out std_logic;
    spi_miso_i 				: in  std_logic;
    spi_clk_o  				: out std_logic;
    spi_ss_o   				: out std_logic_vector (9 downto 0));

end fub_multi_spi_master;

architecture fub_multi_spi_master_arch of fub_multi_spi_master is

  constant number_of_required_bits : integer := integer(ceil(log2(real(slave0_byte_count + slave1_byte_count + slave2_byte_count + slave3_byte_count + slave4_byte_count + slave5_byte_count + slave6_byte_count + slave7_byte_count + slave8_byte_count + slave9_byte_count))));

  signal spi_clks           : integer := get_delay_in_ticks_round (clk_freq_in_hz, spi_clk_perid_in_ns);
  constant setup_clks         : integer := get_delay_in_ticks_round (clk_freq_in_hz, spi_setup_delay_in_ns);
  signal addr_cnt           : integer range 0 to 2**number_of_required_bits - 1;
  signal fub_addr           : integer;
  signal wait_for_more_flag : std_logic;
  signal data_tx            : std_logic_vector (7 downto 0);
  signal data_rx            : std_logic_vector (7 downto 0);
  signal cnt                : integer range 0 to setup_clks - 1 := setup_clks - 1;
  signal data_cnt           : integer range 0 to 7 := 7;
	-- signal flash_byte_count		:	integer;

  type states is (WAIT_FOR_STR, WAIT_SETUP_TIME, SEND_RX_DATA, WAIT_HALF_CLK_PERIOD);
  signal state : states;

  signal spi_clk : std_logic;
	
	signal dummy	:	std_logic;
	

begin  -- fub_multi_spi_master_arch

  spi_clk_o <= spi_clk;

  fub_addr <= conv_integer(fub_addr_i);

  main_p : process (clk_i, rst_i)
  begin  -- process main_p

    if rst_i = '1' then
      fub_busy_o         <= '0';
      spi_clk            <= '0';
      spi_mosi_o         <= '0';
      spi_ss_o           <= (others => '1');
      fub_data_o         <= (others => '0');
      fub_busy_o         <= '0';
      fub_str_o          <= '0';
      data_cnt           <= 7;
      fub_error_o        <= '0';
      wait_for_more_flag <= '0';
			dummy							<=	'0';
			data_rx						<=	(others => '0');
      state              <= WAIT_FOR_STR;
			-- flash_byte_count	<=	0;
    elsif clk_i'event and clk_i = '1' then
      case state is
        
        when WAIT_FOR_STR =>
          if fub_str_i = '1' then
            fub_busy_o <= '1';
            data_tx    <= fub_data_i;
						if read_flag_i	= '1' then
							dummy	<=	'1';
						else
							dummy	<=	'0';
						end if;
            spi_mosi_o <= fub_data_i(data_cnt);
            cnt        <= conv_integer(spi_clks/2-1);
            state      <= WAIT_HALF_CLK_PERIOD;

            if wait_for_more_flag = '0' then
						
							-- flash_byte_count	<= flash_byte_count_i;
              if (fub_addr = slave0_byte_count - 1) and (slave0_byte_count > 0) then
                addr_cnt    <= slave0_byte_count - 1;
                spi_ss_o(0) <= '0';
                if Slave0_Byte_Count > 1 then
                  Wait_For_More_Flag <= '1';
                end if;
              end if;

              if (fub_addr = slave0_byte_count + slave1_byte_count - 1) and (slave1_byte_count > 0) then
                addr_cnt    <= slave1_byte_count - 1;
                spi_ss_o(1) <= '0';
                if Slave1_Byte_Count > 1 then
                  Wait_For_More_Flag <= '1';
                end if;
              end if;

              if (fub_addr = slave0_byte_count + slave1_byte_count + slave2_byte_count - 1) and (slave2_byte_count > 0) then
                addr_cnt    <= slave2_byte_count - 1;
                spi_ss_o(2) <= '0';
                if Slave2_Byte_Count > 1 then
                  Wait_For_More_Flag <= '1';
                end if;
              end if;

              if (fub_addr = slave0_byte_count + slave1_byte_count + slave2_byte_count + slave3_byte_count - 1) and (slave3_byte_count > 0) then
                addr_cnt    <= slave3_byte_count - 1;
                spi_ss_o(3) <= '0';
                if Slave3_Byte_Count > 1 then
                  Wait_For_More_Flag <= '1';
                end if;
              end if;

              if (fub_addr = slave0_byte_count + slave1_byte_count + slave2_byte_count + slave3_byte_count + slave4_byte_count - 1) and (slave4_byte_count > 0) then
                addr_cnt    <= slave4_byte_count - 1;
                spi_ss_o(4) <= '0';
                if Slave4_Byte_Count > 1 then
                  Wait_For_More_Flag <= '1';
                end if;
              end if;

              if (fub_addr = slave0_byte_count + slave1_byte_count + slave2_byte_count + slave3_byte_count + slave4_byte_count + slave5_byte_count - 1) and (slave5_byte_count > 0) then
                addr_cnt    <= slave5_byte_count - 1;
                spi_ss_o(5) <= '0';
                if Slave5_Byte_Count > 1 then
                  Wait_For_More_Flag <= '1';
                end if;
              end if;

              if (fub_addr = slave0_byte_count + slave1_byte_count + slave2_byte_count + slave3_byte_count + slave4_byte_count + slave5_byte_count + slave6_byte_count - 1) and (slave6_byte_count > 0) then
                addr_cnt    <= slave6_byte_count - 1;
                spi_ss_o(6) <= '0';
                if Slave6_Byte_Count > 1 then
                  Wait_For_More_Flag <= '1';
                end if;
              end if;

              if (fub_addr = slave0_byte_count + slave1_byte_count + slave2_byte_count + slave3_byte_count + slave4_byte_count + slave5_byte_count + slave6_byte_count + slave7_byte_count - 1) and (slave7_byte_count > 0) then
                addr_cnt    <= slave7_byte_count - 1;
                spi_ss_o(7) <= '0';
                if Slave7_Byte_Count > 1 then
                  Wait_For_More_Flag <= '1';
                end if;
              end if;

              if (fub_addr = slave0_byte_count + slave1_byte_count + slave2_byte_count + slave3_byte_count + slave4_byte_count + slave5_byte_count + slave6_byte_count + slave7_byte_count + slave8_byte_count - 1) and (slave8_byte_count > 0) then
                addr_cnt    <= slave8_byte_count - 1;
                spi_ss_o(8) <= '0';
                if Slave8_Byte_Count > 1 then
                  Wait_For_More_Flag <= '1';
                end if;
              end if;

              if (fub_addr = slave0_byte_count + slave1_byte_count + slave2_byte_count + slave3_byte_count + slave4_byte_count + slave5_byte_count + slave6_byte_count + slave7_byte_count + slave8_byte_count + flash_byte_count_i - 1) and (flash_byte_count_i > 0) then
								addr_cnt    <= flash_byte_count_i - 1;
                spi_ss_o(9) <= '0';
                if flash_byte_count_i > 1 then
                  Wait_For_More_Flag <= '1';
                end if;
              end if;

            end if;
          end if;
          
        when WAIT_HALF_CLK_PERIOD =>
          if cnt = 0 then
            cnt <= conv_integer(spi_clks/2-1);
            if spi_clk = '0' then
              spi_clk <= '1';
            else
              spi_clk <= '0';
              --
              if data_cnt = 0 then
								if dummy = '1' then
									data_rx(0) <= spi_miso_i;
									dummy	<=	'1';
								end if;
                data_cnt   <= 7;

                if addr_cnt = 0 then
                  spi_ss_o           <= (others => '1');
                  Wait_For_More_Flag <= '0';
                else
                  addr_cnt <= addr_cnt - 1;
                end if;

                state <= SEND_RX_DATA;

              else
								if dummy = '1' then
									data_rx(data_cnt) <= spi_miso_i;
								end if;
                spi_mosi_o        <= data_tx(data_cnt - 1);
                data_cnt          <= data_cnt - 1;
              end if;
              --
            end if;
          else
            cnt <= cnt - 1;
          end if;
          
        when SEND_RX_DATA =>
          if fub_busy_i = '0' and dummy = '1' then
						dummy <= '0';
            fub_data_o <= data_rx;
            fub_str_o  <= '1';
          else
            fub_error_o <= '1';
          end if;
          cnt   <= conv_integer(setup_clks-1);
          state <= WAIT_SETUP_TIME;
        when WAIT_SETUP_TIME =>
          fub_str_o <= '0';
          if cnt = 0 then
            fub_busy_o <= '0';
            state      <= WAIT_FOR_STR;
          else
            cnt <= cnt - 1;
          end if;
      end case;
    end if;
  end process;
end fub_multi_spi_master_arch;
