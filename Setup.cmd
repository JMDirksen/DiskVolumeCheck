@echo off
schtasks /create /tn "DiskVolumeCheck" /tr "powershell.exe -f %~dp0DiskVolumeCheck.ps1" /sc minute /mo 15 /st 00:00
echo.
pause
