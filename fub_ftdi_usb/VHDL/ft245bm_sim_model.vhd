-- simulation model for the FT245BM parallel port interface

library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_arith.all;
use IEEE.STD_LOGIC_unsigned.all;

entity ft245bm_sim_model is
	generic(
			wait_clks  						: integer :=	0;
			wr_inactive_to_ntxe : time := 35 ns; --5..25 ns
			ntxe_inactive_after_wr : time := 80 ns; --80 ns
			init_fifo_rd_cycle_after : time := 1 us;
			fifo_rd_cycle_time : time := 2 us;
			rd_active_to_valid_data : time := 50 ns;
			rd_inactive_to_nrxf : time := 25 ns;
			nrxf_inactive_after_read_cycle : time := 100 ns
		);
	port(
			rst_i	:	in std_logic ;
			clk_i	:	in std_logic ;
			d_io	:	inout std_logic_vector (7 downto 0);
			nrd_i : in std_logic;
			wr_i: in std_logic;
			nrxf_o : out std_logic;
			ntxe_o : out std_logic
		);
	
end ft245bm_sim_model; 


architecture ft245bm_sim_model_arch of ft245bm_sim_model is
	signal data : std_logic_vector (7 downto 0);
	signal d_o : std_logic_vector (7 downto 0);
	signal ntxe : std_logic;

begin

d_io <= d_o when nrd_i = '0' else (others => 'Z');

process
begin
  loop
--		data <= (others => '0');
		ntxe_o <= '0';
    wait on wr_i;
    if wr_i = '0' then
      wait for wr_inactive_to_ntxe;
		  data <= d_io;
      ntxe_o <= '1';
      wait for ntxe_inactive_after_wr;
      ntxe_o <= '0';
    end if;
  end loop; 
--	ntxe_o <= ntxe;
end process;	

process
begin
  nrxf_o <= '1';
--  d_o <= (others => '0');
  d_o <= x"03";
  
  wait for init_fifo_rd_cycle_after;
  loop
    nrxf_o <= '1';
    wait on clk_i;
    if NOW < init_fifo_rd_cycle_after + fifo_rd_cycle_time then
      nrxf_o <= '0';
      wait on nrd_i;
      if nrd_i='0' then
        wait for rd_active_to_valid_data;
--        d_o <= d_o + '1';
        d_o <= x"03";
        wait on nrd_i;
        if nrd_i='1' then
          wait for rd_inactive_to_nrxf;
          nrxf_o <= '1';
          wait for nrxf_inactive_after_read_cycle;
        end if;
      end if;
    end if;
  end loop; 
end process;	

end ft245bm_sim_model_arch;
