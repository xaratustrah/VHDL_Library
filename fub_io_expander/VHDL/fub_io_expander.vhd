-------------------------------------------------------------------------------
--
-- FUB-IO_Expander for the chip MCP23S17
-- O. Bitterling
-- 
-------------------------------------------------------------------------------

-- TABLE 1-6: CONTROL REGISTER SUMMARY (IOCON.BANK = 0)
-- RegisterName Address(hex) bit 7 bit 6 bit 5 bit 4 bit 3 bit 2 bit 1 bit 0 POR/RST value
-- IODIRA         00         IO7 IO6 IO5 IO4 IO3 IO2 IO1 IO0 1111 1111
-- IODIRB         01         IO7 IO6 IO5 IO4 IO3 IO2 IO1 IO0 1111 1111
-- IPOLA          02         IP7 IP6 IP5 IP4 IP3 IP2 IP1 IP0 0000 0000
-- IPOLB          03         IP7 IP6 IP5 IP4 IP3 IP2 IP1 IP0 0000 0000
-- GPINTENA       04         GPINT7 GPINT6 GPINT5 GPINT4 GPINT3 GPINT2 GPINT1 GPINT0 0000 0000
-- GPINTENB       05         GPINT7 GPINT6 GPINT5 GPINT4 GPINT3 GPINT2 GPINT1 GPINT0 0000 0000
-- DEFVALA        06         DEF7 DEF6 DEF5 DEF4 DEF3 DEF2 DEF1 DEF0 0000 0000
-- DEFVALB        07         DEF7 DEF6 DEF5 DEF4 DEF3 DEF2 DEF1 DEF0 0000 0000
-- INTCONA        08         IOC7 IOC6 IOC5 IOC4 IOC3 IOC2 IOC1 IOC0 0000 0000
-- INTCONB        09         IOC7 IOC6 IOC5 IOC4 IOC3 IOC2 IOC1 IOC0 0000 0000
-- IOCON          0A         BANK MIRROR SEQOP DISSLW HAEN ODR INTPOL — 0000 0000
-- IOCON          0B         BANK MIRROR SEQOP DISSLW HAEN ODR INTPOL — 0000 0000
-- GPPUA          0C         PU7 PU6 PU5 PU4 PU3 PU2 PU1 PU0 0000 0000
-- GPPUB          0D         PU7 PU6 PU5 PU4 PU3 PU2 PU1 PU0 0000 0000
-- INTFA          0E         INT7 INT6 INT5 INT4 INT3 INT2 INT1 INTO 0000 0000
-- INTFB          0F         INT7 INT6 INT5 INT4 INT3 INT2 INT1 INTO 0000 0000
-- INTCAPA        10         ICP7 ICP6 ICP5 ICP4 ICP3 ICP2 ICP1 ICP0 0000 0000
-- INTCAPB        11         ICP7 ICP6 ICP5 ICP4 ICP3 ICP2 ICP1 ICP0 0000 0000
-- GPIOA          12         GP7 GP6 GP5 GP4 GP3 GP2 GP1 GP0 0000 0000
-- GPIOB          13         GP7 GP6 GP5 GP4 GP3 GP2 GP1 GP0 0000 0000
-- OLATA          14         OL7 OL6 OL5 OL4 OL3 OL2 OL1 OL0 0000 0000
-- OLATB          15         OL7 OL6 OL5 OL4 OL3 OL2 OL1 OL0 0000 0000


-- Device Opcode         | Register Address
-- 0 1 0 0 A2 A1 A0 R/W  | A7 A6 A5 A4 A3 A2 A1 A0
-- example write IOCON-Register with x"20" 
    -- 40 0A 20 

-- Package Definition


library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_arith.all;

package fub_io_expander_pkg is

  component fub_io_expander
    generic (
      default_io_data    : std_logic_vector (15 downto 0);
      default_setup_data : std_logic_vector (64-1 downto 0);
      spi_address        : integer;   -- 1
      fub_addr_width     : integer;
      fub_data_width     : integer);
    port (

      clk_i              : in  std_logic;
      rst_i              : in  std_logic;
      io_expander_data_i : in  std_logic_vector(15 downto 0);
      io_expander_str_i  : in  std_logic;
      io_expander_busy_o : out std_logic;
      fub_data_o         : out std_logic_vector(fub_data_width - 1 downto 0);
      fub_adr_o          : out std_logic_vector(fub_addr_width - 1 downto 0);
      fub_str_o          : out std_logic;
      fub_busy_i         : in  std_logic);
  end component;

end fub_io_expander_pkg;

package body fub_io_expander_pkg is
end fub_io_expander_pkg;


-- Entity Definition


library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_arith.all;

entity fub_io_expander is
  
  generic (

    default_io_data    : std_logic_vector (15 downto 0) := x"AAAA";
    default_setup_data : std_logic_vector (64-1 downto 0) := x"0A200B20000001C3";              
    spi_address        : integer                        := 0;  -- depends on Multi-SPI-Master
    fub_addr_width     : integer                        := 4;  -- depends on Multi-SPI-Master
    fub_data_width     : integer                        := 8);


  port (
    clk_i : in std_logic;
    rst_i : in std_logic;

    io_expander_data_i : in  std_logic_vector(15 downto 0);
    io_expander_str_i  : in  std_logic;
    io_expander_busy_o : out std_logic;

    fub_data_o : out std_logic_vector(fub_data_width - 1 downto 0);
    fub_adr_o  : out std_logic_vector(fub_addr_width - 1 downto 0);
    fub_str_o  : out std_logic;
    fub_busy_i : in  std_logic

    );

end fub_io_expander;

architecture fub_io_expander_arch of fub_io_expander is


  constant REG_ADR1 		: std_logic_vector (fub_data_width - 1 downto 0):= x"40"; 	--expander name with cleared read/write bit 
  constant REG_ADR2 		: std_logic_vector (fub_data_width - 1 downto 0):= x"12"; 	--adress of pin 21-28
  constant REG_ADR3 		: std_logic_vector (fub_data_width - 1 downto 0):= x"13"; 	--adress of pin 1-8
  constant NO_OF_DATA_BYTES	: integer  										:= 6;		-- byte width of parallel imput *3
  constant SETUP_COMMAND_LENGTH : integer := (default_setup_data'length)/16; -- 64/16 = 4			

  type states is (INIT_IO_EXPANDER, WAIT_FOR_STR, SEND_TO_IO_EXPANDER);
  signal state : states;


  signal cnt : integer range 0 to 3*SETUP_COMMAND_LENGTH +5+1;

  type par_data_array_type is array(0 to NO_OF_DATA_BYTES-1) of
    std_logic_vector(7 downto 0);
  signal par_data_array : par_data_array_type;

  type setup_data_array_type is array(0 to 3*SETUP_COMMAND_LENGTH +5) of
    std_logic_vector(7 downto 0);
  signal setup_data_array : setup_data_array_type;

  type setup_addr_array_type is array(0 to 3*SETUP_COMMAND_LENGTH +5) of
    std_logic_vector(fub_addr_width-1 downto 0);
  signal setup_addr_array : setup_addr_array_type;
  
  signal counter	: integer Range 0 to NO_OF_DATA_BYTES; 
  
begin  -- fub_io_expander_arch
  
  
  par_data_array(0) <= REG_ADR1;
  par_data_array(1) <= REG_ADR2;
  par_data_array(3) <= REG_ADR1;
  par_data_array(4) <= REG_ADR3;

	--conversion of the string "default_setup_data" into array form
  parallel_to_array_gen : for i in 0 to SETUP_COMMAND_LENGTH-1 generate  -- 0 .. 3
    setup_data_array(i*3)     <= REG_ADR1;
    setup_data_array((i*3)+1) <= default_setup_data(SETUP_COMMAND_LENGTH*2*8-1-i*16 downto SETUP_COMMAND_LENGTH*2*8-8-i*16);  
    setup_data_array((i*3)+2) <= default_setup_data(SETUP_COMMAND_LENGTH*2*8-9-i*16 downto SETUP_COMMAND_LENGTH*2*8-16-i*16);
	
	--create an array with correct adresses determined by the "spi_adress"
    setup_addr_array(i*3)     <= conv_std_logic_vector(spi_address+2, fub_addr_width);
    setup_addr_array((i*3)+1) <= conv_std_logic_vector(spi_address+1, fub_addr_width);
    setup_addr_array((i*3)+2) <= conv_std_logic_vector(spi_address, fub_addr_width);  -- max. 12
  end generate;
	
	--add the information from "default_io_data" to the array
  setup_data_array(0+(SETUP_COMMAND_LENGTH-1)*3+3) <= REG_ADR1;
  setup_data_array(1+(SETUP_COMMAND_LENGTH-1)*3+3) <= REG_ADR2;
  setup_data_array(2+(SETUP_COMMAND_LENGTH-1)*3+3) <= default_io_data(15 downto 8);  -- setup_data_array(17)
  setup_data_array(3+(SETUP_COMMAND_LENGTH-1)*3+3) <= REG_ADR1;
  setup_data_array(4+(SETUP_COMMAND_LENGTH-1)*3+3) <= REG_ADR3;
  setup_data_array(5+(SETUP_COMMAND_LENGTH-1)*3+3) <= default_io_data(7 downto 0);    -- setup_data_array(19)
  
  setup_addr_array(0+(SETUP_COMMAND_LENGTH-1)*3+3) <= conv_std_logic_vector(spi_address+2, fub_addr_width); -- setup_addr_array(12)
  setup_addr_array(1+(SETUP_COMMAND_LENGTH-1)*3+3) <= conv_std_logic_vector(spi_address+1, fub_addr_width);
  setup_addr_array(2+(SETUP_COMMAND_LENGTH-1)*3+3) <= conv_std_logic_vector(spi_address, fub_addr_width);
  setup_addr_array(3+(SETUP_COMMAND_LENGTH-1)*3+3) <= conv_std_logic_vector(spi_address+2, fub_addr_width);
  setup_addr_array(4+(SETUP_COMMAND_LENGTH-1)*3+3) <= conv_std_logic_vector(spi_address+1, fub_addr_width);
  setup_addr_array(5+(SETUP_COMMAND_LENGTH-1)*3+3) <= conv_std_logic_vector(spi_address, fub_addr_width);


  p_main : process (clk_i, rst_i)
  begin  -- process p_main
    if rst_i = '1' then                 -- asynchronous reset (active high)
      io_expander_busy_o <= '1';
      fub_str_o          <= '0';
      fub_adr_o          <= (others => '0');
      fub_data_o         <= (others => '0');
      state              <= INIT_IO_EXPANDER;
      cnt                <= 0;
      counter            <= 0;
      
    elsif clk_i'event and clk_i = '1' then  -- rising clock edge
      
      case state is
        
		--
        when INIT_IO_EXPANDER =>
          --sending all data in setup_data_array to the expander. Only once per reset,
          if cnt < 3*SETUP_COMMAND_LENGTH +5+1 then
            if fub_busy_i = '0' then
              fub_data_o <= setup_data_array(cnt);
              fub_adr_o  <= setup_addr_array(cnt);
              fub_str_o  <= '1';
              cnt        <= cnt + 1;
            end if;
          else
            if fub_busy_i = '0' then
              cnt                <= 0;
              fub_str_o          <= '0';
              io_expander_busy_o <= '0';
              state              <= WAIT_FOR_STR;
            end if;
          end if;

         
        when WAIT_FOR_STR =>
          fub_str_o <= '0';
          if io_expander_str_i = '1' then
            io_expander_busy_o <= '1';
            par_data_array(2)  <= io_expander_data_i(15 downto 8);
            par_data_array(5)  <= io_expander_data_i(7 downto 0);
            state              <= SEND_TO_IO_EXPANDER;
          end if;
          
        when SEND_TO_IO_EXPANDER =>

        	
        	if counter < NO_OF_DATA_BYTES then
            	if fub_busy_i = '0' then
              		fub_data_o 	<= par_data_array(counter);
              		fub_adr_o  	<= setup_addr_array(counter);
               		fub_str_o  	<= '1';
              		counter    	<= counter + 1;
            	end if;
          	else
            	if fub_busy_i = '0' then
              		counter        	<= 0;
              		fub_str_o  		<= '0';
              		io_expander_busy_o 		<= '0';
              		state      		<= WAIT_FOR_STR;
            	end if;
          	end if;   
             

        when others => null;
      end case;
    end if;
  end process p_main;

end fub_io_expander_arch;
