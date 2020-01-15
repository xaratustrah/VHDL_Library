# fub\_rx\_master
## IP Core Datasheet
Author: S. Sanjari

### Short Description
This is the reference implementation for the FUB interface master component in the receiving mode.

### Generics

| Name             | Type    | Description                               |
|------------------|---------|-------------------------------------------|
| addr\_width       | integer | Width of the generated address word       |
| data\_width       | integer | Width of the expected data word           |
| addr\_start\_value | integer | Start value for the address generator     |
| addr\_stop\_value  | integer | Stop value for the address generator      |
| addr\_inc\_value   | integer | Increment the next generated word by this |

### Ports


| Name       | Direction | Type             | Description                      |
|------------|-----------|------------------|----------------------------------|
| clk\_i      | in        | std\_logic        | External Interface Clock Signal  |
| rst\_i      | in        | std\_logic        | External Interface reset Signal  |
| data\_o     | out       | std\_logic\_vector | External Interface data bus      |
| addr\_o     | out       | std\_logic\_vector | External Interface address bus   |
| str\_o      | out       | std\_logic        | External Interface strobe Signal |
| fub\_str\_o  | out       | std\_logic        | FUB Interface strobe Signal      |
| fub\_busy\_i | in        | std\_logic        | FUB Interface Busy Signal        |
| fub\_data\_i | in        | std\_logic\_vector | FUB Interface data bus           |
| fub\_addr\_o | out       | std\_logic\_vector | FUB Interface address bus        |


