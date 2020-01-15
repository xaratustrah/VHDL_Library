# fub\_adr\_mux\_2marx\_to\_1sltx
## IP Core/Package Datasheet

### Short Description
Adress-multiplexer with two master receivers and one slave transmitter

### Generics

| Name              | Type    | Description                                                                                  |
|-------------------|---------|----------------------------------------------------------------------------------------------|
| fub\_data\_width    | integer | fub data width                                                                               |
| fub\_in\_adr\_width  | integer | address width on requesting slave side (width has to be 1 bit larger than fub\_out\_adr\_width) |
| fub\_out\_adr\_width | integer | address width on transmitting master side                                                    |

### Ports

| Name        | Direction | Type                                           | Description                               |
|-------------|-----------|------------------------------------------------|-------------------------------------------|
| clk\_i       | in        | std\_logic                                      | clock                                     |
| rst\_i       | in        | std\_logic                                      | reset                                     |
| fubA\_data\_i | in        | std\_logic\_vector(fub\_data\_width-1 downto 0)    | FUB master rx port A (addressed by MSB 0) |
| fubA\_adr\_o  | out       | std\_logic\_vector(fub\_out\_adr\_width-1 downto 0) | FUB master rx port A (addressed by MSB 0) |
| fubA\_str\_o  | out       | std\_logic                                      | FUB master rx port A (addressed by MSB 0) |
| fubA\_busy\_i | in        | std\_logic                                      | FUB master rx port A (addressed by MSB 0) |
| fubB\_data\_i | in        | std\_logic\_vector(fub\_data\_width-1 downto 0)    | FUB master rx port B (addressed by MSB 1) |
| fubB\_adr\_o  | out       | std\_logic\_vector(fub\_out\_adr\_width-1 downto 0) | FUB master rx port B (addressed by MSB 1) |
| fubB\_str\_o  | out       | std\_logic                                      | FUB master rx port B (addressed by MSB 1) |
| fubB\_busy\_i | in        | std\_logic                                      | FUB master rx port B (addressed by MSB 1) |
| fub\_data\_o  | out       | std\_logic\_vector(fub\_data\_width-1 downto 0)    | FUB slave tx port                         |
| fub\_adr\_i   | in        | std\_logic\_vector(fub\_in\_adr\_width-1 downto 0)  | FUB slave tx port                         |
| fub\_str\_i   | in        | std\_logic                                      | FUB slave tx port                         |
| fub\_busy\_o  | out       | std\_logic                                      | FUB slave tx port                         |