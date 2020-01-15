# fub\_packet\_detector
## IP Core/Package Datasheet

### Short Description
This component asserts a pulse of one clock width if the desired pattern is present at the FUB interface. The sensitivity could be controlled using two input signals, meaning that a pattern only on the FUB address bus should be detected, or only on the FUB data bus, or on both of them. The latter means that the address and data bus should both contain the pattern.

The detect signal could be used as a kind of strobe signal for the following component.


### Generics

| Name                     | Type    | Description                               |
|--------------------------|---------|-------------------------------------------|
| detect\_on\_address        | integer | Pattern on the address bus                |
| enable\_address\_detection | boolean | Should the pattern detection be enabled?  |
| detect\_on\_data           | integer | Pattern on the data bus                   |
| enable\_data\_detection    | boolean | Should the pattern detection be enabled?  |
| fub\_data\_width           | integer | Wordsize of FUB data (should be 8 Bit)    |
| fub\_adr\_width            | integer | Wordsize of FUB address (should be 8 Bit) |



### Ports

| Name       | Direction | Type             | Description       |
|------------|-----------|------------------|-------------------|
| clk\_i      | in        | std\_logic        | clock             |
| rst\_i      | in        | std\_logic        | reset             |
| fub\_data\_i | in        | std\_logic\_vector | INPUT FUB Data    |
| fub\_addr\_i | in        | std\_logic\_vector | INPUT FUB Address |
| fub\_busy\_o | out       | std\_logic        | INPUT FUB busy    |
| fub\_strb\_i | in        | std\_logic        | INPUT FUB Strobe  |
| detect\_o   | out       | std\_logic        | Detect signal     |

