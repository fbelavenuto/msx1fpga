@echo off
SET U=..\..\Utils\makeKmp.py
echo Making ABNT2
%U% ABNT2.txt PTBR.kmp
echo Making EN
%U% EN.txt EN.kmp
pause
