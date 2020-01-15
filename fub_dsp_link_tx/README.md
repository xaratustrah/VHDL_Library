# fub\_dsp\_link\_tx
## IP Core/Package Datasheet

### Short Description
Implementation of the DSP-Link-Interface in sending mode. The 32 bit of the DSP-Link are mapped to the 2 bit FUB addresses 0 to 3 (low-byte at address 0) of the FUB interface.

### Generics
None

### Ports

| Name       | Direction | Type                         | Description                             |
|------------|-----------|------------------------------|-----------------------------------------|
| clk\_i      | in        | std\_logic                    | clock                                   |
| rst\_i      | in        | std\_logic                    | reset                                   |
| fub\_data\_i | in        | std\_logic\_vector(7 downto 0) | FUB Interface to DSP-Link               |
| fub\_str\_i  | in        | std\_logic                    |                                         |
| fub\_busy\_o | out       | std\_logic                    |                                         |
| fub\_adr\_i  | in        | std\_logic\_vector(1 downto 0) |                                         |
| dsp\_data\_o | out       | std\_logic\_vector(7 downto 0) | DSP-Link data                           |
| dsp\_cstr\_o | out       | std\_logic                    | DSP-Link strobe                         |
| dsp\_cack\_o | out       | std\_logic                    | DSP-Link acknowledge  (first byte mark) |
| dsp\_crdy\_i | in        | std\_logic                    | DSP-Link ready                          |



### Quartus Project
fub\_dsp\_link\_tx is connected with fub\_tx\_master in the entity fib\_top, so dummy data is generated and sent with a maximum data rate. 

### Testbench
In the testbench fib\_top\_tb, the fub\_dsp\_link\_rx component is connected with fib\_top to simulate an active communication. 

### Hints
The dsp\_crdy\_i signal must be synchronized externaly!
For FIB: All DSP-Link signals (including the data) have to be inverted!

