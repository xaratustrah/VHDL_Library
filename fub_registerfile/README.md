# fub\_registerfile
## IP Core/Package Datasheet

### Short Description

This component realizes a register file with a FUB interface input. The register file will be addressed linearly.
Example: 
Registerfile contains 3 registers (0, 1 and 2) of 8-bits each. FUB data contains x"55", and FUB address contains x"02". Then register number 2 will have a value of 55 hex.

### Generics

| Name              | Type    | Description                                 |
|-------------------|---------|---------------------------------------------|
| fub\_address\_width | integer | Width of the FUB address word               |
| fub\_data\_width    | integer | Width of the FUB data word                  |
| no\_of\_registers   | integer | Number of the registers in the registerfile |
| register\_width    | integer | Width of each register in the registerfile  |


### Ports


| Name           | Direction | Type             | Description                                               |
|----------------|-----------|------------------|-----------------------------------------------------------|
| clk\_i          | in        | std\_logic        | clock                                                     |
| rst\_i          | in        | std\_logic        | reset                                                     |
| fub\_strb\_i     | out       | std\_logic        | strobe signal of FUB interface                            |
| fub\_data\_i     | out       | std\_logic\_vector | FUB interface data bus                                    |
| fub\_addr\_i     | out       | std\_logic\_vector | FUB interface address bus                                 |
| fub\_busy\_o     | in        | std\_logic        | FUB Busy out                                              |
| registerfile\_o | out       | std\_logic        | The whole registerfile mapped to on long std\_logic\_vector |

