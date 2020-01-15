# pi\_controller
## IP Core/Package Datasheet

Author: M. Kumm

### Short Description
pi\_controller is a simple implementation of a digital PI-controller. The implementation is approximated by the rectangular law from the analouge transfer function

![](https://github.com/xaratustrah/VHDL\_Library/blob/master/pi\_controller/DOC/fs.png)

where Kp is proportional gain and KI is integral gain, with:

![](https://github.com/xaratustrah/VHDL\_Library/blob/master/pi\_controller/DOC/s.png)

where TS is sampling time resulting in

![](https://github.com/xaratustrah/VHDL\_Library/blob/master/pi\_controller/DOC/fz.png)


where:

* a1=1
* b0=-(KP+KI*TS)
* b1=KP

The implementation has two pipeline registers in the forward path and has a total additional delay of one sample, i.e. the resulting

![](https://github.com/xaratustrah/VHDL\_Library/blob/master/pi\_controller/DOC/fzprime.png)

### Generics

| Name       | Type    | Description                  |
|------------|---------|------------------------------|
| data\_width | integer | Wordsize of input and output |
| b0         | integer | Parameter b0 as integer      |
| b1         | integer | Parameter b1 as integer      |


### Ports

| Name   | Direction | Type                                     | Description |
|--------|-----------|------------------------------------------|-------------|
| clk\_i  | in        | std\_logic                                | clock       |
| rst\_i  | in        | std\_logic                                | reset       |
| data\_i | in        | std\_logic\_vector (data\_width-1 downto 0) | input       |
| data\_o | out       | std\_logic\_vector (data\_width-1 downto 0) | output      |


### Quartus Project
The quartus project (together with file pi\_controller\_performance\_estimation.vhd) is for determine the space/timing requirements only.

### Testbench
The testbench determines the impulse response of the PI controller.

### Space and Timing Requirements
Space and timing requirements for a cyclone I -6 FPGA (FIB) for different wordsizes are given in the following table and figure. The required fmax setting was set to 200MHz.

| Generic data\_width | LE Usage | max. clock frequency |
|--------------------|----------|----------------------|
| 10                 | 160      | 187 MHz              |
| 12                 | 216      | 177 MHz              |
| 14                 | 280      | 178 MHz              |
| 16                 | 352      | 178 MHz              |
| 32                 | 1216     | 157 MHz              |

Following figure shows No. of LE vs. the used wordsize:

![](https://github.com/xaratustrah/VHDL\_Library/blob/master/pi\_controller/DOC/wordsize.png)
