<#
.SYNOPSIS
    Builds and publishes the cChocoEx PowerShell module.

.DESCRIPTION
    This script handles the build and publication process for the cChocoEx module.
    It can create test builds, publish to a local repository, or publish to the
    PowerShell Gallery.

.PARAMETER Publish
    Specifies the target repository: PSGallery, Nexus, or Local.

.PARAMETER BuildDirectory
    Specifies the build directory path. Defaults to environment variable value.

.PARAMETER IncrementVersion
    When specified, increments the revision number of the module version.
    If not specified, uses the current version number.

.EXAMPLE
    .\build.ps1 -Publish Local
    Creates a build and publishes to the local repository using current version.

.EXAMPLE
    .\build.ps1 -Publish Nexus -IncrementVersion
    Creates a build with incremented version number and publishes to Nexus.

.EXAMPLE
    .\build.ps1 -Publish PSGallery -IncrementVersion
    Creates a build with incremented version number and publishes to PowerShell Gallery.
#>
[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [ValidateSet('PSGallery', 'Nexus', 'Local')]
    [string]
    $Publish,

    [Parameter()]
    [string]
    $BuildDirectory = $env:cChocoEx_BuildDirectory,

    [Parameter()]
    [switch]
    $IncrementVersion
)

#Region Setup
$ErrorActionPreference = 'Stop'
$script:TempPath = $null

# Import environment variables
if (Test-Path (Join-Path $PSScriptRoot 'env_vars.ps1')) {
    Write-Host "Importing environment variables"
    . (Join-Path $PSScriptRoot 'env_vars.ps1')
}

# Environment Variables
$script:BuildRepository = $env:cChocoEx_BuildRepository
$script:BuildDirectory = $env:cChocoEx_BuildDirectory
$script:APIKey_PSGallery = $env:cChocoEx_PublishAPIKey
$script:APIKey_NexusRepo = $env:cChocoEx_BuildAPIKey
$script:NexusRepo = $env:cChocoEx_NexusRepo

# Script Variables
$script:LocalRepository = Join-Path $PSScriptRoot 'builds'
$script:SourceFolder = Join-Path $PSScriptRoot 'src'
$script:ModuleManifestFile = Get-ChildItem -Path $PSScriptRoot -Recurse -Filter 'cChocoEx.psd1' | 
Select-Object -ExpandProperty FullName

Write-Host "Build configuration loaded"
#EndRegion Setup

#Region Functions
function Get-BuildVersion {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$CurrentVersion,
        
        [Parameter()]
        [string]$Repository,

        [Parameter()]
        [switch]$IncrementVersion
    )
    
    # Safely parse the current version
    try {
        [version]$parsedVersion = [version]::new(0, 0, 0, 0)
        if (![version]::TryParse($CurrentVersion, [ref]$parsedVersion)) {
            Write-Warning "Could not parse current version '$CurrentVersion'. Starting from 0.0.0.0"
        }
    }
    catch {
        Write-Warning "Error parsing current version. Starting from 0.0.0.0"
        $parsedVersion = [version]::new(0, 0, 0, 0)
    }

    if ($IncrementVersion) {
        # Use 4-part version (Major.Minor.Build.Revision)
        [version]$DateVersion = [version]::new(
            [int](Get-Date -f yy),
            [int](Get-Date -f MM),
            [int](Get-Date -f dd),
            0  # Start revision at 0
        )
        
        if ($parsedVersion.Major -eq $DateVersion.Major -and 
            $parsedVersion.Minor -eq $DateVersion.Minor -and 
            $parsedVersion.Build -eq $DateVersion.Build) {
            # Same date, increment revision
            $BuildVersion = [version]::new(
                $parsedVersion.Major,
                $parsedVersion.Minor,
                $parsedVersion.Build,
                ($parsedVersion.Revision + 1)
            )
        }
        else {
            # New date, start at revision 1
            $BuildVersion = [version]::new(
                $DateVersion.Major,
                $DateVersion.Minor,
                $DateVersion.Build,
                1
            )
        }
        Write-Host "Incrementing version to: $BuildVersion"
    }
    else {
        # Keep current version
        $BuildVersion = $parsedVersion
        Write-Host "Using current version: $BuildVersion"
    }

    return $BuildVersion
}

function Get-ModuleFunctions {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$Path
    )
    
    Write-Host "Getting function exports from $Path"
    Get-ChildItem -Path $Path -Recurse | 
    Where-Object { $_.Name -match "^[^\.]+-[^\.]+\.ps1$" } -PipelineVariable file | 
    ForEach-Object {
        $ast = [System.Management.Automation.Language.Parser]::ParseFile(
            $file.FullName, [ref]$null, [ref]$null
        )
        if ($ast.EndBlock.Statements.Name) {
            $ast.EndBlock.Statements.Name
        }
    }
}

function Get-ModuleFormats {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$Path
    )
    
    Write-Host "Getting format files from $Path"
    Get-ChildItem -Path $Path -Recurse -Filter *.ps1xml | 
    Select-Object -ExpandProperty Name | 
    ForEach-Object { ".\Formats\$_" }
}

function Update-ModuleVersion {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [version]$Version,
        
        [Parameter(Mandatory)]
        [hashtable]$ManifestParams
    )
    
    $ManifestParams.ModuleVersion = $Version
    Update-ModuleManifest @ManifestParams
    Write-Host "Updated module version to $Version"
}
#EndRegion Functions

#Region Main Process
try {
    Write-Host "Starting build process"
    
    # Create build directory
    $null = New-Item -ItemType Directory -Path $BuildDirectory -Force
    Write-Host "Created build directory: $BuildDirectory"

    # Register local repository
    Register-PSRepository -Name $BuildRepository -SourceLocation $LocalRepository -PublishLocation $LocalRepository -InstallationPolicy Trusted
    
    # Get current version and calculate new version
    $manifestData = Import-PowerShellDataFile -Path $ModuleManifestFile
    $CurrentVersion = $manifestData.ModuleVersion
    Write-Host "Current version from manifest: $CurrentVersion"
    $BuildVersion = Get-BuildVersion -CurrentVersion $CurrentVersion -Repository $BuildRepository -IncrementVersion:$IncrementVersion
    
    if ($IncrementVersion) {
        Write-Host "Updating version from $CurrentVersion to $BuildVersion"
    }
    else {
        Write-Host "Using current version: $BuildVersion"
    }

    # Get module components
    $FunctionsToExport = Get-ModuleFunctions -Path (Join-Path $PSScriptRoot 'src\Public')
    $FormatsToProcess = Get-ModuleFormats -Path (Join-Path $PSScriptRoot 'src\Formats')

    # Update module manifest
    Write-Host "Updating module manifest"
    $manifestParams = @{
        Path              = $ModuleManifestFile
        ModuleVersion     = $BuildVersion
        FunctionsToExport = $FunctionsToExport
        FormatsToProcess  = $FormatsToProcess
    }

    # Get DSC resources
    $dscResources = Get-ChildItem -Path (Join-Path $PSScriptRoot 'src\DSCResources') -Directory | 
    Select-Object -ExpandProperty Name
    if ($dscResources) {
        Write-Host "Adding DSC resources to manifest"
        $manifestParams['DscResourcesToExport'] = $dscResources
    }

    Update-ModuleManifest @manifestParams

    # Create temporary build location
    $BuildGuid = New-Guid
    $script:TempPath = New-Item -ItemType Directory -Path (Join-Path $env:TEMP "$BuildGuid\cChocoEx") -Force
    Copy-Item -Path "$SourceFolder\*" -Destination $TempPath.FullName -Force -Recurse
    Write-Host "Created temporary build at: $($TempPath.FullName)"

    # Handle publishing
    switch ($Publish) {
        'PSGallery' {
            Write-Host "Publishing to PowerShell Gallery"
            $publishParams = @{
                Path        = $TempPath.FullName
                Repository  = 'PSGallery'
                NuGetApiKey = $APIKey_PSGallery
                Force       = $true
                ErrorAction = 'Stop'
            }
            Publish-Module @publishParams
        }
        'Nexus' {
            Write-Host "Publishing to Nexus Repository"
            # Register Nexus repository
            Register-PSRepository -Name 'nexus_repo' -SourceLocation $NexusRepo -PublishLocation $NexusRepo -InstallationPolicy Trusted -PackageManagementProvider NuGet
            
            # Publish to Nexus repository first
            $publishParams = @{
                Path        = $TempPath.FullName
                Repository  = 'nexus_repo'
                NuGetApiKey = $APIKey_NexusRepo
                Force       = $true
                ErrorAction = 'Stop'
            }
            try {
                Publish-Module @publishParams
            }
            catch [System.Exception] {
                if ($_.Exception.Message -match 'already available') {
                    Write-Host "Incrementing version and retrying"
                    $BuildVersion = Get-BuildVersion -CurrentVersion $BuildVersion -Repository $BuildRepository -IncrementVersion:$IncrementVersion
                    Update-ModuleVersion -Version $BuildVersion -ManifestParams $manifestParams
                    Publish-Module @publishParams
                }
                else {
                    throw
                }
            }
            
        }
        'Local' {
            Write-Host "Publishing to local repository"
            # Register local repository
            
            # Publish to local repository
            $publishParams = @{
                Path        = $TempPath.FullName
                Repository  = $BuildRepository
                NuGetApiKey = 'NoKey'
                Force       = $true
                ErrorAction = 'Stop'
            }
            try {
                Publish-Module @publishParams
            }
            catch [System.Exception] {
                if ($_.Exception.Message -match 'already available') {
                    Write-Host "Incrementing version and retrying"
                    $BuildVersion = Get-BuildVersion -CurrentVersion $BuildVersion -Repository $BuildRepository -IncrementVersion:$IncrementVersion
                    Update-ModuleVersion -Version $BuildVersion -ManifestParams $manifestParams
                    Publish-Module @publishParams
                }
                else {
                    throw
                }
            }
    
        }
    }
}
catch {
    Write-Error "Build failed: $($_.Exception.Message)"
    throw
}
finally {
    # Cleanup
    Write-Host "Cleaning up temporary files"
    if ($script:TempPath -and (Test-Path -Path $script:TempPath.FullName)) {
        Remove-Item -Path $script:TempPath.FullName -Recurse -Force
    }
    if ($BuildRepository -and (Get-PSRepository -Name $BuildRepository -ErrorAction SilentlyContinue)) {
        Unregister-PSRepository -Name $BuildRepository
    }
    if ((Get-PSRepository -Name 'nexus_repo' -ErrorAction SilentlyContinue)) {
        Unregister-PSRepository -Name 'nexus_repo'
    }
}
#EndRegion Main Process