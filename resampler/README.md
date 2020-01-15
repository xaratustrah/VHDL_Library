# resampler
## IP Core/Package Datasheet

Author: M. Kumm

### Short Description
Resamples the input data with clk1 to a new sample rate clk2. 

### Generics

| Name       | Type    | Description                               |
|------------|---------|-------------------------------------------|
| data\_width | integer | Number of bits in data input/output word. |


### Ports

| Name   | Direction | Type                                     | Description     |
|--------|-----------|------------------------------------------|-----------------|
| clk1\_i | in        | std\_logic                                | clock of data\_i |
| clk2\_i | in        | std\_logic                                | clock of data\_o |
| data\_i | in        | std\_logic\_vector (data\_width-1 downto 0) | Input Data      |
| data\_o | out       | std\_logic\_vector (data\_width-1 downto 0) | Output Data     |

