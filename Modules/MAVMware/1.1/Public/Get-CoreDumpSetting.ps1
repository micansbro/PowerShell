Function Get-CoreDumpSetting {
<#
.SYNOPSIS
Retrives an ESXi host's network coredump settings.
.DESCRIPTION
This function retrives the IP address, port and 
local VMHost interface used for ESXi network coredump.
.NOTES
Authors:  Michael Ansbro
.PARAMETER Server
One or more VM Host names.
.EXAMPLE
Get-CoreDumpSetting -Server myserver.mydomain.net
.EXAMPLE
'server01','server02' | Get-CoreDumpSetting
#>
    [CmdletBinding()]
    param(
        [Parameter( ValueFromPipeline=$True,
                    HelpMessage='Name of ESXi host')]
        [string[]]$Server='*'
    )

    BEGIN {
        $esxhosts=Get-VMhost $Server
    }

    PROCESS {
        Foreach ($esx in $esxhosts)
            {
            $esxcli = Get-EsxCli -vmhost $esx
            $var10 = $esxcli.system.coredump.network.get()
            $var20 = $esxcli.system.hostname.get()
            
            $Props = @{ 'Hostname'=$var20.hostname
                        'Enabled'=$var10.Enabled;
                        'HostVNic'=$var10.HostVNic;
                        'NetworkServerIP'=$var10.NetworkServerIP;
                        'NetworkServerPort'=$var10.NetworkServerPort
                    }
            $Obj=New-object -Typename psobject -Property $Props
            Write-output $Obj
            }
    }
    END {}
}