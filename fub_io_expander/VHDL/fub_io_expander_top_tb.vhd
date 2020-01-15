-------------------------------------------------------------------------------
-- Title      : Testbench for design "fub_io_expander_top"
-- Project    : 
-------------------------------------------------------------------------------
-- File       : fub_io_expander_top_tb.vhd
-- Author     : 
-- Company    : 
-- Created    : 2008-11-06
-- Last update: 2008-11-06
-- Platform   : 
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2008 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2008-11-06  1.0      ssanjari	Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

-------------------------------------------------------------------------------

entity fub_io_expander_top_tb is

end fub_io_expander_top_tb;

-------------------------------------------------------------------------------

architecture fub_io_expander_top_tb of fub_io_expander_top_tb is

  component fub_io_expander_top
    generic (
      clk_freq_in_hz  : real;
      rs232_baud_rate : real;
      usb_baud_rate   : real);
    port (
      userpin1      : out std_logic;
      userpin2      : out std_logic;
      userpin3      : out std_logic;
      userpin4      : out std_logic;
      userpin5      : out std_logic;
      userpin6      : out std_logic;
      userpin7      : out std_logic;
      userpin8      : out std_logic;
      userpin9      : out std_logic;
      userpin10     : out std_logic;
      userpin11     : out std_logic;
      userpin12     : out std_logic;
      userpin13     : out std_logic;
      userpin14     : out std_logic;
      userpin15     : out std_logic;
      userpin16     : out std_logic;
      userpin17     : out std_logic;
      userpin18     : out std_logic;
      userpin19     : out std_logic;
      rs485datain1  : in  std_logic;
      rs485datain2  : in  std_logic;
      rs485dataout1 : out std_logic;
      rs485dataout2 : out std_logic;
      reset_in      : in  std_logic;
      request_out   : out std_logic;
      select_in     : in  std_logic;
      piggy_ack1    : out std_logic;
      piggy_ack2    : out std_logic;
      piggy_strb1   : out std_logic;
      piggy_strb2   : out std_logic;
      piggy_r_w1    : out std_logic;
      piggy_r_w2    : out std_logic;
      piggy_io0     : out std_logic;
      piggy_io1     : out std_logic;
      piggy_io2     : out std_logic;
      piggy_io3     : out std_logic;
      piggy_io4     : out std_logic;
      piggy_io5     : out std_logic;
      piggy_io6     : out std_logic;
      piggy_io7     : out std_logic;
      uc_link_a0    : out std_logic;
      uc_link_a1    : out std_logic;
      uc_link_a2    : out std_logic;
      uc_link_a3    : out std_logic;
      uc_link_a4    : out std_logic;
      uc_link_a5    : out std_logic;
      uc_link_a6    : out std_logic;
      uc_link_d0    : out std_logic;
      uc_link_d1    : out std_logic;
      uc_link_d2    : out std_logic;
      uc_link_d3    : out std_logic;
      uc_link_d4    : out std_logic;
      uc_link_d5    : out std_logic;
      uc_link_d6    : out std_logic;
      uc_link_d7    : out std_logic;
      strobe        : out std_logic;
      r_w           : out std_logic;
      mrq           : out std_logic;
      ack           : out std_logic;
      fibclock      : in  std_logic;
      cod1schalter4 : in  std_logic;
      cod1schalter2 : in  std_logic;
      cod1schalter8 : in  std_logic;
      cod1schalter1 : in  std_logic;
      cod2schalter4 : in  std_logic;
      cod2schalter2 : in  std_logic;
      cod2schalter8 : in  std_logic;
      cod2schalter1 : in  std_logic;
      cod3schalter4 : in  std_logic;
      cod3schalter2 : in  std_logic;
      cod3schalter8 : in  std_logic;
      cod3schalter1 : in  std_logic;
      vj1tck        : in  std_logic;
      vj1tdo        : out std_logic;
      vj1tms        : in  std_logic;
      vj1tdi        : in  std_logic;
      vj2tck        : out std_logic;
      vj2tdo        : in  std_logic;
      vj2tms        : out std_logic;
      vj2tdi        : out std_logic;
      vj3tck        : out std_logic;
      vj3tdo        : in  std_logic;
      vj3tms        : out std_logic;
      vj3tdi        : out std_logic;
      bank1io0      : in std_logic;
      bank1io1      : in std_logic;
      bank1io2      : in std_logic;
      bank1io3      : in std_logic;
      bank1io4      : in std_logic;
      bank1io5      : in std_logic;
      bank1io6      : in std_logic;
      bank1io7      : in std_logic;
      bank2io0      : in std_logic;
      bank2io1      : in std_logic;
      bank2io2      : in std_logic;
      bank2io3      : in std_logic;
      bank2io4      : in std_logic;
      bank2io5      : in std_logic;
      bank2io6      : in std_logic;
      bank2io7      : in std_logic;
      testpin       : out std_logic;
      rel1          : out std_logic;
      rel2          : out std_logic;
      led1          : out std_logic;
      led2          : out std_logic;
      buzzer        : out std_logic;
      tast1         : in  std_logic;
      tast2         : in  std_logic;
      usbrx         : out std_logic;
      usbtx         : in  std_logic;
      rs232r1out    : in  std_logic;
      rs232t1in     : out std_logic;
      pin_58        : out std_logic;
      quarz         : in  std_logic;
      hfin          : in  std_logic;
      hfin2         : in  std_logic);
  end component;

  -- component generics
  constant clk_freq_in_hz  : real := 10.0E7;
  constant rs232_baud_rate : real := 9600.0;
  constant usb_baud_rate   : real := 9600.0;

  -- component ports
  signal userpin1      : std_logic;
  signal userpin2      : std_logic;
  signal userpin3      : std_logic;
  signal userpin4      : std_logic;
  signal userpin5      : std_logic;
  signal userpin6      : std_logic;
  signal userpin7      : std_logic;
  signal userpin8      : std_logic;
  signal userpin9      : std_logic;
  signal userpin10     : std_logic;
  signal userpin11     : std_logic;
  signal userpin12     : std_logic;
  signal userpin13     : std_logic;
  signal userpin14     : std_logic;
  signal userpin15     : std_logic;
  signal userpin16     : std_logic;
  signal userpin17     : std_logic;
  signal userpin18     : std_logic;
  signal userpin19     : std_logic;
  signal rs485datain1  : std_logic;
  signal rs485datain2  : std_logic;
  signal rs485dataout1 : std_logic;
  signal rs485dataout2 : std_logic;
  signal reset_in      : std_logic;
  signal request_out   : std_logic;
  signal select_in     : std_logic;
  signal piggy_ack1    : std_logic;
  signal piggy_ack2    : std_logic;
  signal piggy_strb1   : std_logic;
  signal piggy_strb2   : std_logic;
  signal piggy_r_w1    : std_logic;
  signal piggy_r_w2    : std_logic;
  signal piggy_io0     : std_logic;
  signal piggy_io1     : std_logic;
  signal piggy_io2     : std_logic;
  signal piggy_io3     : std_logic;
  signal piggy_io4     : std_logic;
  signal piggy_io5     : std_logic;
  signal piggy_io6     : std_logic;
  signal piggy_io7     : std_logic;
  signal uc_link_a0    : std_logic;
  signal uc_link_a1    : std_logic;
  signal uc_link_a2    : std_logic;
  signal uc_link_a3    : std_logic;
  signal uc_link_a4    : std_logic;
  signal uc_link_a5    : std_logic;
  signal uc_link_a6    : std_logic;
  signal uc_link_d0    : std_logic;
  signal uc_link_d1    : std_logic;
  signal uc_link_d2    : std_logic;
  signal uc_link_d3    : std_logic;
  signal uc_link_d4    : std_logic;
  signal uc_link_d5    : std_logic;
  signal uc_link_d6    : std_logic;
  signal uc_link_d7    : std_logic;
  signal strobe        : std_logic;
  signal r_w           : std_logic;
  signal mrq           : std_logic;
  signal ack           : std_logic;
  signal fibclock      : std_logic;
  signal cod1schalter4 : std_logic;
  signal cod1schalter2 : std_logic;
  signal cod1schalter8 : std_logic;
  signal cod1schalter1 : std_logic;
  signal cod2schalter4 : std_logic;
  signal cod2schalter2 : std_logic;
  signal cod2schalter8 : std_logic;
  signal cod2schalter1 : std_logic;
  signal cod3schalter4 : std_logic;
  signal cod3schalter2 : std_logic;
  signal cod3schalter8 : std_logic;
  signal cod3schalter1 : std_logic;
  signal vj1tck        : std_logic;
  signal vj1tdo        : std_logic;
  signal vj1tms        : std_logic;
  signal vj1tdi        : std_logic;
  signal vj2tck        : std_logic;
  signal vj2tdo        : std_logic;
  signal vj2tms        : std_logic;
  signal vj2tdi        : std_logic;
  signal vj3tck        : std_logic;
  signal vj3tdo        : std_logic;
  signal vj3tms        : std_logic;
  signal vj3tdi        : std_logic;
  signal bank1io0      : std_logic;
  signal bank1io1      : std_logic;
  signal bank1io2      : std_logic;
  signal bank1io3      : std_logic;
  signal bank1io4      : std_logic;
  signal bank1io5      : std_logic;
  signal bank1io6      : std_logic;
  signal bank1io7      : std_logic;
  signal bank2io0      : std_logic;
  signal bank2io1      : std_logic;
  signal bank2io2      : std_logic;
  signal bank2io3      : std_logic;
  signal bank2io4      : std_logic;
  signal bank2io5      : std_logic;
  signal bank2io6      : std_logic;
  signal bank2io7      : std_logic;
  signal testpin       : std_logic;
  signal rel1          : std_logic;
  signal rel2          : std_logic;
  signal led1          : std_logic;
  signal led2          : std_logic;
  signal buzzer        : std_logic;
  signal tast1         : std_logic;
  signal tast2         : std_logic;
  signal usbrx         : std_logic;
  signal usbtx         : std_logic;
  signal rs232r1out    : std_logic;
  signal rs232t1in     : std_logic;
  signal pin_58        : std_logic;
  signal quarz         : std_logic;
  signal hfin          : std_logic;
  signal hfin2         : std_logic;
  
  signal par_imput_vec	: std_logic_vector(15 downto 0);

  -- clock
  signal simclk : std_logic := '1';

begin  -- fub_io_expander_top_tb

  -- component instantiation
  DUT: fub_io_expander_top
    generic map (
      clk_freq_in_hz  => clk_freq_in_hz,
      rs232_baud_rate => rs232_baud_rate,
      usb_baud_rate   => usb_baud_rate)
    port map (
      userpin1      => userpin1,
      userpin2      => userpin2,
      userpin3      => userpin3,
      userpin4      => userpin4,
      userpin5      => userpin5,
      userpin6      => userpin6,
      userpin7      => userpin7,
      userpin8      => userpin8,
      userpin9      => userpin9,
      userpin10     => userpin10,
      userpin11     => userpin11,
      userpin12     => userpin12,
      userpin13     => userpin13,
      userpin14     => userpin14,
      userpin15     => userpin15,
      userpin16     => userpin16,
      userpin17     => userpin17,
      userpin18     => userpin18,
      userpin19     => userpin19,
      rs485datain1  => rs485datain1,
      rs485datain2  => rs485datain2,
      rs485dataout1 => rs485dataout1,
      rs485dataout2 => rs485dataout2,
      reset_in      => reset_in,
      request_out   => request_out,
      select_in     => select_in,
      piggy_ack1    => piggy_ack1,
      piggy_ack2    => piggy_ack2,
      piggy_strb1   => piggy_strb1,
      piggy_strb2   => piggy_strb2,
      piggy_r_w1    => piggy_r_w1,
      piggy_r_w2    => piggy_r_w2,
      piggy_io0     => piggy_io0,
      piggy_io1     => piggy_io1,
      piggy_io2     => piggy_io2,
      piggy_io3     => piggy_io3,
      piggy_io4     => piggy_io4,
      piggy_io5     => piggy_io5,
      piggy_io6     => piggy_io6,
      piggy_io7     => piggy_io7,
      uc_link_a0    => uc_link_a0,
      uc_link_a1    => uc_link_a1,
      uc_link_a2    => uc_link_a2,
      uc_link_a3    => uc_link_a3,
      uc_link_a4    => uc_link_a4,
      uc_link_a5    => uc_link_a5,
      uc_link_a6    => uc_link_a6,
      uc_link_d0    => uc_link_d0,
      uc_link_d1    => uc_link_d1,
      uc_link_d2    => uc_link_d2,
      uc_link_d3    => uc_link_d3,
      uc_link_d4    => uc_link_d4,
      uc_link_d5    => uc_link_d5,
      uc_link_d6    => uc_link_d6,
      uc_link_d7    => uc_link_d7,
      strobe        => strobe,
      r_w           => r_w,
      mrq           => mrq,
      ack           => ack,
      fibclock      => fibclock,
      cod1schalter4 => cod1schalter4,
      cod1schalter2 => cod1schalter2,
      cod1schalter8 => cod1schalter8,
      cod1schalter1 => cod1schalter1,
      cod2schalter4 => cod2schalter4,
      cod2schalter2 => cod2schalter2,
      cod2schalter8 => cod2schalter8,
      cod2schalter1 => cod2schalter1,
      cod3schalter4 => cod3schalter4,
      cod3schalter2 => cod3schalter2,
      cod3schalter8 => cod3schalter8,
      cod3schalter1 => cod3schalter1,
      vj1tck        => vj1tck,
      vj1tdo        => vj1tdo,
      vj1tms        => vj1tms,
      vj1tdi        => vj1tdi,
      vj2tck        => vj2tck,
      vj2tdo        => vj2tdo,
      vj2tms        => vj2tms,
      vj2tdi        => vj2tdi,
      vj3tck        => vj3tck,
      vj3tdo        => vj3tdo,
      vj3tms        => vj3tms,
      vj3tdi        => vj3tdi,
      bank1io0      => bank1io0,
      bank1io1      => bank1io1,
      bank1io2      => bank1io2,
      bank1io3      => bank1io3,
      bank1io4      => bank1io4,
      bank1io5      => bank1io5,
      bank1io6      => bank1io6,
      bank1io7      => bank1io7,
      bank2io0      => bank2io0,
      bank2io1      => bank2io1,
      bank2io2      => bank2io2,
      bank2io3      => bank2io3,
      bank2io4      => bank2io4,
      bank2io5      => bank2io5,
      bank2io6      => bank2io6,
      bank2io7      => bank2io7,
      testpin       => testpin,
      rel1          => rel1,
      rel2          => rel2,
      led1          => led1,
      led2          => led2,
      buzzer        => buzzer,
      tast1         => tast1,
      tast2         => tast2,
      usbrx         => usbrx,
      usbtx         => usbtx,
      rs232r1out    => rs232r1out,
      rs232t1in     => rs232t1in,
      pin_58        => pin_58,
      quarz         => quarz,
      hfin          => hfin,
      hfin2         => hfin2);

  -- clock generation
  simclk <= not simclk after 10 ns; -- 50 MHz
  quarz <= simclk;

-- diese mit zeitangabe benutzen bitte

(bank1io0,bank1io1,bank1io2,bank1io3,bank1io4,bank1io5,bank1io6,bank1io7,bank2io0,bank2io1,bank2io2,bank2io3,bank2io4,bank2io5,bank2io6,bank2io7) <= par_imput_vec;

	stimu : process
	Begin
		wait for 300 ns;
		tast2 <= '1';
		par_imput_vec <= "1010101010101010";
		wait for 40 ns;
		tast2 <= '0';
		wait for 10 us;
		tast2 <= '1';
		par_imput_vec <= "1111000011110000";
		wait for 40 ns;
		tast2 <= '0';
		wait for 10 us;
	end process stimu;

   reset	: process
   Begin
   		tast1 <= '1';
		wait for 60 ns;
		tast1 <= '0';
		wait;
	end process reset;		












--   bank1io0 : out std_logic;
--     bank1io1 : out std_logic;
--     bank1io2 : out std_logic;
--     bank1io3 : out std_logic;
--     bank1io4 : out std_logic;
--     bank1io5 : out std_logic;
--     bank1io6 : out std_logic;
--     bank1io7 : out std_logic;
--     bank2io0 : out std_logic;
--     bank2io1 : out std_logic;
--     bank2io2 : out std_logic;
--     bank2io3 : out std_logic;
--     bank2io4 : out std_logic;
--     bank2io5 : out std_logic;
--     bank2io6 : out std_logic;
--     bank2io7 : out std_logic;



end fub_io_expander_top_tb;

