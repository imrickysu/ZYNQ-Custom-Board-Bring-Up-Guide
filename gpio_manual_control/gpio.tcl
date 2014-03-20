# This tcl file set MIO PIN 10 to output status.
# Use set_mio_high and set_mio_low functions to pull up and low the MIO PIN 10.
# If other pins are connected to LED, modify the address accordingly.
# ps7_init.tcl is not a pre-requirement for this tcl.



mwr 0xf8000728 0x1200 ;# set MIO_PIN_10. 
#0x1200 means  TRI_ENABLE = 0, L0_SEL = 0, L1_SEL = 0 and L3_SEL = 0
mwr 0xe000a204 0x400 ;#set bit 10 to 1 in DIRM_0register
mwr 0xe000a208 0x400 ;#set bit 10 to 1 in OEN_0 register

proc set_mio_high {} {
	mwr 0xe000a040 0xFFFFFFFF;
}

proc set_mio_low {} {
	mwr 0xe000a040 0x0;
}