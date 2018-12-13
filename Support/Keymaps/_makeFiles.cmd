@echo off
SET U=..\..\Utils\makeKmp.py
echo Making ABNT2
%U% ABNT2.txt PTBR.kmp
echo Making EN
%U% EN.txt EN.kmp
echo Making SPA
%U% SPA.txt SPA.kmp
echo Making FR
%U% FR.txt FR.kmp
echo Making JP
%U% JP.txt JP.kmp
pause
