Function Set-ESXiCoreDump {
<#
.SYNOPSIS
Set the ESXi host coredump information.

.DESCRIPTION
This function sets the Network Server IP address, port and local VMHost interface used for ESXi network coredump.

.PARAMETER NetworkServerIP
The IP address of the network server used to store the core dump file.

.PARAMETER NetworkServerPort
The TCP/IP port used to conect to the network server.

.PARAMETER HostVNic
The interface used by the VMhost to transmit the core dump file.

.EXAMPLE
 Set-ESXiCoreDump -NetworkServerIP '10.10.10.10' -NetworkServerPort '6500' -HostVNic 'vmk0'
 
#>

param(

    [string]$NetworkServerIP,

    [string]$NetworkServerPort='6500',

    [string]$HostVNic='vmk0'
)


Foreach ($vmhost in (get-vmhost))
{
$esxcli = Get-EsxCli -vmhost $vmhost
$esxcli.system.coredump.network.get()
}

Foreach ($vmhost in (get-vmhost))
{
$esxcli = Get-EsxCli -vmhost $vmhost
$esxcli.system.coredump.network.set($null, $CoreDumpInterface, $CoreDumpIP, $CoreDumpPort)
$esxcli.system.coredump.network.set($true)
}
}