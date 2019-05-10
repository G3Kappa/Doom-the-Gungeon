@echo off
:loop
SET /p ID="Enter ID: "
WST.exe extract SFX.bnk %ID%
WST.exe decode %ID%.wem %ID%.wav
del %ID%.wem
goto loop