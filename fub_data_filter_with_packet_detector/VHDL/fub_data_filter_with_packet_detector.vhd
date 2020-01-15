-------------------------------------------------------------------------------
-- fub_data_filter filters all fub packages (blacklisted) that are specified in data_vector_i. 
-- M. Kumm
-- 2009-06-24 added generic switch for whitelisted / blacklisted filtering C. Thielmann
-- 2010-07-1  detect_on_data_o was added
-------------------------------------------------------------------------------
-- Package Definition

library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_arith.all;
use IEEE.STD_LOGIC_unsigned.all;
use ieee.math_real.all;

--use work.init_rom_pkg.all;

package fub_data_filter_with_packet_detector_pkg is

	component fub_data_filter_with_packet_detector
	generic (
		fub_data_width      	: integer;
		fub_addr_width       	: integer;
		no_of_data_words		: integer;
		whitelist				: std_logic := '0'
	);
	port (
		rst_i					: in  std_logic;
		clk_i					: in  std_logic;
		detect_on_address_i		: in  std_logic_vector(fub_addr_width-1 downto 0);
		detect_on_data_vector_i	: in  std_logic_vector(no_of_data_words*fub_data_width-1 downto 0);
		fub_in_data_i			: in  std_logic_vector(fub_data_width-1 downto 0);
		fub_in_addr_i			: in  std_logic_vector(fub_addr_width-1 downto 0);
		fub_in_strb_i			: in  std_logic;
		fub_in_busy_o			: out std_logic;
		fub_out_data_o			: out std_logic_vector(fub_data_width-1 downto 0);
		fub_out_addr_o			: out std_logic_vector(fub_addr_width-1 downto 0);
		fub_out_strb_o			: out std_logic;
		fub_out_busy_i			: in  std_logic;
		detect_on_data_o		: out std_logic
	);
	end component;
end fub_data_filter_with_packet_detector_pkg;

package body fub_data_filter_with_packet_detector_pkg is
end fub_data_filter_with_packet_detector_pkg;

-- Entity Definition

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;


entity fub_data_filter_with_packet_detector is
generic (
		fub_data_width      	: integer;
		fub_addr_width       	: integer;
		no_of_data_words		: integer 	:= 10;
		whitelist				: std_logic := '0'	-- '0' = blacklist, '1' = whitelist
		);								
port (
		rst_i					: in  std_logic;
		clk_i					: in  std_logic;
		detect_on_address_i		: in  std_logic_vector(fub_addr_width-1 downto 0);
		detect_on_data_vector_i	: in  std_logic_vector(no_of_data_words*fub_data_width-1 downto 0);
		fub_in_data_i			: in  std_logic_vector(fub_data_width-1 downto 0);
		fub_in_addr_i			: in  std_logic_vector(fub_addr_width-1 downto 0);
		fub_in_strb_i			: in  std_logic;
		fub_in_busy_o			: out std_logic;
		fub_out_data_o			: out std_logic_vector(fub_data_width-1 downto 0);
		fub_out_addr_o			: out std_logic_vector(fub_addr_width-1 downto 0);
		fub_out_strb_o			: out std_logic;
		fub_out_busy_i			: in  std_logic;
		detect_on_data_o		: out std_logic
	);
end fub_data_filter_with_packet_detector;

architecture arch_fub_data_filter_with_packet_detector of fub_data_filter_with_packet_detector is 

  type par_data_array_type is array(0 to no_of_data_words-1) of std_logic_vector(fub_data_width-1 downto 0);
  signal par_data_array : par_data_array_type;

  signal try_again_flag : std_logic;

begin
  parallel_to_array_gen : for i in 0 to no_of_data_words-1 generate
    par_data_array(i)  <= detect_on_data_vector_i((i+1)*fub_data_width-1 downto i*fub_data_width);
  end generate;

  process (clk_i, rst_i)
  variable data_valid : std_logic;
  begin
    if rst_i = '1' then
      fub_in_busy_o 	<= '1';
      fub_out_strb_o 	<= '0';
	  fub_out_data_o 	<= (others => '0');
	  fub_out_addr_o 	<= (others => '0');
      try_again_flag 	<= '0';
    elsif rising_edge(clk_i) then
      fub_out_strb_o 	<= '0';
	  detect_on_data_o	<= '0';
	  fub_in_busy_o 	<= '0';
	  data_valid := not whitelist;
      if (fub_in_strb_i = '1' and  fub_in_addr_i = detect_on_address_i) or try_again_flag='1'  then  -- or try_again_flag='1'
        fub_in_busy_o 	<= '1';
        for i in 0 to no_of_data_words-1 loop
          if fub_in_data_i = par_data_array(i) then
			data_valid := whitelist;
          end if;
        end loop ;            
        if data_valid = '1' then
            if fub_out_busy_i = '0' then
              fub_out_strb_o 	<= '1';
              fub_out_data_o 	<= fub_in_data_i;
              fub_out_addr_o 	<= fub_in_addr_i;
              try_again_flag 	<= '0';
			  detect_on_data_o	<= '1';
			  fub_in_busy_o 	<= '0';
            else
              try_again_flag 	<= '1';
            end if;
        end if;
      end if;
     end if;
  end process;

end arch_fub_data_filter_with_packet_detector;
