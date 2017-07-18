<#
.SYNOPSIS
Function to write messages to either the console or a log file.
.DESCRIPTION
This cmdlet is used to write messages to the console or a log (text) file.
The messages can be given a level from INFO to DEBUG and they include and time and date stamp.

.EXAMPLE
 Write-log -Message "$Service has been succesfully started" -Level DEBUG
.EXAMPLE
Write-Log -Level FATAL -Message "The command was unable to process." -Logfile $logFilePath
.NOTES
Author - 
Date - 
Version - 
#>

Function Write-Log {
    [CmdletBinding()]
    Param(
    [Parameter(Mandatory=$False)]
    [ValidateSet("INFO","WARN","ERROR","FATAL","DEBUG")]
    [String]
    $Level = "INFO",

    [Parameter(Mandatory=$True)]
    [string]
    $Message,

    [Parameter(Mandatory=$False)]
    [string]
    $logfile
    )

    $Stamp = (Get-Date).toString("yyyy/MM/dd HH:mm:ss")
    $Line = "$Stamp $Level $Message"
    If($logfile) {
        Add-Content $logfile -Value $Line
    }
    Else {
        Write-Output $Line
    }
}