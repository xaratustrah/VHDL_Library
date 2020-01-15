library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_arith.all;
use IEEE.STD_LOGIC_unsigned.all;

entity encoder_main is
  
  port (
    -------------------------------------------
    master               : in  std_logic;
    -------------------------------------------
    clk_i                : in  std_logic;
    rst_i                : in  std_logic;
    no_more_ring_data_i  : in  std_logic;
    ring_got_data_i      : in  std_logic;
    ring_str_i           : in  std_logic;
    ring_data_i          : in  std_logic;
    sending_o            : out std_logic;
    reset_detected_o     : out std_logic;
    need_ring_data_o     : out std_logic;
    need_input_data_o    : out std_logic;
    input_data_i         : in  std_logic;
    input_got_data_i     : in  std_logic;
    block_transfer_i     : in  std_logic;
    no_more_input_data_i : in  std_logic;
    data_mc_o            : out std_logic
    );                                                          

end encoder_main;

architecture encoder_main_arch of encoder_main is

  type state_type is (WAIT1, WAIT2, START00, START01, START02, START1, START2, START3, START4, SET_TOKEN_BIT1, SET_TOKEN_BIT2, RING1, RING2, INPUT1, INPUT2, END_TOKEN1, END_TOKEN2, END_TOKEN2a, END_TOKEN2b, END_TOKEN3, END_TOKEN4, END_TOKEN5, NEW_EMPTY_TOKEN1);

  signal state           : state_type;
  signal end_token_count : integer range 0 to 3 :=2;

  signal count_for_reset_out : integer range 0 to 7;

  signal empty_token    : std_logic;
  signal ring_taken     : std_logic;
  signal input_taken    : std_logic;
  signal block_transfer : std_logic;

  signal error_count     : integer range 0 to 2045 :=1020;
  signal master_intern   : integer range 0 to 2045;
  signal new_empty_token : std_logic;

begin

  encoder_main_process : process(clk_i, rst_i)
  begin
    if rst_i = '1' then
      data_mc_o           <= '1';
      sending_o           <= '0';
      ring_taken          <= '0';
      reset_detected_o    <= '0';
      input_taken         <= '0';
      empty_token         <= '0';
      need_ring_data_o    <= '0';
      need_input_data_o   <= '0';
      new_empty_token     <= '0';
      block_transfer      <= '0';
      count_for_reset_out <= 7;
      end_token_count     <= 2;
      if master = '1' then
        master_intern <= 2040;
      else
        master_intern <= 1020;
      end if;

      if master = '1' then
        error_count <= 2040;
      else
        error_count <= 1020;
      end if;
      state               <= WAIT1;

    elsif clk_i'event and clk_i = '1' then
      reset_detected_o <= '0';          --|| reset_detected_o reset
      case state is
        when WAIT1 =>  -- waiting for strobe_i to come // setting default '0' to data_mc_o
          if ring_str_i = '1' then
            data_mc_o   <= '1';         -- '0' because of changing state
            state       <= START00;
            error_count <= master_intern;
          elsif error_count = 0 then  -- need to create a new token, old one got lost // set reset first
            error_count      <= master_intern;
            reset_detected_o <= '1';    --|| reset_detected_o set
            if master = '1' then
              data_mc_o <= '1';
              state     <= START00;
            else
              data_mc_o <= '1';
              state     <= WAIT2;
            end if;
          else
            data_mc_o   <= '1';
            error_count <= error_count - 1;
            state       <= WAIT2;
          end if;
        when WAIT2 =>  -- waiting for strobe_i to come // setting default '0' to data_mc_o
          data_mc_o <= '0';
          if ring_str_i = '1' then
            state       <= START01;
            error_count <= master_intern;
          else
            state <= WAIT1;
          end if;
        when start00 =>
          data_mc_o <= '0';
          state     <= START01;
        when START01 =>
          data_mc_o <= '1';
          state     <= START02;
        when START02 =>
          data_mc_o <= '0';
          state     <= START1;
        when START1 =>
          data_mc_o <= '0';
          state     <= START2;
        when START2 =>                  -- set '1' of "10" befor encoding data
          data_mc_o <= '1';
          state     <= START3;
        when START3 =>                  -- set '0' of "10" befor encoding data
          data_mc_o <= '1';
          state     <= START4;
          if new_empty_token = '1' then
            ring_taken  <= '0';
            input_taken <= '0';
          elsif block_transfer = '1' and input_got_data_i = '1' then
            input_taken <= '1';
            if block_transfer_i = '1' then
              block_transfer <= '1';
            else
              block_transfer <= '0';
            end if;
          elsif ring_got_data_i = '1' then  -- RING DATA TAKEN
            ring_taken <= '1';
          elsif input_got_data_i = '1' and ring_got_data_i = '0' then  -- INPUT DATA TAKEN
            input_taken <= '1';
            if block_transfer_i = '1' then
              block_transfer <= '1';
            else
              block_transfer <= '0';
            end if;
          else
            empty_token <= '1';         -- TOKEN IS EMPTY
            ring_taken  <= '0';
            input_taken <= '0';
          end if;
        when START4 =>                  -- set '0' of "10" befor encoding data
          data_mc_o <= '0';
          state     <= SET_TOKEN_BIT1;
          if input_taken = '1' then
            need_input_data_o <= '1';  -- set need_input_data (3 clks later input_data arrives)
          elsif ring_taken = '1' then
            need_ring_data_o <= '1';  -- set need_ring_data ( 3 clks later ring_data arrives)                                         
          else
            need_ring_data_o  <= '0';
            need_input_data_o <= '0';
          end if;
        when SET_TOKEN_BIT1 =>
          need_ring_data_o  <= '0';     -- reset need_ring_data
          need_input_data_o <= '0';     -- reset need_input_data
          state             <= SET_TOKEN_BIT2;
          if new_empty_token = '1' then
            data_mc_o <= '1';
          elsif ring_taken = '1' then
            data_mc_o <= '0';           -- first part of '1'
          elsif input_taken = '1' then
            data_mc_o <= '0';           -- first part of '1'
            sending_o <= '1';  -- || this ACCESS POINT is sending data in the ring || --
          else                          -- no data
            data_mc_o <= '1';  -- first part of '0' to show that token is empty
          end if;
        when SET_TOKEN_BIT2 =>
          sending_o <= '0';             -- reset sending
          if new_empty_token = '1' then
            data_mc_o <= '0';
            state     <= END_TOKEN1;
          elsif empty_token = '1' then
            data_mc_o <= '0';           -- secound part of '0'
            state     <= END_TOKEN1;    -- switch to the end
          else
            data_mc_o <= '1';           -- second part of '1'
            if ring_taken = '1' then
              state <= RING1;           -- ring data taken
            elsif input_taken = '1' then
              state <= input1;          -- input data taken
            end if;
          end if;
        when RING1 =>
          ring_taken <= '0';            -- reset ring_taken
          data_mc_o  <= not ring_data_i;
          state      <= RING2;
        when RING2 =>
          data_mc_o <= ring_data_i;
          if error_count > 0 then  -- maximal length of the pakage is master_intern
            if no_more_ring_data_i = '0' then
              error_count <= error_count - 1;
              state       <= RING1;
            else                        -- there is no more data
              state       <= END_TOKEN1;
              error_count <= master_intern;
            end if;
          else         -- ERROR DETECTED // MAX LENGTH OF TOKEN REACHED
            error_count      <= master_intern;
            state            <= END_TOKEN1;
            reset_detected_o <= '1';
          end if;
        when INPUT1 =>
          data_mc_o <= not input_data_i;
          state     <= INPUT2;
        when INPUT2 =>
          data_mc_o <= input_data_i;
          if error_count > 0 then  -- maximal length of the pakage is master_intern
            if no_more_input_data_i = '0' then
              error_count <= error_count - 1;
              state       <= INPUT1;
            else                        -- there is no more data
              state       <= END_TOKEN1;
              error_count <= master_intern;
            end if;
          else
            error_count      <= master_intern;
            state            <= END_TOKEN1;
            reset_detected_o <= '1';
          end if;
        when END_TOKEN1 =>
          data_mc_o <= '1';
          if end_token_count > 0 then
            end_token_count <= end_token_count - 1;
            state           <= END_TOKEN1;
          else
            end_token_count <= 2;
            state           <= END_TOKEN2;
          end if;
        when END_TOKEN2 =>
          data_mc_o <= '0';
          state     <= END_TOKEN2a;
        when END_TOKEN2a =>
          data_mc_o <= '0';
          state     <= END_TOKEN2b;
        when END_TOKEN2b =>
          data_mc_o <= '0';
          state     <= END_TOKEN3;
        when END_TOKEN3 =>
          data_mc_o <= '1';
          state     <= END_TOKEN4;
        when END_TOKEN4 =>
          data_mc_o <= '0';
          state     <= END_TOKEN5;
        when END_TOKEN5 =>
          data_mc_o <= '1';
          if new_empty_token = '1' then
            new_empty_token <= '0';     -- reset new_empty_token
            state           <= WAIT2;
          elsif input_taken = '1' then  -- set an empty token after the sended token
            input_taken <= '0';         -- reset input_taken
            if block_transfer = '1' then
              state <= START00;
            else
              state           <= NEW_EMPTY_TOKEN1;
              new_empty_token <= '1';
            end if;
          else
            empty_token <= '0';         -- reste empty_token
            state       <= WAIT2;
          end if;
        when NEW_EMPTY_TOKEN1 =>
          data_mc_o <= '0';
          state     <= START01;
      end case;
    end if;
  end process;
  
end encoder_main_arch;

