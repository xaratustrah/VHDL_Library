# fub\_fifo
## IP Core/Package Datasheet

### Short Description
This component implements a FIFO function with a FUB interface on both input and output side.

### Generics

| Name           | Type    | Description                       |
|----------------|---------|-----------------------------------|
| fub\_data\_width | integer | Width of the FUB Data bus         |
| fub\_addr\_width | integer | Width of the FUB address bus      |
| fifo\_depth     | integer | Number of words the FIFO contains |

### Ports


| Name          | Direction | Type             | Description         |
|---------------|-----------|------------------|---------------------|
| clk\_i         | in        | std\_logic        | clock               |
| rst\_i         | in        | std\_logic        | reset               |
| fub\_rx\_data\_i | in        | std\_logic\_vector | Standard FUB signal |
| fub\_rx\_strb\_i | in        | std\_logic        | Standard FUB signal |
| fub\_rx\_busy\_o | out       | std\_logic        | Standard FUB signal |
| fub\_rx\_addr\_i | in        | std\_logic\_vector | Standard FUB signal |
| fub\_tx\_data\_o | out       | std\_logic\_vector | Standard FUB signal |
| fub\_tx\_busy\_i | in        | std\_logic        | Standard FUB signal |
| fub\_tx\_strb\_o | out       | std\_logic        | Standard FUB signal |
| fub\_tx\_addr\_o | out       | std\_logic\_vector | Standard FUB signal |



