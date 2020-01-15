--! BEGIN_MOD 
-- status : new component
-- desc   : pipelined cordic
--          takes data_width+2 cycles
--! END_MOD
--
-- some modifications from the original version from A. Guntoro has been done by M. Kumm 
-- (some parts was not been used and has been removed):
-- the additional i_data/o_data port has been removed
-- the second i_i/i_q port has been removed
-- gsi port name convention has been used
-- package added

-- Package Definition

library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_arith.all;
use IEEE.STD_LOGIC_unsigned.all;

package cordic_16bit_pkg is
  component cordic_16bit
    generic(
      data_width : natural := 16
      );
    port(
      clk_i       : in  std_logic;
      rst_i       : in  std_logic;
      i_i         : in  std_logic_vector(data_width-1 downto 0);
      q_i         : in  std_logic_vector(data_width-1 downto 0);
      magnitude_o : out std_logic_vector(data_width-1 downto 0);
      phase_o     : out std_logic_vector(data_width-1 downto 0)
      );
  end component;
end cordic_16bit_pkg;
package body cordic_16bit_pkg is
end cordic_16bit_pkg;

-- Entity Definition

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

entity cordic_16bit is
  generic(
    data_width : natural := 16
    );
  port(
    clk_i       : in  std_logic;
    rst_i       : in  std_logic;
    i_i         : in  std_logic_vector(data_width-1 downto 0);
    q_i         : in  std_logic_vector(data_width-1 downto 0);
    magnitude_o : out std_logic_vector(data_width-1 downto 0);
    phase_o     : out std_logic_vector(data_width-1 downto 0)
    );
end cordic_16bit;

architecture cordic_16bit_arch of cordic_16bit is

  function GetNPhi return std_logic_vector is
    variable v : std_logic_vector(data_width-1 downto 0) := (others => '0');
  begin
    v               := (others => '0');
    v(data_width-1) := '1';
    return v;
  end;
  
  function adjust_x(
    a    : std_logic_vector(data_width-1 downto 0);
    b    : std_logic_vector(data_width-1 downto 0);
    sign : std_logic;
    step : natural) return std_logic_vector is
    variable result : std_logic_vector(data_width-1 downto 0);
    variable shift  : std_logic_vector(data_width-1 downto 0);
  begin
    shift                             := (others => b(data_width-1));
    shift(data_width-step-1 downto 0) := b(data_width-1 downto step);
    if (sign = '1') then
      result := a - shift;
    else
      result := a + shift;
    end if;
    return result;
  end;
  
  function adjust_y(
    a    : std_logic_vector(data_width-1 downto 0);
    b    : std_logic_vector(data_width-1 downto 0);
    sign : std_logic;
    step : natural) return std_logic_vector is
    variable result : std_logic_vector(data_width-1 downto 0);
    variable shift  : std_logic_vector(data_width-1 downto 0);
  begin
    shift                             := (others => b(data_width-1));
    shift(data_width-step-1 downto 0) := b(data_width-1 downto step);
    if (sign = '1') then
      result := a + shift;
    else
      result := a - shift;
    end if;
    return result;
  end;
  
  function adjust_z(
    a    : std_logic_vector(data_width-1 downto 0);
    b    : std_logic_vector(data_width-1 downto 0);
    sign : std_logic) return std_logic_vector is
    variable result : std_logic_vector(data_width-1 downto 0);
  begin
    if (sign = '1') then
      result := a - b;
    else
      result := a + b;
    end if;
    return result;
  end;

  type LUT_TYPE is array (natural range<>) of std_logic_vector(data_width-1 downto 0);
  constant LUT : LUT_TYPE(0 to data_width-2) := (
    x"2000", x"12E4", x"09FB", x"0511",
    x"028B", x"0145", x"00A2", x"0051",
    x"0028", x"0014", x"000A", x"0005",
    x"0002", x"0001", x"0000"
    );

  constant NPHI_CONST : std_logic_vector(data_width-1 downto 0) := GetNPhi;

  type X_TYPE is array(natural range <>) of std_logic_vector(data_width-1 downto 0);
  type Y_TYPE is array(natural range <>) of std_logic_vector(data_width-1 downto 0);
  type Z_TYPE is array(natural range <>) of std_logic_vector(data_width-1 downto 0);
  type A_TYPE is array(natural range <>) of std_logic_vector(1 downto 0);

  constant X_CONST : std_logic_vector(data_width-1 downto 0) := (others => '0');
  constant Y_CONST : std_logic_vector(data_width-1 downto 0) := (others => '0');
  constant Z_CONST : std_logic_vector(data_width-1 downto 0) := (others => '0');
  constant A_CONST : std_logic_vector(1 downto 0)            := (others => '0');


  signal p_dataout : std_logic_vector(data_width+1 downto 0) := (others => '0');
  signal p_x       : X_TYPE(0 to data_width-1)               := (others => X_CONST);
  signal p_y       : Y_TYPE(0 to data_width-1)               := (others => Y_CONST);
  signal p_z       : Z_TYPE(0 to data_width-1)               := (others => Z_CONST);
  signal p_adjust  : A_TYPE(0 to data_width-1)               := (others => A_CONST);

  signal s_org_x     : std_logic_vector(data_width-1 downto 0) := (others => '0');
  signal s_org_y     : std_logic_vector(data_width-1 downto 0) := (others => '0');
  signal s_magnitude : std_logic_vector(data_width-1 downto 0) := (others => '0');
  signal s_phase     : std_logic_vector(data_width-1 downto 0) := (others => '0');
  
begin

  process(rst_i, clk_i)
    variable direction : std_logic;
  begin
    if (rst_i = '1') then
      
      p_dataout <= (others => '0');
      
    elsif (clk_i = '1' and clk_i'event) then


      -------------
      -- stage 1 --
      -------------
      -- input  : q_i, i_i
      -- output : s_org_x, s_org_y, p_dataout()

      -- data output pipeline
--         p_dataout(0) <= i_data; -- modified (M. Kumm)
--         for n in 1 to data_width+1 loop -- modified (M. Kumm)
--            p_dataout(n) <= p_dataout(n-1); -- modified (M. Kumm)
--         end loop; -- modified (M. Kumm)

      -- calculate x & y
--         s_org_x <= SIGNED(i_q1) - SIGNED(i_q2); -- modified (M. Kumm)
--         s_org_y <= SIGNED(i_i1) - SIGNED(i_i2); -- modified (M. Kumm)

      s_org_x <= i_i;                   -- modified (M. Kumm)
      s_org_y <= q_i;                   -- modified (M. Kumm)

      -------------
      -- stage 2 --
      -------------
      -- input  : s_org_x, s_org_y
      -- output : p_x(0), p_y(0), p_z(0), p_adjust(0)

      -- pre-processing: input x & y adjustment
      if (s_org_x(data_width-1) = '0') then
        p_x(0)      <= s_org_x;
        p_y(0)      <= s_org_y;
        p_adjust(0) <= "00";
      else
        p_x(0) <= -signed(s_org_x);
        p_y(0) <= -signed(s_org_y);
        if (s_org_y(data_width-1) = '0') then
          p_adjust(0) <= "01";
        else
          p_adjust(0) <= "10";
        end if;
      end if;
      p_z(0) <= (others => '0');

      -------------
      -- stage 3 --
      -------------
      -- input  : p_x(0), p_y(0), p_z(0), p_adjust(0)
      -- output : p_x(), p_y(), p_z(), p_adjust()

      -- cordic         
      for i in 1 to data_width-1 loop
        direction := p_y(i-1)(data_width-1);
        p_x(i)    <= adjust_x(p_x(i-1), p_y(i-1), direction, i-1);
        p_y(i)    <= adjust_y(p_y(i-1), p_x(i-1), direction, i-1);
        p_z(i)    <= adjust_z(p_z(i-1), LUT(i-1), direction);
      end loop;

      -- traverse adjustment signal
      for n in 1 to data_width-1 loop
        p_adjust(n) <= p_adjust(n-1);
      end loop;

      -------------
      -- stage 4 --
      -------------
      -- input  : p_x(~), p_y(~), p_z(~), p_adjust(~)
      -- output : s_magnitude, s_phase

      s_magnitude <= p_x(data_width-1);
      case p_adjust(data_width-1) is
        when "01" =>                    -- adjust with +pi
          s_phase <= p_z(data_width-1) - NPHI_CONST;
        when "10" =>                    -- adjust with -pi
          s_phase <= p_z(data_width-1) + NPHI_CONST;
        when others =>
          s_phase <= p_z(data_width-1);
      end case;
      
    end if;
  end process;

--   o_data      <= p_dataout(data_width+1); -- modified (M. Kumm)
  magnitude_o <= s_magnitude;
  phase_o     <= s_phase;
  
end cordic_16bit_arch;
