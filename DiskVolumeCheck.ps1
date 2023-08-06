$HealthStatus = "Healthy", "Warning", "Unhealthy"

$disks = Get-WmiObject -Namespace root\Microsoft\Windows\Storage -Class MSFT_Disk | Where-Object {$_.PartitionStyle -and -not $_.IsOffline}
$disks | Sort-Object -Property Number | Select-Object Number, Model, @{Name="SerialNumber";Expression={$_.SerialNumber.Trim()}}, FirmwareVersion, @{Name="Size (GB)";Expression={[math]::Round($_.Size / 1GB)}}, @{Name="HealthStatus";Expression={$HealthStatus[$_.HealthStatus]}}

$volumes = Get-WmiObject -Namespace root\Microsoft\Windows\Storage -Class MSFT_Volume | Where-Object {$_.DriveLetter}
$volumes | Sort-Object -Property DriveLetter | Select-Object DriveLetter, FileSystemLabel, FileSystem, @{Name="Size (GB)";Expression={[math]::Round($_.Size / 1GB)}}, @{Name="HealthStatus";Expression={$HealthStatus[$_.HealthStatus]}}
