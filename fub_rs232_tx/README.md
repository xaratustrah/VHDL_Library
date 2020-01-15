# fub\_rs232\_tx
## IP Core/Package Datasheet
Author: M. Kumm

### Short Description
fub\_rs232\_tx is a simple component for transmitting data over RS-232. The counterpart is the component fub\_rs232\_rx, but both components are completely independent. The interface from FPGA-side is a FUB (receiving, slave) interface with no address bus. The output to RS-232 is a single TX-signal that can be directly connected to e.g. a MAX232.

### Generics

| Name           | Type | Description                    |
|----------------|------|--------------------------------|
| clk\_freq\_in\_hz | real | The used clock frequency in Hz |
| baud\_rate      | real | Baudrate for RS-232            |


### Ports

| Name       | Direction | Type                         | Description      |
|------------|-----------|------------------------------|------------------|
| clk\_i      | in        | std\_logic                    | clock            |
| rst\_i      | in        | std\_logic                    | reset            |
| rs232\_tx\_o | out       | std\_logic                    | RS-232 TX Signal |
| fub\_str\_i  | in        | std\_logic                    | FUB              |
| fub\_busy\_o | out       | std\_logic                    | FUB              |
| fub\_data\_i | in        | std\_logic\_vector(7 downto 0) | FUB              |

### Dependencies to other IP Cores
real\_time\_calculator

### Quartus Project
In the FIB-Project  fib\_rs232\_tx\_top, a fub\_tx\_master component is instantiated to send ascii chars from 'A' to 'Z' over fub\_rs232\_tx. The baudrate is set to 9600 baud. 

### Testbench
Only clk and reset signals are generated in the testbench for fib\_rs232\_tx\_top.

### Hints
For the FIB board, rs232\_tx\_o can be directly connected with the output pin rs232\_tx\_o.

