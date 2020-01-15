# inout\_driver02
## IP Core/Package Datasheet

Author: S. Sanjari

### Short Description
The inout\_driver02  component represents a driver for handling inout data type.

### Generics


| Name         | Type    | Description                                         |
|--------------|---------|-----------------------------------------------------|
| io\_bus\_width | integer | Number of bits used for each bus on the multiplexer |


### Ports

| Name                    | Direction | Type             | Description               |
|-------------------------|-----------|------------------|---------------------------|
| read\_not\_write\_to\_bus\_i | in        | std\_logic        | Enable signal             |
| data\_bus\_io             | inout     | std\_logic\_vector | IO Bus connection         |
| data\_to\_bus\_i           | in        | std\_logic\_vector | Data written into the bus |
| data\_from\_bus\_o         | out       | std\_logic\_vector | Data read from the bus    |

