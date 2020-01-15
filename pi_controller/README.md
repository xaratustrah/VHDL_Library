# pi_controller
## IP Core/Package Datasheet

Author: M. Kumm

### Short Description
pi_controller is a simple implementation of a digital PI-controller. The implementation is approximated by the rectangular law from the analouge transfer function

![](https://github.com/xaratustrah/VHDL_Library/blob/master/pi_controller/DOC/fs.png)

where Kp is proportional gain and KI is integral gain, with:

![](https://github.com/xaratustrah/VHDL_Library/blob/master/pi_controller/DOC/s.png)

where TS is sampling time resulting in

![](https://github.com/xaratustrah/VHDL_Library/blob/master/pi_controller/DOC/fz.png)


where:

* a1=1
* b0=-(KP+KI*TS)
* b1=KP

The implementation has two pipeline registers in the forward path and has a total additional delay of one sample, i.e. the resulting

![](https://github.com/xaratustrah/VHDL_Library/blob/master/pi_controller/DOC/fzprime.png)

### Generics

| Name       | Type    | Description                  |
|------------|---------|------------------------------|
| data_width | integer | Wordsize of input and output |
| b0         | integer | Parameter b0 as integer      |
| b1         | integer | Parameter b1 as integer      |


### Ports

| Name   | Direction | Type                                     | Description |
|--------|-----------|------------------------------------------|-------------|
| clk_i  | in        | std_logic                                | clock       |
| rst_i  | in        | std_logic                                | reset       |
| data_i | in        | std_logic_vector (data_width-1 downto 0) | input       |
| data_o | out       | std_logic_vector (data_width-1 downto 0) | output      |


### Quartus Project
The quartus project (together with file pi_controller_performance_estimation.vhd) is for determine the space/timing requirements only.

### Testbench
The testbench determines the impulse response of the PI controller.

### Space and Timing Requirements
Space and timing requirements for a cyclone I -6 FPGA (FIB) for different wordsizes are given in the following table and figure. The required fmax setting was set to 200MHz.

| Generic data_width | LE Usage | max. clock frequency |
|--------------------|----------|----------------------|
| 10                 | 160      | 187 MHz              |
| 12                 | 216      | 177 MHz              |
| 14                 | 280      | 178 MHz              |
| 16                 | 352      | 178 MHz              |
| 32                 | 1216     | 157 MHz              |

Following figure shows No. of LE vs. the used wordsize:

![](https://github.com/xaratustrah/VHDL_Library/blob/master/pi_controller/DOC/wordsize.png)
