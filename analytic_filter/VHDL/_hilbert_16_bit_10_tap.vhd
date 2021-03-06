-- -------------------------------------------------------------
--
-- Module: hilbert_filter
--
-- Generated by MATLAB(R) 7.0 and the Filter Design HDL Coder 1.0.
--
-- Generated on: 2007-06-13 14:09:15
--
-- -------------------------------------------------------------

-- -------------------------------------------------------------
-- HDL Code Generation Options:
--
-- TargetLanguage: VHDL
-- Name: hilbert_filter
-- TargetDirectory: G:\svn\PLDWORK\LIB\analytic_filter\VHDL
-- LoopUnrolling: On
-- PackagePostfix: 
-- SplitEntityFilePostfix: 
-- SplitArchFilePostfix: 
-- InlineConfigurations: Off
-- SafeZeroConcat: Off
-- TestBenchStimulus: impulse step ramp chirp noise 
--
-- Filter Settings:
--
-- Discrete-Time FIR Filter (real)
-- -------------------------------
-- Filter Structure  : Direct-Form FIR
-- Filter Order      : 10
-- Stable            : Yes
-- Linear Phase      : Yes (Type 3)
-- Arithmetic        : fixed
--
--          CoeffWordLength: 16
--           CoeffAutoScale: true
--                   Signed: true
--
--          InputWordLength: 16
--          InputFracLength: 15
--
--         OutputWordLength: 16
--               OutputMode: 'AvoidOverflow'
--
--              ProductMode: 'KeepMSB'
--        ProductWordLength: 32
--
--                AccumMode: 'KeepMSB'
--          AccumWordLength: 40
--            CastBeforeSum: true
--
--                RoundMode: 'convergent'
--             OverflowMode: 'saturate'
-- -------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.numeric_std.ALL;

ENTITY hilbert_filter IS
   PORT( clk                             :   IN    std_logic; 
         clk_enable                      :   IN    std_logic; 
         reset                           :   IN    std_logic; 
         filter_in                       :   IN    std_logic_vector(15 DOWNTO 0); -- sfix16_En15
         filter_out                      :   OUT   std_logic_vector(15 DOWNTO 0)  -- sfix16_En10
         );

END hilbert_filter;


----------------------------------------------------------------
--Module Architecture: hilbert_filter
----------------------------------------------------------------
ARCHITECTURE rtl OF hilbert_filter IS
  -- Local Functions
  -- Type Definitions
  TYPE delay_pipeline_type IS ARRAY (NATURAL range <>) OF signed(15 DOWNTO 0); -- sfix16_En15
  -- Constants
  CONSTANT coeff1                         : signed(15 DOWNTO 0) := to_signed(-3397, 16); -- sfix16_En15
  CONSTANT coeff2                         : signed(15 DOWNTO 0) := to_signed(-52, 16); -- sfix16_En15
  CONSTANT coeff3                         : signed(15 DOWNTO 0) := to_signed(-5776, 16); -- sfix16_En15
  CONSTANT coeff4                         : signed(15 DOWNTO 0) := to_signed(-26, 16); -- sfix16_En15
  CONSTANT coeff5                         : signed(15 DOWNTO 0) := to_signed(-17501, 16); -- sfix16_En15
  CONSTANT coeff6                         : signed(15 DOWNTO 0) := to_signed(0, 16); -- sfix16_En15
  CONSTANT coeff7                         : signed(15 DOWNTO 0) := to_signed(17501, 16); -- sfix16_En15
  CONSTANT coeff8                         : signed(15 DOWNTO 0) := to_signed(26, 16); -- sfix16_En15
  CONSTANT coeff9                         : signed(15 DOWNTO 0) := to_signed(5776, 16); -- sfix16_En15
  CONSTANT coeff10                        : signed(15 DOWNTO 0) := to_signed(52, 16); -- sfix16_En15
  CONSTANT coeff11                        : signed(15 DOWNTO 0) := to_signed(3397, 16); -- sfix16_En15

  -- Signals
  SIGNAL delay_pipeline                   : delay_pipeline_type(0 TO 10); -- sfix16_En15
  SIGNAL product11                        : signed(31 DOWNTO 0); -- sfix32_En30
  SIGNAL product10                        : signed(31 DOWNTO 0); -- sfix32_En30
  SIGNAL product9                         : signed(31 DOWNTO 0); -- sfix32_En30
  SIGNAL product8                         : signed(31 DOWNTO 0); -- sfix32_En30
  SIGNAL product7                         : signed(31 DOWNTO 0); -- sfix32_En30
  SIGNAL product5                         : signed(31 DOWNTO 0); -- sfix32_En30
  SIGNAL product4                         : signed(31 DOWNTO 0); -- sfix32_En30
  SIGNAL product3                         : signed(31 DOWNTO 0); -- sfix32_En30
  SIGNAL product2                         : signed(31 DOWNTO 0); -- sfix32_En30
  SIGNAL product1                         : signed(31 DOWNTO 0); -- sfix32_En30
  SIGNAL sum1                             : signed(39 DOWNTO 0); -- sfix40_En30
  SIGNAL add_temp                         : signed(32 DOWNTO 0); -- sfix33_En30
  SIGNAL sum2                             : signed(39 DOWNTO 0); -- sfix40_En30
  SIGNAL add_temp_1                       : signed(40 DOWNTO 0); -- sfix41_En30
  SIGNAL sum3                             : signed(39 DOWNTO 0); -- sfix40_En30
  SIGNAL add_temp_2                       : signed(40 DOWNTO 0); -- sfix41_En30
  SIGNAL sum4                             : signed(39 DOWNTO 0); -- sfix40_En30
  SIGNAL add_temp_3                       : signed(40 DOWNTO 0); -- sfix41_En30
  SIGNAL sum5                             : signed(39 DOWNTO 0); -- sfix40_En30
  SIGNAL add_temp_4                       : signed(40 DOWNTO 0); -- sfix41_En30
  SIGNAL sum6                             : signed(39 DOWNTO 0); -- sfix40_En30
  SIGNAL add_temp_5                       : signed(40 DOWNTO 0); -- sfix41_En30
  SIGNAL sum7                             : signed(39 DOWNTO 0); -- sfix40_En30
  SIGNAL add_temp_6                       : signed(40 DOWNTO 0); -- sfix41_En30
  SIGNAL sum8                             : signed(39 DOWNTO 0); -- sfix40_En30
  SIGNAL add_temp_7                       : signed(40 DOWNTO 0); -- sfix41_En30
  SIGNAL sum9                             : signed(39 DOWNTO 0); -- sfix40_En30
  SIGNAL add_temp_8                       : signed(40 DOWNTO 0); -- sfix41_En30
  SIGNAL output_typeconvert               : signed(15 DOWNTO 0); -- sfix16_En10
  SIGNAL output_register                  : signed(15 DOWNTO 0); -- sfix16_En10


BEGIN

  -- Block Statements
  Delay_Pipeline_process : PROCESS (clk, reset)
  BEGIN
    IF reset = '1' THEN
      delay_pipeline(0 TO 10) <= (OTHERS => (OTHERS => '0'));
    ELSIF clk'event AND clk = '1' THEN
      IF clk_enable = '1' THEN
        delay_pipeline(0) <= signed(filter_in);
        delay_pipeline(1 TO 10) <= delay_pipeline(0 TO 9);
      END IF;
    END IF; 
  END PROCESS Delay_Pipeline_process;

  product11 <= delay_pipeline(10) * coeff11;

  product10 <= delay_pipeline(9) * coeff10;

  product9 <= delay_pipeline(8) * coeff9;

  product8 <= delay_pipeline(7) * coeff8;

  product7 <= delay_pipeline(6) * coeff7;

  product5 <= delay_pipeline(4) * coeff5;

  product4 <= delay_pipeline(3) * coeff4;

  product3 <= delay_pipeline(2) * coeff3;

  product2 <= delay_pipeline(1) * coeff2;

  product1 <= delay_pipeline(0) * coeff1;

  add_temp <= resize(product1, 33) + resize(product2, 33);
  sum1 <= resize( add_temp, 40);

  add_temp_1 <= resize(sum1, 41) + resize(product3, 41);
  sum2 <= (39 => '0', OTHERS => '1') WHEN (add_temp_1(40) = '0' AND add_temp_1(39) /= '0') OR (add_temp_1(40) = '0' AND add_temp_1(39 DOWNTO 0) = "0111111111111111111111111111111111111111") -- special case0
      ELSE (39 => '1', OTHERS => '0') WHEN add_temp_1(40) = '1' AND add_temp_1(39) /= '1'
      ELSE (add_temp_1(39 DOWNTO 0));

  add_temp_2 <= resize(sum2, 41) + resize(product4, 41);
  sum3 <= (39 => '0', OTHERS => '1') WHEN (add_temp_2(40) = '0' AND add_temp_2(39) /= '0') OR (add_temp_2(40) = '0' AND add_temp_2(39 DOWNTO 0) = "0111111111111111111111111111111111111111") -- special case0
      ELSE (39 => '1', OTHERS => '0') WHEN add_temp_2(40) = '1' AND add_temp_2(39) /= '1'
      ELSE (add_temp_2(39 DOWNTO 0));

  add_temp_3 <= resize(sum3, 41) + resize(product5, 41);
  sum4 <= (39 => '0', OTHERS => '1') WHEN (add_temp_3(40) = '0' AND add_temp_3(39) /= '0') OR (add_temp_3(40) = '0' AND add_temp_3(39 DOWNTO 0) = "0111111111111111111111111111111111111111") -- special case0
      ELSE (39 => '1', OTHERS => '0') WHEN add_temp_3(40) = '1' AND add_temp_3(39) /= '1'
      ELSE (add_temp_3(39 DOWNTO 0));

  add_temp_4 <= resize(sum4, 41) + resize(product7, 41);
  sum5 <= (39 => '0', OTHERS => '1') WHEN (add_temp_4(40) = '0' AND add_temp_4(39) /= '0') OR (add_temp_4(40) = '0' AND add_temp_4(39 DOWNTO 0) = "0111111111111111111111111111111111111111") -- special case0
      ELSE (39 => '1', OTHERS => '0') WHEN add_temp_4(40) = '1' AND add_temp_4(39) /= '1'
      ELSE (add_temp_4(39 DOWNTO 0));

  add_temp_5 <= resize(sum5, 41) + resize(product8, 41);
  sum6 <= (39 => '0', OTHERS => '1') WHEN (add_temp_5(40) = '0' AND add_temp_5(39) /= '0') OR (add_temp_5(40) = '0' AND add_temp_5(39 DOWNTO 0) = "0111111111111111111111111111111111111111") -- special case0
      ELSE (39 => '1', OTHERS => '0') WHEN add_temp_5(40) = '1' AND add_temp_5(39) /= '1'
      ELSE (add_temp_5(39 DOWNTO 0));

  add_temp_6 <= resize(sum6, 41) + resize(product9, 41);
  sum7 <= (39 => '0', OTHERS => '1') WHEN (add_temp_6(40) = '0' AND add_temp_6(39) /= '0') OR (add_temp_6(40) = '0' AND add_temp_6(39 DOWNTO 0) = "0111111111111111111111111111111111111111") -- special case0
      ELSE (39 => '1', OTHERS => '0') WHEN add_temp_6(40) = '1' AND add_temp_6(39) /= '1'
      ELSE (add_temp_6(39 DOWNTO 0));

  add_temp_7 <= resize(sum7, 41) + resize(product10, 41);
  sum8 <= (39 => '0', OTHERS => '1') WHEN (add_temp_7(40) = '0' AND add_temp_7(39) /= '0') OR (add_temp_7(40) = '0' AND add_temp_7(39 DOWNTO 0) = "0111111111111111111111111111111111111111") -- special case0
      ELSE (39 => '1', OTHERS => '0') WHEN add_temp_7(40) = '1' AND add_temp_7(39) /= '1'
      ELSE (add_temp_7(39 DOWNTO 0));

  add_temp_8 <= resize(sum8, 41) + resize(product11, 41);
  sum9 <= (39 => '0', OTHERS => '1') WHEN (add_temp_8(40) = '0' AND add_temp_8(39) /= '0') OR (add_temp_8(40) = '0' AND add_temp_8(39 DOWNTO 0) = "0111111111111111111111111111111111111111") -- special case0
      ELSE (39 => '1', OTHERS => '0') WHEN add_temp_8(40) = '1' AND add_temp_8(39) /= '1'
      ELSE (add_temp_8(39 DOWNTO 0));

  output_typeconvert <= (15 => '0', OTHERS => '1') WHEN (sum9(39) = '0' AND sum9(38 DOWNTO 35) /= "0000") OR (sum9(39) = '0' AND sum9(35 DOWNTO 20) = "0111111111111111") -- special case0
      ELSE (15 => '1', OTHERS => '0') WHEN sum9(39) = '1' AND sum9(38 DOWNTO 35) /= "1111"
--      ELSE (resize( shift_right(sum9(39) & sum9(35 DOWNTO 0) + ( "0" & (sum9(20) & NOT sum9(20) & NOT sum9(20) & NOT sum9(20) & NOT sum9(20) & NOT sum9(20) & NOT sum9(20) & NOT sum9(20) & NOT sum9(20) & NOT sum9(20) & NOT sum9(20) & NOT sum9(20) & NOT sum9(20) & NOT sum9(20) & NOT sum9(20) & NOT sum9(20) & NOT sum9(20) & NOT sum9(20) & NOT sum9(20) & NOT sum9(20))), 20), 16));
      ELSE (resize( shift_right(sum9(39) & sum9(35 DOWNTO 0) + ( "0" & (sum9(20) & NOT sum9(20) & NOT sum9(20) & NOT sum9(20) & NOT sum9(20) & NOT sum9(20) & NOT sum9(20) & NOT sum9(20) & NOT sum9(20) & NOT sum9(20) & NOT sum9(20) & NOT sum9(20) & NOT sum9(20) & NOT sum9(20) & NOT sum9(20) & NOT sum9(20) & NOT sum9(20) & NOT sum9(20) & NOT sum9(20) & NOT sum9(20))), 15), 16));

  Output_Register_process : PROCESS (clk, reset)
  BEGIN
    IF reset = '1' THEN
      output_register <= (OTHERS => '0');
    ELSIF clk'event AND clk = '1' THEN
      IF clk_enable = '1' THEN
        output_register <= output_typeconvert;
      END IF;
    END IF; 
  END PROCESS Output_Register_process;

  -- Assignment Statements
  filter_out <= std_logic_vector(output_register);

END rtl;
