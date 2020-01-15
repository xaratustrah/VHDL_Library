# fub\_two\_clk\_sync
## IP Core/Package Datasheet
Author: T. Guthier

### Short Description
fub\_two\_clk\_sync can be used to synchronize FUB data between two clk domains. There is no difference between synchronization from lower to faster or faster to lower clk domain.


### Generics

| Name    | Type    | Description         |
|---------|---------|---------------------|
| bitSize | integer | bitsize of fub\_data |
| adrSize | integer | bitsize of fub\_adr  |


### Ports

| Name       | Direction | Type             | Description |
|------------|-----------|------------------|-------------|
| clk\_i      | in        | std\_logic        | clock       |
| rst\_i      | in        | std\_logic        | reset       |
| fub\_data\_i | in        | std\_logic\_vector | FUB         |
| fub\_data\_o | out       | std\_logic\_vector | FUB         |
| fub\_str\_i  | in        | std\_logic        | FUB         |
| fub\_str\_o  | out       | std\_logic        | FUB         |
| fub\_adr\_i  | in        | std\_logic\_vector | FUB         |
| fub\_adr\_o  | out       | std\_logic\_vector | FUB         |
| fub\_busy\_i | in        | std\_logic        | FUB         |
| fub\_busy\_o | out       | std\_logic        | FUB         |

