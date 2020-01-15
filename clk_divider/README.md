# clk\_divider
## IP Core/Package Datasheet

### Short Description

This is a clock divider. The following three operation modes may be considered:

* If the clk\_div\_in factor is set to zero, output is set to logical zero.
* If the clk\_div\_in factor is set to 1 (one), then the clk\_i is directly connected to the ouput clock.
* If the clk\_div\_in factor is set to any other integer number, the a clock division is made by that factor. For instance a value of 5 woluld result in the following waveform:
       
![](https://github.com/xaratustrah/VHDL\_Library/blob/master/clk\_divider/DOC/example\_wave.png)

which means that for a period of 20ns (50MHz) the resulting waveform will have a positive clock edge every 100ns (10MHz).


### Generics


| Name              | Type    | Description                                           |
|-------------------|---------|-------------------------------------------------------|
| clk\_divider\_width | integer | Width of the data word describing the division factor |

### Ports

| Name       | Direction | Type             | Description                               |
|------------|-----------|------------------|-------------------------------------------|
| clk\_i      | in        | std\_logic        | Clock (input)                             |
| rst\_i      | in        | std\_logic        | Reset                                     |
| clk\_o      | out       | std\_logic        | Clock output (result)                     |
| clk\_div\_in | in        | std\_logic\_vector | Ddata word describing the division factor |
