function Get-GhostLUNs {
<#
.SYNOPSIS
This function retrives LUNs that were perenially reserved 
and then removed leaving a ghost LUN.
.DESCRIPTION
If a perenially reserved LUN has been removed from a VMHost 
before the reservation is turned off you will see an
empty LUN on the host's storage list.
The LUN will show as size 0 and have no vendor name.
.PARAMETER Server
One or more VM Host names
.EXAMPLE
Get-GhostLUNs
.EXAMPLE
Get-GhostLUNS -Server 'US-host01.domain.com'
#>
    [CmdletBinding()]
    param (
        [string[]]$Server='*'
    )
    BEGIN {
        $esxhosts=Get-VMhost $Server
    }
    PROCESS {
        foreach ($esx in $esxhosts) {
            $esx.name
            $cli = get-esxcli -vmhost $esx


                $cliDisk = $cli.storage.core.device.list()
            $luns = $cliDisk | where DisplayName -eq "" 
            foreach ($disk in $luns){
                Write-Host $disk.ScsiCanonicalName, $disk.DisplayName, $disk.device, $disk.IsPerenniallyReserved
            }
        }
  }
  END{}
}