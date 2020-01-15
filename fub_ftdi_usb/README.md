# fub\_ftdi\_usb
## IP Core/Package Datasheet

### Short Description
fub\_ftdi\_usb is an interface for the FT245R USB FIFO IC from FTDI (FT245BR should also be compatible, but has never been tested). USB can be accessed via two FUB interfaces, one FUB for writung to USB (fub\_in, fub slave interface) and one for reading (fub\_out, fub master interface). fub\_out generates data when data is received from the host PC and is therefore a fub master. The interface to FT245 is made bidirectional, so a direct connection can be made without extra busdrivers.

### Generics

| Name           | Type | Description                    |
|----------------|------|--------------------------------|
| clk\_freq\_in\_hz | real | The used clock frequency in Hz |


### Ports

| Name           | Direction | Type                            | Description                     |
|----------------|-----------|---------------------------------|---------------------------------|
| clk\_i          | in        | std\_logic                       | clock                           |
| rst\_i          | in        | std\_logic                       | reset                           |
| fub\_in\_data\_i  | in        | std\_logic\_vector (7 downto 0);  | FUB interface to USB            |
| fub\_in\_str\_i   | in        | std\_logic                       | FUB interface to USB            |
| fub\_in\_busy\_o  | out       | std\_logic                       | FUB interface to USB            |
| fub\_out\_data\_o | out       | std\_logic\_vector  (7 downto 0); | FUB interface from USB          |
| fub\_out\_str\_o  | out       | std\_logic                       | FUB interface from USB          |
| fub\_out\_busy\_i | in        | std\_logic                       | FUB interface from USB          |
| ftdi\_d\_io      | inout     | std\_logic (7 downto 0)          | Signals routed directly to FTDI |
| ftdi\_nrd\_o     | out       | std\_logic                       | Signals routed directly to FTDI |
| ftdi\_wr\_o      | out       | std\_logic                       | Signals routed directly to FTDI |
| ftdi\_nrxf\_i    | in        | std\_logic                       | Signals routed directly to FTDI |
| ftdi\_ntxe\_i    | in        | std\_logic                       | Signals routed directly to FTDI |


### Dependencies to other IP Cores
real\_time\_calculator\_pkg

### Quartus Project
Two projects has bees implemented:
usb\_sender: Sends packets (ASCII chars 'a' to 'z') over USB every 100ms. Data received from USB is sent via RS‑232 with a baudrate of 9600 baud.

rs232\_repeater: Acts like an FT232, data from RS‑232 is routed to USB and vice versa.

### Testbench
usb\_sender\_tb and rs232\_repeater\_tb simulates the behaiviour of the corresponding fib top-level entity, descriped under  7.

### Hints
Generally, ftdi\_nrxf and ftdi\_ntxe have to be synchronized externaly:

```
  process(clk)
  begin
    if clk='1' and clk'event then
    	ftdi_nrxf_synced <= ftdi_nrxf;
    	ftdi_ntxe_synced <= ftdi_ntxe;
    end if;
  end process;
```

For the use with FIB in combination with the UDL-Board, the connection is made via the external 78135 transceivers (inverting). Therefore, the transceivers have to be set in the right direction, data and status signal has to be inverted. Use the following code snippet: 

```
--DSP-Link Direction:
DSP_DIR_D <= not ftdi_nrd; --DIR: '1'=to FPGA, '0'=from FPGA
DSP_DIR_STRACK <= '0'; --DIR: '1'=to FPGA, '0'=from FPGA
DSP_DIR_REQRDY <= '1'; --DIR: '1'=to FPGA, '0'=from FPGA

--FTDI signal mapping
ftdi_d(0) <= not DSP_D_R0 when ftdi_nrd = '0' else 'Z';
ftdi_d(1) <= not DSP_D_R1 when ftdi_nrd = '0' else 'Z';
ftdi_d(2) <= not DSP_D_R2 when ftdi_nrd = '0' else 'Z';
ftdi_d(3) <= not DSP_D_R3 when ftdi_nrd = '0' else 'Z';
ftdi_d(4) <= not DSP_D_R4 when ftdi_nrd = '0' else 'Z';
ftdi_d(5) <= not DSP_D_R5 when ftdi_nrd = '0' else 'Z';
ftdi_d(6) <= not DSP_D_R6 when ftdi_nrd = '0' else 'Z';
ftdi_d(7) <= not DSP_D_R7 when ftdi_nrd = '0' else 'Z';

DSP_D_W0 <= not ftdi_d(0);	
DSP_D_W1 <= not ftdi_d(1);
DSP_D_W2 <= not ftdi_d(2);
DSP_D_W3 <= not ftdi_d(3);
DSP_D_W4 <= not ftdi_d(4);
DSP_D_W5 <= not ftdi_d(5);
DSP_D_W6 <= not ftdi_d(6);
DSP_D_W7 <= not ftdi_d(7);

DSP_CSTR_W <= not ftdi_wr;
DSP_CACK_W <= not ftdi_nrd;

ftdi_nrxf <= not DSP_CRDY_R;
ftdi_ntxe <= not DSP_CREQ_R; 
```

