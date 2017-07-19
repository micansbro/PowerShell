<#
.SYNOPSIS
Returns settings from the local security policy
.DESCRIPTION
This function returns a hashtable of the local security policy settings.
.EXAMPLE
    Get-LocalSecurityPolicySettings
#>

function Get-LocalSecurityPolicySettings {

    $temp = "c:\temp"
    $file = "$temp\pol.txt"
    if (-not (test-path $temp)) {
        new-item -ItemType Directory -Path $temp -Force
    }
    [string] $readableNames
    $outHash = @{}
    $process = [diagnostics.process]::Start("secedit.exe", "/export /cfg $file /areas securitypolicy")
    $process.WaitForExit()
    $in = get-content $file
    foreach ($line in $in) {
        if ($line -like "*password*" -or $line -like "*lockout*" -and $line -notlike "machine\*" -and $line -notlike "require*" ) {
            $policy = $line.substring(0,$line.IndexOf("=") - 1)
            switch ($policy){
            "passwordhistorysize" {$policy = "Enforce Password Policy"}
            "maximumpasswordage" {$policy = "Maximum Password Age"}
            "minimumpasswordage" {$policy = "Minimum Password Age"}
            "minimumpasswordlength" {$policy = "Minimum Password Length"}
            "passwordcomplexity" {$policy = "Password must meet complexity requirements"}
            "cleartextpassword" {$policy = "Store Passwords Using Reversible Encryption"}
            "lockoutduration" {$policy = "Account Lockout Duration"}
            "lockoutbadaccount" {$policy = "Account Lockout Threshold"}
            "resetlockoutcount" {$policy = "Reset Account Lockout Counter After"}
            }
            $values = $line.substring($line.IndexOf("=") + 1,$line.Length - ($line.IndexOf("=") + 1))
            #$values =  $values.Trim({}) -split ","
            $outHash.Add($policy,$values) #output edited version
        }
    }
    Write-output $outHash
}
