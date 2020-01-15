# fub\_direct\_opt\_link\_rx
## IP Core/Package Datasheet

Author: T. Guthier

### Short Description
fub\_direct\_opt\_link\_rx is a component to receive data send by fub\_direct\_opt\_link\_tx over an optical link. This two components are implemented to get a fast unidirectional connection between two FIBs. The interface to the FPGA is a FUB( sending, master) including an optional address vector. If the address is used, set generic use\_adr <= 1, if not used set use\_adr <= 0.
The input from optical input needs to get synchronized two times with 250MHz. The whole component has to get a 250MHz input clk.

### Generics

| Name        | Type    | Description                                             |
|-------------|---------|---------------------------------------------------------|
| bitSize     | integer | the bitsize of the fub\_data output                      |
| adr\_bitSize | integer | the bitsize of the fub\_adr output                       |
| use\_adr     | integer | determins if fub\_adr\_o is used ( <= 1 ) or not ( <= 0 ) |

### Ports


| Name       | Direction | Type             | Description          |
|------------|-----------|------------------|----------------------|
| clk\_i      | in        | std\_logic        | clock                |
| rst\_i      | in        | std\_logic        | reset                |
| opt\_data\_i | in        | std\_logic        | optical input signal |
| fub\_busy\_i | in        | std\_logic        | FUB                  |
| fub\_data\_o | out       | std\_logic\_vector | FUB                  |
| fub\_adr\_o  | out       | std\_logic\_vector | FUB                  |
| fub\_str\_o  | out       | std\_logic        | FUB                  |


### Additional files
decoder 
decoder\_main
decoder\_comparator
fub\_output\_adr\_demux
seriell\_parallel 


### Quartus Project
mls\_opt\_rx
rs232\_opt\_rx

### Testbench
found in fub\_direct\_opt\_link\_tx

### Hints
If the connected device cannot be used with 250MHz use fub\_two\_clk\_sync for synchronization between the fub\_direct\_opt\_link\_rx and the slower clk domain of the connected device. If the design cannot reach the timing of 250MHz run the timing optimizer adviser. 



