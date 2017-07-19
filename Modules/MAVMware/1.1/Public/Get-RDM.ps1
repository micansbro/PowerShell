
# Parameter help description
[Parameter]
[string]$Cluster

Get-cluster $Cluster | Get-VM | get-Harddisk -disktype "RawPhysical","RawVirtual" | Select-Object -Unique