# fub\_rs232\_rx
## IP Core/Package Datasheet
Author: M. Kumm

### Short Description
fub\_rs232\_rx is a simple component for receiving data over RS-232. The counterpart is the component fub\_rs232\_tx, but both components are completely independent. The interface from FPGA-side is a FUB (sending, master) interface with no address bus. The input from RS-232 is a single RX-signal that can be directly connected to e.g. a MAX232.


### Generics

| Name           | Type | Description                    |
|----------------|------|--------------------------------|
| clk\_freq\_in\_hz | real | The used clock frequency in Hz |
| baud\_rate      | real | Baudrate for RS-232            |

### Ports

| Name       | Direction | Type                          | Description      |
|------------|-----------|-------------------------------|------------------|
| clk\_i      | in        | std\_logic                     | clock            |
| rst\_i      | in        | std\_logic                     | reset            |
| rs232\_rx\_i | in        | std\_logic                     | RS-232 RX Signal |
| fub\_str\_o  | out       | std\_logic                     | FUB              |
| fub\_busy\_i | in        | std\_logic                     | FUB              |
| fub\_data\_o | out       | std\_logic\_vector (7 downto 0) | FUB              |
| receive\_error	| out	| std\_logic | A '1' on this signal means that one telegram was lost, due to a slow FUB receiver for debug purposes. This bit can only be reset to '0' with rst\_i. | 


### Dependencies to other IP Cores
real\_time\_calculator

### Testbench
The testbench connects the fub\_tx\_master component, that generates FUB telegrams with fub\_rs232\_tx to generate a RS-232 conform signal. This signal is fed into fub\_rs232\_rx that generates the original FUB telegrams which is are at least fed into fub\_rx\_slave to decode the plain data.

### Hints

For the FIB board, rs232\_rx\_i is inverted, i.e. the FIB input signal rs232\_rx\_i must be inverted.

