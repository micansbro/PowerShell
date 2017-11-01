<#
.SYNOPSIS
  Get a systems uptime.
.DESCRIPTION
  This command uses WMI to display the system uptime.
.EXAMPLE
  Get-SystemUptime
.NOTES
  01/11/2017
#>
function Get-SystemUptime ($computer = "$env:computername") {
  $lastboot = [System.Management.ManagementDateTimeconverter]::ToDateTime("$((gwmi  Win32_OperatingSystem).LastBootUpTime)")
  $uptime = (Get-Date) - $lastboot
  return (($uptime.days).ToString()+"d:"+($uptime.hours).ToString()+"h:"+$uptime.minutes.ToString()+"m:"+($uptime.seconds).ToString()+"s")
}
