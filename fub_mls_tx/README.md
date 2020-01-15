# fub\_mls\_tx
## IP Core/Package Datasheet
Author: T. Guthier

### Short Description
fub\_mls\_tx sends a 8 bit maximum length sequence over a FUB interface. Its fub\_str\_o signal is always high and whenever fub\_busy\_i is ‘0’ the value of fub\_data\_o and fub\_adr\_o change. Both output vectors have a length of 8 bit. 

### Generics
none

### Ports

| Name       | Direction | Type             | Description |
|------------|-----------|------------------|-------------|
| clk\_i      | in        | std\_logic        | clock       |
| rst\_i      | in        | std\_logic        | reset       |
| fub\_data\_o | out       | std\_logic\_vector | FUB         |
| fub\_str\_o  | out       | std\_logic        | FUB         |
| fub\_adr\_o  | out       | std\_logic\_vector | FUB         |
| fub\_busy\_i | in        | std\_logic        | FUB         |



### Hints
fub\_mls\_rx can be used to verify that the data send by fub\_mls\_tx has not changed during the transmission. 

