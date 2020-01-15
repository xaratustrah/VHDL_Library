# fub\_dds
## IP Core/Package Datasheet

### Short Description
fub\_dds is a FUB Interface to the analog devices AD9854 DDS in parallel port mode. The dds-update output pin is bidirectional and the default direction is "in" (the default update direction from the DDS is out!), only when reg 1F bit 0 is set to '0', the dds-update direction is switched to out. The data is transfered in two cycles to the DDS, so a full speed access can be achieved. The limitation of speed is given from the DDS timing (address setup time), so that the clk period must be less than 8 ns (125MHz). One write cycle takes therefore 16 ns (update rate 62.5 MHz). The update can be triggered by specifying a specific dds address update\_adr (e.g. FTW low byte). Note that the update is triggered when update\_adr is received from the FUB interface and not when the data is already sent to the DDS! 

### Generics

| Name               | Type    | Description                                                                                            |
|--------------------|---------|--------------------------------------------------------------------------------------------------------|
| clk\_freq\_in\_hz     | real    | The used clock frequency in Hz                                                                         |
| dds\_clk\_freq\_in\_hz | real    | The used dds frequency in Hz (for calculating the dds reset time)                                      |
| update\_adr         | integer |                                                                                                        |
| fub\_addr\_width     | integer | Wordsize of the FUB address, normaly this is set to 6 bit, unless a higher address for updates is used |

### Ports

| Name          | Direction | Type                                         | Description    |
|---------------|-----------|----------------------------------------------|----------------|
| clk\_i         | in        | std\_logic                                    | clock          |
| rst\_i         | in        | std\_logic                                    | reset          |
| fub\_data\_i    | in        | std\_logic\_vector (7 downto 0)                | FUB in (slave) |
| fub\_addr\_i    | in        | std\_logic\_vector (fub\_addr\_width-1 downto 0) | FUB in (slave) |
| fub\_str\_i     | in        | std\_logic                                    | FUB in (slave) |
| fub\_busy\_o    | out       | std\_logic                                    | FUB in (slave) |
| fub\_busy\_o    | out       | std\_logic                                    | FUB in (slave) |
| dds\_rst\_o     | out       | std\_logic\_vector (7 downto 0)                | Pins to DDS    |
| dds\_data\_o    | out       | std\_logic\_vector (5 downto 0)                | Pins to DDS    |
| dds\_addr\_o    | out       | std\_logic                                    | Pins to DDS    |
| dds\_nwr\_o     | out       | std\_logic                                    | Pins to DDS    |
| dds\_update\_io | inout     | std\_logic                                    | Pins to DDS    |


### Dependencies to other IP Cores
real\_time\_calculator\_pkg

### Quartus Project
fib\_dds\_ini - sends an init string to the dds (via fub\_rom\_tx), which sets the output frequency to 1 MHz.

### Testbench
fib\_dds\_ini\_top\_tb for testing fib\_dds\_ini\_top.

### Hints
The DDS signal dds\_fsk and dds\_sh\_key should be set to zero when they are not used.

### Space and Timing Requirements
28 LE on a Cyclone I typically.

