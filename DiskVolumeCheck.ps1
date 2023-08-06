$HealthStatus = "Healthy", "Warning", "Unhealthy"

$disks = Get-WmiObject -Namespace root\Microsoft\Windows\Storage -Class MSFT_Disk | Where-Object {$_.PartitionStyle -and -not $_.IsOffline} | Sort-Object -Property Number
$disks | Select-Object Number, Model, @{Name="SerialNumber";Expression={$_.SerialNumber.Trim()}}, FirmwareVersion, @{Name="Size (GB)";Expression={[math]::Round($_.Size / 1GB)}}, @{Name="HealthStatus";Expression={$HealthStatus[$_.HealthStatus]}}

$volumes = Get-WmiObject -Namespace root\Microsoft\Windows\Storage -Class MSFT_Volume | Where-Object {$_.DriveLetter} | Sort-Object -Property DriveLetter
$volumes | Select-Object DriveLetter, FileSystemLabel, FileSystem, @{Name="Size (GB)";Expression={[math]::Round($_.Size / 1GB)}}, @{Name="HealthStatus";Expression={$HealthStatus[$_.HealthStatus]}}

$disks | % {
    if($_.HealthStatus) { Start-Process "cmd" "/c msg * Disk $($_.Number) has status: $($HealthStatus[$_.HealthStatus])" -WindowStyle Hidden }
}
$volumes | % {
    if($_.HealthStatus) { Start-Process "cmd" "/c msg * Volume $($_.DriveLetter): has status: $($HealthStatus[$_.HealthStatus])" -WindowStyle Hidden }
}
