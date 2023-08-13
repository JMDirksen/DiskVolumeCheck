$checks = @()
$errors = 0

# Check physical disks
$checks += Get-PhysicalDisk | Select-Object -Property *, @{Name="Type";Expression={"PhysicalDisk"}}

# Check storage pools
$checks += Get-StoragePool -IsPrimordial $False -ErrorAction SilentlyContinue | Select-Object -Property *, @{Name="Type";Expression={"StoragePool"}}

# Check virtual disks
$checks += Get-VirtualDisk | Select-Object -Property *, @{Name="Type";Expression={"VirtualDisk"}}

# Check volumes
$checks += Get-Volume | Where-Object { $_.FileSystemLabel -or $_.DriveLetter } | `
    Select-Object -Property *, @{Name="Type";Expression={"Volume"}}, @{Name="FriendlyName";Expression={$_.FileSystemLabel+" ("+$_.DriveLetter+":)"}}

# Check for errors
$errors = ($checks | Where-Object { $_.HealthStatus -ne "Healthy" -or $_.OperationalStatus -ne "OK" }).Length

# Generate/show output
$html = $checks | ConvertTo-Html -Property Type, FriendlyName, HealthStatus, OperationalStatus | Out-String
$checks | Format-Table -Property Type, FriendlyName, HealthStatus, OperationalStatus

# Load SMTP config
$configFile = Join-Path (Split-Path $MyInvocation.MyCommand.Path) "SMTPConfig.ps1"
if (Test-Path $configFile) { . $configFile }
else {
	Write-Host "Config file SMTPConfig.ps1 not found" -ForegroundColor Yellow
    Write-Host "Please copy, rename and modify SMTPConfig.template.ps1 for sending failure e-mails" -ForegroundColor Yellow
	Exit
}

# Load/request SMTP credentials
$credFile = Join-Path (Split-Path $MyInvocation.MyCommand.Path) "credentials.xml"
if(Test-Path $credFile) { $SMTPCredentials = Import-Clixml $credFile }
else {
    $user = Read-Host "Username for $($SendMailmessageParams.SMTPServer)"
    $pass = Read-Host "Password" -AsSecureString
    $SMTPCredentials = New-Object System.Management.Automation.PSCredential ($user, $pass)
    try {
        $subject = "DiskVolumeCheck test e-mail"
        Send-MailMessage -Subject $subject -Body $html -BodyAsHtml @SendMailMessageParams -Credential $SMTPCredentials -ErrorAction Stop
    }
    catch {
        Write-Host "Sending test e-mail failed!" -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Red
        Exit
    }
    $SMTPCredentials | Export-Clixml $credFile
}

# Send mail on errors
if($errors) {
    $subject = "DiskVolumeCheck $errors error"
    if($errors -gt 1) { $subject += "s" }
    Send-MailMessage -Subject $subject -Body $html -BodyAsHtml @SendMailMessageParams -Credential $SMTPCredentials
}
