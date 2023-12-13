
PROJECT = msx_de2
all:
	quartus_map $(PROJECT)
	quartus_fit $(PROJECT)
	quartus_asm $(PROJECT)
	quartus_sta $(PROJECT)

clean:
	rm -rf db incremental_db output_files simulation *.qws *.txt
