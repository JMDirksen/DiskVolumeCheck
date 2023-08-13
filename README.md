# DiskVolumeCheck

Check the health status of physical disks, storage pools, virtual disks and volumes  
Send an e-mail on errors (not Healthy/OK)

## Output example

```
PS C:\DiskVolumeCheck> .\DiskVolumeCheck.ps1

Type         FriendlyName HealthStatus OperationalStatus
----         ------------ ------------ -----------------
PhysicalDisk CT1000P3SSD8 Healthy      OK
StoragePool  Pool 1       Healthy      OK
VirtualDisk  VDisk 1      Healthy      OK
Volume       OS (C:)      Healthy      OK
```
