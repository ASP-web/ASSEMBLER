echo
d:
cd d:\C++\AsmTesting\AsmTesting\GOST 34.12 MAGMA\
c:\masm32\bin\ml.exe /c /coff /Cp gost_31_12_magma.asm
c:\masm32\bin\link.exe /lib /subsystem:windows /libpath:c:/masm32/bin gost_31_12_magma.obj
pause