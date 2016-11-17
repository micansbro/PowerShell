<#
.SYNOPSIS
Gets all local and network installed printers.
.DESCRIPTION
This function uses WMI to get all local and 
network installed printers.
.PARAMETER Computername
One or more computer hostnames
.EXAMPLE
Get-Printer -ComputerName 'Server01', 'Sever02'
.EXAMPLE
'Server01', 'Sever02' | Get-Printer
.NOTES
Author: Michael Ansbro
#>
function Get-Printer {

[Cmdletbinding()]
param (
    [Parameter(ValueFromPipeline=$True)]
    [String[]]$Computername = $env:COMPUTERNAME
)

PROCESS {
foreach ($Comp in $ComputerName) {
    $Printers = Get-WmiObject -Computername $Comp -Class win32_printer -ErrorAction SilentlyContinue
        Foreach ($Printer in $Printers){
            $Obj = New-object -TypeName PSCustomObject -Property @{
                Hostname = $Comp;
                PrinterName = $Printer.name;
                PrinterStatus = $Printer.PrinterStatus;
                ShareName = $Printer.ShareName
            }
            Write-Output $Obj
         }
        
    }
}
}
 