###################################################################
# Project Configuration:
#
# Specify the name of the design (project), the Quartus II Settings
# File (.qsf), and the list of source files used.
###################################################################

ASSIGNMENT_FILES = $(PROJECT).qpf $(PROJECT).qsf
OUTPUT_FOLDER = output_files

###################################################################
# Main Targets
#
# all: build everything
# clean: remove output files and database
###################################################################

.PHONY: bitstream
bitstream: smart.log asm sta jic rbf

$(OUTPUT_FOLDER):
	mkdir -p $(OUTPUT_FOLDER)

#clean:
#	rm -rf *.rpt *.chg smart.log *.htm *.eqn *.pin *.sof *.pof db
clean:
	rm -rf db incremental_db $(OUTPUT_FOLDER) simulation *.qws \
		*.chg smart.log *.rbf *.jic

map: smart.log $(OUTPUT_FOLDER)/$(PROJECT).map.rpt
fit: smart.log $(OUTPUT_FOLDER)/$(PROJECT).fit.rpt
asm: smart.log $(OUTPUT_FOLDER)/$(PROJECT).asm.rpt
sta: smart.log $(OUTPUT_FOLDER)/$(PROJECT).sta.rpt
jic: smart.log $(OUTPUT_FOLDER)/$(PROJECT).jic
rbf: smart.log $(OUTPUT_FOLDER)/$(PROJECT).rbf
smart: smart.log

###################################################################
# Target implementations
###################################################################

STAMP = echo done >

$(OUTPUT_FOLDER)/$(PROJECT).map.rpt: map.chg $(SOURCE_FILES)
	quartus_map $(MAP_ARGS) $(PROJECT)
	$(STAMP) fit.chg

$(OUTPUT_FOLDER)/$(PROJECT).fit.rpt: fit.chg $(OUTPUT_FOLDER)/$(PROJECT).map.rpt
	quartus_fit $(FIT_ARGS) $(PROJECT)
	$(STAMP) asm.chg
	$(STAMP) sta.chg

$(OUTPUT_FOLDER)/$(PROJECT).asm.rpt: asm.chg $(OUTPUT_FOLDER)/$(PROJECT).fit.rpt
	quartus_asm $(ASM_ARGS) $(PROJECT)

$(OUTPUT_FOLDER)/$(PROJECT).sta.rpt: sta.chg $(OUTPUT_FOLDER)/$(PROJECT).fit.rpt
	quartus_sta $(STA_ARGS) $(PROJECT)

smart.log: $(ASSIGNMENT_FILES)
	quartus_sh --determine_smart_action $(PROJECT) > smart.log

$(OUTPUT_FOLDER)/$(PROJECT).jic: jic.chg $(OUTPUT_FOLDER)/$(PROJECT).sta.rpt
	quartus_cpf -c $(OUTPUT_FOLDER)/$(PROJECT).sof $(CPF_ARGS) $@

$(OUTPUT_FOLDER)/$(PROJECT).rbf: rbf.chg $(OUTPUT_FOLDER)/$(PROJECT).sta.rpt
	quartus_cpf -c $(OUTPUT_FOLDER)/$(PROJECT).sof $@


###################################################################
# Project initialization
###################################################################

$(ASSIGNMENT_FILES):
	quartus_sh --prepare $(PROJECT)

%.chg:
	$(STAMP) $@
