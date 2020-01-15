# fub\_flash
## IP Core/Package Datasheet

Author: T. Guthier

### Short Description
Fub\_flash is a component to communicate with the flash chip (see EPCS4 (cyc\_c51014).pdf for details of the flash) installed on the FIB. It has two FUB Interfaces. One to write data on the flash, the other to read data from the flash. The code is optimized for block transfer. Block transfer means, that emidietly after you got access to an address, you use the next higher address as well. For example, writing data on address 1 to 10 or reading out address 4 to 241. A writing block always ends at the end of a page. A page has 256 addresses. The first page starts with address 0, the second with 256 and so on.
A flash memory needs to be deleted before the second time data is written on the same address. That is why you can activate an automatic erase cycle in front of every write prozess by setting the generic “erase\_in\_front\_of\_write” to ‘1’. Notice that writing a block has only an erase cycle in front of the first writing operation, so it is recommended to use blockwise writing.
There is a external erase port which can be used. The erase cycle will aways erase the whole sector of the given address. The address range of the sectors, as well as timing informations,  can be found in EPCS4 (cyc\_c51014).pdf. Make sure that the erase\_str will not be high at the same time as fub\_write\_str or fub\_read\_str, because those signals will be ignored if erase\_str is high.

### Generics

| Name                       | Type      | Description                        |
|----------------------------|-----------|------------------------------------|
| main\_clk                   | real      | clock                              |
| priority\_on\_reading        | std\_logic | if both str signals, which to use? |
| my\_delay\_in\_ns\_for\_reading | real      | depends on used flash ( 25.0 )     |
| my\_delay\_in\_ns\_for\_writing | real      | depends on used flash ( 20.0 )     |
| erase\_in\_front\_of\_write    | std\_logic | needed if erase\_i is not used      |

### Ports

| Name             | Direction | Type             | Description                                                             |
|------------------|-----------|------------------|-------------------------------------------------------------------------|
| clk\_i            | in        | std\_logic        | clock                                                                   |
| rst\_i            | in        | std\_logic        | reset                                                                   |
| fub\_write\_busy\_o | out       | std\_logic\_vector | FUB                                                                     |
| fub\_write\_data\_i | out       | std\_logic        | FUB                                                                     |
| fub\_write\_adr\_i  | out       | std\_logic\_vector | FUB                                                                     |
| fub\_write\_str\_i  | in        | std\_logic        | FUB                                                                     |
| fub\_read\_busy\_o  | out       | std\_logic        | FUB                                                                     |
| fub\_read\_data\_o  | out       | std\_logic\_vector | FUB                                                                     |
| fub\_read\_adr\_i   | in        | std\_logic\_vector | FUB                                                                     |
| fub\_read\_str\_i   | in        | std\_logic        | FUB                                                                     |
| erase\_str\_i      | in        | std\_logic        | external erase, needed if generic “erase\_in\_front\_of\_write” is not used |
| erase\_adr\_i      | in        | std\_logic\_vector | adr of the sector which will be erased                                  |
| nCS\_o            | out       | std\_logic        | connected with flash                                                    |
| asdi\_o           | out       | std\_logic        | connected with flash                                                    |
| dclk\_o           | out       | std\_logic        | connected with flash                                                    |
| data\_i           | in        | std\_logic        | connected with flash                                                    |

