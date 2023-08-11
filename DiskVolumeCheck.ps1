$errors = 0

# Check physical disks
$PDs = Get-PhysicalDisk | Select-Object -Property *, @{Name="Type";Expression={"PhysicalDisk"}}

# Check storage pools
$SPs = Get-StoragePool -IsPrimordial $False | Select-Object -Property *, @{Name="Type";Expression={"StoragePool"}}

# Check virtual disks
$VDs = Get-VirtualDisk | Select-Object -Property *, @{Name="Type";Expression={"VirtualDisk"}}

# Check volumes
$Vs = Get-Volume | Where-Object { $_.FileSystemLabel -or $_.DriveLetter } | Select-Object -Property *, @{Name="Type";Expression={"Volume"}}, @{Name="FriendlyName";Expression={$_.FileSystemLabel+" ("+$_.DriveLetter+":)"}}

# Check for errors
$combined = $PDs + $SPs + $VDs + $Vs
$errors = ($combined | Where-Object { $_.HealthStatus -ne "Healthy" -or $_.OperationalStatus -ne "OK" }).Length

# Generate/show output
$html = $combined | ConvertTo-Html -Property Type, FriendlyName, HealthStatus, OperationalStatus | Out-String
$combined | ft -Property Type, FriendlyName, HealthStatus, OperationalStatus

# Load SMTP config
Split-Path $MyInvocation.MyCommand.Path -Parent | Set-Location   # Set workdir
$configFile = ".\SMTPConfig.ps1"
if (Test-Path $configFile) { . $configFile }
else {
	Write-Host "`nConfig file SMTPConfig.ps1 not found, please copy and modify SMTPConfig.ps1.template for sending failure e-mails" -ForegroundColor Yellow
	exit
}

# Check/generate/test secure SMTP password
if(-not(Test-Path 'password.txt')) {
    Read-Host -AsSecureString -Prompt "Enter SMTP password for user $SMTPUser" | ConvertFrom-SecureString | Set-Content 'password.txt'
    $SMTPCredentials = New-Object System.Management.Automation.PSCredential -ArgumentList $SMTPUser, $(Get-Content 'password.txt' | ConvertTo-SecureString)
    try {
        Send-MailMessage -From $EmailFrom -Subject "DiskVolumeCheck test e-mail" -To $EmailTo -Body "This is a test" -Credential $SMTPCredentials -Port $SMTPPort -SmtpServer $SMTPServer -UseSsl -ErrorAction Stop
    }
    catch {
        Remove-Item 'password.txt'
        Write-Host "`nSending test e-mail failed! (not storing password)`n" -ForegroundColor Red
        Write-Host $Error[0].Exception -ForegroundColor Red
    }
}
else {
    $SMTPCredentials = New-Object System.Management.Automation.PSCredential -ArgumentList $SMTPUser, $(Get-Content 'password.txt' | ConvertTo-SecureString)
}

# Send mail on errors
if($errors) {
    $subject = "DiskVolumeCheck $errors error"
    if($errors -gt 1) { $subject += "s" }
    Send-MailMessage -From $EmailFrom -Subject $subject -To $EmailTo -Body $html -Credential $SMTPCredentials -Port $SMTPPort -SmtpServer $SMTPServer -UseSsl -BodyAsHtml
}
