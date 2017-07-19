$ModuleManifestName = 'MALocalUser.psd1'
Import-Module $PSScriptRoot\..\$ModuleManifestName
$ModulePath = Split-Path -Parent $MyInvocation.MyCommand.Path
$ModuleName = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -Replace ".Tests.ps1"

$ManifestPath   = "$ModulePath\$ModuleName.psd1"

# test the module manifest - exports the right functions, processes the right formats, and is generally correct
Describe "Manifest" {
    $Manifest = $null
    It "has a valid manifest" {
        {
            $Script:Manifest = Test-ModuleManifest -Path $ManifestPath -ErrorAction Stop -WarningAction SilentlyContinue
        } | Should Not Throw
    }

    It "has a valid name" {
        $Script:Manifest.Name | Should Be $ModuleName
    }

	It "has a valid root module" {
        $Script:Manifest.RootModule | Should Be "$ModuleName.psm1"
    }

	It "has a valid Description" {
        $Script:Manifest.Description | Should Not BeNullOrEmpty
    }

    It "has a valid guid" {
        $Script:Manifest.Guid | Should Be '1ac5a7d4-d4c1-4f09-9582-09206c2bd7f1'
    }

	It "has a valid prefix" {
		$Script:Manifest.Prefix | Should Not BeNullOrEmpty
	}

	It "has a valid copyright" {
		$Script:Manifest.CopyRight | Should Not BeNullOrEmpty
	}

	It 'exports all public functions' {
		$FunctionFiles = Get-ChildItem "$ModulePath\Public" -Filter *.ps1 | Select-Object -ExpandProperty BaseName
		$FunctionNames = $FunctionFiles | foreach {$_ -replace '-', "-$($Script:Manifest.Prefix)"}
		$ExFunctions = $Script:Manifest.ExportedFunctions.Values.Name
		foreach ($FunctionName in $FunctionNames)
		{
			$ExFunctions -contains $FunctionName | Should Be $true
		}
	}
}