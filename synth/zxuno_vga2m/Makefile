
CP = cp

DESIGN = zxuno
DEVICE_NAME = xc6slx9
DEVICE_PACKAGE = tqg144
DEVICE_SPEED = 2
UCF_FILE = ../../src/syn-zxuno/zxuno_pins_vga2m.ucf

# Make all runs to place & route
all: pld
	$(CP) $(DESIGN).bit ../../_BINs/zxuno_vga.bit
	$(CP) $(DESIGN).pld ../../_BINs/COREX.ZX1_VGA

include ../makefile_xilinx.inc
