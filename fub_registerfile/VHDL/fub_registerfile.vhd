-------------------------------------------------------------------------------
-- 
-- FUB to Registerfile component
--
-- S. Sanjari
-------------------------------------------------------------------------------
-- Package Definition
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package fub_registerfile_pkg is

  component fub_registerfile
    generic (
      no_of_registers   : integer;
      fub_address_width : integer;
      fub_data_width    : integer);
    port (
      clk_i          : in  std_logic;
      rst_i          : in  std_logic;
      fub_strb_i     : in  std_logic;
      fub_data_i     : in  std_logic_vector (fub_data_width - 1 downto 0);
      fub_addr_i     : in  std_logic_vector (fub_address_width - 1 downto 0);
      fub_busy_o     : out std_logic;
      registerfile_o : out std_logic_vector (no_of_registers * fub_data_width - 1 downto 0));
  end component;

end fub_registerfile_pkg;

package body fub_registerfile_pkg is
end fub_registerfile_pkg;

-- Entity Definition

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fub_registerfile is

  generic (
    no_of_registers   : integer := 6;
    fub_address_width : integer := 16;
    fub_data_width    : integer := 8);  -- this is the same is register width

  port (
    clk_i : in std_logic;
    rst_i : in std_logic;

    fub_strb_i : in  std_logic;
    fub_data_i : in  std_logic_vector (fub_data_width - 1 downto 0);
    fub_addr_i : in  std_logic_vector (fub_address_width - 1 downto 0);
    fub_busy_o : out std_logic;

    registerfile_o : out std_logic_vector (no_of_registers * fub_data_width - 1 downto 0)
    );

end fub_registerfile;

architecture fub_registerfile_arch of fub_registerfile is

  type registerfile_type is array(0 to no_of_registers - 1) of
    std_logic_vector(fub_data_width - 1 downto 0);
  signal local_registerfile : registerfile_type;

  type state_type is (RESET_REGISTERS, USE_REGISTERS);
  signal state : state_type;

  signal counter : integer range 0 to no_of_registers - 1;
  
begin  -- fub_registerfile_arch

  registerfile_connection_gen : for i in 0 to no_of_registers - 1 generate
    registerfile_o ((i+1)*fub_data_width - 1 downto i*fub_data_width) <= local_registerfile (i);
  end generate registerfile_connection_gen;

  mail_p : process (clk_i, rst_i)
  begin  -- process mail_p
    if rst_i = '1' then                 -- asynchronous reset (active high)

      fub_busy_o <= '1';
      counter    <= 0;
      state      <= RESET_REGISTERS;
      
    elsif clk_i'event and clk_i = '1' then  -- rising clock edge

      case state is
        when RESET_REGISTERS =>
          if counter = (no_of_registers - 1) then
            fub_busy_o                   <= '0';
            local_registerfile (counter) <= (others => '0');
            state                        <= USE_REGISTERS;
          else
            local_registerfile (counter) <= (others => '0');
            counter                      <= counter + 1;
          end if;
          
        when USE_REGISTERS =>
          if fub_strb_i = '1' then
            if to_integer(unsigned(fub_addr_i)) < no_of_registers then
              local_registerfile(to_integer(unsigned(fub_addr_i))) <= fub_data_i;
            end if;
          end if;

        when others => null;

      end case;
    end if;
  end process mail_p;

end fub_registerfile_arch;
