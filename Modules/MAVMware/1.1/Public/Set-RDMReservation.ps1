function Set-RDMReservation {
[CmdletBinding(SupportsShouldProcess=$true)]
<#
.SYNOPSIS
Set RDMs to perennially reserved.
.DESCRIPTION
The cmdlet set any RDMs to perennially reserved for the hosts within the supplied cluster. RDMs used by
Microsoft Cluster Service cause VM Hosts to take a long time to boot up unless the RDM lun is
perennially reserved. 
.NOTES
Authors:  Michael Ansbro
Date: 16/03/2017
Version: 1.1
.PARAMETER ClusterName
The name of the cluster where the RDMs are in use.
.EXAMPLE
Set-RDMReservation -ClusterName 'ServerCluster01' 
#>

 Param(

    [Parameter(Mandatory=$True)]
    [ValidateNotNullorEmpty()]
    [String]$ClusterName
    )
 

    $ClusterInfo = Get-Cluster $ClusterName
    $VMHosts = Get-VMhost -Location $ClusterInfo
    $RDMDisk = $ClusterInfo | Get-VM | Get-HardDisk -DiskType "RawPhysical","RawVirtual" | Select-Object -ExpandProperty ScsiCanonicalName -Unique



    foreach ($esxiSever in $vmHosts) {
        $myesxcli = Get-EsxCli -VMHost $esxiSever
            
            foreach ($naa in $RDMDisk) {
                
                $diskinfo = $myesxcli.storage.core.device.list("$naa") | Select-Object -ExpandProperty IsPerenniallyReserved
                
                if($diskinfo -eq "false")
                {
                    Write-Output "Configuring Perennial Reservation for LUN $naa"
                    if($PSCmdlet.ShouldProcess("$naa 'on' $esxiSever")){$myesxcli.storage.core.device.setconfig($false,$naa,$true)}
                    
                }
                else 
                {
                    Write-output "$naa is already reserved on $esxiSever "
                }
 
           }
    
    }      

}