<#
.SYNOPSIS
Checks if a server is running SMBv1
.DESCRIPTION
This command checks a given computer to see if SMBv1 is enabled. The method it uses depends on the OS. WIndows 8/2012 and above have native PowerShell commands.
Legacy OS's use a registry lookup.
.EXAMPLE
$computers = (Get-adcomputer -filter * -searchBase "ou=servers, dc=domain, dc=suffix").name
Test-SMBv1 -Computers $computers


#>
function Test-SMBv1{
 
 Param (
  [cmdletbinding()]
  [Parameter(Mandatory=$true)]
  [string[]]$computers
 )
$computerCount = $computers.count

# Create empty array
$compArray =@()
# Foreach loop to create an object for every computername provided.    
foreach ($computer in $computers) {
      
      [version]$OSVersion = (gwmi -class win32_operatingSystem -Property version -ComputerName $computer -ErrorAction SilentlyContinue).version
      [string]$SMBv1Found = ''

      $compObj = New-Object System.Object
      $compObj | Add-Member -Type NoteProperty -Name Name -Value $computer
      $compObj | Add-Member -Type NoteProperty -Name OSVersion -Value $OSVersion
      $compObj | Add-Member -Type NoteProperty -Name SMBv1Found -Value $SMBv1Found
      $compArray += $compObj
}
# Collect all servers that responded to a wmi call
$respondingArray = $compArray | where {$_.OSVersion -ne $null}
$respondingServers = $respondingArray.count
# Foreach loop to process all responding servers
foreach ($server in $respondingArray) {
  # If the server is Windows 8/2012 or higher use the PowerShell command
  if ($server.OSversion -ge [version]"6.2.0000") {
    
    [boolean]$server.SMBv1Found += Invoke-command -ComputerName $server.Name -ScriptBlock {(Get-SmbServerConfiguration).EnableSMB1Protocol}

  } Else {
      try {
      $Reg = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine', $server.name)
      $RegKey= $Reg.OpenSubKey("SYSTEM\\CurrentControlSet\\Services\\LanmanServer\\Parameters")
      $RegValue = $RegKey.GetValue("SMB1")
      } Catch {}
        if ($regValue -eq $null -or 1 ) {
          [boolean]$server.SMBv1Found += $true

        }
    }
}
"Testing $ComputerCount enabled computer names."
"$respondingServers of the computers responded to a WMI call."      
$compArray
}