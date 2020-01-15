-------------------------------------------------------------------------------
--
-- two clk sync
-- T. Guthier
--
-------------------------------------------------------------------------------

-- Package Definition

library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_arith.all;
use IEEE.STD_LOGIC_unsigned.all;

package fub_two_clk_sync_save_pkg is
component fub_two_clk_sync_save
	generic(	
			bitSize		: integer := 8;
			adrSize		: integer := 2
		);
	port(	
			rst_i			: in std_logic;
			clk_input_i		: in std_logic;
			clk_output_i	: in std_logic;
			fub_str_i		: in std_logic;
			fub_data_i		: in std_logic_vector( bitSize - 1 downto 0 );
			fub_adr_i		: in std_logic_vector( adrSize - 1 downto 0 );
			fub_busy_i		: in std_logic;
			fub_str_o		: out std_logic;
			fub_busy_o		: out std_logic;
			fub_data_o		: out std_logic_vector( bitSize - 1 downto 0 );
			fub_adr_o		: out std_logic_vector( adrSize - 1 downto 0 )
		);
end component; 
end fub_two_clk_sync_save_pkg;

package body fub_two_clk_sync_save_pkg is
end fub_two_clk_sync_save_pkg;

-- Entity Definition

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE IEEE.STD_LOGIC_arith.all;
USE IEEE.STD_LOGIC_unsigned.all;

entity fub_two_clk_sync_save is

generic(	
			bitSize		: integer := 8;
			adrSize		: integer := 2
		);

port(	
		rst_i			: in std_logic;
		clk_input_i		: in std_logic;
		clk_output_i	: in std_logic;
		--fub in
		fub_data_i		: in std_logic_vector( bitSize - 1 downto 0 );
		fub_adr_i		: in std_logic_vector( adrSize - 1 downto 0 );
		fub_str_i		: in std_logic;
		fub_busy_o		: out std_logic;
		--fub out
		fub_data_o		: out std_logic_vector( bitSize - 1 downto 0 );
		fub_adr_o		: out std_logic_vector( adrSize - 1 downto 0 );
		fub_str_o		: out std_logic;
		fub_busy_i		: in std_logic
	);
	
end fub_two_clk_sync_save;

architecture fub_two_clk_sync_save_arch of fub_two_clk_sync_save is

  signal data_tmp : std_logic_vector( bitSize - 1 downto 0 );
  signal adr_tmp : std_logic_vector( adrSize - 1 downto 0 );
  
  signal async_valid : std_logic;
  signal async_ack : std_logic;

  signal sync_valid1 : std_logic;
  signal sync_ack1 : std_logic;
  signal sync_valid2 : std_logic;
  signal sync_ack2 : std_logic;
  
  type rx_states is (WAIT_FOR_STROBE, WAIT_FOR_ACK, WAIT_FOR_NACK);
  signal rx_state: rx_states;

  type tx_states is (WAIT_FOR_VALID, WAIT_FOR_NVALID);
  signal tx_state: tx_states;
    
begin
  p_input_rx: process(clk_input_i, rst_i)
  begin
    if rst_i='1' then
      rx_state <= WAIT_FOR_STROBE;
      async_valid <= '0';
      data_tmp <= (others => '0');
      adr_tmp <= (others => '0');
      fub_busy_o <= '0';
      sync_ack1 <= '0';
      sync_ack2 <= '0';
    elsif clk_input_i'event and clk_input_i='1' then
      sync_ack1 <= async_ack;
      sync_ack2 <= sync_ack1;
      case rx_state is
        when WAIT_FOR_STROBE =>
          if fub_str_i='1' then
            data_tmp <= fub_data_i;
            adr_tmp <= fub_adr_i;
            fub_busy_o <= '1';
            rx_state <= WAIT_FOR_ACK;
          end if;
        when WAIT_FOR_ACK =>
          if sync_ack2 ='1' then
            async_valid <= '0';
            rx_state <= WAIT_FOR_NACK;
          else
            async_valid <= '1';
          end if;
        when WAIT_FOR_NACK =>
          if sync_ack2 ='0' then
            rx_state <= WAIT_FOR_STROBE;
            fub_busy_o <= '0';
          end if;
      end case;
    end if;
  end process p_input_rx;
    
  p_output_tx: process(clk_output_i, rst_i)
  begin
    if rst_i='1' then
      tx_state <= WAIT_FOR_VALID;
      async_ack <= '0';
      fub_str_o <= '0';
      fub_data_o <= (others => '0');
      fub_adr_o <= (others => '0');
      sync_valid1 <= '0';
      sync_valid2 <= '0';
    elsif clk_output_i'event and clk_output_i='1' then
      sync_valid1 <= async_valid;
      sync_valid2 <= sync_valid1;
      case tx_state is
        when WAIT_FOR_VALID =>
          if sync_valid2 = '1' then
            if fub_busy_i = '0' then
              fub_data_o <= data_tmp;
              fub_adr_o <= adr_tmp;
              fub_str_o <= '1';
              async_ack <= '1';
              tx_state <= WAIT_FOR_NVALID;
            end if;
          end if;
        when WAIT_FOR_NVALID =>
          fub_str_o <= '0';
          if sync_valid2 = '0' then
            async_ack <= '0';
            tx_state <= WAIT_FOR_VALID;
          end if;
      end case;
    end if;
  end process p_output_tx;
  
end fub_two_clk_sync_save_arch;			