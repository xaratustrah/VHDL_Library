-------------------------------------------------------------------------------
--
-- FUB 8 bit maximum length sequence transmitter
-- T. Guthier
--
-------------------------------------------------------------------------------



  -- fub_mls_tx_DDS_REG_inst : Entity work.fub_mls_tx_FW02
	-- generic	map( 	
    -- strb_delay		 	=> 0 -- as fast as possible
	-- )  
	-- port map(  
			-- clk_i       =>	clk50_i,
			-- rst_i				=>	rst_PU_i, 
      
			-- fub_adr_o   => open,		
			-- fub_data_o  => fub_mls_data,	
			-- fub_str_o 	=> fub_mls_strb,
      -- fub_busy_i	=> fub_mls_busy
	-- );

-- Package Definition

library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_arith.all;
use IEEE.STD_LOGIC_unsigned.all;

package fub_mls_tx_FW02_pkg is
component fub_mls_tx_FW02
	generic	( 	
    strb_delay		 	: integer  := 10 
	);  
	port (  
			clk_i			: in std_logic ;
			rst_i			: in std_logic ;
			fub_busy_i		: in std_logic ;
			fub_data_o		: out std_logic_vector( 7 downto 0 ) ;
			fub_adr_o		: out std_logic_vector( 7 downto 0 ) ;
			fub_str_o 		: out std_logic 
	);
end component; 
end fub_mls_tx_FW02_pkg;

package body fub_mls_tx_FW02_pkg is
end fub_mls_tx_FW02_pkg;

-- Entity Definition


LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE IEEE.STD_LOGIC_arith.all;
USE IEEE.STD_LOGIC_unsigned.all;

entity fub_mls_tx_FW02 is
	generic	( 	
    strb_delay		 	: integer  := 10 
	);  

  port (  
		clk_i			: in std_logic ;
		rst_i			: in std_logic ;
		fub_busy_i		: in std_logic ;
		fub_data_o		: out std_logic_vector( 7 downto 0 ) ;
		fub_adr_o		: out std_logic_vector( 7 downto 0 ) ;
		fub_str_o 		: out std_logic 
	);

end fub_mls_tx_FW02;

architecture fub_mls_tx_FW02_arch of fub_mls_tx_FW02 is

signal old_data 	      : std_logic_vector( 7 downto 0 ) ;
signal old_adr		      : std_logic_vector( 7 downto 0 ) ;
signal wait_cnt_check		: natural range 0 to strb_delay;

begin

	fub_mls_tx_FW02_process : process(clk_i, rst_i )
  
    variable wait_cnt				:	integer range 0 to strb_delay :=	strb_delay;
  
	begin
		if rst_i = '1' then
			fub_data_o 	<= "10001000" ;
			fub_adr_o	<= "10000000" ;
			old_data	<= "00010001" ;
			old_adr		<= "00000001" ;
			fub_str_o	<= '0' ;
		elsif rising_edge(clk_i) then
      wait_cnt_check <= wait_cnt;
      
      if fub_busy_i = '0' then
        fub_str_o 		<= '0';  
      end if;

      
			if (wait_cnt = 0) then
        if (fub_busy_i = '0') then				-- switch data
          fub_data_o	 	<= old_data;
          fub_adr_o			<= old_adr;
          fub_str_o 		<= '1';
          wait_cnt      := strb_delay;
          old_data(0)		<= (((old_data(2) xor old_data(4)) xor old_data(6)) xor old_data(7));
          for n in 0 to 6 loop
            old_data(n+1)	<= old_data(n);
          end loop;
          old_adr(0)			<= (((old_adr(2) xor old_adr(4)) xor old_adr(6)) xor old_adr(7));
          for m in 0 to 6 loop
            old_adr(m+1)	<= old_adr(m); 
          end loop;
        end if;
      else
        wait_cnt      := wait_cnt - 1;
      end if;
		end if;
	end process;
	
end fub_mls_tx_FW02_arch ;
			