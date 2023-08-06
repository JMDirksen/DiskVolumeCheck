# Set workdir
Split-Path $MyInvocation.MyCommand.Path -Parent | Set-Location

# Set variables
$HealthStatus = "Healthy", "Warning", "Unhealthy"

# Read disks
$disks = Get-WmiObject -Namespace root\Microsoft\Windows\Storage -Class MSFT_Disk | Where-Object {$_.PartitionStyle -and -not $_.IsOffline} | Sort-Object -Property Number
$disks | Select-Object Number, Model, @{Name="SerialNumber";Expression={$_.SerialNumber.Trim()}}, FirmwareVersion, @{Name="Size (GB)";Expression={[math]::Round($_.Size / 1GB)}}, @{Name="HealthStatus";Expression={$HealthStatus[$_.HealthStatus]}}

# Read volumes
$volumes = Get-WmiObject -Namespace root\Microsoft\Windows\Storage -Class MSFT_Volume | Where-Object {$_.DriveLetter} | Sort-Object -Property DriveLetter
$volumes | Select-Object DriveLetter, FileSystemLabel, FileSystem, @{Name="Size (GB)";Expression={[math]::Round($_.Size / 1GB)}}, @{Name="HealthStatus";Expression={$HealthStatus[$_.HealthStatus]}}

# Check for errors (HealthStatus not zero)
$errors = ""
$disks | % {
    if($_.HealthStatus) {
        $errors += "Disk $($_.Number) has status: $($HealthStatus[$_.HealthStatus])`n"
    }
}
$volumes | % {
    if($_.HealthStatus) {
        $errors += "Volume $($_.DriveLetter): has status: $($HealthStatus[$_.HealthStatus])`n"
    }
}

# Load SMTP config
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
    Send-MailMessage -From $EmailFrom -Subject "DiskVolumeCheck failure" -To $EmailTo -Body $errors -Credential $SMTPCredentials -Port $SMTPPort -SmtpServer $SMTPServer -UseSsl
}
