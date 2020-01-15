# fub\_mls\_rx
## IP Core/Package Datasheet

Author: T. Guthier

### Short Description
fub\_mls\_rx can be used to verify if a FUB package send by fub\_mls\_tx has not changed during a transmission. 
Its FPGA sided connection is a FUB interface. The vector length of fub\_data\_i and fub\_adr\_i is 8. The output signals show when the system is locked and when an error occurs. There is a 8 bit counter who counts the number of erros to an limit of 255. The overflow signal shows if there are more then 255 errors.
 
### Generics

| Name    | Direction | Type      | Description                                      |
|---------|-----------|-----------|--------------------------------------------------|
| use\_adr | in        | std\_logic | ‘1’ if 8Bit address vector is used || ‘0’ if not |

### Ports

| Name               | Direction | Type             | Description                                     |
|--------------------|-----------|------------------|-------------------------------------------------|
| clk\_i              | in        | std\_logic        | clock                                           |
| rst\_i              | in        | std\_logic        | reset                                           |
| fub\_data\_i         | in        | std\_logic\_vector | FUB                                             |
| fub\_str\_i          | in        | std\_logic        | FUB                                             |
| fub\_adr\_i          | in        | std\_logic\_vector | FUB                                             |
| fub\_busy\_o         | out       | std\_logic        | FUB                                             |
| locked\_o           | out       | std\_logic        | Locked signal                                   |
| failure\_o          | out       | std\_logic        | Failure signal                                  |
| failure\_vector\_o   | out       | std\_logic\_vector | 8 bit Vector that counts the number of failures |
| failure\_overflow\_o | out       | std\_logic        | Failure overflow signal                         |

### Additional files
data\_comparator.vhd


