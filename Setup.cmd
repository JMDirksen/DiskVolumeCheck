@echo off
schtasks /create /tn "DiskVolumeCheck" /tr "powershell.exe -f %~dp0DiskVolumeCheck.ps1" /ru system /sc minute /mo 15 /st 00:00
echo.
echo.
if %ERRORLEVEL%==1 echo Make sure to run this setup with elevated permissions (Run as administrator).
pause
