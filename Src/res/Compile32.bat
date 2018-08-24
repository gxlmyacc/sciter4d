#..\..\Bin\tiscript.exe -o "masterscript.tis" -c "src\masterscript_src.tis"

del /f /q ..\MyRes32.res

Brcc32 ..\MyRes32.rc 
Brcc32 ..\version.rc 