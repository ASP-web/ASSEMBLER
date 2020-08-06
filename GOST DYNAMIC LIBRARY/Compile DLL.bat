echo
d:
cd d:\C++\AsmTesting\AsmTesting\GOST DYNAMIC LIBRARY\
c:\masm32\bin\ml.exe /c /coff /Cp gost_31_12_magma.asm
c:\masm32\bin\link.exe /dll /subsystem:windows /def:gost_31_12_magma.def /libpath:c:/masm32/bin gost_31_12_magma.obj
pause