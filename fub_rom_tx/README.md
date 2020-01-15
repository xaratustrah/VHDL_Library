# fub\_rom\_tx
## IP Core/Package Datasheet
Author: M. Kumm


### Short Description
fub\_rom\_tx is a FUB sender that transmits the content of a user defined ROM. The input data format must be defined in a separate package with the name init\_rom\_pkg by the user (as type init\_rom) with a specified ROM size (as constant init\_rom\_size) and a specified wordsize (as constant init\_data\_width). This package is automatically included (used) in fub\_rom\_tx and must be used in the userfile. The package definition for a 100 byte ROM and a standard wordsize of 8 bit can be defined as follows:

```
library ieee;
use ieee.std\_logic\_1164.all;

package init\_rom\_pkg is

constant init\_rom\_size : integer := 100;
constant init\_data\_width : integer := 8;
type init\_rom is array(0 to init\_rom\_size-1) of std\_logic\_vector(init\_data\_width-1 downto 0);

end init\_rom\_pkg;

package body init\_rom\_pkg is
end init\_rom\_pkg;
```

### Generics

| Name	Type	Description |                 |      |      |        |         |       |        |    |            |         |         |     |                |     |    |     |    |   |    |        |      |        |
|---------------------|-----------------|------|------|--------|---------|-------|--------|----|------------|---------|---------|-----|----------------|-----|----|-----|----|---|----|--------|------|--------|
| wait\_clks           | integer         |      |      | Number | of      | clock | cycles | to | be         | waited  | between | the | transmissions. | Can | be | set | to | 0 | to | enable | full | speed. |
| addr\_width          | integer	Wordsize | of   | the  | FUB    | address | word. |        |    |            |         |         |     |                |     |    |     |    |   |    |        |      |        |
| endless\_loop        | boolean	If       | this | flag | is     | true,   | the   | ROM    | is | transfered | endless | in      | a   | loop           |     |    |     |    |   |    |        |      |        |


### Ports


| Name        | Direction | Type                                          | Description         |
|-------------|-----------|-----------------------------------------------|---------------------|
| clk\_i       | in        | std\_logic                                     | clock               |
| rst\_i       | in        | std\_logic                                     | reset               |
| init\_data\_i | in        | init\_rom                                      | Input data ROM      |
| fub\_data\_o  | out       | std\_logic\_vector (init\_data\_width-1 downto 0) | FUB output (master) |
| fub\_addr\_o  | out       | std\_logic\_vector (addr\_width-1 downto 0)      | FUB output (master) |
| fub\_str\_o   | out       | std\_logic                                     | FUB output (master) |
| fub\_busy\_i  | in        | std\_logic                                     | FUB output (master) |



### Dependencies to other IP Cores
init\_rom\_pkg (user defined)

### Quartus Project
None (see fub\_dds Quartus project for an example).

### Testbench
None (see fub\_dds Modelsim project for an example).

### Space and Timing Requirements
39 LE on a Cyclone I typically.

