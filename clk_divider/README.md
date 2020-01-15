# clk_divider
## IP Core/Package Datasheet

### Short Description

This is a clock divider. The following three operation modes may be considered:

    • If the clk_div_in factor is set to zero, output is set to logical zero.
    • If the clk_div_in factor is set to 1 (one), then the clk_i is directly connected to the ouput clock.
    • If the clk_div_in factor is set to any other integer number, the a clock division is made by that factor. For instance a value of 5 woluld result in the following waveform:
    
    
    which means that for a period of 20ns (50MHz) the resulting waveform will have 	a positive clock edge every 100ns (10MHz).


### Generics


| Name              | Type    | Description                                           |
|-------------------|---------|-------------------------------------------------------|
| clk_divider_width | integer | Width of the data word describing the division factor |

### Ports

| Name       | Direction | Type             | Description                               |
|------------|-----------|------------------|-------------------------------------------|
| clk_i      | in        | std_logic        | Clock (input)                             |
| rst_i      | in        | std_logic        | Reset                                     |
| clk_o      | out       | std_logic        | Clock output (result)                     |
| clk_div_in | in        | std_logic_vector | Ddata word describing the division factor |
