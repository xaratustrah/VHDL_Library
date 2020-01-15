-- -------------------------------------------------------------
--
-- Module: hilbert_filter
--
-- Generated by MATLAB(R) 7.4 and the Filter Design HDL Coder 2.0.
--
-- Generated on: 2007-06-26 22:05:44
--
-- -------------------------------------------------------------

-- -------------------------------------------------------------
-- HDL Code Generation Options:
--
-- TargetLanguage: VHDL
-- FIRAdderStyle: tree
-- OptimizeForHDL: on
-- CastBeforeSum: off
-- TargetDirectory: G:\svn\PLDWORK\LIB\analytic_filter\VHDL
-- AddPipelineRegisters: on
-- Name: hilbert_filter
-- DALUTPartition: [8  2]
-- TestBenchStimulus: chirp impulse noise ramp step 
--
-- Filter Settings:
--
-- Discrete-Time FIR Filter (real)
-- -------------------------------
-- Filter Structure  : Direct-Form FIR
-- Filter Length     : 11
-- Stable            : Yes
-- Linear Phase      : Yes (Type 3)
-- Arithmetic        : fixed
-- Numerator         : s16,15 -> [-1 1)
-- Input             : s16,15 -> [-1 1)
-- Filter Internals  : Specify Precision
--   Output          : s16,10 -> [-32 32)
--   Product         : s32,30 -> [-2 2)
--   Accumulator     : s40,30 -> [-512 512)
--   Round Mode      : convergent
--   Overflow Mode   : saturate
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
  TYPE delay_pipeline_type IS ARRAY (NATURAL range <>) OF std_logic; -- boolean
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
  SIGNAL filter_in_cast                   : signed(15 DOWNTO 0); -- sfix16_En15
  SIGNAL cur_count                        : unsigned(3 DOWNTO 0); -- ufix4
  SIGNAL phase_1                          : std_logic; -- boolean
  SIGNAL phase_1_1                        : std_logic; -- boolean
  SIGNAL phase_1_2                        : std_logic; -- boolean
  SIGNAL serialoutb1                      : std_logic; -- boolean
  SIGNAL shiftreg                         : signed(15 DOWNTO 0); -- sfix16_En15
  SIGNAL delay_pipeline                   : delay_pipeline_type(0 TO 159); -- boolean
  SIGNAL mem_addr_1                       : unsigned(7 DOWNTO 0); -- ufix8
  SIGNAL memoutb1_1                       : signed(15 DOWNTO 0); -- sfix16_En15
  SIGNAL mem_addr_2                       : unsigned(1 DOWNTO 0); -- ufix2
  SIGNAL memoutb1_2                       : signed(12 DOWNTO 0); -- sfix13_En15
  SIGNAL memoutb1                         : signed(15 DOWNTO 0); -- sfix16_En15
  SIGNAL sum1_1                           : signed(16 DOWNTO 0); -- sfix17_En15
  SIGNAL sumpipe1_1                       : signed(16 DOWNTO 0); -- sfix17_En15
  SIGNAL acc_out                          : signed(32 DOWNTO 0); -- sfix33_En30
  SIGNAL memoutb1_cast                    : signed(32 DOWNTO 0); -- sfix33_En30
  SIGNAL add_sub_out                      : signed(32 DOWNTO 0); -- sfix33_En30
  SIGNAL acc_out_shft                     : signed(32 DOWNTO 0); -- sfix33_En30
  SIGNAL acc_in                           : signed(32 DOWNTO 0); -- sfix33_En30
  SIGNAL addsub_add                       : signed(32 DOWNTO 0); -- sfix33_En30
  SIGNAL addsub_sub                       : signed(32 DOWNTO 0); -- sfix33_En30
  SIGNAL add_temp                         : signed(33 DOWNTO 0); -- sfix34_En30
  SIGNAL sub_temp                         : signed(33 DOWNTO 0); -- sfix34_En30
  SIGNAL final_acc_out                    : signed(32 DOWNTO 0); -- sfix33_En30
  SIGNAL output_da                        : signed(32 DOWNTO 0); -- sfix33_En30
  SIGNAL output_typeconvert               : signed(15 DOWNTO 0); -- sfix16_En10
  SIGNAL output_register                  : signed(15 DOWNTO 0); -- sfix16_En10


BEGIN

  -- Block Statements
  filter_in_cast <= signed(filter_in);

  Counter_process : PROCESS (clk, reset)
  BEGIN
    IF reset = '1' THEN
      cur_count <= to_unsigned(15, 4);
    ELSIF clk'event AND clk = '1' THEN
      IF clk_enable = '1' THEN
        IF cur_count = to_unsigned(15, 4) THEN
          cur_count <= to_unsigned(0, 4);
        ELSE
          cur_count <= cur_count + 1;
        END IF;
      END IF;
    END IF; 
  END PROCESS Counter_process;

  phase_1 <= '1' WHEN cur_count = to_unsigned(15, 4) AND clk_enable = '1' ELSE '0';

  phase_1_1 <= '1' WHEN cur_count = to_unsigned(0, 4) AND clk_enable = '1' ELSE '0';

  phase_1_2 <= '1' WHEN cur_count = to_unsigned(1, 4) AND clk_enable = '1' ELSE '0';

  Serializer_1_process : PROCESS (clk, reset)
  BEGIN
    IF reset = '1' THEN
      shiftreg <= to_signed(0, 16);
    ELSIF clk'event AND clk = '1' THEN
      IF clk_enable = '1' THEN
        IF phase_1 = '1' THEN
          shiftreg <= filter_in_cast;
        ELSE
          shiftreg <= '0' & shiftreg(15 DOWNTO 1);
        END IF;
      END IF;
    END IF; 
  END PROCESS Serializer_1_process;

  serialoutb1 <= shiftreg(0);
 
  Delay_Pipeline_1_process : PROCESS (clk, reset)
  BEGIN
    IF reset = '1' THEN
      delay_pipeline(0 TO 159) <= (OTHERS => '0');
    ELSIF clk'event AND clk = '1' THEN
      IF clk_enable = '1' THEN
        delay_pipeline(0) <= serialoutb1;
        delay_pipeline(1 TO 159) <= delay_pipeline(0 TO 158);
      END IF;
    END IF; 
  END PROCESS Delay_Pipeline_1_process;


  mem_addr_1 <= delay_pipeline(127) & delay_pipeline(111) & delay_pipeline(95) & delay_pipeline(63) & delay_pipeline(47) & delay_pipeline(31) & delay_pipeline(15) & serialoutb1;

  PROCESS(mem_addr_1)
  BEGIN
    CASE mem_addr_1 IS
      WHEN "00000000" => memoutb1_1 <= "0000000000000000";
      WHEN "00000001" => memoutb1_1 <= "1111001010111011";
      WHEN "00000010" => memoutb1_1 <= "1111111111001100";
      WHEN "00000011" => memoutb1_1 <= "1111001010000111";
      WHEN "00000100" => memoutb1_1 <= "1110100101110000";
      WHEN "00000101" => memoutb1_1 <= "1101110000101011";
      WHEN "00000110" => memoutb1_1 <= "1110100100111100";
      WHEN "00000111" => memoutb1_1 <= "1101101111110111";
      WHEN "00001000" => memoutb1_1 <= "1111111111100110";
      WHEN "00001001" => memoutb1_1 <= "1111001010100001";
      WHEN "00001010" => memoutb1_1 <= "1111111110110010";
      WHEN "00001011" => memoutb1_1 <= "1111001001101101";
      WHEN "00001100" => memoutb1_1 <= "1110100101010110";
      WHEN "00001101" => memoutb1_1 <= "1101110000010001";
      WHEN "00001110" => memoutb1_1 <= "1110100100100010";
      WHEN "00001111" => memoutb1_1 <= "1101101111011101";
      WHEN "00010000" => memoutb1_1 <= "1011101110100011";
      WHEN "00010001" => memoutb1_1 <= "1010111001011110";
      WHEN "00010010" => memoutb1_1 <= "1011101101101111";
      WHEN "00010011" => memoutb1_1 <= "1010111000101010";
      WHEN "00010100" => memoutb1_1 <= "1010010100010011";
      WHEN "00010101" => memoutb1_1 <= "1001011111001110";
      WHEN "00010110" => memoutb1_1 <= "1010010011011111";
      WHEN "00010111" => memoutb1_1 <= "1001011110011010";
      WHEN "00011000" => memoutb1_1 <= "1011101110001001";
      WHEN "00011001" => memoutb1_1 <= "1010111001000100";
      WHEN "00011010" => memoutb1_1 <= "1011101101010101";
      WHEN "00011011" => memoutb1_1 <= "1010111000010000";
      WHEN "00011100" => memoutb1_1 <= "1010010011111001";
      WHEN "00011101" => memoutb1_1 <= "1001011110110100";
      WHEN "00011110" => memoutb1_1 <= "1010010011000101";
      WHEN "00011111" => memoutb1_1 <= "1001011110000000";
      WHEN "00100000" => memoutb1_1 <= "0100010001011101";
      WHEN "00100001" => memoutb1_1 <= "0011011100011000";
      WHEN "00100010" => memoutb1_1 <= "0100010000101001";
      WHEN "00100011" => memoutb1_1 <= "0011011011100100";
      WHEN "00100100" => memoutb1_1 <= "0010110111001101";
      WHEN "00100101" => memoutb1_1 <= "0010000010001000";
      WHEN "00100110" => memoutb1_1 <= "0010110110011001";
      WHEN "00100111" => memoutb1_1 <= "0010000001010100";
      WHEN "00101000" => memoutb1_1 <= "0100010001000011";
      WHEN "00101001" => memoutb1_1 <= "0011011011111110";
      WHEN "00101010" => memoutb1_1 <= "0100010000001111";
      WHEN "00101011" => memoutb1_1 <= "0011011011001010";
      WHEN "00101100" => memoutb1_1 <= "0010110110110011";
      WHEN "00101101" => memoutb1_1 <= "0010000001101110";
      WHEN "00101110" => memoutb1_1 <= "0010110101111111";
      WHEN "00101111" => memoutb1_1 <= "0010000000111010";
      WHEN "00110000" => memoutb1_1 <= "0000000000000000";
      WHEN "00110001" => memoutb1_1 <= "1111001010111011";
      WHEN "00110010" => memoutb1_1 <= "1111111111001100";
      WHEN "00110011" => memoutb1_1 <= "1111001010000111";
      WHEN "00110100" => memoutb1_1 <= "1110100101110000";
      WHEN "00110101" => memoutb1_1 <= "1101110000101011";
      WHEN "00110110" => memoutb1_1 <= "1110100100111100";
      WHEN "00110111" => memoutb1_1 <= "1101101111110111";
      WHEN "00111000" => memoutb1_1 <= "1111111111100110";
      WHEN "00111001" => memoutb1_1 <= "1111001010100001";
      WHEN "00111010" => memoutb1_1 <= "1111111110110010";
      WHEN "00111011" => memoutb1_1 <= "1111001001101101";
      WHEN "00111100" => memoutb1_1 <= "1110100101010110";
      WHEN "00111101" => memoutb1_1 <= "1101110000010001";
      WHEN "00111110" => memoutb1_1 <= "1110100100100010";
      WHEN "00111111" => memoutb1_1 <= "1101101111011101";
      WHEN "01000000" => memoutb1_1 <= "0000000000011010";
      WHEN "01000001" => memoutb1_1 <= "1111001011010101";
      WHEN "01000010" => memoutb1_1 <= "1111111111100110";
      WHEN "01000011" => memoutb1_1 <= "1111001010100001";
      WHEN "01000100" => memoutb1_1 <= "1110100110001010";
      WHEN "01000101" => memoutb1_1 <= "1101110001000101";
      WHEN "01000110" => memoutb1_1 <= "1110100101010110";
      WHEN "01000111" => memoutb1_1 <= "1101110000010001";
      WHEN "01001000" => memoutb1_1 <= "0000000000000000";
      WHEN "01001001" => memoutb1_1 <= "1111001010111011";
      WHEN "01001010" => memoutb1_1 <= "1111111111001100";
      WHEN "01001011" => memoutb1_1 <= "1111001010000111";
      WHEN "01001100" => memoutb1_1 <= "1110100101110000";
      WHEN "01001101" => memoutb1_1 <= "1101110000101011";
      WHEN "01001110" => memoutb1_1 <= "1110100100111100";
      WHEN "01001111" => memoutb1_1 <= "1101101111110111";
      WHEN "01010000" => memoutb1_1 <= "1011101110111101";
      WHEN "01010001" => memoutb1_1 <= "1010111001111000";
      WHEN "01010010" => memoutb1_1 <= "1011101110001001";
      WHEN "01010011" => memoutb1_1 <= "1010111001000100";
      WHEN "01010100" => memoutb1_1 <= "1010010100101101";
      WHEN "01010101" => memoutb1_1 <= "1001011111101000";
      WHEN "01010110" => memoutb1_1 <= "1010010011111001";
      WHEN "01010111" => memoutb1_1 <= "1001011110110100";
      WHEN "01011000" => memoutb1_1 <= "1011101110100011";
      WHEN "01011001" => memoutb1_1 <= "1010111001011110";
      WHEN "01011010" => memoutb1_1 <= "1011101101101111";
      WHEN "01011011" => memoutb1_1 <= "1010111000101010";
      WHEN "01011100" => memoutb1_1 <= "1010010100010011";
      WHEN "01011101" => memoutb1_1 <= "1001011111001110";
      WHEN "01011110" => memoutb1_1 <= "1010010011011111";
      WHEN "01011111" => memoutb1_1 <= "1001011110011010";
      WHEN "01100000" => memoutb1_1 <= "0100010001110111";
      WHEN "01100001" => memoutb1_1 <= "0011011100110010";
      WHEN "01100010" => memoutb1_1 <= "0100010001000011";
      WHEN "01100011" => memoutb1_1 <= "0011011011111110";
      WHEN "01100100" => memoutb1_1 <= "0010110111100111";
      WHEN "01100101" => memoutb1_1 <= "0010000010100010";
      WHEN "01100110" => memoutb1_1 <= "0010110110110011";
      WHEN "01100111" => memoutb1_1 <= "0010000001101110";
      WHEN "01101000" => memoutb1_1 <= "0100010001011101";
      WHEN "01101001" => memoutb1_1 <= "0011011100011000";
      WHEN "01101010" => memoutb1_1 <= "0100010000101001";
      WHEN "01101011" => memoutb1_1 <= "0011011011100100";
      WHEN "01101100" => memoutb1_1 <= "0010110111001101";
      WHEN "01101101" => memoutb1_1 <= "0010000010001000";
      WHEN "01101110" => memoutb1_1 <= "0010110110011001";
      WHEN "01101111" => memoutb1_1 <= "0010000001010100";
      WHEN "01110000" => memoutb1_1 <= "0000000000011010";
      WHEN "01110001" => memoutb1_1 <= "1111001011010101";
      WHEN "01110010" => memoutb1_1 <= "1111111111100110";
      WHEN "01110011" => memoutb1_1 <= "1111001010100001";
      WHEN "01110100" => memoutb1_1 <= "1110100110001010";
      WHEN "01110101" => memoutb1_1 <= "1101110001000101";
      WHEN "01110110" => memoutb1_1 <= "1110100101010110";
      WHEN "01110111" => memoutb1_1 <= "1101110000010001";
      WHEN "01111000" => memoutb1_1 <= "0000000000000000";
      WHEN "01111001" => memoutb1_1 <= "1111001010111011";
      WHEN "01111010" => memoutb1_1 <= "1111111111001100";
      WHEN "01111011" => memoutb1_1 <= "1111001010000111";
      WHEN "01111100" => memoutb1_1 <= "1110100101110000";
      WHEN "01111101" => memoutb1_1 <= "1101110000101011";
      WHEN "01111110" => memoutb1_1 <= "1110100100111100";
      WHEN "01111111" => memoutb1_1 <= "1101101111110111";
      WHEN "10000000" => memoutb1_1 <= "0001011010010000";
      WHEN "10000001" => memoutb1_1 <= "0000100101001011";
      WHEN "10000010" => memoutb1_1 <= "0001011001011100";
      WHEN "10000011" => memoutb1_1 <= "0000100100010111";
      WHEN "10000100" => memoutb1_1 <= "0000000000000000";
      WHEN "10000101" => memoutb1_1 <= "1111001010111011";
      WHEN "10000110" => memoutb1_1 <= "1111111111001100";
      WHEN "10000111" => memoutb1_1 <= "1111001010000111";
      WHEN "10001000" => memoutb1_1 <= "0001011001110110";
      WHEN "10001001" => memoutb1_1 <= "0000100100110001";
      WHEN "10001010" => memoutb1_1 <= "0001011001000010";
      WHEN "10001011" => memoutb1_1 <= "0000100011111101";
      WHEN "10001100" => memoutb1_1 <= "1111111111100110";
      WHEN "10001101" => memoutb1_1 <= "1111001010100001";
      WHEN "10001110" => memoutb1_1 <= "1111111110110010";
      WHEN "10001111" => memoutb1_1 <= "1111001001101101";
      WHEN "10010000" => memoutb1_1 <= "1101001000110011";
      WHEN "10010001" => memoutb1_1 <= "1100010011101110";
      WHEN "10010010" => memoutb1_1 <= "1101000111111111";
      WHEN "10010011" => memoutb1_1 <= "1100010010111010";
      WHEN "10010100" => memoutb1_1 <= "1011101110100011";
      WHEN "10010101" => memoutb1_1 <= "1010111001011110";
      WHEN "10010110" => memoutb1_1 <= "1011101101101111";
      WHEN "10010111" => memoutb1_1 <= "1010111000101010";
      WHEN "10011000" => memoutb1_1 <= "1101001000011001";
      WHEN "10011001" => memoutb1_1 <= "1100010011010100";
      WHEN "10011010" => memoutb1_1 <= "1101000111100101";
      WHEN "10011011" => memoutb1_1 <= "1100010010100000";
      WHEN "10011100" => memoutb1_1 <= "1011101110001001";
      WHEN "10011101" => memoutb1_1 <= "1010111001000100";
      WHEN "10011110" => memoutb1_1 <= "1011101101010101";
      WHEN "10011111" => memoutb1_1 <= "1010111000010000";
      WHEN "10100000" => memoutb1_1 <= "0101101011101101";
      WHEN "10100001" => memoutb1_1 <= "0100110110101000";
      WHEN "10100010" => memoutb1_1 <= "0101101010111001";
      WHEN "10100011" => memoutb1_1 <= "0100110101110100";
      WHEN "10100100" => memoutb1_1 <= "0100010001011101";
      WHEN "10100101" => memoutb1_1 <= "0011011100011000";
      WHEN "10100110" => memoutb1_1 <= "0100010000101001";
      WHEN "10100111" => memoutb1_1 <= "0011011011100100";
      WHEN "10101000" => memoutb1_1 <= "0101101011010011";
      WHEN "10101001" => memoutb1_1 <= "0100110110001110";
      WHEN "10101010" => memoutb1_1 <= "0101101010011111";
      WHEN "10101011" => memoutb1_1 <= "0100110101011010";
      WHEN "10101100" => memoutb1_1 <= "0100010001000011";
      WHEN "10101101" => memoutb1_1 <= "0011011011111110";
      WHEN "10101110" => memoutb1_1 <= "0100010000001111";
      WHEN "10101111" => memoutb1_1 <= "0011011011001010";
      WHEN "10110000" => memoutb1_1 <= "0001011010010000";
      WHEN "10110001" => memoutb1_1 <= "0000100101001011";
      WHEN "10110010" => memoutb1_1 <= "0001011001011100";
      WHEN "10110011" => memoutb1_1 <= "0000100100010111";
      WHEN "10110100" => memoutb1_1 <= "0000000000000000";
      WHEN "10110101" => memoutb1_1 <= "1111001010111011";
      WHEN "10110110" => memoutb1_1 <= "1111111111001100";
      WHEN "10110111" => memoutb1_1 <= "1111001010000111";
      WHEN "10111000" => memoutb1_1 <= "0001011001110110";
      WHEN "10111001" => memoutb1_1 <= "0000100100110001";
      WHEN "10111010" => memoutb1_1 <= "0001011001000010";
      WHEN "10111011" => memoutb1_1 <= "0000100011111101";
      WHEN "10111100" => memoutb1_1 <= "1111111111100110";
      WHEN "10111101" => memoutb1_1 <= "1111001010100001";
      WHEN "10111110" => memoutb1_1 <= "1111111110110010";
      WHEN "10111111" => memoutb1_1 <= "1111001001101101";
      WHEN "11000000" => memoutb1_1 <= "0001011010101010";
      WHEN "11000001" => memoutb1_1 <= "0000100101100101";
      WHEN "11000010" => memoutb1_1 <= "0001011001110110";
      WHEN "11000011" => memoutb1_1 <= "0000100100110001";
      WHEN "11000100" => memoutb1_1 <= "0000000000011010";
      WHEN "11000101" => memoutb1_1 <= "1111001011010101";
      WHEN "11000110" => memoutb1_1 <= "1111111111100110";
      WHEN "11000111" => memoutb1_1 <= "1111001010100001";
      WHEN "11001000" => memoutb1_1 <= "0001011010010000";
      WHEN "11001001" => memoutb1_1 <= "0000100101001011";
      WHEN "11001010" => memoutb1_1 <= "0001011001011100";
      WHEN "11001011" => memoutb1_1 <= "0000100100010111";
      WHEN "11001100" => memoutb1_1 <= "0000000000000000";
      WHEN "11001101" => memoutb1_1 <= "1111001010111011";
      WHEN "11001110" => memoutb1_1 <= "1111111111001100";
      WHEN "11001111" => memoutb1_1 <= "1111001010000111";
      WHEN "11010000" => memoutb1_1 <= "1101001001001101";
      WHEN "11010001" => memoutb1_1 <= "1100010100001000";
      WHEN "11010010" => memoutb1_1 <= "1101001000011001";
      WHEN "11010011" => memoutb1_1 <= "1100010011010100";
      WHEN "11010100" => memoutb1_1 <= "1011101110111101";
      WHEN "11010101" => memoutb1_1 <= "1010111001111000";
      WHEN "11010110" => memoutb1_1 <= "1011101110001001";
      WHEN "11010111" => memoutb1_1 <= "1010111001000100";
      WHEN "11011000" => memoutb1_1 <= "1101001000110011";
      WHEN "11011001" => memoutb1_1 <= "1100010011101110";
      WHEN "11011010" => memoutb1_1 <= "1101000111111111";
      WHEN "11011011" => memoutb1_1 <= "1100010010111010";
      WHEN "11011100" => memoutb1_1 <= "1011101110100011";
      WHEN "11011101" => memoutb1_1 <= "1010111001011110";
      WHEN "11011110" => memoutb1_1 <= "1011101101101111";
      WHEN "11011111" => memoutb1_1 <= "1010111000101010";
      WHEN "11100000" => memoutb1_1 <= "0101101100000111";
      WHEN "11100001" => memoutb1_1 <= "0100110111000010";
      WHEN "11100010" => memoutb1_1 <= "0101101011010011";
      WHEN "11100011" => memoutb1_1 <= "0100110110001110";
      WHEN "11100100" => memoutb1_1 <= "0100010001110111";
      WHEN "11100101" => memoutb1_1 <= "0011011100110010";
      WHEN "11100110" => memoutb1_1 <= "0100010001000011";
      WHEN "11100111" => memoutb1_1 <= "0011011011111110";
      WHEN "11101000" => memoutb1_1 <= "0101101011101101";
      WHEN "11101001" => memoutb1_1 <= "0100110110101000";
      WHEN "11101010" => memoutb1_1 <= "0101101010111001";
      WHEN "11101011" => memoutb1_1 <= "0100110101110100";
      WHEN "11101100" => memoutb1_1 <= "0100010001011101";
      WHEN "11101101" => memoutb1_1 <= "0011011100011000";
      WHEN "11101110" => memoutb1_1 <= "0100010000101001";
      WHEN "11101111" => memoutb1_1 <= "0011011011100100";
      WHEN "11110000" => memoutb1_1 <= "0001011010101010";
      WHEN "11110001" => memoutb1_1 <= "0000100101100101";
      WHEN "11110010" => memoutb1_1 <= "0001011001110110";
      WHEN "11110011" => memoutb1_1 <= "0000100100110001";
      WHEN "11110100" => memoutb1_1 <= "0000000000011010";
      WHEN "11110101" => memoutb1_1 <= "1111001011010101";
      WHEN "11110110" => memoutb1_1 <= "1111111111100110";
      WHEN "11110111" => memoutb1_1 <= "1111001010100001";
      WHEN "11111000" => memoutb1_1 <= "0001011010010000";
      WHEN "11111001" => memoutb1_1 <= "0000100101001011";
      WHEN "11111010" => memoutb1_1 <= "0001011001011100";
      WHEN "11111011" => memoutb1_1 <= "0000100100010111";
      WHEN "11111100" => memoutb1_1 <= "0000000000000000";
      WHEN "11111101" => memoutb1_1 <= "1111001010111011";
      WHEN "11111110" => memoutb1_1 <= "1111111111001100";
      WHEN "11111111" => memoutb1_1 <= "1111001010000111";
      WHEN OTHERS => memoutb1_1 <= "1111001010000111";
    END CASE;
  END PROCESS;

  mem_addr_2 <= delay_pipeline(159) & delay_pipeline(143);

  PROCESS(mem_addr_2)
  BEGIN
    CASE mem_addr_2 IS
      WHEN "00" => memoutb1_2 <= "0000000000000";
      WHEN "01" => memoutb1_2 <= "0000000110100";
      WHEN "10" => memoutb1_2 <= "0110101000101";
      WHEN "11" => memoutb1_2 <= "0110101111001";
      WHEN OTHERS => memoutb1_2 <= "0110101111001";
    END CASE;
  END PROCESS;

  sum1_1 <= resize(memoutb1_1, 17) + resize(memoutb1_2, 17);

  temp_process1 : PROCESS (clk, reset)
  BEGIN
    IF reset = '1' THEN
      sumpipe1_1 <= (OTHERS => '0');
    ELSIF clk'event AND clk = '1' THEN
      IF clk_enable = '1' THEN
        sumpipe1_1 <= sum1_1;
      END IF;
    END IF; 
  END PROCESS temp_process1;

  memoutb1 <= sumpipe1_1(15 DOWNTO 0);

  memoutb1_cast <= resize(memoutb1(15 DOWNTO 0) & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0', 33);

  acc_out_shft <= resize(acc_out(32 DOWNTO 1), 33);

  add_temp <= resize(acc_out_shft, 34) + resize(memoutb1_cast, 34);
  addsub_add <= add_temp(32 DOWNTO 0);

  sub_temp <= resize(acc_out_shft, 34) - resize(memoutb1_cast, 34);
  addsub_sub <= sub_temp(32 DOWNTO 0);

  add_sub_out <= addsub_sub WHEN ( phase_1_1 = '1' ) ELSE
                      addsub_add;

  acc_in <= memoutb1_cast WHEN ( phase_1_2 = '1' ) ELSE
            add_sub_out;

  Acc_reg_process : PROCESS (clk, reset)
  BEGIN
    IF reset = '1' THEN
      acc_out <= (OTHERS => '0');
    ELSIF clk'event AND clk = '1' THEN
      IF clk_enable = '1' THEN
        acc_out <= acc_in;
      END IF;
    END IF; 
  END PROCESS Acc_reg_process;

  Finalsum_reg_process : PROCESS (clk, reset)
  BEGIN
    IF reset = '1' THEN
      final_acc_out <= (OTHERS => '0');
    ELSIF clk'event AND clk = '1' THEN
      IF phase_1_2 = '1' THEN
        final_acc_out <= acc_out;
      END IF;
    END IF; 
  END PROCESS Finalsum_reg_process;

  output_da <= final_acc_out;

  output_typeconvert <= resize(shift_right(output_da(32) & output_da(32 DOWNTO 0) + ( "0" & (output_da(20) & NOT output_da(20) & NOT output_da(20) & NOT output_da(20) & NOT output_da(20) & NOT output_da(20) & NOT output_da(20) & NOT output_da(20) & NOT output_da(20) & NOT output_da(20) & NOT output_da(20) & NOT output_da(20) & NOT output_da(20) & NOT output_da(20) & NOT output_da(20) & NOT output_da(20) & NOT output_da(20) & NOT output_da(20) & NOT output_da(20) & NOT output_da(20))), 20), 16);

  Output_Register_process : PROCESS (clk, reset)
  BEGIN
    IF reset = '1' THEN
      output_register <= (OTHERS => '0');
    ELSIF clk'event AND clk = '1' THEN
      IF phase_1 = '1' THEN
        output_register <= output_typeconvert;
      END IF;
    END IF; 
  END PROCESS Output_Register_process;

  -- Assignment Statements
  filter_out <= std_logic_vector(output_register);
END rtl;