#ZYNQ Custom Board Bring Up Guide


This is a guide for bringing up custom ZYNQ boards. It covers test sequence, test method, common error situations and code and project that can help to investigate a bring-up problem.

Note: This guide assumes developers are famaliar with Vivado and SDK. For more info about Vivado/SDK tutorials, please refer to [UG940](http://www.xilinx.com/support/documentation/sw_manuals/xilinx2013_4/ug940-vivado-tutorial-embedded-design.pdf).

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

### Setting Up DDR3 
ZYNQ Memory Controller supports training and write leveling for DDR3. For most DDR3 memory components which obey the routing rules, setting up DDR3 is as easy as to input the DDR3 part number and enabling all three DRAM trainings in DDR Configuration.

### Setting Up DDR2
Since DDR2 training is not supported by ZYNQ, DDR2 board delay details needs to be input into DDR Configuration manually.

* Input DDR2 component part number
* Select `Training/Board Details` from `User Input` to `Calculated`
* Input trace length in mm in Board Delay Calculation Table, the DQS to CLK delay and Board delay will be calculated automatically.
    * If the DDR component only uses one clock, input CLK1, CLK2 and CLK3 length same as CLK0

### Test DDR
#### Memory Tests Example Application
The simple memory test application can be created from `File` -> `New` -> `Application Project` -> `Next` -> `Memory Tests`. By default, it can test first 4096 bytes of every memory region including DDR, OCM and AXI BRAM. If the test fails, it will not provide more information about error rate and error patterns but only print a fail on the screen.

#### ZYNQ DRAM Test
The ZYNQ DRAM Test example acts interactively. User needs to type commands in the UART terminal to choose the test function. It's an easy job to run memory test with various sizes. The test result will also show how many errors are encountered and what's the expacted data, what's the real data and what are the wrong bits. This application can be created from `File` -> `New` -> `Application Project` -> `Next` -> `ZYNQ DRAM Test`.



## Flash
- Check Flash interface Read/Write ability
- Program Flash from SDK/u-boot
- Boot from Flash
  - Understand ZYNQ Boot from Flash flow
  - Prepare bootloader for debugging booting from Flash
  - Debug considerations

### Programming Flash from SDK
SDK Program Flash Tool supports to program QSPI, NAND and NOR Flash directly. By simply selecting the MCS/Bin file and click Program button, we can test the Flash peripheral circuit. If `Verify after flash` is selected, the programming program will read and compare the data after program completes. If it report "verification success", we can say the Flash is working properly. For how to generate the program image, please refer to [Prepare Flash Image](#prepare-flash-image)


### Programming Flash from example designs
In <SDK_installation_directory>/sw/ directory, each driver version has a subdirectory. In these directories, there's a `example` subdirectory. All flash controllers have example designs to program the flash, read back and verify. Create new empty applicaitons in SDK and add the related files into the app, then we can know whether ZYNQ is able to write any words into the Flash.

* Prepare the u-boot image with the instructions in [Xilinx Wiki u-boot page](http://www.wiki.xilinx.com/Build+U-Boot#Zynq)
* Open XMD, connect ARM, initialize ZYNQ, then download u-boot to DDR and run
```tcl
# The tcl to initialize ZYNQ and run u-boot
# "xmd -tcl xx.tcl" to run it when larunching XMD
# or run "source xx.tcl" inside XMD
source ps7_init.tcl
ps7_init
dow u-boot.elf
run
```


### Programming Flash from u-boot
In the days that SDK programming tools were not ready, u-boot is the best Flash programming tool. The preparation of u-boot image may be a little bit complicated, but it's worth doing it. U-boot still can do some jobs that SDK can't, such as erase the entire Flash chip.


### Prepare Flash Image
The MCS/Bin ROM file can be prepared by `Xilinx Tools` -> `Prepare ZYNQ Boot Image`. For details about the tool, please refer to its [help](http://www.xilinx.com/support/documentation/sw_manuals/xilinx2013_4/SDK_Doc/tasks/sdk_t_create_zynq_boot_image.htm)

To check whether ZYNQ has been boot successfully, the easist way is to see some characters being printed from UART.
* Create a Hello World app and run it via JTAG to make sure UART works fine. Make an image of FSBL + Hello World. Program it into Flash. Set boot mode to Flash. After power up, if "Hello World" is printed, the Flash boot is successful.
* Recompile the FSBL with `DEBUG_FSBL` defined in gcc compiler settings. FSBL will then print more details of the stages its running and error messages if it encounters any.


### Boot From Flash Debug Considerations
- Check whether BootROM code finished correctly by analyze `INIT_B` status. In Non-Secure mode, if `INIT_B` goes high after power on, BootROM has executed successfully.
- If the `FSBL_DEBUG_INFO` enabled FSBL is not able to print any data from UART, try to connect JTAG and use XMD to read register `BOOTROM_ERROR_CODE` at 0xF8000258.
- If FSBL is able to print some error info but not making senses, use SDK to debug FSBL.


## Ethernet
Ethernet can be connected in various ways for ZYNQ: RGMII though MIO to PHY, GMII/MII though EMIO to FPGA pin to PHY, GMII to SGMII or 1000BASE-X though EMIO to FPGA SERDES to external with or without PHY. 

### Example code
The emacps driver's example code is the simplest standalone test application. Create a new empty application and add the code to it.

The code has some preset #defines for 10M/100M/1000M speed configuration. Modify these #defines to accomondate the real hardware design.

In case the appliation reports some errors when running, try to turn off the DCache of the CPU and run again. The gem uses DMA to transfer data, it's easy to encounter errors when Cache are not set properly. Turning off caches is the simpliest way to get rid of these kind of problems. Of course the real design will need cache, add proper cache fluch and invalidate functions carefully after verified the app works fine because it means the hardware is good.

### U-boot
U-boot has the ability to send ping packages and fetch boot images via TFTP. So u-boot is also a good test application. The preparation flow is the same as above.

Note that u-boot network funcitons are based on polling rather than interrupt. It doesn't support responding ping packages. It can only send out ping packages (ARP and ICMP).


## Run u-boot

## Run Linux
