# fub\_direct\_opt\_link\_tx
## IP Core/Package Datasheet
Author: T. Guthier

### Short Description
fub\_direct\_opt\_link\_tx is a component to send data send over an optical link, which can be received by fub\_direct\_opt\_link\_rx. This two components are implemented to get a fast unidirectional connection between two FIBs. The interface to the FPGA is a FUB( receiving, slave) including an optional address vector. If the address is used, set generic use\_adr <= 1, if not used set use\_adr <= 0. The component needs a 100MHz input clk.


### Generics

| Name        | Type    | Description                                             |
|-------------|---------|---------------------------------------------------------|
| bitSize     | integer | the bitsize of the fub\_data output                      |
| adr\_bitSize | integer | the bitsize of the fub\_adr output                       |
| use\_adr     | integer | determins if fub\_adr\_o is used ( <= 1 ) or not ( <= 0 ) |


### Ports

| Name       | Direction | Type             | Description           |
|------------|-----------|------------------|-----------------------|
| clk\_i      | in        | std\_logic        | clock                 |
| rst\_i      | in        | std\_logic        | reset                 |
| opt\_data\_o | out       | std\_logic        | optical output signal |
| fub\_busy\_o | out       | std\_logic        | FUB                   |
| fub\_data\_i | in        | std\_logic\_vector | FUB                   |
| fub\_adr\_i  | in        | std\_logic\_vector | FUB                   |
| fub\_str\_i  | in        | std\_logic        | FUB                   |



