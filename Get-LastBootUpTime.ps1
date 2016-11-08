function Get-LastBootUpTime {
<#
.SYNOPSIS
Get a computer's last boot up time
.DESCRIPTION
This function gets the last boot up time from a computer 
by using the win32_operatingsystem class in WMI and displays 
the data in a readable format.
.PARAMETER ComputerName
One or more computernames up to a maximum of 10
.EXAMPLE
'Server01' , 'Server02' | Get-LastBootUpTime
.EXAMPLE
Get-LastBootUpTime -Computername 'Server01','Server02'
.NOTES 
Author: Michael Ansbro
 
 
#>
    [CmdletBinding()]
    param(
            [Parameter(ValueFromPipeline=$True)]
            [ValidateCount(1,10)]
            [Alias('hostname')] 
            [String[]]$Computername = 'localhost'
    )
    BEGIN {
        
    }
    PROCESS {
        foreach ($Computer in $Computername) {
            Get-WmiObject win32_operatingsystem -ComputerName $Computer |
            Select-Object csname, @{LABEL=’LastBootUpTime’;EXPRESSION={$_.ConverttoDateTime($_.lastbootuptime)}}

        }
    }
    END {}
}

