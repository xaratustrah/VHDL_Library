# fub\_registerfile\_cntrl
## IP Core/Package Datasheet
Author: M. Kumm


### Short Description

The fub\_registerfile\_cntrl component was implemented for handling the parameter registers or the RAM content of several applications. It has two FUB interfaces for reading and writing directly to the register file/RAM (cfg\_reg\_in/cfg\_reg\_out), two FUB interfaces for an optional flash device for non-volatile storing the content of the register file/RAM and one RAM interface which is compatible to the Altera altsyncram Megacore. A registerfile that also uses this RAM interface is implemented in "registerfile\_ram\_interface\_pkg". The following table shows the registers of the fub\_registerfile\_cntrl component itself. The commands read block, write flash and read flash are configured by a start- and end address which must be programmed before or can be set by the generics “default\_start\_adr” and “default\_end\_adr”. After a hardware reset the register will read out the flash memory in the range of the default address parameters. The FUB\_OUT interface sends a fub package when ever the register file is changed. The generics reg\_adr\_firmware\_id, reg\_adr\_firmware\_version and reg\_adr\_firmware\_conf should be connected to the same signals like component id\_info.


| Default Address | Register                 | Description                                               |
|-----------------|--------------------------|-----------------------------------------------------------|
| FFF0            | REG\_ADR\_CMD              | 1=read single, 2=read block,  4=write flash, 8=read flash |
| FFF1            | REG\_ADR\_START\_ADR\_HIGH   | High byte start address                                   |
| FFF2            | REG\_ADR\_START\_ADR\_LOW    | Low byte start address                                    |
| FFF3            | REG\_ADR\_END\_ADR\_HIGH     | High byte end address                                     |
| FFF4            | REG\_ADR\_END\_ADR\_LOW      | Low byte end address                                      |
| FFF5            | REG\_ADR\_FIRMWARE\_ID      | Firmware id (read only)                                   |
| FFF6            | REG\_ADR\_FIRMWARE\_VERSION | Firmware version (read only)                              |
| FFF7            | REG\_ADR\_FIRMWARE\_CONFIG  | Firmware configuration (read only)                        |
| FFF8-FFFF       | reserved                 | reserved for future applications                          |

### Generics

| Name                     | Type    | Description                                                                        |
|--------------------------|---------|------------------------------------------------------------------------------------|
| clk\_freq\_in\_hz           | real    | The used clock frequency in Hz                                                     |
| adr\_width                | integer | Address width of all FUB interfaces                                                |
| data\_width               | integer | Data width of FUB, should be allways 8 Bit.                                        |
| reg\_adr\_cmd              | integer | Address of the CMD register (default FFF0h­)                                       |
| reg\_adr\_start\_adr\_high   | integer | Address of the high byte of the start address register (default FFF1h­)            |
| reg\_adr\_start\_adr\_low    | integer | Address of the low byte of the start address register (default FFF2h­)             |
| reg\_adr\_end\_adr\_high     | integer | Address of the high byte of the end address register (default FFF3h­)              |
| reg\_adr\_end\_adr\_low      | integer | Address of the low byte of the end address register (default FFF4h­)               |
| reg\_adr\_firmware\_id      | integer | Address of the firmware id (default FFF5h­)                                        |
| reg\_adr\_firmware\_version | integer | Address of the firmware version (default FFF6h­)                                   |
| reg\_adr\_firmware\_config  | integer | Address of the firmware configuration (default FFF7h­)                             |
| mask\_adr                 | integer | This address will be ignored when flash is read out (typically the reset register) |
| firmware\_id              | integer | The actual firmware id                                                             |
| firmware\_version         | integer | The actual firmware version                                                        |
| firmware\_config          | integer | The actual firmware configuration                                                  |
| default\_start\_adr        | integer | Default 16 BIT START ADR                                                           |
| default\_end\_adr          | integer | Default 16 BIT END ADR                                                             |

### Ports


| Name                   | Direction | Type                                     | Description                              |
|------------------------|-----------|------------------------------------------|------------------------------------------|
| clk\_i                  | in        | std\_logic                                | clock                                    |
| rst\_i                  | in        | std\_logic                                | reset                                    |
| fub\_cfg\_reg\_in\_dat\_i   | in        | std\_logic\_vector (data\_width-1 downto 0) | Config in FUB port                       |
| fub\_cfg\_reg\_in\_adr\_i   | in        | std\_logic\_vector (adr\_width-1downto 0)   | Config in FUB port                       |
| fub\_cfg\_reg\_in\_str\_i   | in        | std\_logic                                | Config in FUB port                       |
| fub\_cfg\_reg\_in\_busy\_o  | out       | std\_logic                                | Config in FUB port                       |
| fub\_cfg\_reg\_out\_str\_o  | out       | std\_logic                                | Config out FUB port                      |
| fub\_cfg\_reg\_out\_dat\_o  | out       | std\_logic\_vector (data\_width-1downto 0)  | Config out FUB port                      |
| fub\_cfg\_reg\_out\_adr\_o  | out       | std\_logic\_vector (adr\_width-1downto 0)   | Config out FUB port                      |
| fub\_cfg\_reg\_out\_busy\_i | in        | std\_logic                                | Config out FUB port                      |
| fub\_fr\_busy\_i          | in        | std\_logic                                | FUB to flash component (read)            |
| fub\_fr\_dat\_i           | in        | std\_logic\_vector (data\_width-1downto 0)  | FUB to flash component (read)            |
| fub\_fr\_str\_o           | out       | std\_logic                                | FUB to flash component (read)            |
| fub\_fr\_adr\_o           | out       | std\_logic\_vector (adr\_width-1downto 0)   | FUB to flash component (read)            |
| fub\_fw\_str\_o           | out       | std\_logic                                | FUB to flash component (write)           |
| fub\_fw\_busy\_i          | in        | std\_logic                                | FUB to flash component (write)           |
| fub\_fw\_dat\_o           | out       | std\_logic\_vector (data\_width-1downto 0)  | FUB to flash component (write)           |
| fub\_fw\_adr\_o           | out       | std\_logic\_vector (adr\_width-1downto 0)   | FUB to flash component (write)           |
| ram\_wren\_o             | out       | std\_logic                                | RAM interface (compatible to altsyncram) |
| ram\_adr\_o              | out       | std\_logic\_vector (adr\_width-1downto 0)   | RAM interface (compatible to altsyncram) |
| ram\_dat\_o              | out       | std\_logic\_vector (data\_width-1downto 0)  | RAM interface (compatible to altsyncram) |
| ram\_q\_i                | in        | std\_logic\_vector (data\_width-1downto 0)  | RAM interface (compatible to altsyncram) |
| fub\_out\_str\_o          | out       | std\_logic                                | FUB Master Output                        |
| fub\_out\_data\_o         | out       | std\_logic\_vector (data\_width-1downto 0)  | FUB Master Output                        |
| fub\_out\_adr\_o          | out       | std\_logic\_vector (adr\_width-1downto 0)   | FUB Master Output                        |
| fub\_out\_busy\_i         | in        | std\_logic                                | FUB Master Output                        |


### Functions
None.

### Dependencies to other IPCores

Maybe registerfile\_ram\_interface\_pkg could be usefull for some applications.

### Quartus Project
FIB Testproject in which the registerfile can be programmed via RS232. Register address 0000 is directly mapped to the piggy io interface (LED board).

### Testbench
A configuration stream is sendt via RS-232 to fib\_top of the quartus project, writing and reading the registerfile.

### Hints
This is a logic element optimized version of the original registerfile\_cntrl which uses instead of a RAM interface two FUB interfaces.
When using rs232\_rx, always synchronize the input signal! Otherwise it will hang up after some transmittions.
If the FUB\_OUT interface is not as fast as the flash and the reg\_cfg\_in interface, a fifo is needed to make sure that no pakage gets lost.


