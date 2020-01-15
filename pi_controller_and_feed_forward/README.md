# pi\_controller\_and\_feed\_forward
## IP Core/Package Datasheet
Author: T. Guthier


### Short Description
PI Controller with an additional forward control path. The forward control path can be used by an additional input channel (data\_nl\_i). To use it, the input signal “use\_nl\_feed\_forwad” must be ‘1’. The controller has an intern ANTIWINUP, so the maximum value of the integrating path is limited. The int\_data\_width must be set high enough to ensure that no overflow can occur. It can be calculated by a formular found in “Studienarbeit Thomas Guthier”. For full documentation see “Studienarbeit Thomas Guthier”.

### Generics

| Name                         | Type      | Description                                                                                        |
|------------------------------|-----------|----------------------------------------------------------------------------------------------------|
| use\_negative\_adc\_input       | std\_logic | If adc input range is -10V to 10V set ‘0’, because the controller will only use the range 0 to 10V |
| data\_width                   | integer   | sum of int\_data\_width\_before\_dot + int\_data\_width\_after\_dot                                        |
| int\_data\_width\_before\_dot    | integer   |                                                                                                    |
| int\_data\_width\_after\_dot     | integer   |                                                                                                    |
| intern\_data\_width            | integer   |                                                                                                    |
| number\_of\_pipelines\_for\_mult | integer   | Recommended: intern\_data\_width / 2                                                                 |
| sampling\_frequency           | real      | Sampling Frequenzy of the ADC                                                                      |



### Ports

| Name                | Direction | Type                                           | Description                                                       |
|---------------------|-----------|------------------------------------------------|-------------------------------------------------------------------|
| clk\_i               | input     | std\_logic                                      | Clk                                                               |
| rst\_i               | input     | std\_logic                                      | Rest                                                              |
| k\_v                 | input     | std\_logic\_vector(intern\_data\_width-1 downto 0) | Parameter of forward control path                                 |
| k\_p                 | input     | std\_logic\_vector(intern\_data\_width-1 downto 0) | Parameter of proportional path                                    |
| k\_i                 | input     | std\_logic\_vector(intern\_data\_width-1 downto 0) | Parameter of integrating path                                     |
| data\_w\_i            | input     | std\_logic\_vector(data\_width-1 downto 0)        | Incoming “Istwert”                                                |
| data\_y\_i            | input     | std\_logic\_vector(data\_width-1 downto 0)        | Incoming “Sollwert”                                               |
| data\_u\_o            | output    | std\_logic\_vector(data\_width-1 downto 0)        | “Stellgröße”                                                      |
| use\_nl\_feed\_forward | Input     | std\_logic                                      | If the NL Feed Forward Input is used, this signal must be set ‘1’ |

