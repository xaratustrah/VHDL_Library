-- -------------------------------------------------------------
--
-- Module: hilbert_filter
--
-- Generated by MATLAB(R) 7.4 and the Filter Design HDL Coder 2.0.
--
-- Generated on: 2007-06-27 15:35:09
--
-- -------------------------------------------------------------

-- -------------------------------------------------------------
-- HDL Code Generation Options:
--
-- TargetLanguage: VHDL
-- OptimizeForHDL: on
-- CastBeforeSum: off
-- TargetDirectory: G:\svn\PLDWORK\LIB\analytic_filter\VHDL
-- AddPipelineRegisters: on
-- Name: hilbert_filter
--
-- Filter Settings:
--
-- Discrete-Time FIR Filter (real)
-- -------------------------------
-- Filter Structure  : Direct-Form Antisymmetric FIR
-- Filter Length     : 11
-- Stable            : Yes
-- Linear Phase      : Yes (Type 3)
-- Arithmetic        : fixed
-- Numerator         : s16,15 -> [-1 1)
-- Input             : s16,16 -> [-5.000000e-001 5.000000e-001)
-- Filter Internals  : Specify Precision
--   Output          : s16,16 -> [-5.000000e-001 5.000000e-001)
--   Tap Sum         : s17,16 -> [-1 1)
--   Product         : s32,30 -> [-2 2)
--   Accumulator     : s32,30 -> [-2 2)
--   Round Mode      : convergent
--   Overflow Mode   : wrap
-- -------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.numeric_std.ALL;

ENTITY hilbert_filter IS
   PORT( clk                             :   IN    std_logic; 
         clk_enable                      :   IN    std_logic; 
         reset                           :   IN    std_logic; 
         filter_in                       :   IN    std_logic_vector(15 DOWNTO 0); -- sfix16_En16
         filter_out                      :   OUT   std_logic_vector(15 DOWNTO 0)  -- sfix16_En16
         );

END hilbert_filter;


----------------------------------------------------------------
--Module Architecture: hilbert_filter
----------------------------------------------------------------
ARCHITECTURE rtl OF hilbert_filter IS
  -- Local Functions
  -- Type Definitions
  TYPE delay_pipeline_type IS ARRAY (NATURAL range <>) OF signed(15 DOWNTO 0); -- sfix16_En16
  TYPE sumdelay_pipeline_type IS ARRAY (NATURAL range <>) OF signed(31 DOWNTO 0); -- sfix32_En30
  -- Constants
  CONSTANT coeff1                         : signed(15 DOWNTO 0) := to_signed(-3494, 16); -- sfix16_En15
  CONSTANT coeff2                         : signed(15 DOWNTO 0) := to_signed(0, 16); -- sfix16_En15
  CONSTANT coeff3                         : signed(15 DOWNTO 0) := to_signed(-5835, 16); -- sfix16_En15
  CONSTANT coeff4                         : signed(15 DOWNTO 0) := to_signed(0, 16); -- sfix16_En15
  CONSTANT coeff5                         : signed(15 DOWNTO 0) := to_signed(-17521, 16); -- sfix16_En15
  CONSTANT coeff6                         : signed(15 DOWNTO 0) := to_signed(0, 16); -- sfix16_En15

  -- Signals
  SIGNAL delay_pipeline                   : delay_pipeline_type(0 TO 10); -- sfix16_En16
  SIGNAL tapsum1                          : signed(16 DOWNTO 0); -- sfix17_En16
  SIGNAL tapsum_mcand                     : signed(16 DOWNTO 0); -- sfix17_En16
  SIGNAL tapsum3                          : signed(16 DOWNTO 0); -- sfix17_En16
  SIGNAL tapsum_mcand_1                   : signed(16 DOWNTO 0); -- sfix17_En16
  SIGNAL tapsum5                          : signed(16 DOWNTO 0); -- sfix17_En16
  SIGNAL tapsum_mcand_2                   : signed(16 DOWNTO 0); -- sfix17_En16
  SIGNAL product5                         : signed(31 DOWNTO 0); -- sfix32_En30
  SIGNAL mul_temp                         : signed(32 DOWNTO 0); -- sfix33_En31
  SIGNAL product3                         : signed(31 DOWNTO 0); -- sfix32_En30
  SIGNAL mul_temp_1                       : signed(32 DOWNTO 0); -- sfix33_En31
  SIGNAL product1                         : signed(31 DOWNTO 0); -- sfix32_En30
  SIGNAL mul_temp_2                       : signed(32 DOWNTO 0); -- sfix33_En31
  SIGNAL sumvector1                       : sumdelay_pipeline_type(0 TO 1); -- sfix32_En30
  SIGNAL add_temp                         : signed(32 DOWNTO 0); -- sfix33_En30
  SIGNAL sumdelay_pipeline1               : sumdelay_pipeline_type(0 TO 1); -- sfix32_En30
  SIGNAL sum2                             : signed(31 DOWNTO 0); -- sfix32_En30
  SIGNAL add_temp_1                       : signed(32 DOWNTO 0); -- sfix33_En30
  SIGNAL output_typeconvert               : signed(15 DOWNTO 0); -- sfix16_En16
  SIGNAL output_register                  : signed(15 DOWNTO 0); -- sfix16_En16


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


  tapsum1 <= resize(delay_pipeline(0), 17) - resize(delay_pipeline(10), 17);

  tapsum_mcand <= tapsum1;

  tapsum3 <= resize(delay_pipeline(2), 17) - resize(delay_pipeline(8), 17);

  tapsum_mcand_1 <= tapsum3;

  tapsum5 <= resize(delay_pipeline(4), 17) - resize(delay_pipeline(6), 17);

  tapsum_mcand_2 <= tapsum5;

  mul_temp <= tapsum_mcand_2 * coeff5;
  product5 <= resize(shift_right(mul_temp(32 DOWNTO 0) + ( "0" & (mul_temp(1))), 1), 32);

  mul_temp_1 <= tapsum_mcand_1 * coeff3;
  product3 <= resize(shift_right(mul_temp_1(32 DOWNTO 0) + ( "0" & (mul_temp_1(1))), 1), 32);

  mul_temp_2 <= tapsum_mcand * coeff1;
  product1 <= resize(shift_right(mul_temp_2(32 DOWNTO 0) + ( "0" & (mul_temp_2(1))), 1), 32);

  add_temp <= resize(product5, 33) + resize(product3, 33);
  sumvector1(0) <= add_temp(31 DOWNTO 0);

  sumvector1(1) <= product1;

  sumdelay_pipeline_process1 : PROCESS (clk, reset)
  BEGIN
    IF reset = '1' THEN
      sumdelay_pipeline1 <= (OTHERS => (OTHERS => '0'));
    ELSIF clk'event AND clk = '1' THEN
      IF clk_enable = '1' THEN
        sumdelay_pipeline1(0 TO 1) <= sumvector1(0 TO 1);
      END IF;
    END IF; 
  END PROCESS sumdelay_pipeline_process1;

  add_temp_1 <= resize(sumdelay_pipeline1(0), 33) + resize(sumdelay_pipeline1(1), 33);
  sum2 <= add_temp_1(31 DOWNTO 0);

  output_typeconvert <= resize(shift_right(sum2(29 DOWNTO 0) + ( "0" & (sum2(14) & NOT sum2(14) & NOT sum2(14) & NOT sum2(14) & NOT sum2(14) & NOT sum2(14) & NOT sum2(14) & NOT sum2(14) & NOT sum2(14) & NOT sum2(14) & NOT sum2(14) & NOT sum2(14) & NOT sum2(14) & NOT sum2(14))), 14), 16);

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