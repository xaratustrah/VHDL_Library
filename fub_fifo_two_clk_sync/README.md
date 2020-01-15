# fub\_fifo\_two\_clk\_sync
## IP Core/Package Datasheet

### Short Description
Synchronizes data between two asynchronous clock domains using a FIFO (Fast In Fast Out) Memory.

### Generics

| Name                   | Type    | Description                                       |
|------------------------|---------|---------------------------------------------------|
| intended\_device\_family | string  | The used FPGA Device (f.e.: “Cyclone”)            |
| worddepth              | integer | FIFO Memory Wordsize                              |
| use\_adr                | integer | Err:509                                           |
| fub\_data\_width         | integer | fub data width                                    |
| fub\_adr\_width          | integer | fub address width (= 0, if no addresses are used) |

### Ports

| Name             | Direction | Type                                        | Description           |
|------------------|-----------|---------------------------------------------|-----------------------|
| rst\_i            | in        | std\_logic                                   | reset                 |
| write\_clk\_i      | in        | std\_logic                                   | clock of writing part |
| read\_clk\_i       | in        | std\_logic                                   | clock of reading part |
| fub\_write\_data\_i | in        | std\_logic\_vector(fub\_data\_width-1 downto 0) | Writing FUB Interface |
| fub\_write\_adr\_i  | in        | std\_logic\_vector(fub\_adr\_width-1 downto 0)  | Writing FUB Interface |
| fub\_write\_str\_i  | in        | std\_logic                                   | Writing FUB Interface |
| fub\_write\_busy\_o | out       | std\_logic                                   | Writing FUB Interface |
| fub\_read\_data\_o  | out       | std\_logic\_vector(fub\_data\_width-1 downto 0) | Reading FUB Interface |
| fub\_read\_adr\_o   | out       | std\_logic\_vector(fub\_adr\_width-1 downto 0)  | Reading FUB Interface |
| fub\_read\_str\_o   | out       | std\_logic                                   | Reading FUB Interface |
| fub\_read\_busy\_i  | in        | std\_logic                                   | Reading FUB Interface |

