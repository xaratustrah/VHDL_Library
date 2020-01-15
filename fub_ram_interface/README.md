# fub\_ram\_interface
## IP Core/Package Datasheet
Author: T. Wollmann

### Short Description
FUB to RAM interface working in both directions, therefore two FUB interfaces are necessary, one as slave receiver writing on RAM, one as slave transmitter reading from RAM.

### Generics

| Name             | Type      | Description                                 |
|------------------|-----------|---------------------------------------------|
| adr\_width        | integer   | adress width                                |
| data\_width       | integer   | data width                                  |
| delay\_clk        | integer   | delay for interacting with RAM (default: 2) |
| priority\_on\_read | std\_logic | priority (default: 0)                       |

### Ports

| Name             | Direction | Type                                    | Description   |
|------------------|-----------|-----------------------------------------|---------------|
| clk\_i            | in        | std\_logic                               | clock         |
| rst\_i            | in        | std\_logic                               | reset         |
| fub\_write\_adr\_i  | in        | std\_logic\_vector(adr\_width-1 downto 0)  | FUB in        |
| fub\_write\_data\_i | in        | std\_logic\_vector(data\_width-1 downto 0) | FUB in        |
| fub\_write\_str\_i  | in        | std\_logic                               | FUB in        |
| fub\_write\_busy\_o | out       | std\_logic                               | FUB in        |
| fub\_read\_adr\_i   | in        | std\_logic\_vector(adr\_width-1 downto 0)  | FUB out       |
| fub\_read\_data\_o  | out       | std\_logic\_vector(data\_width-1 downto 0) | FUB out       |
| fub\_read\_str\_i   | in        | std\_logic                               | FUB out       |
| fub\_read\_busy\_o  | out       | std\_logic                               | FUB out       |
| ram\_wren\_o       | out       | std\_logic                               | RAM interface |
| ram\_adr\_o        | out       | std\_logic\_vector(adr\_width-1 downto 0)  | RAM interface |
| ram\_data\_o       | out       | std\_logic\_vector(data\_width-1 downto 0) | RAM interface |
| ram\_q\_i          | in        | std\_logic\_vector(data\_width-1 downto 0) | RAM interface |


### Hints
Note that this inteface has only slave interfaces.

### Space and Timing Requirements
clk\_delay if this interface is at work, clk\_delay+2 for the first transmission.

