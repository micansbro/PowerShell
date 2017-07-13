# Author: Torkild Retvedt
# License: The MIT License (MIT) 
#
# Creates multiple zip-files from the modules of in a given DSC MOF-file.
# This script should be run on the same machine that generated the MOF-file.
# 
# Example: A DSC MOF-file with content like:
#
# instance of ...
# {
#   ...
#   ModuleName = "PSDesiredStateConfiguration";
#   ModuleVersion = "1.0";
#   ...
# };
#
# Will produce a zip and checksum for each module, in this case "PSDesiredStateConfiguration".
# DestinationPath
# |- PSDesiredStateConfiguration_1.0.zip
# \- PSDesiredStateConfiguration_1.0.zip.checksum
#
# When generating the MOF-file, the module must be in %PSModulePath%.
# The name and structure of the archive should be correct for usage with the DSC pull server.
# You will probably want to place the contents of the DestinationPath in the directory
# pointed to by "ModulePath" in the PullServer configuration.
#
# Typically, you'd want to run this script at the same time you would create a MOF file and its
# checksum. This way, the file you're serving on the PULL server will  always be accompanied
# by the complete set of modules needed by any client.
#

Function Get-DscModulePath {
    param(
        [String]
        [Parameter(Mandatory=$True)]
        $Name
    )

    foreach($path in $env:PSModulePath.Split(";")) {
        $modulePath = Join-Path $path $Name

        Write-Verbose "Searcing for module in $modulePath"

        if (Test-Path -Path (Join-Path $modulePath "DSCResources")) {
            Write-Verbose "Found DSC resource: ${modulePath}"

            return $modulePath
        }
    }

    throw "Module not found: ${Name}"
}

Function New-DscResourceArchive {
    param(
        [String]
        [Parameter(Mandatory=$True)]
        $Module,
        [String]
        [Parameter(Mandatory=$True)]
        $Version,
        [String]
        [Parameter(Mandatory=$True)]
        $DestinationPath
    )

    Write-Verbose ("Processing module: {0}, {1}" -f $Module, $Version)

    $modulePath = Get-DscModulePath -Name $Module

    Write-Verbose ("Compressing module: {0}" -f $modulePath)
    $level = [System.IO.Compression.CompressionLevel]::Optimal
    $zipfile = Join-Path $DestinationPath ("{0}_{1}.zip" -f $Module, $Version)
    $includeBase = $True # needed to comply with the DSC zipped module format

    if (Test-Path $zipfile) {
        Write-Verbose ("Removing old module: {0}" -f $zipfile)
        Remove-Item -Force $zipfile
        Remove-Item -Force "${zipfile}.checksum"
    }

    Add-Type -Assembly "System.IO.Compression.FileSystem"
    $res = New-Item -Type Directory -Path (Split-Path $zipFile) -Force
    [System.IO.Compression.ZipFile]::CreateFromDirectory($modulePath, $zipfile, $level, $includeBase)
    Write-Host ("Module exported: {0}" -f $zipfile)

    New-DscChecksum -Path $zipfile
    Write-Verbose ("Checksum created: {0}.checksum" -f $zipfile)
}

Function Get-DscResourcesFromMof {
    param(
        [String]
        [Parameter(Mandatory=$True)]
        $MofFile
    )

    $match = [IO.File]::ReadAllText($MofFile) | Select-String -AllMatches "(\{(?:[^{}]|\{[^{}]*\})*})"

    $modules = @{}
        
    $match.Matches | ForEach-Object {
        $resource = $_

        if ($resource -match "ModuleName\s*=\s*""(.*)"";") {
            $module = $Matches[1]
            $version = ""

            if ($resource -match "ModuleVersion\s*=\s*""(.*)"";") {
                $version = $Matches[1]

                if ([System.String]::IsNullOrWhiteSpace($version)) {
                    $version = "1.0.0.0"
                }
            }

            if (!$modules.ContainsKey($module)) {
                Write-Verbose ("Found new module: {0}, {1}" -f $module, $version)
                $modules[$module] = $version
            }
        }
    }

    $modules
}

Function New-MofArchive {
    param(
        [String]
        [Parameter(Mandatory=$True)]
        $MofFile,
        [String]
        [Parameter(Mandatory=$True)]
        $DestinationPath
    )

    $modules = Get-DscResourcesFromMof -MofFile $MofFile

    $modules.Keys | ForEach-Object {
        $module = $_

        New-DscResourceArchive -Module $module -Version $modules[$module] -DestinationPath $DestinationPath
    }
}