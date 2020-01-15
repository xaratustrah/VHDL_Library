# fub\_demux\_1\_to\_2
## IP Core/Package Datasheet

### Short Description
A FUB demultiplexer from one receiving FUB slave port to two equal transmitting master ports. The maximum total speed is defined by the slowest output port. A latency of one clock cycle is introduced. The maximum thoughput is one transfer in 3 clock cycles (1/3 clk).

### Generics

| Name           | Type    | Description                    |
|----------------|---------|--------------------------------|
| clk\_freq\_in\_hz | real    | The used clock frequency in Hz |
| fub\_data\_width | integer | Data width of FUB (8 Bit)      |
| fub\_adr\_width  | integer | Address width of the used FUB  |

#### Ports

| Name         | Direction | Type                                         | Description  |
|--------------|-----------|----------------------------------------------|--------------|
| clk\_i        | in        | std\_logic                                    | clock        |
| rst\_i        | in        | std\_logic                                    | reset        |
| fub\_data\_i   | in        | std\_logic\_vector (fub\_data\_width-1 downto 0) | FUB input    |
| fub\_adr\_i    | in        | std\_logic\_vector (fub\_adr\_width-1 downto 0)  | FUB input    |
| fub\_str\_i    | in        | std\_logic                                    | FUB input    |
| fub\_busy\_o   | out       | std\_logic                                    | FUB input    |
| fub\_a\_data\_o | out       | std\_logic\_vector (fub\_data\_width-1 downto 0) | FUB output A |
| fub\_a\_adr\_o  | out       | std\_logic\_vector (fub\_adr\_width-1 downto 0)  | FUB output A |
| fub\_a\_str\_o  | out       | std\_logic                                    | FUB output A |
| fub\_a\_busy\_i | in        | std\_logic                                    | FUB output A |
| fub\_b\_data\_o | out       | std\_logic\_vector (fub\_data\_width-1 downto 0) | FUB output B |
| fub\_b\_adr\_o  | out       | std\_logic\_vector (fub\_adr\_width-1 downto 0)  | FUB output B |
| fub\_b\_str\_o  | out       | std\_logic                                    | FUB output B |
| fub\_b\_busy\_i | in        | std\_logic                                    | FUB output B |


### Testbench
One instance of fub\_tx\_master and two instances of fub\_rx\_slave are used to simulate different transmittion modes with different speed.