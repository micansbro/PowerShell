Function Get-KMSIPAddress {

<#
.SYNOPSIS
Gets the configured KMS IP address on a computer.

.DESCRIPTION
The function gets the IP address of the KMS server as listed in the registry.

.PARAMETER ComputerName
Specifies which Computer to get the KMS IP Address from.

.EXAMPLE
 Get-KMSIPAddress -Computername "Server01"

.EXAMPLE
"Server01", "Server02" | Get-KMSIPAddress
 
#>
    [CmdletBinding()]
    param(
        [Parameter(ValuefromPipeline=$True,
                   HelpMessage="Computer name or IP address")]
        [Alias('Hostname', 'Server')]
        [String[]]$Computername='localhost'
           
    )


    BEGIN { }
    PROCESS {
        Write-Verbose "Beginning PROCESS block"
        foreach ($Computer in $Computername) {
            Write-Verbose "Querying $Computer"
            $Reg=[Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine', $Computer)
            $RegKey=$Reg.OpenSubKey("SOFTWARE\Microsoft\Windows NT\CurrentVersion\SoftwareProtectionPlatform")
            $KMSIP=$RegKey.GetValue("KeyManagementServiceName")
          
            $Props=@{'ComputerName'=$Computer;
                     'KMS IP Address'=$KMSIP}
            Write-Verbose "Query complete"
            $Obj=New-Object -TypeName PSObject -Property $Props
            Write-Output $obj
            }
        }
    
    END {}

}