library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_arith.all;
use IEEE.STD_LOGIC_unsigned.all;

entity data_comparator_FW02 is

  generic (
    use_adr : std_logic := '1'
    );

  port (
    clk_i              : in  std_logic;
    rst_i              : in  std_logic;
    -- mls sequence to be checked
    fub_addr_i         : in  std_logic_vector (7 downto 0);
    fub_data_i         : in  std_logic_vector (7 downto 0);   
    fub_strb_i         : in  std_logic;
    fub_busy_o         : out std_logic; 
    -- interface to fub_mls_tx for verification purpose
    addr_cmp_i     : in  std_logic_vector (7 downto 0);    
    data_cmp_i     : in  std_logic_vector (7 downto 0);
    strb_cmp_i     : in  std_logic;
    busy_cmp_o     : out std_logic;
    
    locked_o           : out std_logic;
    failure_vector_o   : out std_logic_vector(7 downto 0);
    failure_o          : out std_logic;
    failure_overflow_o : out std_logic

    ) ;

end data_comparator_FW02;

architecture data_comparator_arch of data_comparator_FW02 is

  type state_type is (RST_WAIT, UNLOCKED, LOCKED);

  signal state          : state_type;
  signal count          : integer range 120 downto 0;
  signal failure_vector : std_logic_vector(7 downto 0);

begin

  data_comparator_process : process (clk_i, rst_i)
    variable fub_mls_addr_VAR : std_logic_vector(7 downto 0); 
    variable fub_mls_data_VAR : std_logic_vector(7 downto 0); 
    variable fub_mls_busy_VAR	: std_logic := '0'; 
 
  begin
    if rst_i = '1' then
      count              <= 120;
      fub_busy_o         <= '0';
      locked_o           <= '0';
      failure_vector_o   <= (others => '0');
      failure_o          <= '0';
      failure_vector     <= (others => '0');
      failure_overflow_o <= '0';

      busy_cmp_o         <= '1';
      
      fub_mls_busy_VAR   := '0';
      
      state              <= RST_WAIT; 

      
    elsif rising_edge (clk_i) then
      failure_vector_o <= failure_vector;
      
      
      if (fub_mls_busy_VAR = '0')  then
        if (strb_cmp_i = '1')  then
          fub_mls_addr_VAR  := addr_cmp_i;
          fub_mls_data_VAR  := data_cmp_i;
          fub_mls_busy_VAR  := '1'; 
        end if;
      end if;
      
      
      
      
      case state is
        when RST_WAIT =>
          if count > 0 then
            count <= count - 1;
            state <= RST_WAIT;
          else
            count <= 120;
            state <= UNLOCKED;
            -- busy_compare_o     <= '0'; -- (S.Schäfer: Zeile wurde neu eingefügt. Beschleunigt das einrasten.)
          end if;
        when UNLOCKED =>
          -- busy_compare_o <= '1';
          -- if fub_strb_i = '1' and (fub_data_i = fub_mls_data_VAR) then
		  -- diese Zeile hieß ürsprünglich: if fub_str_i = '1' and ((use_adr = '1' and (fub_data_i = data_compare_i)) or use_adr = '0') then  Das ist aus meiner Sicht (S.Schäfer) schrott. Mit o.g Änderung läufts!
          if fub_strb_i = '1' then
            if (fub_data_i = fub_mls_data_VAR) and ((use_adr = '1' and (fub_addr_i = fub_mls_addr_VAR)) or use_adr = '0') then   
              state          <= LOCKED;
              locked_o       <= '1';
              -- busy_compare_o <= '0';  --|| get new compare_data // it takes 2 CLKs until new data arrives
              fub_mls_busy_VAR := '0';  --|| get new compare_data // it takes 2 CLKs until new data arrives
            -- else
              -- state <= UNLOCKED;
            end if;
          end if;
        when LOCKED =>
          -- busy_compare_o <= '1';
          if fub_strb_i = '1' then
            if (fub_data_i = fub_mls_data_VAR) and ((use_adr = '1' and (fub_addr_i = fub_mls_addr_VAR)) or use_adr = '0') then
              -- state          <= LOCKED;
              -- busy_compare_o <= '0';  --|| get new compare_data // it takes 2 CLKs until new data arrives
              fub_mls_busy_VAR := '0';  --|| get new compare_data // it takes 2 CLKs until new data arrives

            elsif failure_vector = "11111111" then
              state              <= UNLOCKED;
              failure_vector     <= "00000000";
              failure_overflow_o <= '1';
              failure_o          <= '1';
              locked_o           <= '0';
              -- busy_compare_o     <= '0';  --|| get new compare_data 
            else
              state          <= UNLOCKED;
              failure_vector <= failure_vector + "00000001";
              failure_o      <= '1';
              locked_o       <= '0';
              -- busy_compare_o <= '0';    --|| get new compare_data
            end if;
          -- else
            -- state <= LOCKED;
          end if;
      end case;
      
    busy_cmp_o <= fub_mls_busy_VAR; 
     
      
    end if;
  end process;

end data_comparator_arch;

