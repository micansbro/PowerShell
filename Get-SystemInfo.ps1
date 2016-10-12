function Get-SystemInfo {
<#
.SYNOPSIS
Retrieves key system version and model information
from one to ten computers.
.DESCRIPTION
Get-SystemInfo uses Windows Management Instrumentation
(WMI) to retrieve information from one or more computers.
Specify computers by name or by IP address.
.PARAMETER ComputerName
One or more computer names or IP addresses, up to a maximum
of 10.
.PARAMETER LogErrors
Specify this switch to create a text log file of computers
that could not be queried.
.PARAMETER ErrorLog
When used with -LogErrors, specifies the file path and name
to which failed computer names will be written. Defaults to
C:\Retry.txt.
.EXAMPLE
 Get-Content names.txt | Get-SystemInfo
.EXAMPLE
 Get-SystemInfo -ComputerName SERVER1,SERVER2
#>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$True,
                   ValueFromPipeline=$True,
                   HelpMessage="Computer name or IP address")]
        [ValidateCount(1,10)]
        [Alias('hostname')]
        [string[]]$ComputerName,

        [string]$ErrorLog = 'c:\users\mansbro\desktop\retry.txt',

        [switch]$LogErrors
    )
    BEGIN {
        Write-Verbose "Error log will be $ErrorLog"
    }
    PROCESS {
        Write-Verbose "Beginning PROCESS block"
        foreach ($computer in $computername) {
            Write-Verbose "Querying $computer"
            Try {
            $Everything_ok=$True
            $os = Get-WmiObject -class Win32_OperatingSystem -computerName $computer -ErrorAction Stop
            
            } Catch {
                $Everything_ok=$False
                Write-Warning "$Computer failed"
                if ($LogErrors) {
                    $computer | out-file $ErrorLog -Append
                    Write-Warning "Logged to $ErrorLog"
                }
            }
            If ($Everything_ok) {
            $comp = Get-WmiObject -class Win32_ComputerSystem -computerName $computer
            $bios = Get-WmiObject -class Win32_BIOS -computerName $computer
            $props = @{'ComputerName'=$computer;
                       'OSVersion'=$os.version;
                       'OSArchitecture'=$OS.OSArchitecture;
                       'SPVersion'=$os.servicepackmajorversion;
                       'Manufacturer'=$comp.manufacturer;
                       'Model'=$comp.model}
            Write-Verbose "WMI queries complete"
            $obj = New-Object -TypeName PSObject -Property $props
            $obj.PSObject.TypeNames.Insert(0,'MOL.SystemInfo')
            Write-Output $obj
            }
        }
    }
    END {}
}

Get-SystemInfo -ComputerName localhost