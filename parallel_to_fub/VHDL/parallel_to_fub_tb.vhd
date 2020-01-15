library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_arith.all;
use IEEE.STD_LOGIC_unsigned.all;
use ieee.math_real.all;

use work.parallel_to_fub_pkg.all;

entity parallel_to_fub_tb is
  generic (
    clk_period       : time    := 10 ns;
    no_of_data_bytes : integer := 10;
    adr_width        : integer := 4
    );
end parallel_to_fub_tb;

architecture parallel_to_fub_tb_arch of parallel_to_fub_tb is

  signal clk : std_logic := '0';
  signal rst : std_logic;

  type par_data_array_type is array(0 to no_of_data_bytes-1) of
    std_logic_vector(7 downto 0);
  signal par_data_array : par_data_array_type;

  signal par_data : std_logic_vector(no_of_data_bytes*8-1 downto 0);

  type par_adr_array_type is array(0 to no_of_data_bytes-1) of
    std_logic_vector(adr_width-1 downto 0);
  signal par_adr_array : par_adr_array_type;

  signal par_adr : std_logic_vector(no_of_data_bytes*adr_width-1 downto 0);
  
begin
  par_data_array(0) <= x"00";
  par_data_array(1) <= x"11";
  par_data_array(2) <= x"22";
  par_data_array(3) <= x"33";
  par_data_array(4) <= x"44";
  par_data_array(5) <= x"55";
  par_data_array(6) <= x"66";
  par_data_array(7) <= x"77";
  par_data_array(8) <= x"88";
  par_data_array(9) <= x"99";

  par_adr_array(0) <= x"9";
  par_adr_array(1) <= x"8";
  par_adr_array(2) <= x"7";
  par_adr_array(3) <= x"6";
  par_adr_array(4) <= x"5";
  par_adr_array(5) <= x"4";
  par_adr_array(6) <= x"3";
  par_adr_array(7) <= x"2";
  par_adr_array(8) <= x"1";
  par_adr_array(9) <= x"0";

  array_to_parallel_gen : for i in 0 to no_of_data_bytes-1 generate
    par_data((i+1)*8-1 downto i*8)                <= par_data_array(i);
    par_adr((i+1)*adr_width-1 downto i*adr_width) <= par_adr_array(i);
  end generate;

  parallel_to_fub_inst : parallel_to_fub
    generic map (
      no_of_data_bytes => no_of_data_bytes,
      adr_width        => adr_width
      )
    port map(
      rst_i      => rst,
      clk_i      => clk,
      par_data_i => par_data,
      par_adr_i  => par_adr,
      par_str_i  => '1',
      par_busy_o => open,
      fub_data_o => open,
      fub_adr_o  => open,
      fub_str_o  => open,
      fub_busy_i => '0'
      );

  clk <= not clk after clk_period/2;
  rst <= '1', '0' after 4*clk_period;
  
end parallel_to_fub_tb_arch;
