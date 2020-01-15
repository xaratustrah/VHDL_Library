# real\_time\_calculator
## IP Core/Package Datasheet

Author: M. Kumm

### Short Description
Gets delay in clock ticks from a desired value in ns using a defined system clock frequency.


### Functions

| Name                     | Description                                                                                                                                                                                                               |
|--------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| get\_delay\_in\_ticks\_ceil  | Always returns the next upper integer value. The resulting value multiplied by system clock period is always larger than or equal to the desired delay in ns. Use this function when minimum delays should be guaranteed. |
| get\_delay\_in\_ticks\_floor | Always returns the next lower integer value. The resulting value multiplied by system clock period is always less than or equal to the desired delay in ns.                                                               |
| get\_delay\_in\_ticks\_round | Always returns the nearest integer value. The resulting value multiplied by system clock period is always the nearest to the desired delay in ns. Use this function when the most exact delay is necessary.               |
| limit\_to\_minimal\_value   | Returns the period as type time from a given frequency as real. Useful for clock generation in testbenches e.g. clk <= not clk after 0.5 * freq\_real\_to\_period\_time(clk\_freq\_in\_hz);                                      |


### Hints
"RTCalc\_example.vhd" shows some examples how to use the functions.


