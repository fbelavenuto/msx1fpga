
CP = cp

DESIGN = wxedax
DEVICE_NAME = xc6slx9
DEVICE_PACKAGE = tqg144
DEVICE_SPEED = 2
UCF_FILE = ../../src/syn-wxedax/wxedax_pins.ucf

# Make all runs to place & route
all: pld
	$(CP) $(DESIGN).bit $(DESIGN).pld ../../_BINs

include ../makefile_xilinx.inc
