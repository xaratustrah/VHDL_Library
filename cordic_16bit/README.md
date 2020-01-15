# cordic\_16bit
## IP Core/Package Datasheet

### Short Description
CORDIC implementation from Andre Guntoro (TU-Darmstadt), please refer to ref [1].


### Generics

| Name       | Type    | Description                                                                                          |
|------------|---------|------------------------------------------------------------------------------------------------------|
| data\_width | natural | Must be set to 16, for another data width, the LUT constants (LUT-Array) has to be calculated again. |


### Ports

| Name        | Direction | Type                                     | Description                                                                |
|-------------|-----------|------------------------------------------|----------------------------------------------------------------------------|
| clk\_i       | in        | std\_logic                                | clock                                                                      |
| rst\_i       | in        | std\_logic                                | reset                                                                      |
| i\_i         | in        | std\_logic\_vector (data\_width-1 downto 0) | in-phase component                                                         |
| q\_i         | in        | std\_logic\_vector (data\_width-1 downto 0) | quadratur-phase component                                                  |
| magnitude\_o | out       | std\_logic\_vector (data\_width-1 downto 0) | magnitude out, has to be multiplied with 0.607253 to get the exact result. |
| phase\_o     | out       | std\_logic\_vector (data\_width-1 downto 0) | phase out, 215..215-1 corresponds to -pi..+pi                                |

### Quartus project

The quartus project is for determine the space/timing requirements only.

### Testbench

cordic\_16bit\_tb.vhd calculates values of some specific vectors.


### Hints

A valid result is available after data\_width+2 cycles.



### Literature

[1] Statusbericht zum GSI-Projekt ”Rekonfigurierbare Rechensysteme für digitale  Hochfrequenzregelungen bei Schwerionenbeschleunigern”, Extending the Phase Detector module: Magnitude and Phase Information; Andre Guntoro; 21. Juli 2006

