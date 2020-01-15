# fub\_dsp\_link\_rx
## IP Core/Package Datasheet

### Short Description
Implementation of the DSP-Link-Interface in receiving mode. The 32 bit of the DSP-Link are mapped to the 2 bit FUB addresses 0 to 3 (low-byte at address 0) of the FUB interface.

### Generics
None


### Ports

| Name       | Direction | Type                         | Description                             |
|------------|-----------|------------------------------|-----------------------------------------|
| clk\_i      | in        | std\_logic                    | clock                                   |
| rst\_i      | in        | std\_logic                    | reset                                   |
| fub\_busy\_i | in        | std\_logic                    | FUB Interface to DSP-Link               |
| fub\_str\_o  | out       | std\_logic                    |                                         |
| fub\_adr\_o  | out       | std\_logic\_vector(1 downto 0) |                                         |
| fub\_data\_o | out       | std\_logic\_vector(7 downto 0) |                                         |
| dsp\_data\_i | in        | std\_logic\_vector(7 downto 0) | DSP-Link data                           |
| dsp\_cstr\_i | in        | std\_logic                    | DSP-Link strobe                         |
| dsp\_cack\_i | in        | std\_logic                    | DSP-Link acknowledge  (first byte mark) |
| dsp\_crdy\_o | out       | std\_logic                    | DSP-Link ready                          |

### Hints
The dsp\_cstr\_i and dsp\_cack\_i signals must be synchronized externaly!
For FIB: All DSP-Link signals (including the data) have to be inverted!
