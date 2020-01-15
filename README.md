# FUB (FIB Universal Bus)

A collection of VHDL IP Cores for FPGAs and CPLDs developed by [@martin-kumm](https://github.com/martin-kumm) and me [@xaratustrah](https://github.com/xaratustrah) and also some of our then students (O. Bitterling, T. Guthier and T. Wollmann) in the time between 2006 and 2009.

## History

"FIB Universal Bus" or **FUB** was designed to define a standard for on chip communication between IP cores, originally designed to work with a specific FPGA platform called "FPGA Interface Board" **FIB** and its adapter board "FIB Application board" **FAB**. While the FIB board contained a powerful FPGA with many hardware interfaces, the FAB board, which was piggy-backed on top of the FIB board, contained a powerful analog to digital and digital to analog converter.

Here is a picture of the FIB board:

![FAB Board](https://raw.githubusercontent.com/xaratustrah/VHDL\_Library/master/fib.png)

Here is a picture of the FAB board in its Revision D, which was installed on top of the FIB board:

![FAB Board](https://raw.githubusercontent.com/xaratustrah/VHDL\_Library/master/fab_revd.jpg)

## Usage

The FUB standard is written in plane VHDL language with simplicity in mind so that all components are (hopefully) platform independent and can be used on variety of FPGA and CPLDs on the market.

## Structure

Every IP core is available as one or several VDHL files in the `VHDL` directory. These files may be be accompanied by simulation test benches and top level entities.

Additional platform specific project files are available for the older **Alterra Quartus** (meanwhile [Intel Quartus Prime](https://www.intel.com/content/www/us/en/software/programmable/quartus-prime/overview.html)) and simulation project file for [ModelSim](https://www.mentor.com/products/fpga/verification-simulation/modelsim/). The use of these platform and software specific project files are not mandatory, and IP cores can be used on other platforms such as [Xilinx ISE](https://www.xilinx.com/products/design-tools/ise-design-suite.html) or other vendors as well, maybe with a little bit of modification.


## Related Publications
In reverse chronological order:

* An FPGA-Based Linear All-Digital Phase-Locked Loop. Kumm, M., Klingbeil, H., Zipf, P. (2010).  IEEE Transactions on Circuits and Systems I: Regular Papers, 57(9), 2487–2497. <a target="_blank" href="http://doi.org/10.1109/TCSI.2010.2046237">LINK &#128279;</a>
* A High-Speed Data Converter for Digital Control of Synchrotron RF Cavities, M. S. Sanjari et. al. GSI Scientific Report GSI-ACCELERATORS-07 (2009). <a target="_blank" href="https://repository.gsi.de/record/53522">LINK &#128279;</a>
* Digital Hilbert transformers for FPGA-based phase-locked loops, M. Kumm and M. S. Sanjari, International Conference on Field Programmable Logic and Applications FPL 2008, Heidelberg, Germany. <a href="http://dx.doi.org/10.1109/FPL.2008.4629940"
target="_blank">LINK &#128279;</a>
* Realtime Communication Based on Optical Fibers for the Control of Digital RF Components, M. Kumm et. al. GSI Scientific Report GSI-ACCELERATORS-14 (2007). <a target="_blank"
href="https://repository.gsi.de/record/53524">LINK
&#128279;</a>
* FPGA-Realisierung eines Offset-Lokaloszillators basierend auf PLL- und DDS-Technologien, M. Kumm. Diplomarbeit an der Technischen Universität Darmstadt (2007) <a target="_blank" href="http://www.martin-kumm.de/Diplomarbeit_Martin_Kumm_TUD_2007.pdf">LINK &#128279;</a>
* Hardware and software implementation of a radio frequency high-speed data conversion unit for digital control systems, M. S. Sanjari, Bachelors' Thesis, Technische Universität
Darmstadt, Germany (2006).<a href="http://repository.gsi.de/record/200271" target="_blank">LINK &#128279;</a>
* Entwicklung eines ADC-DAC Bards für digitale Regelsysteme in einer DSP-Umgebung, J. Jöst, Dipolomarbeit Fachhochschule Bielefeld (2006).
* Entwurf und Implementierung eines echtzeitfähigen Network-on-Chip für den Einsatz in zeitkritischen Regelungsaufgaben, Ulrich Fischer, Diplomarbeit, Fachhochschule Fulda, 2005