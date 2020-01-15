# real\_time\_blinker
## IP Core/Package Datasheet

Author: S. Sanjari

### Short Description

This module implements a real time blinker for use with LEDs, Buzzer, etc. For conveniance in generating audio visual signalling elements, the unit of measurement has been set to mili seconds. The blinker output has a 50% duty cycle.

### Generics

| Name               | Type | Description                    |
|--------------------|------|--------------------------------|
| clk\_freq\_in\_hz     | real | The used clock frequency in Hz |
| blink\_period\_in\_ms | real | Blink period in mili seconds   |

### Ports

| Name    | Direction | Type      | Description          |
|---------|-----------|-----------|----------------------|
| clk\_i   | in        | std\_logic | clock                |
| rst\_i   | in        | std\_logic | reset                |
| blink\_o | out       | std\_logic | blinker ouput signal |

