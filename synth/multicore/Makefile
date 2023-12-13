
PROJECT = msx_multicore
all:
	quartus_map $(PROJECT)
	quartus_fit $(PROJECT)
	quartus_asm $(PROJECT)
	quartus_sta $(PROJECT)
	quartus_cpf -c .\output_files\msx_multicore.sof -s EP4CE10 -d EPCS16 ..\..\_BINs\msx_multicore_.jic
	quartus_cpf -c .\output_files\msx_multicore.sof ..\..\_BINs\msx_multicore_.rbf

clean:
	rm -rf db incremental_db output_files simulation *.qws *.txt
