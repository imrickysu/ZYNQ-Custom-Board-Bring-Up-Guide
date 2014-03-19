#ZYNQ Custom Board Bring Up Guide


This is a guide for bringing up custom ZYNQ boards. It covers test sequence, test method, common error situations and code and project that can help to investigate a bring-up problem.

This document is under development. Please feel free to fork and pull.

## Power

## JTAG

### Test JTAG via XMD
* Run `Xilinx Microprocessor Debugger` from Windows start menu -> Xilinx Design Suite -> Vivado -> SDK, or type `xmd` in Linux console after `source settings.sh`
* Run `connect arm hw` and check the output
    * If connect successful, it shows <place holder for connect success screenshot>
    * If unsuccessful, check JTAG cable connection, power sequence, power connection and clock connection
* Try to read and write OCM via XMD
    * `mrd 0x00001000`
    * `mwr 0x00001000 0x12345678`
    * `mrd 0x00001000`
* Try to program a bit file
    * How to prepare a bit file is not covered in this doc. Refer to CTT-ZYNQ.pdf for the process.
    * Run `fpga -f download.bit` to program the bit file

### Common Errors ###
* Only PL logic can be found in JTAG chain. ARM can not be found.
    * MIO_2 controls the selection of Cascaded JTAG and Independent JTAG. If Independent JTAG is selected, ARM cannot be seen in the JTAG chain.


### Known Issues ###
* If there are more than one ZYNQ in the JTAG chain, XMD cannot connect to the second ZYNQ if software version is prior to 2014.1



## UART

### Hello World in OCM
The default Hello World example application in SDK sets the running memory in DDR. If DDR has not been initialized properly, Hello World app won't be run successfully. The best way to test UART is to run the Hello World in OCM.

* Create a ZYNQ design in Vivado
    * Configure Reference Clock
    * Setup UART pin
    * Generate output products and export to SDK
* Create the Hello World app in OCM
    *  Create a workspace
    *  Create a BSP and import the Vivado exported XML
    *  Create a new application and select the Hello World template
    *  Right Click the Hello World app, select `Generate Linker Script`
    *  In Basic Tab, set all sections in `ps7_ram_0_S_AXI_BASEADDR` from the drop down menu
    *  Save and recompile the app
* Connect UART console in host PC
* Run the Hello World app by Right Click the app, select `Run As` -> `Launch on Hardware`
    * The "Hello World" should be printed
    * If it's not printed, it means something goes wrong. Try `Debug As` -> `Launch on Hardware (System Debugger)`. If the debugger can stop at main(), it means the function can be executed, clock and PLL are working, but UART is not configured properly or UART circuit on PCB board has some issues. 

## DDR Memory


## Flash
