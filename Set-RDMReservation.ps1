function Set-RDMReservation {
<#
.SYNOPSIS
Set RDMs to perennially reserved.
.DESCRIPTION
Set RDMs to perennially reserved for the hosts of the cluster in which the VMs reside.
.PARAMETER vCenter
The hostname name of the vCenter 

.PARAMETER Datacenter
The name of the datacenter where the cluster resides

.PARAMETER Cluster Name
The name of the cluster where the RDMs are in use

.EXAMPLE
 Set-RDMReservation -vCenter server.domain.com -Datacenter 
 
#>

 [cmdletbinding()]

 Param(
    [Parameter(Mandatory=$True)]
    [ValidateNotNullorEmpty()]
    [String]$vcenter,

    [Parameter(Mandatory=$True)]
    [ValidateNotNullorEmpty()]
    [String]$cluster
    )
 
# Check for and if needed add VMware PSSnapin
IF ((Get-PSSnapin VMware.VimAutomation.Core -ErrorAction SilentlyContinue) -eq $null)
{
    Add-PSSnapin VMware.VimAutomation.Core
    Write-host "VMware Snapin loaded"
}

 
$connected = Connect-VIServer -Server $vcenter | Out-Null
 
$clusterInfo = get-cluster $cluster
$vmHosts = $clusterInfo | get-vmhost | select -ExpandProperty Name
$RDMDisk = $clusterInfo | Get-VM | Get-HardDisk -DiskType "RawPhysical","RawVirtual" | Select -ExpandProperty ScsiCanonicalName -Unique
 
foreach ($vmhost in $vmHosts) {
$myesxcli = Get-EsxCli -VMHost $vmhost
 
    foreach ($naa in $RDMDisk) {
 
    $diskinfo = $myesxcli.storage.core.device.list("$naa") | Select -ExpandProperty IsPerenniallyReserved
    $vmhost + " " + $naa + " " + "IsPerenniallyReserved= " + $diskinfo
    if($diskinfo -eq "false")
    {
    write-host "Configuring Perennial Reservation for LUN $naa"
    $myesxcli.storage.core.device.setconfig($false,$naa,$true)
    $diskinfo = $myesxcli.storage.core.device.list("$naa") | Select -ExpandProperty IsPerenniallyReserved
    $vmhost + " " + $naa + " " + "IsPerenniallyReserved= " + $diskinfo
    }
}
}
 
Disconnect-VIServer $vcenter -confirm:$false | Out-Null
 }

 Set-RDMReservation -vcenter byfvcenter01 -cluster NonSPLA_Prod_Cluster