<#
.SYNOPSIS
Retrieves the local Windows user accounts.
.DESCRIPTION
This function retrieves all local users accounts from Windows.
.PARAMETER Username
One or more usernames.
.PARAMETER Computername
One or more computernames.
.EXAMPLE
'Server01' | Get-LocalUserAccount
.EXAMPLE
Get-LocalUserAccount -Computername 'server01' -Username 'User01'
.NOTES Author: Michael Ansbro
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
            where {$_.schemaclassname -eq "user" -and $_.name -eq $user}
            }    
    }else{
            $server.children |
            where {$_.schemaclassname -eq "user"}
        }
    }
}