#..\..\Bin\tiscript.exe -o "masterscript.tis" -c "src\masterscript_src.tis"

del /f /q ..\MyRes64.res

Brcc32 ..\MyRes64.rc
Brcc32 ..\version.rc