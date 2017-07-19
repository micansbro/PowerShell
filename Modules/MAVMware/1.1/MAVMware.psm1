#Requires -modules vmware.vimautomation.core

#Gather all files
$PublicFunctions = @(Get-ChildItem -Path $PSScriptRoot\public\*.ps1 -ErrorAction SilentlyContinue)
$PrivateFunctions = @(Get-ChildItem -Path $PSScriptRoot\private\*.ps1 -ErrorAction SilentlyContinue)

# Dot source the functions
foreach ($file in ($PublicFunctions + $PrivateFunctions)) {
    Try {
        . $file.fullname
    } Catch {
        Write-Error -Message "Failed to import function $($File.Fullname): $_"
    }
}

# Export the public functions for module use
Export-ModuleMember -Function $PublicFunctions.basename