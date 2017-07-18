<#
.SYNOPSIS
Get all local user accounts.
.DESCRIPTION
The cmdlet obtains all local user accounts from the system on which it is run unless the computername parameter is used.
.EXAMPLE
Get-LocalUserAccount
.EXAMPLE
Get-LocalUserAccount -ComputerName 'server01' -Username 'User01'
.NOTES
Author - Michael Ansbro
Date - 01/02/2017
Version - 1.0
#>

Function Get-LocalUserAccount{
[CmdletBinding()]
param (
 
 [parameter(ValueFromPipeline=$true,
   ValueFromPipelineByPropertyName=$true)]
 [string[]]$ComputerName=$env:computername,
 
 [string]$UserName
)

foreach ($comp in $ComputerName){

    [ADSI]$server="WinNT://$comp"

    if ($UserName){

            foreach ($User in $UserName){
            $server.children |
            Where-Object {$_.schemaclassname -eq "user" -and $_.name -eq $user}
            }    
    }else{

            $server.children |
            Where-Object {$_.schemaclassname -eq "user"}
        }
    }
}