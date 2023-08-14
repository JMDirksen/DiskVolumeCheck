@echo off
if not exist SMTPConfig.ps1 copy SMTPConfig.template.ps1 SMTPConfig.ps1
notepad.exe SMTPConfig.ps1
echo Creating task with 15 minute interval...
schtasks /create /tn "DiskVolumeCheck" /tr "powershell.exe -f %~dp0DiskVolumeCheck.ps1" /sc minute /mo 15 /st 00:00
echo Creating monthly task with the -SendEmail parameter...
schtasks /create /tn "DiskVolumeCheck-SendEmail" /tr "powershell.exe -f %~dp0DiskVolumeCheck.ps1 -SendEmail" /sc monthly /mo 1 /st 00:00
powershell.exe -f DiskVolumeCheck.ps1
echo.
echo If all runs well you should be able to change the task 'DiskVolumeCheck[-SendEmail]' to 'Run whether user is logged on or not' with 'Do not store password...' on to make it run in the background.
echo.
pause
