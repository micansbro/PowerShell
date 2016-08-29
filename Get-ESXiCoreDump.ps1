Function Get-ESXiCoreDump {
<#
.SYNOPSIS
Get the ESXi host coredump information.

.DESCRIPTION
This function retrives the Network Server IP address, port and local VMHost interface used for ESXi network coredump.

.PARAMETER ESXihost
The ESXi host of which to retieve the network coredump information.

.EXAMPLE
Get-ESXiCoreDump -ESXihost myserver.mydomain.net

.EXAMPLE
'myserver.mydomain.net','myserver1.mydomain.net' | Get-ESXiCoreDump
 
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory=$True,
               ValueFromPipeline=$True,
               HelpMessage='Name of ESXi host')]
    [string[]]$ESXihost

)

BEGIN {}

PROCESS {

    Foreach ($VMhost in $ESXihost)
        {
        $esxcli = Get-EsxCli -vmhost $VMhost
        $esxcli
        $esxcli.system.coredump.network.get()
        }
}

}