function Remove-GhostLUN {
<#
.SYNOPSIS
This function removes LUNs that were perenially reserved 
and then removed leaving a ghost LUN.
.DESCRIPTION
If a perenially reserved LUN has been removed from a VMHost 
before the reservation is turned off you will see an
empty LUN on the host's storage list.
The LUN will show as size 0 and have no vendor name.
.NOTES
Authors:  Michael Ansbro
.PARAMETER Server
One or more VM Host names
.EXAMPLE
Remove-GhostLUN
.EXAMPLE
Remove-GhostLUN -Server 'US-host01.domain.com'
.EXAMPLE
'us-host01','us-host02' | Remove-GhostLUN
#>
    [CmdletBinding()]
    param 
        (
            [parameter(ValueFromPipeline)]
            [string[]]$serverName='*'
        )

    BEGIN {
        $esxhosts=Get-VMhost $serverName
    }
    PROCESS {
        foreach ($esx in $esxhosts) {
            $esx.name
            $cli = get-esxcli -vmhost $esx


                $cliDisk = $cli.storage.core.device.list()
            $luns = $cliDisk | Where-Object DisplayName -eq "" 
            foreach ($disk in $luns){
                Write-Output $disk.ScsiCanonicalName, $disk.DisplayName, $disk.device, $disk.IsPerenniallyReserved
                $cli.storage.core.device.setconfig($false,$disk.device,$false)
            }
        }
  }
  END{}
}