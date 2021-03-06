-- megafunction wizard: %LPM_MULT%
-- GENERATION: STANDARD
-- VERSION: WM1.0
-- MODULE: lpm_mult 

-- ============================================================
-- File Name: mult.vhd
-- Megafunction Name(s):
-- 			lpm_mult
--
-- Simulation Library Files(s):
-- 			lpm
-- ============================================================
-- ************************************************************
-- THIS IS A WIZARD-GENERATED FILE. DO NOT EDIT THIS FILE!
--
-- 7.2 Build 151 09/26/2007 SJ Web Edition
-- ************************************************************


--Copyright (C) 1991-2007 Altera Corporation
--Your use of Altera Corporation's design tools, logic functions 
--and other software and tools, and its AMPP partner logic 
--functions, and any output files from any of the foregoing 
--(including device programming or simulation files), and any 
--associated documentation or information are expressly subject 
--to the terms and conditions of the Altera Program License 
--Subscription Agreement, Altera MegaCore Function License 
--Agreement, or other applicable license agreement, including, 
--without limitation, that your use is for the sole purpose of 
--programming logic devices manufactured by Altera and sold by 
--Altera or its authorized distributors.  Please refer to the 
--applicable agreement for further details.


LIBRARY ieee;
USE ieee.std_logic_1164.all;

LIBRARY lpm;
USE lpm.all;

ENTITY mult IS
	PORT
	(
		clock		: IN STD_LOGIC ;
		dataa		: IN STD_LOGIC_VECTOR (27 DOWNTO 0);
		datab		: IN STD_LOGIC_VECTOR (27 DOWNTO 0);
		result		: OUT STD_LOGIC_VECTOR (55 DOWNTO 0)
	);
END mult;


ARCHITECTURE SYN OF mult IS

	SIGNAL sub_wire0	: STD_LOGIC_VECTOR (55 DOWNTO 0);



	COMPONENT lpm_mult
	GENERIC (
		lpm_hint		: STRING;
		lpm_pipeline		: NATURAL;
		lpm_representation		: STRING;
		lpm_type		: STRING;
		lpm_widtha		: NATURAL;
		lpm_widthb		: NATURAL;
		lpm_widthp		: NATURAL
	);
	PORT (
			dataa	: IN STD_LOGIC_VECTOR (27 DOWNTO 0);
			datab	: IN STD_LOGIC_VECTOR (27 DOWNTO 0);
			clock	: IN STD_LOGIC ;
			result	: OUT STD_LOGIC_VECTOR (55 DOWNTO 0)
	);
	END COMPONENT;

BEGIN
	result    <= sub_wire0(55 DOWNTO 0);

	lpm_mult_component : lpm_mult
	GENERIC MAP (
		lpm_hint => "MAXIMIZE_SPEED=5",
		lpm_pipeline => 8,
		lpm_representation => "SIGNED",
		lpm_type => "LPM_MULT",
		lpm_widtha => 28,
		lpm_widthb => 28,
		lpm_widthp => 56
	)
	PORT MAP (
		dataa => dataa,
		datab => datab,
		clock => clock,
		result => sub_wire0
	);



END SYN;

-- ============================================================
-- CNX file retrieval info
-- ============================================================
-- Retrieval info: PRIVATE: AutoSizeResult NUMERIC "0"
-- Retrieval info: PRIVATE: B_isConstant NUMERIC "0"
-- Retrieval info: PRIVATE: ConstantB NUMERIC "0"
-- Retrieval info: PRIVATE: INTENDED_DEVICE_FAMILY STRING "MAX II"
-- Retrieval info: PRIVATE: LPM_PIPELINE NUMERIC "8"
-- Retrieval info: PRIVATE: Latency NUMERIC "1"
-- Retrieval info: PRIVATE: OptionalSum NUMERIC "0"
-- Retrieval info: PRIVATE: SYNTH_WRAPPER_GEN_POSTFIX STRING "0"
-- Retrieval info: PRIVATE: SignedMult NUMERIC "1"
-- Retrieval info: PRIVATE: USE_MULT NUMERIC "1"
-- Retrieval info: PRIVATE: ValidConstant NUMERIC "0"
-- Retrieval info: PRIVATE: WidthA NUMERIC "28"
-- Retrieval info: PRIVATE: WidthB NUMERIC "28"
-- Retrieval info: PRIVATE: WidthP NUMERIC "56"
-- Retrieval info: PRIVATE: WidthS NUMERIC "1"
-- Retrieval info: PRIVATE: aclr NUMERIC "0"
-- Retrieval info: PRIVATE: clken NUMERIC "0"
-- Retrieval info: PRIVATE: optimize NUMERIC "1"
-- Retrieval info: CONSTANT: LPM_HINT STRING "MAXIMIZE_SPEED=5"
-- Retrieval info: CONSTANT: LPM_PIPELINE NUMERIC "8"
-- Retrieval info: CONSTANT: LPM_REPRESENTATION STRING "SIGNED"
-- Retrieval info: CONSTANT: LPM_TYPE STRING "LPM_MULT"
-- Retrieval info: CONSTANT: LPM_WIDTHA NUMERIC "28"
-- Retrieval info: CONSTANT: LPM_WIDTHB NUMERIC "28"
-- Retrieval info: CONSTANT: LPM_WIDTHP NUMERIC "56"
-- Retrieval info: USED_PORT: clock 0 0 0 0 INPUT NODEFVAL clock
-- Retrieval info: USED_PORT: dataa 0 0 28 0 INPUT NODEFVAL dataa[27..0]
-- Retrieval info: USED_PORT: datab 0 0 28 0 INPUT NODEFVAL datab[27..0]
-- Retrieval info: USED_PORT: result 0 0 56 0 OUTPUT NODEFVAL result[55..0]
-- Retrieval info: CONNECT: @dataa 0 0 28 0 dataa 0 0 28 0
-- Retrieval info: CONNECT: result 0 0 56 0 @result 0 0 56 0
-- Retrieval info: CONNECT: @datab 0 0 28 0 datab 0 0 28 0
-- Retrieval info: CONNECT: @clock 0 0 0 0 clock 0 0 0 0
-- Retrieval info: LIBRARY: lpm lpm.lpm_components.all
-- Retrieval info: GEN_FILE: TYPE_NORMAL mult.vhd TRUE
-- Retrieval info: GEN_FILE: TYPE_NORMAL mult.inc FALSE
-- Retrieval info: GEN_FILE: TYPE_NORMAL mult.cmp TRUE
-- Retrieval info: GEN_FILE: TYPE_NORMAL mult.bsf FALSE
-- Retrieval info: GEN_FILE: TYPE_NORMAL mult_inst.vhd FALSE
-- Retrieval info: GEN_FILE: TYPE_NORMAL mult_waveforms.html TRUE
-- Retrieval info: GEN_FILE: TYPE_NORMAL mult_wave*.jpg FALSE
-- Retrieval info: LIB_FILE: lpm
