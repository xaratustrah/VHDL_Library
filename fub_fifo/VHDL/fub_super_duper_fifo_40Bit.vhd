-------------------------------------------------------------------------------
-- FUB super_duper_fifo_40Bit Component
-- S. Schäfer
-------------------------------------------------------------------------------

-- Package Definition

library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_unsigned.all;

package fub_super_duper_fifo_40Bit_pkg is
  component fub_super_duper_fifo_40Bit
    generic (
      fub_data_width 				: integer;
      fub_addr_width 				: integer;
      fifo_depth     				: integer);
    port (
	  arst_i						: in std_logic;	  
      rst_i         				: in  std_logic;
      clk_i         				: in  std_logic;
	  -- FUB RX Slave Part
      fub_rx_data_i 				: in  std_logic_vector (fub_data_width - 1 downto 0);
      fub_rx_strb_i 				: in  std_logic;
      fub_rx_busy_o 				: out std_logic;
      fub_rx_addr_i 				: in  std_logic_vector (fub_addr_width - 1 downto 0);
	  -- FUB TX Master Part
      fub_tx_strb_o 				: out std_logic;
      fub_tx_busy_i 				: in  std_logic;
      fub_tx_addr_o 				: out std_logic_vector (fub_addr_width - 1 downto 0);
      fub_tx_data_o 				: out std_logic_vector (fub_data_width - 1 downto 0);
	  
	  -- 	  fifo - Flag's
	  almost_fifo_empty_flag		: out std_logic;	
	  almost_fifo_full_flag			: out std_logic;
	  fifo_empty_flag				: out std_logic;	
	  fifo_full_flag				: out std_logic;
	  fifo_exploitation_flag 		: out std_logic_vector (7 downto 0)
	  ); 
	end component;
end fub_super_duper_fifo_40Bit_pkg;

package body fub_super_duper_fifo_40Bit_pkg is
end fub_super_duper_fifo_40Bit_pkg;

-- Entity Definition

library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_unsigned.all;

entity fub_super_duper_fifo_40Bit_pkg is
  
  generic (
    fub_data_width 			: integer := 40;
    fub_addr_width 			: integer := 0;
    fifo_depth     			: integer := 256);

  port (
	arst_i					: in std_logic;
    rst_i 					: in std_logic;
    clk_i 					: in std_logic;

    -- FUB RX Slave Part
    fub_rx_data_i 			: in  std_logic_vector (fub_data_width - 1 downto 0);
    fub_rx_strb_i 			: in  std_logic;
    fub_rx_busy_o 			: out std_logic;
    fub_rx_addr_i 			: in  std_logic_vector (fub_addr_width - 1 downto 0);

    -- FUB TX Master Part
    fub_tx_strb_o 			: out std_logic;
    fub_tx_busy_i 			: in  std_logic;
    fub_tx_addr_o 			: out std_logic_vector (fub_addr_width - 1 downto 0);
    fub_tx_data_o 			: out std_logic_vector (fub_data_width - 1 downto 0);
	
	-- 	  fifo - Flag's
	almost_fifo_empty_flag	: out std_logic;	
	almost_fifo_full_flag	: out std_logic;
	fifo_empty_flag			: out std_logic;	
	fifo_full_flag			: out std_logic;
	fifo_exploitation_flag 	: out std_logic_vector (7 downto 0)	
	);
end fub_super_duper_fifo_40Bit_pkg;

architecture fub_super_duper_fifo_40Bit_arch of fub_super_duper_fifo_40Bit_pkg is

  component super_duper_fifo_40Bit
    port (
	  aclr 			: in  std_logic;
      clock 		: in  std_logic;
      data  		: in  std_logic_vector (fub_addr_width + fub_data_width - 1 downto 0);
      rdreq 		: in  std_logic;
      sclr  		: in  std_logic;
      wrreq 		: in  std_logic;
      almost_empty 	: in  std_logic;
      almost_full 	: in  std_logic;	  
      empty 		: out std_logic;
      full  		: out std_logic;
      q     		: out std_logic_vector (fub_addr_width + fub_data_width - 1 downto 0)
      usedw			: out std_logic_vector (7 downto 0)	  
	  );
  end component;

  signal fifo_data_in  			: std_logic_vector (fub_addr_width + fub_data_width - 1 downto 0);
  signal fifo_rdreq    			: std_logic;
  signal fifo_wrreq    			: std_logic;
  signal almost_fifo_empty    	: std_logic;
  signal almost_fifo_full     	: std_logic;  
  signal fifo_empty    			: std_logic;
  signal fifo_full     			: std_logic;
  signal fifo_data_out 			: std_logic_vector (fub_addr_width + fub_data_width - 1 downto 0);
  signal fifo_exploitation		: std_logic_vector (7 downto 0);
  
  type read_cycle_state_type is (WAIT_FOR_FIFO_CONTENT, WAIT_FOR_BUSY, SENDING);

  signal read_cycle_state : read_cycle_state_type;

begin  -- fub_fifo_arch

  super_duper_fifo_40Bit_inst : super_duper_fifo_40Bit
    port map (
      aclr  => arst_i,	
      clock => clk_i,
      data  => fifo_data_in,
      rdreq => fifo_rdreq,
      sclr  => rst_i,
      wrreq => fifo_wrreq,
      almost_empty => almost_fifo_empty,	  
      almost_full  => almost_fifo_full,	  
      empty => fifo_empty,
      full  => fifo_full,	  
      q     => fifo_data_out,
	  usedw => fifo_exploitation	  
	  );
	  
	almost_fifo_empty_flag		<= almost_fifo_empty;	
	almost_fifo_full_flag		<= almost_fifo_full;
	fifo_empty_flag				<= fifo_empty;
	fifo_full_flag 				<= fifo_full; 
	fifo_exploitation_flag		<= fifo_exploitation; 
	  
  p_fub_rx_slave : process (clk_i, rst_i)
  begin  -- process p_fub_rx_slave
    if rst_i = '1' then                 -- asynchronous reset (active high)

      fub_rx_busy_o    <= '0';
      fub_tx_strb_o    <= '0';
      fub_tx_addr_o    <= (others => '0');
      fub_tx_data_o    <= (others => '0');
      read_cycle_state <= WAIT_FOR_FIFO_CONTENT;

    elsif clk_i'event and clk_i = '1' then  -- rising clock edge

      -- Write Part
      if fub_rx_strb_i = '1' then
        fub_rx_busy_o <= '1';
        if fifo_full = '0' then
          fub_rx_busy_o <= '0';
          fifo_wrreq    <= '1';
          fifo_data_in  <= fub_rx_addr_i & fub_rx_data_i;
        end if;
      else
        fifo_wrreq    <= '0';
        fub_rx_busy_o <= '0';
      end if;

-- Read Part

      case read_cycle_state is
        when WAIT_FOR_FIFO_CONTENT =>
          fub_tx_strb_o <= '0';
          if fifo_empty = '0' then
            fifo_rdreq       <= '1';
            read_cycle_state <= SENDING;
          else
            fifo_rdreq <= '0';
          end if;

        when SENDING =>
          fifo_rdreq <= '0';
          read_cycle_state <= WAIT_FOR_BUSY;
          
        when WAIT_FOR_BUSY =>
          if fub_tx_busy_i = '0' then
            fub_tx_strb_o    <= '1';
            fub_tx_addr_o    <= fifo_data_out (fub_addr_width + fub_data_width - 1 downto fub_data_width);
            fub_tx_data_o    <= fifo_data_out (fub_data_width - 1 downto 0);
            read_cycle_state <= WAIT_FOR_FIFO_CONTENT;
          else
            fub_tx_strb_o <= '0';
          end if;

        when others => null;
      end case;
    end if;
  end process p_fub_rx_slave;
end fub_super_duper_fifo_40Bit_arch;
