library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_arith.all;
use IEEE.STD_LOGIC_unsigned.all;

entity data_comparator is

  generic (
    use_adr : std_logic := '1'
    );

  port (
    clk_i              : in  std_logic;
    rst_i              : in  std_logic;
    fub_data_i         : in  std_logic_vector (7 downto 0);
    fub_adr_i          : in  std_logic_vector (7 downto 0);
    data_compare_i     : in  std_logic_vector (7 downto 0);
    adr_compare_i      : in  std_logic_vector (7 downto 0);
    fub_str_i          : in  std_logic;
    fub_busy_o         : out std_logic;
    locked_o           : out std_logic;
    failure_vector_o   : out std_logic_vector(7 downto 0);
    failure_o          : out std_logic;
    failure_overflow_o : out std_logic;
    busy_compare_o     : out std_logic
    ) ;

end data_comparator;

architecture data_comparator_arch of data_comparator is

  type state_type is (RST_WAIT, UNLOCKED, LOCKED);

  signal state          : state_type;
  signal count          : integer range 120 downto 0;
  signal failure_vector : std_logic_vector(7 downto 0);

begin

  data_comparator_process : process (clk_i, rst_i)
  begin
    if rst_i = '1' then
      count              <= 120;
      fub_busy_o         <= '0';
      locked_o           <= '0';
      failure_vector_o   <= (others => '0');
      failure_o          <= '0';
      failure_vector     <= (others => '0');
      failure_overflow_o <= '0';
      state              <= RST_WAIT;
      busy_compare_o     <= '1';
    elsif clk_i'event and clk_i = '1' then
      failure_vector_o <= failure_vector;
      case state is
        when RST_WAIT =>
          if count > 0 then
            count <= count - 1;
            state <= RST_WAIT;
          else
            count <= 120;
            state <= UNLOCKED;
            busy_compare_o     <= '0'; -- (S.Schäfer: Zeile wurde neu eingefügt. Beschleunigt das einrasten.)
          end if;
        when UNLOCKED =>
          busy_compare_o <= '1';
          if fub_str_i = '1' and (fub_data_i = data_compare_i) then
		  -- diese Zeile hieß ürsprünglich: if fub_str_i = '1' and ((use_adr = '1' and (fub_data_i = data_compare_i)) or use_adr = '0') then  Das ist aus meiner Sicht (S.Schäfer) schrott. Mit o.g Änderung läufts!
            state          <= LOCKED;
            locked_o       <= '1';
            busy_compare_o <= '0';  --|| get new compare_data // it takes 2 CLKs until new data arrives
          else
            state <= UNLOCKED;
          end if;
        when LOCKED =>
          busy_compare_o <= '1';
          if fub_str_i = '1' then
            if (fub_data_i = data_compare_i) and ((use_adr = '1' and (fub_adr_i = adr_compare_i)) or use_adr = '0') then
              state          <= LOCKED;
              busy_compare_o <= '0';  --|| get new compare_data // it takes 2 CLKs until new data arrives
            elsif failure_vector = "11111111" then
              state              <= UNLOCKED;
              failure_vector     <= "00000000";
              failure_overflow_o <= '1';
              failure_o          <= '1';
              locked_o           <= '0';
              busy_compare_o     <= '0';  --|| get new compare_data 
            else
              state          <= UNLOCKED;
              failure_vector <= failure_vector + "00000001";
              failure_o      <= '1';
              locked_o       <= '0';
              busy_compare_o <= '0';    --|| get new compare_data
            end if;
          else
            state <= LOCKED;
          end if;
      end case;
    end if;
  end process;

end data_comparator_arch;

