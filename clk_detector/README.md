# clk\_detector
## IP Core/Package Datasheet

### Short Description

clk\_detector is used for visualization of high speed signals on LED's acting like a monoflop. When the one bit input x\_i changes its value, a pulse with a pulse length of "output\_on\_time\_in\_ms" is produced at x\_o, which can be directly put on an LED for signaling e.g. data strobes, activity on serial communications, fast triggers, etc.

### Generics

| Name                 | Type | Description                                                                                                 |
|----------------------|------|-------------------------------------------------------------------------------------------------------------|
| clk\_freq\_in\_hz       | real | The used clock frequency in Hz                                                                              |
| output\_on\_time\_in\_ms | real | Pulse length of x\_o, for e.g. 100ms, that can be easiely detectet with a human eye, it must be set to 100.0 |


### Ports

| Name  | Direction | Type      | Description    |
|-------|-----------|-----------|----------------|
| clk\_i | in        | std\_logic | clock          |
| rst\_i | in        | std\_logic | reset          |
| x\_i   | in        | std\_logic | Trigger input  |
| x\_o   | out       | std\_logic | Output for LED |

