@echo off
sjasmplus UARTTST.ASM
if ERRORLEVEL 1 goto erro
copy UARTTST.BIN F:\

goto ok

:erro
echo OCORREU UM ERRO

:ok
pause
