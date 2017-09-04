@echo off

set /p version="Enter VGA or HDMI: "

set fname_i=msx_multicore
set fname_o=msx_multicore_%version%

echo Generating Multicore Files
copy .\output_files\%fname_i%.sof ..\..\_BINs\%fname_o%.sof
c:\altera\13.0sp1\quartus\bin64\quartus_cpf -s EP4CE10 -d EPCS16 -c .\output_files\%fname_i%.sof ..\..\_BINs\%fname_o%.jic
c:\altera\13.0sp1\quartus\bin64\quartus_cpf -c .\output_files\%fname_i%.sof D:..\..\_BINs\%fname_o%.rbf
pause
