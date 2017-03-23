set ISEPATH=C:\Xilinx\14.7\ISE_DS\ISE\bin\nt64
set MACHINE=zxuno_top
set UCFVERSION=v3
set SPEED=2

call %ISEPATH%\xst      -intstyle ise -ifn %MACHINE%.xst -ofn %MACHINE%.syr
call %ISEPATH%\ngdbuild -intstyle ise -dd _ngo -sd ipcore_dir -nt timestamp -uc ..\..\src\syn-zxuno\zxuno_pins_%UCFVERSION%.ucf -p xc6slx9-tqg144-%SPEED% %MACHINE%.ngc %MACHINE%.ngd
call %ISEPATH%\map      -intstyle ise -w -ol high -mt 2 -p xc6slx9-tqg144-%SPEED% -logic_opt off -t 1 -xt 0 -register_duplication off -r 4 -global_opt off -ir off -pr off -lc off -power off -o %MACHINE%_map.ncd %MACHINE%.ngd %MACHINE%.pcf
call %ISEPATH%\par      -intstyle ise -w -ol high -mt 4 %MACHINE%_map.ncd %MACHINE%.ncd %MACHINE%.pcf
call %ISEPATH%\trce     -intstyle ise -v 3 -s %SPEED% -n 3 -fastpaths -xml %MACHINE%.twx %MACHINE%.ncd -o %MACHINE%.twr %MACHINE%.pcf
call %ISEPATH%\bitgen   -intstyle ise -f %MACHINE%.ut %MACHINE%.ncd

pause