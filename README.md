# DiskVolumeCheck

Check the health status of disks and volumes

## Output example

```
PS C:\DiskVolumeCheck> DiskVolumeCheck.ps1

Number          : 0
Model           : WDC WD30EFRX-68EUZN0
SerialNumber    : WD-XXXXXXXXXXXX
FirmwareVersion : 82.00A82
Size (GB)       : 2795
HealthStatus    : Healthy

Number          : 1
Model           : WDC WD30EFRX-68AX9N0
SerialNumber    : WD-XXXXXXXXXXXX
FirmwareVersion : 80.00A80
Size (GB)       : 2795
HealthStatus    : Healthy

Number          : 2
Model           : Samsung SSD 980 1TB
SerialNumber    : 0025_XXXX_XXXX_XXXX.
FirmwareVersion : 3B4QFXO7
Size (GB)       : 932
HealthStatus    : Healthy

DriveLetter     : C
FileSystemLabel : OS
FileSystem      : NTFS
Size (GB)       : 931
HealthStatus    : Healthy

DriveLetter     : D
FileSystemLabel : Data
FileSystem      : NTFS
Size (GB)       : 2495
HealthStatus    : Healthy
```
