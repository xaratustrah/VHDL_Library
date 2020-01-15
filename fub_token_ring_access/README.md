# fub\_token\_ring\_access
## IP Core/Package Datasheet
Author: T. Guthier

### Short Description
The fub\_token\_ring\_access is an access point to a token ring structure wich is connected due to optical fibres. Every access point has one FUB input and one FUB output interface.
The FUB output interface of every access point is addressed by its specific local address (local\_adr). Data can be sended from any access point FUB input to any other access point FUB output. The target address (target\_adr) of the sending access point must be identical to the local address (local\_adr) of the receiver. Also the sum of the bitSize\_input + adr\_bitSize\_input of the sending access point must be indentical with the sum of the bitSize\_output + adr\_bitSize\_output of the receiving access point.
One of the access points has to be master.
Every access point works in two different clk domains. The FUB input domain works with a 80MHz clock, the FUB output domain works with a clock of 200MHz. The incoming optical data has to be synchronized two times with 200MHz.
For the complete documentation look at “VHDL Implementierung eines Token Rings 0.9.pdf”


### Generics


| Name               | Type    | Description                                             |
|--------------------|---------|---------------------------------------------------------|
| bitSize\_input      | integer | the bitsize of the fub\_data\_i (input)                   |
| bitSize\_output     | integer | the bitsize of the fub\_data\_o (output)                  |
| adr\_bitSize\_input  | integer | the bitsize of the fub\_adr\_i (input)                    |
| use\_adr\_input      | integer | determins if fub\_adr\_i is used ( <= 1 ) or not ( <= 0 ) |
| adr\_bitSize\_output | integer | the bitsize of the fub\_adr\_o (output)                   |
| use\_adr\_output     | integer | determins if fub\_adr\_o is used ( <= 1 ) or not ( <= 0 ) |


### Ports

| Name             | Direction | Type                         | Description                                                                                                    |
|------------------|-----------|------------------------------|----------------------------------------------------------------------------------------------------------------|
| target\_adr       | input     | std\_logic\_vector(7 downto 0) | determines to which access point the data is send                                                              |
| local\_adr        | input     | std\_logic\_vector(7 downto 0) | the unique token address of this specific access point                                                         |
| master           | input     | std\_logic                    | one and only one of the access points has to be set master(value '1') all the others are not master(value '0') |
| clk100\_i         | input     | std\_logic                    | clock for the input domain (needs 80MHz input)                                                                 |
| clk250\_i         | input     | std\_logic                    | clock for the output domain (needs 200MHz input)                                                               |
| data\_i           | input     | std\_logic                    | incoming optical data (needs to get synced two times with 200MHz)                                              |
| data\_o           | output    | std\_logic                    | outgoing optical data                                                                                          |
| observer\_data    | output    | std\_logic                    | test signal to look at the incoming optical data                                                               |
| fub\_data\_i       | input     | std\_logic\_vector             | incoming FUB                                                                                                   |
| fub\_busy\_o       | output    | std\_logic                    | incoming FUB                                                                                                   |
| fub\_str\_i        | input     | std\_logic                    | incoming FUB                                                                                                   |
| fub\_adr\_i        | input     | std\_logic\_vector             | incoming FUB                                                                                                   |
| fub\_data\_o       | output    | std\_logic\_vector             | outgoing FUB                                                                                                   |
| fub\_str\_o        | output    | std\_logic                    | outgoing FUB                                                                                                   |
| fub\_adr\_o        | output    | std\_logic\_vector             | outgoing FUB                                                                                                   |
| fub\_busy\_i       | input     | std\_logic                    | outgoing FUB                                                                                                   |
| block\_transfer\_i | input     | std\_logic                    | blocktransfer input                                                                                            |


### Additonal files
decoder
decoder\_sync
decoder\_main
decoder\_comparator
encoder
encoder\_sync
encoder\_memory
encoder\_main
fub\_input
fub\_input\_adr\_mux
fub\_input\_parallel\_seriell
fub\_output
fub\_output\_seriell\_parallel
fub\_output\_adr\_demux

### Quartus Project
token\_ring\_ap6
token\_ring\_mls\_two\_ap
token\_ring\_mls\_two\_ap2
token\_ring\_rs232\_two\_ap

### Testbench
token\_ring\_mls\_two\_ap\_tb
token\_ring\_mls\_two\_ap2\_tb

### Hints
If the connected device cannot be used with 200MHz use fub\_two\_clk\_sync for synchronization between the fub\_direct\_opt\_link\_rx and the slower clk domain of the connected device.
If the design cannot reach the timing of 200MHz run the timing optimizer adviser.
There are also other CLKs possible, but the decoder CLK must be 2,5 * encoder CLK. If the CLKs are changed you have to make sure, that the connected electronic is able to work with that signals, especially the transmitter and receivers.


