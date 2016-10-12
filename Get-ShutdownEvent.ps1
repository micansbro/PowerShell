function Get-ShutdownEvent {
<#
.SYNOPSIS
Retrievs the Windows events which show the last shutdown.
.DESCRIPTION
Retrievs the Windows events which show the last shutdown.
.PARAMETER Computername
Specifys which computer to get the Windows events from.
.EXAMPLE
 Get-ShutdownEvent -Computername ADServer01
 
#>
    [CmdletBinding()]
    param(
    [Parameter(ValuefromPipeline=$True,
               HelpMessage="Computer name or IP address" )]
    [Alias('Hostname', 'Server')]
    [String]$Computername='localhost'
    )
    
    BEGIN {}

    PROCESS {
        Get-WinEvent -FilterHashtable @{ Logname='System'; ID='1074'} -ComputerName $Computername
    }
    END {}
}