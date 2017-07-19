Function Set-CoreDumpSetting {
<#
.SYNOPSIS
Set the ESXi host coredump information.
.DESCRIPTION
This function sets the Network Server IP address, port and local 
VMHost interface used for ESXi network coredump.
.NOTES
Authors:  Michael Ansbro
.PARAMETER NetworkServerIP
The IP address of the network server used to store the core dump file.
.PARAMETER NetworkServerPort
The TCP/IP port used to conect to the network server.
.PARAMETER HostVNic
The interface used by the VMhost to transmit the core dump file.
.EXAMPLE
 Set-CoreDumpSetting -NetworkServerIP '10.10.10.10' -NetworkServerPort '6500' -HostVNic 'vmk0'
#>
[CmdletBinding()]
param(
    [Parameter(ValueFromPipeline=$True)]
    [string]$Server='*',

    [Parameter(Mandatory=$True,
               ValueFromPipeline=$True)]
    [string]$NetworkServerIP,

    [string]$NetworkServerPort='6500',

    [string]$HostVNic='vmk0'
)
BEGIN {
    $esxhosts=Get-VMHost $server
}

PROCESS {
    Foreach ($esx in $esxHosts)
        {
        $esxcli = Get-EsxCli -vmhost $vmhost
        $esxcli.system.coredump.network.set($null, $HostVNic, $NetworkServerIP, $NetworkServerPort)
        $esxcli.system.coredump.network.set($true)
        }
}
END{}
}