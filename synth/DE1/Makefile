
CP = cp

###################################################################
# Project Configuration:
#
# Specify the name of the design (project), the Quartus II Settings
# File (.qsf), and the list of source files used.
###################################################################

PROJECT = msx_de1
#SOURCE_FILES = 

###################################################################
# Executable Configuration
###################################################################

MAP_ARGS = #--family="Cyclone II"
FIT_ARGS = #--part=EP2C20F484C7
ASM_ARGS =
STA_ARGS =
CPF_ARGS = -s EP2C20 -d EPCS4

all: bitstream
	$(CP) $(OUTPUT_FOLDER)/$(PROJECT).?of ../../_BINs
	$(CP) $(OUTPUT_FOLDER)/$(PROJECT).jic ../../_BINs
	$(CP) $(OUTPUT_FOLDER)/$(PROJECT).rbf ../../_BINs

include ../makefile_altera.inc
