# parallel\_to\_fub
## IP Core/Package Datasheet

### Short Description
parallel\_to\_fub is a FUB sender that transmit the content of parallel data words that are connected to the input port (par\_data\_i). The target FUB addresses for the different data words can be specified with a seperate input address vector (par\_adr\_i). This address can be different for each data word. The used address width can be specified with the generic adr\_width, the size of the parallel data input vector in bytes can be specified by no\_of\_data\_bytes. The parallel data word is transmitted via FUB when par\_str\_i is high for at least one clock cycle, during the transmittion, the strobe signal is ignored.

### Generics

| Name             | Type    | Description                                     |
|------------------|---------|-------------------------------------------------|
| no\_of\_data\_bytes | integer | Size of the parallel data input vector in bytes |
| adr\_width        | integer | Wordsize of the output fub address              |


### Ports

| Name       | Direction | Type                                                     | Description                         |
|------------|-----------|----------------------------------------------------------|-------------------------------------|
| clk\_i      | in        | std\_logic                                                | clock                               |
| rst\_i      | in        | std\_logic                                                | reset                               |
| par\_data\_i | in        | std\_logic\_vector (no\_of\_data\_bytes*8-1 downto 0)         | Parallel data input vector          |
| par\_adr\_i  | in        | std\_logic\_vector (no\_of\_data\_bytes*adr\_width-1 downto 0) | Parallel target adress input vector |
| par\_str\_i  | in        | std\_logic                                                | Strobe for parallel data            |
| par\_busy\_o | out       | std\_logic                                                | Busy for parallel data              |
| fub\_data\_o | out       | std\_logic\_vector(7 downto 0)                             | FUB interface                       |
| fub\_adr\_o  | out       | std\_logic\_vector (adr\_width-1 downto 0)                  | FUB interface                       |
| fub\_str\_o  | out       | std\_logic                                                | FUB interface                       |
| fub\_busy\_i | in        | std\_logic                                                | FUB interface                       |



### Testbench
In the testbench, a 10 byte data vector is sent via FUB all the time.

### Hints
For an easier usage, an array of std\_logic\_vector can be defined for the data and address vectors:  

```
  type par\_data\_array\_type is array(0 to no\_of\_data\_bytes-1) of
  std\_logic\_vector(7 downto 0);
  signal par\_data\_array : par\_data\_array\_type;

  signal par\_data : std\_logic\_vector(no\_of\_data\_bytes*8-1 downto 0);

  type par\_adr\_array\_type is array(0 to no\_of\_data\_bytes-1) of
  std\_logic\_vector(adr\_width-1 downto 0);
  signal par\_adr\_array : par\_adr\_array\_type;

  signal par\_adr : std\_logic\_vector(no\_of\_data\_bytes*adr\_width-1 downto 0);
```

The arrays can then be mapped to the vectors using the generate statement:

```
  array\_to\_parallel\_gen: for i in 0 to no\_of\_data\_bytes-1 generate
    par\_data((i+1)*8-1 downto i*8) <= par\_data\_array(i);
    par\_adr((i+1)*adr\_width-1 downto i*adr\_width) <= par\_adr\_array(i);
  end generate;
```


