# const\_delay
## IP Core/Package Datasheet

### Short Description
Implements a constant delay of z-D where D is defined with generic delay\_in\_taps.

![](https://github.com/xaratustrah/VHDL\_Library/blob/master/const\_delay/DOC/rtl.png)

### Generics

| Name          | Type    | Description                   |
|---------------|---------|-------------------------------|
| data\_width    | integer | Wordsize of input/output data |
| delay\_in\_clks | integer | Delay in clock cycles         |


### Ports

| Name   | Direction | Type                                     | Description |
|--------|-----------|------------------------------------------|-------------|
| clk\_i  | in        | std\_logic                                | clock       |
| rst\_i  | in        | std\_logic                                | reset       |
| data\_i | in        | std\_logic\_vector (data\_width-1 downto 0) | Data in     |
| data\_o | out       | std\_logic\_vector (data\_width-1 downto 0) | Data out    |


