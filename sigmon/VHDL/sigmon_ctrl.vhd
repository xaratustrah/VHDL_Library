-------------------------------------------------------------------------------
--
-- SigMon Controller, controlls the communication between Host PC (SigMon Application) and Data FIFO
-- M. Kumm
--
-------------------------------------------------------------------------------

-- Package Definition

library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_arith.all;
use IEEE.STD_LOGIC_unsigned.all;

package sigmon_ctrl_pkg is
component sigmon_ctrl
		generic(
			data_width  : integer;  --width of the input signal, must be n*8 bit
			fifo_size: integer; --8192 --no of fifo words
			external_trigger_en: boolean;
			magic_number: integer -- (=55ff00aa) magic number as header indentifier 
		);
		port(
			clk_i						:	in  std_logic;
			rst_i 				:	in  std_logic;
			--data interface
			data_i: std_logic_vector(data_width-1 downto 0);
			data_trigger_i: std_logic;
			--fifo interface
			fifo_d_o		: out std_logic_vector (data_width-1 downto 0);  --data to fifo
			fifo_rdreq_o		: out std_logic ;
			fifo_wrreq_o		: out std_logic ;
			fifo_empty_i		: in std_logic ;
			fifo_full_i		: in std_logic ;
			fifo_d_i		: in std_logic_vector (data_width-1 downto 0);  --data from fifo
			--fub out
			fub_tx_str_o					:	out		std_logic;
			fub_tx_busy_i				: in	std_logic;
			fub_tx_data_o				:	out std_logic_vector(7 downto 0);
      --fub in
			fub_rx_str_i					:	in		std_logic;
			fub_rx_busy_o				: out	std_logic;
			fub_rx_data_i				:	in std_logic_vector(7 downto 0);
			test_o           : out std_logic
	);
	
end component; 
end sigmon_ctrl_pkg;

package body sigmon_ctrl_pkg is
end sigmon_ctrl_pkg;

library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_arith.all;
use IEEE.STD_LOGIC_unsigned.all;

entity sigmon_ctrl is
		generic(
			data_width  : integer := 16;  --width of the input signal, must be n*8 bit
			fifo_size: integer := 4096; -- enable external trigger (otherwise immediate trigger is active)
			external_trigger_en: boolean := true; --8192 --no of fifo words
			magic_number: integer := 1442775210 -- (=55ff00aa) magic number as header indentifier 
		);
		port(
			clk_i						:	in  std_logic;
			rst_i 				:	in  std_logic;
			--data interface
			data_i: std_logic_vector(data_width-1 downto 0);
			data_trigger_i: std_logic;
			--fifo interface
			fifo_d_o		: out std_logic_vector (data_width-1 downto 0);  --data to fifo
			fifo_rdreq_o		: out std_logic ;
			fifo_wrreq_o		: out std_logic ;
			fifo_empty_i		: in std_logic ;
			fifo_full_i		: in std_logic ;
			fifo_d_i		: in std_logic_vector (data_width-1 downto 0);  --data from fifo
			--fub out
			fub_tx_str_o					:	out		std_logic;
			fub_tx_busy_i				: in	std_logic;
			fub_tx_data_o				:	out std_logic_vector(7 downto 0);
      --fub in
			fub_rx_str_i					:	in		std_logic;
			fub_rx_busy_o				: out	std_logic;
			fub_rx_data_i				:	in std_logic_vector(7 downto 0);
			test_o           : out std_logic
	);
	
end sigmon_ctrl; 

architecture sigmon_ctrl_arch of sigmon_ctrl is

type states is (WAIT_FOR_CMD,WAIT_FOR_TRIGGER,FIFO_DATA_AQUISITION,SENDING_HEADER,FIFO_READING,STOP);
signal state: states;
type fifo_read_states is (WAIT_FOR_FUB_BUSY,WAIT_FOR_FIFO_DATA_READY,SEND_FUB_DATA);
signal fifo_read_state: fifo_read_states;

signal cnt: integer range 0 to fifo_size;
signal byte_cnt: integer range 0 to data_width/8;
--signal tmp_data: std_logic_vector(data_width-1 downto 0);

signal header_fifo_size: std_logic_vector(31 downto 0);
signal header_magic_number: std_logic_vector(31 downto 0);

signal data_trigger_old: std_logic;


constant CMD_SINGLESHOT : std_logic_vector(7 downto 0) := x"03";
constant CMD_CONT_START : std_logic_vector(7 downto 0) := x"01";
constant CMD_CONT_STOP : std_logic_vector(7 downto 0) := x"02";
constant CMD_SET_TRIGGER : std_logic_vector(7 downto 0) := x"13";

signal test_data : std_logic_vector(15 downto 0);

begin

header_fifo_size <= conv_std_logic_vector(fifo_size-1,32);
header_magic_number <= conv_std_logic_vector(magic_number,32);
    
process (clk_i, rst_i, data_i)
begin
	if rst_i = '1' then
	  cnt <= 0;
		state <= WAIT_FOR_CMD;
    fifo_rdreq_o <= '0';  
    fifo_wrreq_o <= '0';
    fub_tx_str_o <= '0';
    fub_rx_busy_o <= '1';
    byte_cnt <= 0;
    data_trigger_old <= '0';
    test_o <= '0';
	elsif clk_i'EVENT and clk_i = '1' then	
    fub_rx_busy_o <= '1';
		data_trigger_old <= data_trigger_i;
		case state is
  	   when WAIT_FOR_CMD =>
  	       fub_rx_busy_o <= '0';
  	       if fub_rx_str_i = '1' then
  	           case fub_rx_data_i is
  	               when CMD_SINGLESHOT =>
                      test_o <= '1';
                      if external_trigger_en = true then
    	                  state <= WAIT_FOR_TRIGGER;
    	                else
    	                  state <= FIFO_DATA_AQUISITION;
    	                end if;
  	               when others =>
  	           end case;
  	       end if;
  	  when WAIT_FOR_TRIGGER =>
        if data_trigger_i = '1' and data_trigger_old = '0' then
          state <= FIFO_DATA_AQUISITION;
        end if;  	  
			when FIFO_DATA_AQUISITION =>
					test_data <= (others => '0'); --für test
          if cnt < fifo_size then
            cnt <= cnt + 1;
            fifo_d_o <= data_i;
            fifo_wrreq_o <= '1';  
          else
            fifo_wrreq_o <= '0';
            cnt <= 0;
            state <= SENDING_HEADER;
          end if;
			when SENDING_HEADER =>
	      if fub_tx_busy_i = '0' then
   	      fub_tx_str_o <= '1';
 			   	cnt <= cnt+1;
			  	 case cnt is
			  	  when 0 =>
		   	      fub_tx_data_o <= header_magic_number(7 downto 0);
           when 1 =>
		   	      fub_tx_data_o <= header_magic_number(15 downto 8);
			  	  when 2 =>
		   	      fub_tx_data_o <= header_magic_number(23 downto 16);
			  	  when 3 =>
		   	      fub_tx_data_o <= header_magic_number(31 downto 24);
			  	  when 4 =>
		   	      fub_tx_data_o <= header_fifo_size(7 downto 0);			  	      
			  	  when 5 =>
		   	      fub_tx_data_o <= header_fifo_size(15 downto 8);
			  	  when 6 =>
		   	      fub_tx_data_o <= header_fifo_size(23 downto 16);
			  	  when 7 =>
		   	      fub_tx_data_o <= header_fifo_size(31 downto 24);
			  	  when 8 =>
              fub_tx_str_o <= '0';
		   	      state <= FIFO_READING;
		   	      fifo_read_state <= WAIT_FOR_FUB_BUSY;
		   	      cnt <= 0;
			  	  when others => null;
			  	end case;
			  end if;    
			when FIFO_READING =>
        case fifo_read_state is
          when WAIT_FOR_FUB_BUSY =>
	          if fub_tx_busy_i = '0' then
	            if byte_cnt=0 then  --new word is needed
  	           fifo_rdreq_o <= '1';
               fifo_read_state <= WAIT_FOR_FIFO_DATA_READY;
              else
               fifo_read_state <= SEND_FUB_DATA;
  	           end if;
            end if;
          when WAIT_FOR_FIFO_DATA_READY =>
            fifo_read_state <= SEND_FUB_DATA; --it takes one clk cycle till fifo data is ready
            fifo_rdreq_o <= '0';
          when SEND_FUB_DATA =>
	          if fifo_empty_i='0' then
        		  fub_tx_str_o <= '1';
              if (byte_cnt+1)*8 >= data_width then
                byte_cnt<=0;
              else
                byte_cnt <= byte_cnt+1;  
              end if;
              case byte_cnt is
                  when 0 =>
                    fub_tx_data_o <= fifo_d_i(7 downto 0);
--										fub_tx_data_o <= test_data(7 downto 0); --test !!
                  when 1 =>
                    fub_tx_data_o <= fifo_d_i(15 downto 8);
--										fub_tx_data_o <= test_data(15 downto 8);  --test !!
--										test_data <= test_data + 1;
--                  when 2 =>
--                    fub_tx_data_o <= fifo_d_i(23 downto 16);
--                  when 3 =>
--                    fub_tx_data_o <= fifo_d_i(31 downto 24);
                  when others => null;
              end case;
              fifo_read_state <= WAIT_FOR_FUB_BUSY;
            else
              fifo_rdreq_o <= '0';
              fub_tx_str_o <= '0';
--              state <= FIFO_DATA_AQUISITION;
							test_o <= '0';
              state <= WAIT_FOR_CMD; --for debug
            end if;
        end case;          
			when STOP =>
        
    end case;	
  end if;
end process;
    
end sigmon_ctrl_arch;
