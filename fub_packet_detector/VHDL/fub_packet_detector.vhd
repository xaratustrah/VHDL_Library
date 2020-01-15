-------------------------------------------------------------------------------
-- FUB Packet detector
-- Asserts a pulse of one clock width if the desired pattern is present at the
-- FUB input.
-- S. Sanjari OKT 2007
-------------------------------------------------------------------------------

-- Package Definition

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

package fub_packet_detector_pkg is

  component fub_packet_detector
    generic (
      detect_on_address        : integer;
      enable_address_detection : boolean;
      detect_on_data           : integer;
      enable_data_detection    : boolean;
      fub_data_width           : integer;
      fub_adr_width            : integer
    );
    port (
      clk_i      : in  std_logic;
      rst_i      : in  std_logic;
      fub_data_i : in  std_logic_vector(fub_data_width-1 downto 0);
      fub_addr_i : in  std_logic_vector(fub_adr_width-1 downto 0);
      fub_strb_i : in  std_logic;
      fub_busy_o : out std_logic;
      detect_o   : out std_logic);
  end component;

end fub_packet_detector_pkg;

package body fub_packet_detector_pkg is
end fub_packet_detector_pkg;

-- Entity Definition

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity fub_packet_detector is
  
  generic (
    detect_on_address        : integer;
    enable_address_detection : boolean;
    detect_on_data           : integer;
    enable_data_detection    : boolean;
    fub_data_width           : integer;
    fub_adr_width            : integer
  );

  port (
    clk_i : in std_logic;
    rst_i : in std_logic;
    fub_data_i : in  std_logic_vector(fub_data_width-1 downto 0);
    fub_addr_i : in  std_logic_vector(fub_adr_width-1 downto 0);
    fub_strb_i : in  std_logic;
    fub_busy_o : out std_logic;
    detect_o : out std_logic
  );

end fub_packet_detector;

architecture fub_packet_detector_arch of fub_packet_detector is

begin  -- fub_packet_detector_arch

  p_main : process (clk_i, rst_i)
  begin  -- process p_main
    if rst_i = '1' then                 -- asynchronous reset (active high)
      
      detect_o   <= '0';
      fub_busy_o <= '0';
      
    elsif clk_i'event and clk_i = '1' then  -- rising clock edge
      fub_busy_o <= '0';
      detect_o <= '0';                      -- reset on each clock
      if fub_strb_i = '1' then
        if enable_data_detection = true and enable_address_detection = false then
          if fub_data_i = conv_std_logic_vector(detect_on_data,fub_data_width) then
              detect_o <= '1';
          end if;
        elsif enable_address_detection = true and enable_data_detection = false then
          if fub_addr_i = conv_std_logic_vector(detect_on_address,fub_adr_width) then
              detect_o <= '1';
          end if;
        elsif enable_address_detection = true and enable_data_detection = true then
          if fub_addr_i = conv_std_logic_vector(detect_on_address,fub_adr_width) and fub_data_i = conv_std_logic_vector(detect_on_data,fub_data_width) then
            detect_o <= '1';
          end if;
        end if;
      end if;
    end if;
  end process p_main;

end fub_packet_detector_arch;
