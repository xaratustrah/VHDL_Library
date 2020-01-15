library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_arith.all;
use IEEE.STD_LOGIC_unsigned.all;
library lpm;
use lpm.lpm_components.all;

library work;

entity led is
  generic (
    Use_LPM : integer := 0
    ); 
  port
    (
      ENA    : in  std_logic;
      CLK    : in  std_logic;
      Sig_In : in  std_logic;
      nLED   : out std_logic
      );
end led;

architecture arch_led of led is

  component lpm_counter
    generic (
      lpm_width     : natural;
      lpm_type      : string;
      lpm_direction : string
      );
    port(
      clock  : in  std_logic;
      cnt_en : in  std_logic := '1';
      q      : out std_logic_vector (lpm_width-1 downto 0);
      aclr   : in  std_logic
      );
  end component;


  constant C_Cnt_Len : integer := 3;
  signal S_Cnt       : std_logic_vector(C_Cnt_Len-1 downto 0);


begin

  Led_with_lpm : if Use_LPM = 1 generate  --------------------------------------

    signal S_Ena : std_logic;

  begin
    S_Ena <= '1' when (S_Cnt(S_Cnt'high) = '0') and (Ena = '1') else '0';

    led_cnt : lpm_counter
      generic map (
        lpm_width     => C_Cnt_Len,
        lpm_type      => "LPM_COUNTER",
        lpm_direction => "UP"
        )
      port map(
        clock  => clk,
        aclr   => Sig_In,
        cnt_en => S_Ena,
        q      => S_Cnt
        );


--led_opndrn : opndrn
--PORT MAP(A_IN => S_Cnt(S_Cnt'high),
--               A_OUT => nLED);
    
  end generate Led_with_lpm;  -------------------------------------------------


  Led_without_lpm : if Use_LPM = 0 generate  -----------------------------------

  begin
    P_Led_Stretch : process (clk, Sig_in, S_Cnt)
    begin
      if Sig_in = '1' then
        S_Cnt <= CONV_STD_LOGIC_VECTOR(0, S_Cnt'length);
      elsif clk'event and CLK = '1' then
        if Ena = '1' and S_Cnt(S_Cnt'high) = '0' then
          S_Cnt <= S_Cnt + 1;
        end if;
      end if;
    end process P_Led_Stretch;
    
  end generate Led_without_lpm;  ----------------------------------------------

  P_Led_on : process (S_Cnt(S_Cnt'high))
  begin
    if S_Cnt(S_Cnt'high) = '0' then
      nLed <= '0';
    else
      nLed <= 'Z';
    end if;
  end process P_Led_on;

end arch_led;
