
CP = cp

###################################################################
# Project Configuration:
#
# Specify the name of the design (project), the Quartus II Settings
# File (.qsf), and the list of source files used.
###################################################################

PROJECT = msx_multicore2
#SOURCE_FILES = 

###################################################################
# Executable Configuration
###################################################################

MAP_ARGS = #--family="Cyclone IV E"
FIT_ARGS = #--part=EP4CE22F17C8
ASM_ARGS =
STA_ARGS =
CPF_ARGS = -s EP4CE22 -d EPCS16

all: bitstream
	$(CP) $(OUTPUT_FOLDER)/$(PROJECT).?of ../../_BINs
	$(CP) $(OUTPUT_FOLDER)/$(PROJECT).jic ../../_BINs
	$(CP) $(OUTPUT_FOLDER)/$(PROJECT).rbf ../../_BINs

include ../makefile_altera.inc
