# id\_info
### IP Core/Package Datasheet
Author: M. Kumm

### Short Description
id\_info Displays a firmware ID, a version number and a configuration after reset with a few leds. After that, the normal LED meanig that is provided at the input is fed through to the output.


### Generics

| Name                   | Type    | Description                                                                                                                                                               |
|------------------------|---------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| clk\_freq\_in\_hz         | real    | The used clock frequency in Hz                                                                                                                                            |
| display\_time\_in\_ms     | real    | Time between switching the data display in ms                                                                                                                             |
| firmware\_id            | integer | ID of the firmware (is displayed first)                                                                                                                                   |
| firmware\_version       | integer | Version of the firmware (is displayed after)                                                                                                                              |
| firmware\_configuration | integer | When a configuration is used by means of different genercis but the same firmware and version, this field can be used to distinguish between them (is displayed at last). |
| led\_cnt                | integer | Number of LEDs                                                                                                                                                            |

### Ports

| Name  | Direction | Type                                  | Description                                                          |
|-------|-----------|---------------------------------------|----------------------------------------------------------------------|
| clk\_i | in        | std\_logic                             | clock                                                                |
| rst\_i | in        | std\_logic                             | reset                                                                |
| led\_i | in        | std\_logic\_vector (led\_cnt-1 downto 0) | LED status signals in normal operation (after 3x display\_time\_in\_ms) |
| led\_o | out       | std\_logic\_vector (led\_cnt-1 downto 0) | Connection to LED's                                                  |


### Hints
Example for FIB Board:
On the FIB board there are four front LEDs.

```
    -- leds
    led1 : out std\_logic;
    led2 : out std\_logic;
    led3 : out std\_logic;
    led4 : out std\_logic;

```


The nearest LED to board is LED1 and the farthest is LED4. So with a mapping like:

```
  --led signal mapping
  led4 <= led\_id\_inf\_o(3);
  led3 <= led\_id\_inf\_o(2);
  led2 <= led\_id\_inf\_o(1);
  led1 <= led\_id\_inf\_o(0);
```

you can use the signals easily.
28.09.2007/sh



