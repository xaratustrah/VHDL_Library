-------------------------------------------------------------------------------
--
-- RS232 sender with fub interface M. Kumm
--
-------------------------------------------------------------------------------

-- Package Definition

library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_arith.all;
use IEEE.STD_LOGIC_unsigned.all;
use ieee.math_real.all;

package fub_rs232_tx_pkg is
  component fub_rs232_tx
    generic(
      clk_freq_in_hz : real;
      baud_rate      : real
      );
    port(
      clk_i      : in  std_logic;
      rst_i      : in  std_logic;
      rs232_tx_o : out std_logic;
      fub_str_i  : in  std_logic;
      fub_busy_o : out std_logic;
      fub_data_i : in  std_logic_vector(7 downto 0)
      );

  end component;
end fub_rs232_tx_pkg;

package body fub_rs232_tx_pkg is
end fub_rs232_tx_pkg;

-- Entity Definition

library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_arith.all;
use IEEE.STD_LOGIC_unsigned.all;
use ieee.math_real.all;

use work.real_time_calculator_pkg.all;

entity fub_rs232_tx is
  generic(
    clk_freq_in_hz : real := 50.0E6;
    baud_rate      : real := 9600.0
    );
  port(
    clk_i      : in  std_logic;
    rst_i      : in  std_logic;
    rs232_tx_o : out std_logic;
    fub_str_i  : in  std_logic;
    fub_busy_o : out std_logic;
    fub_data_i : in  std_logic_vector(7 downto 0)
    );

end fub_rs232_tx;

architecture fub_rs232_tx_arch of fub_rs232_tx is

  constant clk_div : integer := get_delay_in_ticks_round(clk_freq_in_hz, 1.0/baud_rate * 1.0E9);

  signal data_cnt : integer range 0 to 10;
  signal data     : std_logic_vector (7 downto 0);
  signal clk_cnt  : integer range 0 to clk_div-1;

  type states is (RECEIVING, BUSY);
  signal state : states;


begin

  fub_rs232_tx_p : process (clk_i, rst_i, fub_str_i, fub_data_i)
  begin
    if rst_i = '1' then
      data_cnt   <= 0;
      clk_cnt    <= 0;
      data       <= (others => '0');
      rs232_tx_o <= '1';                --normal level
      fub_busy_o <= '1';
      state      <= RECEIVING;
    elsif clk_i'event and clk_i = '1' then
      case state is
        when RECEIVING =>
          fub_busy_o <= '0';
          if fub_str_i = '1' then
            data       <= fub_data_i;
            fub_busy_o <= '1';          --set busy
            state      <= BUSY;
          end if;
        when BUSY =>
          if clk_cnt = 0 then
                                        --set rs232 tx bit
            if data_cnt = 0 then
              rs232_tx_o <= '0';        --startbit
            elsif data_cnt = 9 then
              rs232_tx_o <= '1';        --stopbit
            elsif data_cnt = 10 then
              fub_busy_o <= '0';        --reset busy
              state      <= RECEIVING;
            else
              rs232_tx_o <= data(data_cnt - 1);
            end if;
            if data_cnt = 10 then       --finished
              data_cnt <= 0;            --reset counter
            else
              data_cnt <= data_cnt + 1;
              clk_cnt  <= clk_cnt + 1;
            end if;
          elsif clk_cnt = clk_div-1 then
                                        --counter limit reached
            clk_cnt <= 0;
          else
            clk_cnt <= clk_cnt + 1;
          end if;
      end case;
    end if;
  end process;

end fub_rs232_tx_arch;
