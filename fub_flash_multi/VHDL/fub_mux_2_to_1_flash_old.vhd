-------------------------------------------------------------------------------
--
-- M. Kumm
-- Flash-modification by T.Wollmann2010
--
-------------------------------------------------------------------------------

-- Package Definition

library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_arith.all;
use IEEE.STD_LOGIC_unsigned.all;

package fub_mux_2_to_1_flash_pkg is
  component fub_mux_2_to_1_flash
    generic (
      priority        : integer;
      fubA_data_width : integer;
      fubA_adr_width  : integer;
      fubB_data_width : integer;
      fubB_adr_width  : integer;
      fub_data_width  : integer;
      fub_adr_width   : integer;
			spi_address_A		:	integer;
			spi_address_B		:	integer
    );
    port (
      clk_i       			: in    std_logic;
      rst_i       			: in    std_logic;
      --  Flash FUB channel
      fubA_data_i 			: in  std_logic_vector(fubA_data_width-1 downto 0);
      fubA_adr_i  			: in  std_logic_vector(fubA_adr_width-1 downto 0);
      fubA_str_i  			: in  std_logic;
      fubA_busy_o 			: out std_logic;
			fubA_read_flag_i	:	in	std_logic;
			flash_byte_cnt_i	:	in	integer;
      -- FUB channel B
      fubB_data_i 			: in  std_logic_vector(fubB_data_width-1 downto 0);
      fubB_adr_i  			: in  std_logic_vector(fubB_adr_width-1 downto 0);
      fubB_str_i  			: in  std_logic;
      fubB_busy_o 			: out std_logic;
      -- FUB output	
      fub_data_o  			: out std_logic_vector(fub_data_width-1 downto 0);
      fub_adr_o   			: out std_logic_vector(fub_adr_width-1 downto 0);
      fub_str_o   			: out std_logic;
      fub_busy_i  			: in  std_logic;
			read_flag_o				:	out	std_logic;
			flash_byte_cnt_o	:	out	integer
    );
  end component;
end fub_mux_2_to_1_flash_pkg;

package body fub_mux_2_to_1_flash_pkg is
end fub_mux_2_to_1_flash_pkg;

-- Entity Definition

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity fub_mux_2_to_1_flash is
  generic (
    priority        : integer := 1;     -- 1: channel A, 2: channel B, 0: both
    fubA_data_width : integer := 8;
    fubA_adr_width  : integer := 8;
    fubB_data_width : integer := 8;
    fubB_adr_width  : integer := 8;
    fub_data_width  : integer := 8;
    fub_adr_width   : integer := 8;
		spi_address_A		:	integer	:= 0;
    spi_address_B		:	integer	:= 1
	);
  port (
    clk_i       			: in  std_logic;
    rst_i       			: in  std_logic;
    -- Flash FUB channel
    fubA_data_i 			: in  std_logic_vector(fubA_data_width-1 downto 0);
    fubA_adr_i  			: in  std_logic_vector(fubA_adr_width-1 downto 0);
    fubA_str_i  			: in  std_logic;
    fubA_busy_o 			: out std_logic;
		fubA_read_flag_i	:	in	std_logic;
		flash_byte_cnt_i	:	in	integer;
    -- FUB channel B
    fubB_data_i 			: in  std_logic_vector(fubB_data_width-1 downto 0);
    fubB_adr_i  			: in  std_logic_vector(fubB_adr_width-1 downto 0);
    fubB_str_i  			: in  std_logic;
    fubB_busy_o 			: out std_logic;
    -- FUB output
    fub_data_o  			: out std_logic_vector(fub_data_width-1 downto 0);
    fub_adr_o   			: out std_logic_vector(fub_adr_width-1 downto 0);
    fub_str_o   			: out std_logic;
    fub_busy_i  			: in  std_logic;
		read_flag_o				:	out	std_logic;
		flash_byte_cnt_o	:	out	integer
    );
begin
  assert fubA_adr_width <= fub_adr_width
                           report "fubA_adr_width muss kleiner gleich als fub_adr_width sein!"
                           severity error;
  assert fubA_data_width <= fub_data_width
                            report "fubA_data_width muss kleiner gleich als fub_data_width sein!"
                            severity error;
  assert fubB_adr_width <= fub_adr_width
                           report "fubB_adr_width muss kleiner gleich als fub_adr_width sein!"
                           severity error;
  assert fubB_data_width <= fub_data_width
                            report "fubB_data_width muss kleiner gleich als fub_data_width sein!"
                            severity error;
end entity fub_mux_2_to_1_flash;

architecture fub_mux_2_to_1_flash_arch of fub_mux_2_to_1_flash is

  type states is (
    WAIT_STATE,
    FLAG_STATE
    );

  type channel_flag_type is
  record
    set, rst, output : std_logic;
  end record;

  signal stateA    : states;
  signal flagA     : channel_flag_type;
  signal fubA_data : std_logic_vector(fubA_data_i'length-1 downto 0);
  signal fubA_adr  : std_logic_vector(fubA_adr_i'length-1 downto 0);
	signal fubA_cnt	 : integer;

  signal stateB    : states;
  signal flagB     : channel_flag_type;
  signal fubB_data : std_logic_vector(fubB_data_i'length-1 downto 0);
  signal fubB_adr  : std_logic_vector(fubB_adr_i'length-1 downto 0);
	signal fubB_cnt	 : integer;

  signal ch_num 				: std_logic;
	
	signal	rdy_A		:	std_logic;
	signal	rdy_B		:	std_logic;
	
	signal read_flag			:	std_logic;
	signal flash_byte_cnt	:	integer;

begin

  flagA.output <= '0' when rst_i = '1' else
                        '1' when flagA.set = '1' and flagA.rst = '0' else
                        '0' when flagA.set = '0' and flagA.rst = '1' else
                        flagA.output;

  flagB.output <= '0' when rst_i = '1' else
                        '1' when flagB.set = '1' and flagB.rst = '0' else
                        '0' when flagB.set = '0' and flagB.rst = '1' else
                        flagB.output;
												
  channel_A_ctrl : process (rst_i, clk_i, stateA, flagA, fubA_str_i)
  begin
    if (rst_i = '1') then
      fubA_busy_o <= '1';
      flagA.set   <= '0';
      stateA      <= WAIT_STATE;
			read_flag		<=	'0';
			flash_byte_cnt	<=	0;
			fubA_adr		<=	(others => '0');
			fubA_cnt		<=	0;
    elsif (clk_i = '1' and clk_i'event) then
      case stateA is
        when WAIT_STATE =>
          if fubA_str_i = '1' then
            fubA_busy_o <= '1';
            if flagA.output = '0' then
              fubA_data 			<=	fubA_data_i;
              fubA_adr  			<=	fubA_adr_i;
							read_flag				<=	fubA_read_flag_i;
							flash_byte_cnt	<=	flash_byte_cnt_i;
              flagA.set 			<=	'1';
              stateA    			<=	FLAG_STATE;
							fubA_cnt				<=	conv_integer(fubA_adr_i);
            end if;
          else
            fubA_busy_o <= '0';
          end if;
        when FLAG_STATE =>
          flagA.set <= '0';
          if flagA.output = '0' then
            fubA_busy_o <= '0';
            stateA      <= WAIT_STATE;
          else
            fubA_busy_o <= '1';
          end if;
        when others => null;
      end case;
    end if;
  end process channel_A_ctrl;

  channel_B_ctrl : process (rst_i, clk_i, stateB, flagB, fubB_str_i)
  begin
    if (rst_i = '1') then
      fubB_busy_o <= '1';
      flagB.set   <= '0';
      stateB      <= WAIT_STATE;
			fubB_adr		<=	(others => '0');
			fubB_cnt		<=	0;
    elsif (clk_i = '1' and clk_i'event) then
      case stateB is
        when WAIT_STATE =>
          if (fubB_str_i = '1') then
            fubB_busy_o <= '1';
            if (flagB.output = '0') then
              fubB_data <=	fubB_data_i;
              fubB_adr  <=	fubB_adr_i;
              flagB.set <=	'1';
              stateB    <=	FLAG_STATE;
							fubB_cnt	<=	conv_integer(fubB_adr_i);
            end if;
          else
            fubB_busy_o <= '0';
          end if;
        when FLAG_STATE =>
          flagB.set <= '0';
          if (flagB.output = '0') then
            fubB_busy_o <= '0';
            stateB      <= WAIT_STATE;
          else
            fubB_busy_o <= '1';
          end if;
        when others => null;
      end case;
    end if;
  end process channel_B_ctrl;

  output_ctrl : process(rst_i, clk_i, flagA, flagB, fub_busy_i)
  begin
    if (rst_i = '1') then
      fub_str_o  <= '0';
      flagA.rst  <= '0';
      flagB.rst  <= '0';
      ch_num     <= '0';
      fub_data_o <= (others => '0');
      fub_adr_o  <= (others => '0');
			read_flag_o<=	'0';
			rdy_A				<=	'1';
			rdy_B				<=	'1';
    elsif (clk_i = '1' and clk_i'event) then
      flagA.rst <= '0';
      flagB.rst <= '0';
			read_flag_o	<=	'0';
			if rdy_A = '1' then
				ch_num	<=	'1';
				rdy_A	<=	'0';
			elsif rdy_B = '1' then
				ch_num	<=	'0';
				rdy_B		<=	'0';
			end if;
      if (fub_busy_i = '0') then
				fub_str_o <= '0';
        case priority is
          when 0 =>
            if (ch_num = '0') then
              if (flagA.output = '1') then
                flagA.rst                   <= '1';
                fub_data_o(fubA_data'range) <= fubA_data;
                fub_adr_o(fubA_adr'range)   <= conv_std_logic_vector(spi_address_A, fub_adr_width) + fubA_adr;
                fub_str_o                   <= '1';
								read_flag_o									<=	read_flag;
								flash_byte_cnt_o						<=	flash_byte_cnt;
								if (fubA_cnt = 0) then
									rdy_A												<=	'1';
								end if;
              -- elsif (flagB.output = '1') then
                -- flagB.rst                   <= '1';
                -- fub_data_o(fubB_data'range) <= fubB_data;
                -- fub_adr_o(fubB_adr'range)   <= fubB_adr;
                -- fub_str_o                   <= '1';
--                                                      else
--                                                              fub_str_o <= '0';
              end if;
            else
              if (flagB.output = '1') then
                flagB.rst                   <= '1';
                fub_data_o(fubB_data'range) <= fubB_data;
                fub_adr_o(fubB_adr'range)   <= conv_std_logic_vector(spi_address_B, fub_adr_width) + fubB_adr;
                fub_str_o                   <=	'1';
								if (fubB_cnt = 0) then
									rdy_B    <= '1';
								end if;

              -- elsif (flagA.output = '1') then
                -- flagA.rst                   <= '1';
                -- fub_data_o(fubA_data'range) <= fubA_data;
                -- fub_adr_o(fubA_adr'range)   <= fubA_adr;
                -- fub_str_o                   <= '1';
								-- read_flag_o									<=	read_flag;
								-- flash_byte_cnt_o						<=	flash_byte_cnt;
--                                                      else
--                                                              fub_str_o <= '0';
              end if;
            end if;
          when 1 =>
            if (flagA.output = '1') then
              flagA.rst                   <= '1';
              fub_data_o(fubA_data'range) <= fubA_data;
              fub_adr_o(fubA_adr'range)   <= conv_std_logic_vector(spi_address_A, fub_adr_width);
              fub_str_o                   <= '1';
							read_flag_o									<=	read_flag;
							flash_byte_cnt_o						<=	flash_byte_cnt;
							if (fubA_cnt = 0) then
								rdy_A		<= '1';
							end if;
            -- elsif (flagB.output = '1') then
              -- flagB.rst                   <= '1';
              -- fub_data_o(fubB_data'range) <= fubB_data;
              -- fub_adr_o(fubB_adr'range)   <= fubB_adr;
              -- fub_str_o                   <= '1';

--                                              else
--                                                      fub_str_o <= '0';
            end if;
          when 2 =>
            if (flagB.output = '1') then
              flagB.rst                   <= '1';
              fub_data_o(fubB_data'range) <= fubB_data;
              fub_adr_o(fubB_adr'range)   <= conv_std_logic_vector(spi_address_B, fub_adr_width);
              fub_str_o                   <= '1';
							if (fubB_cnt = 0) then
								rdy_B    <= '1';
							end if;
            -- elsif (flagA.output = '1') then
              -- flagA.rst                   <= '1';
              -- fub_data_o(fubA_data'range) <= fubA_data;
              -- fub_adr_o(fubA_adr'range)   <= fubA_adr;
              -- fub_str_o                   <= '1';
							-- read_flag_o									<=	read_flag;
							-- flash_byte_cnt_o						<=	flash_byte_cnt;
--                                              else
--                                                      fub_str_o <= '0';
            end if;
          when others => null;
        end case;
      end if;
    end if;
  end process output_ctrl;

end architecture fub_mux_2_to_1_flash_arch;