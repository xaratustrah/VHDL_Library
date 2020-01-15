# busdriver
## IP Core/Package Datasheet

### Current Status

Deprecated, please use inout\_driver02 instead

## Short Description

The busdriver  component represents a driver for handling inout data type. The bus width is fixed to 16-bit.

## Generics

None

## Ports

| Name              | Direction | Type             | Description               |
|-------------------|-----------|------------------|---------------------------|
| en\_write\_to\_bus\_i | in        | std\_logic        | Enable signal             |
| data\_bus\_io       | inout     | std\_logic\_vector | IO Bus connection         |
| data\_to\_bus\_i     | in        | std\_logic\_vector | Data written into the bus |
| data\_from\_bus\_o   | out       | std\_logic\_vector | Data read from the bus    |

