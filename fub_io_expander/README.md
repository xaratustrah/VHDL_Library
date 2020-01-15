# fub\_IO\_expander
## IP Core/Package Datasheet
Author: O. Bitterling

### Short Description
Configures an IO expander (MCP23S17) and creates a transparent data transmission between its parallel input ports and the output ports of the expander through a serial communication.

### Generics

| Name               | Type                            | Description                                                                          |
|--------------------|---------------------------------|--------------------------------------------------------------------------------------|
| default\_io\_data    | std\_logic\_vector(15 downto 0)   | Initial state of the 16 GPIO ports of the expander if they are configured as output. |
| default\_setup\_data | std\_logic\_vector(n*16 downto 0) | Configuration string wich is used to initialize the expander before use.             |
| spi\_address        | integer                         | Lowest adress in regard to the module fub\_multi\_spi\_master                           |
| fub\_addr\_width     | integer                         | Width of the fub adress output                                                       |
| fub\_data\_width     | integer                         | Width of the fub data output                                                         |

### Ports

| Name               | Direction | Type                                    | Description |
|--------------------|-----------|-----------------------------------------|-------------|
| clk\_i              | in        | std\_logic                               | clock       |
| rst\_i              | in        | std\_logic                               | reset       |
| fub\_adr\_o          | out       | std\_logic\_vector(addr\_width-1 downto 0) | FUB out     |
| fub\_ data\_o        | out       | std\_logic\_vector(data\_width-1 downto 0) | FUB out     |
| fub\_str\_o          | out       | std\_logic                               | FUB out     |
| fub\_busy\_i         | in        | std\_logic                               | FUB out     |
| io\_expander\_data\_i | in        | std\_logic\_vector(15 downto 0)           | Parallel in |
| io\_expander\_str\_i  | in        | std\_logic                               | Parallel in |
| io\_expander\_busy\_o | out       | std\_logic                               | Parallel in |

### Hints

For proper operation the pins one and two always have to configured as input whereas the pins seven and eight can be configured as input or output either. Therefor the configuration string default\_setup\_data must hold one of the following parts : x"0103" ; x"0183" ; x"0143" ; x"01C3". These represent the four possible combinations of the pins six and seven.
