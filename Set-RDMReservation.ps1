function Set-RDMReservation {
<#
.SYNOPSIS
Set RDMs to perennially reserved.
.DESCRIPTION
Set any RDMs to perennially reserved for the hosts within the supplied cluster.
.PARAMETER ClusterName
The name of the cluster where the RDMs are in use.
.EXAMPLE
Set-RDMReservation -ClusterName 'ServerCluster01' 
#>

 [cmdletbinding()]
 Param(

    [Parameter(Mandatory=$True)]
    [ValidateNotNullorEmpty()]
    [String]$ClusterName
    )
 
BEGIN {
    $ClusterInfo=Get-Cluster $ClusterName
    $VMHosts=Get-VMhost -Location $ClusterInfo
    $RDMDisk=$ClusterInfo | Get-VM | Get-HardDisk -DiskType "RawPhysical","RawVirtual" | Select -ExpandProperty ScsiCanonicalName -Unique
}

PROCESS{
    foreach ($esx in $vmHosts) {
        $myesxcli = Get-EsxCli -VMHost $esx
            
            foreach ($naa in $RDMDisk) {
                $diskinfo = $myesxcli.storage.core.device.list("$naa") | Select -ExpandProperty IsPerenniallyReserved
                $esx + " " + $naa + " " + "IsPerenniallyReserved= " + $diskinfo
                if($diskinfo -eq "false")
                {
                Write-host "Configuring Perennial Reservation for LUN $naa"
                $myesxcli.storage.core.device.setconfig($false,$naa,$true)
                $diskinfo = $myesxcli.storage.core.device.list("$naa") | Select -ExpandProperty IsPerenniallyReserved
                $esx + " " + $naa + " " + "IsPerenniallyReserved= " + $diskinfo
                }
            }
    }
}      

END{} 
 
 }