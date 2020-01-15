# fub\_ng\_backplane
## IP Core/Package Datasheet

Author: T. Wollmann

### Short Description
Converts the asynchronous 24 bit parallel data to synchronized fub 8 bit parallel data

### Generics

None

### Ports

| Name       | Direction | Type                          | Description                                                                       |
|------------|-----------|-------------------------------|-----------------------------------------------------------------------------------|
| clk\_i      | in        | std\_logic                     | clock                                                                             |
| rst\_i      | in        | std\_logic                     | reset                                                                             |
| par\_data\_i | in        | std\_logic\_vector(23 downto 0) | asynchronous 24 bit parallel data input vector                                    |
| par\_adr\_i  | in        | std\_logic\_vector(5 downto 0)  | parallel adress input vector                                                      |
| fub\_busy\_i | in        | std\_logic                     | fub busy signal                                                                   |
| data\_o     | out       | std\_logic\_vector(23 downto 0) | additional output port for synchronized parallel data                             |
| fub\_data\_o | out       | std\_logic\_vector(7 downto 0)  | synchronous 8 bit fub data output                                                 |
| set\_o      | out       | std\_logic                     | Synchronization Strobe                                                            |
| par\_busy\_o | out       | std\_logic                     | parallel interface busy signal                                                    |
| fub\_adr\_o  | out       | std\_logic\_vector(1 downto 0)  | adresses the fub 8 bit parallel vector to its position from 24 bit parallel input |
| fub\_str\_o  | out       | std\_logic                     | Strobe signal of FUB interface                                                    |

### Space and Timing Requirements
Requires 152 logic elements

