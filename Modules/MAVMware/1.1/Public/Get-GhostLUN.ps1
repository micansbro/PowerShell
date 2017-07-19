function Get-GhostLUN {
<#
.SYNOPSIS
This function retrives LUNs that were perenially reserved 
and then removed leaving a ghost LUN.
.DESCRIPTION
If a perenially reserved LUN has been removed from a VMHost 
before the reservation is turned off you will see an
empty LUN on the host's storage list.
The LUN will show as size 0 and have no vendor name.
.NOTES
Author:  Michael Ansbro
Version: 1.1
.PARAMETER Server
One or more VM Host names
.EXAMPLE
Get-GhostLUN
.EXAMPLE
Get-GhostLUN -Server 'US-host01.domain.com'
#>
    [CmdletBinding()]
    param (
            [Parameter( ValueFromPipeline=$True,
                        HelpMessage='Name of ESXi host')]
        [string[]]$Server='*'
    )
    BEGIN {
        $esxhosts = Get-VMhost $Server
    }

    PROCESS {
        foreach ($esx in $esxhosts) {
            $disks = @()
            $cli = get-esxcli -vmhost $esx
            $luns = $cli.storage.core.device.list() | Where-Object {$_.DisplayName -eq ""}
              
            ForEach ($disk in $luns){
                
                $device = $disk.device
                $vmhost = $esx.name
                $size = $disk.size
                $reserved = $disk.IsPerenniallyReserved

                $obj = New-object System.Object
                $obj | Add-member -type NoteProperty -Name 'Device ID' -Value $device
                $obj | Add-member -type NoteProperty -Name 'VMHost' -Value $vmhost
                $obj | Add-member -type NoteProperty -Name 'Disk Size' -Value $size
                $obj | Add-member -type NoteProperty -Name 'Perennially Reserved' -Value $reserved
                $disks += $obj

                Write-Output $disks
            }
        }
  }
  END{}
}