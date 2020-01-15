# fub\_modulbus
## IP Core Datasheet

### Short Description
This is a wrapper component for the Modul Bus component written by BELAB. This wrapper should allow the user to bind the signals using the standard FUB interface. This wrapper also remains unchanged even if new versions of the Modul Bus component are delivered.

### Generics

| Name           | Type                          | Description                    |
|----------------|-------------------------------|--------------------------------|
| clk\_freq\_in\_hz | integer                       | The used clock frequency in Hz |
| mb\_id          | integer                       | ID No of the Modul Bus         |
| mb\_version     | std\_logic\_vector (7 downto 0) | Version No. of the Modul Bus   |
| fub\_addr\_width | integer                       | FUB address bus width          |
| fub\_data\_width | integer                       | FUB data bus width             |

### Ports

| Name                 | Direction | Type                                         | Description                                                                                       |
|----------------------|-----------|----------------------------------------------|---------------------------------------------------------------------------------------------------|
| rst\_i                | in        | std\_logic                                    | Reset Signal                                                                                      |
| clk\_i                | in        | std\_logic                                    | Clock input signal                                                                                |
| fub\_str\_o            | out       | std\_logic                                    | FUB Strobe                                                                                        |
| fub\_busy\_i           | in        | std\_logic                                    | FUB Busy                                                                                          |
| fub\_addr\_o           | out       | std\_logic\_vector (fub\_addr\_width-1 downto 0) | FUB address output                                                                                |
| fub\_data\_o           | out       | std\_logic\_vector (fub\_data\_width-1 downto 0) | FUB data output                                                                                   |
| mb\_RdnWr             | in        | std\_logic                                    | Modul bus read not write signal                                                                   |
| mb\_nDs               | in        | std\_logic                                    | Modul  bus data strobe signal                                                                     |
| mb\_nReset            | in        | std\_logic                                    | Modul bus reset signal                                                                            |
| mb\_Mod\_Adr           | in        | std\_logic\_vector (4 downto 0)                | Address of the currently running modul bus cycle                                                  |
| mb\_Mod\_Data          | inout     | std\_logic\_vector (7 downto 0)                | Modul Bus data bus                                                                                |
| mb\_Sub\_Adr           | in        | std\_logic\_vector (7 downto 0)                | Sub address of the currently running modul bus cycle                                              |
| mb\_Vmod\_Adr          | in        | std\_logic\_vector(4 downto 0)                 | Address of the Modul Bus slot in the backplane                                                    |
| mb\_Vmod\_ID           | in        | std\_logic\_vector(7 downto 0)                 | Type of the doughter card expected in this slot (the slot specified by the mb\_Vmod\_Adr parameter) |
| mb\_Vmod\_SK           | in        | std\_logic\_vector (7 downto 0)                | Modul bus scaling, different for each card type.                                                  |
| mb\_n\_Ext\_Data\_Bus\_EN | out       | std\_logic                                    | If low, the external data drivers of the Modul Bus are on.                                        |
| mb\_nDtAck            | out       | std\_logic                                    | All external modul bus actions must be applied here.                                              |
| mb\_nInterlock        | out       | std\_logic                                    | ?                                                                                                 |
| mb\_nID\_OK\_LED        | out       | std\_logic                                    | Modul bus ID OK LED                                                                               |
| mb\_nDt\_LED           | out       | std\_logic                                    | Modul bus data transfer indicator                                                                 |
| mb\_nSel\_LED          | out       | std\_logic                                    | Modul bus select LED                                                                              |