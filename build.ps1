[CmdletBinding()]
param (
    [Parameter()]
    [switch]
    $Publish
)
$ErrorActionPreference = 'stop'

#Env Variables
if (Test-Path (Join-Path $PSScriptRoot 'env_vars.ps1')) {
    . (Join-Path $PSScriptRoot 'env_vars.ps1')
}
$BuildRepository = $env:cChocoEx_BuildRepository
$BuildDirectory = $env:cChocoEx_BuildDirectory
$APIKey_PSGallery = $env:cChocoEx_PublishAPIKey
$APIKey_NexusRepo = $env:cChocoEx_BuildAPIKey
$NexusRepo = $env:cChocoEx_NexusRepo

#Script Variables
$LocalRepository = "$PSScriptRoot\builds"
$SourceFolder = (Join-Path $PSScriptRoot 'src')
$NuspecFile = (Get-ChildItem -Path $PSScriptRoot -Recurse -Filter cChocoEx.nuspec).FullName
$ModuleManifestFile = (Get-ChildItem -Path $PSScriptRoot -Recurse -Filter 'cChocoEx.psd1').FullName

Write-Host "NUSPEC FILE: $NuspecFile" -ForegroundColor Cyan
Write-Host "BUILD DIRECTORY: $BuildDirectory" -ForegroundColor Cyan

#Test Builds
if (-Not($Publish)) {
    #Dependencies
    New-Item -ItemType Directory -Path $BuildDirectory -Force -ErrorAction SilentlyContinue | Out-Null
    if (-not(Test-Path "$PSScriptRoot\nuget.exe")) {
        Invoke-WebRequest -Uri 'https://dist.nuget.org/win-x86-commandline/latest/nuget.exe' -OutFile "$PSScriptRoot\nuget.exe"
    }

    Register-PSRepository -Name $env:cChocoEx_BuildRepository -SourceLocation $LocalRepository -PublishLocation $LocalRepository -InstallationPolicy Trusted

    #Version Update
    [version]$CurrentVersion = (Import-PowerShellDataFile -Path $ModuleManifestFile).ModuleVersion
    [version]$DateVersion = Get-Date -f yy.MM.dd
    if ($CurrentVersion -ge $DateVersion) {
        $BuildVersion = ([string]$DateVersion.Major + '.' + [string]$DateVersion.Minor + '.' + [string]$DateVersion.Build + '.' + [string]($CurrentVersion.Revision + 1))
    }
    else {
        $BuildVersion = ([string]$DateVersion + '.1')
    }

    try {
        #Update Module Manifest
        Update-ModuleManifest -Path $ModuleManifestFile -ModuleVersion $BuildVersion

        #Update Version in Nuspec
        [xml]$xml = Get-Content -Path $NuSpecFile -Raw
        $xml.package.metadata.version = $BuildVersion
        #$xml.SelectSingleNode('/nuspec:package/nuspec:metadata/nuspec:description', $ns).InnerText = Get-Content -Raw (Join-Path $Directory 'ReadMe.md')
        $xml.Save($NuSpecFile)
        Write-Host "$NuSpecFile -- Original Version: $CurrentVersion -- Updated to $BuildVersion"
    }
    catch {
        throw $_.Exception.Message
    }

    #Publish
    $Guid = New-Guid | Select-Object -ExpandProperty Guid
    $TempPath = New-Item -ItemType Directory -Path (Join-Path $env:TEMP "$Guid\cChocoEx") -Force -ErrorAction SilentlyContinue
    Copy-Item -Path "$SourceFolder\*" -Destination $TempPath.FullName -Force -Recurse
    Publish-Module -Path $TempPath -Repository $BuildRepository -NuGetApiKey 'NoKey' -Force

    #Push
    try {
        $NupkgFile = (Get-ChildItem -Path $BuildDirectory -Filter *.nupkg | Where-Object { $_.Name -Match $BuildVersion }).FullName
        #Argumenbts
        $ArgumentList = @(
            'push'
            $NupkgFile
            "-ApiKey $APIKey_NexusRepo"
            "-Source $NexusRepo"
        )
        Start-Process -FilePath "$PSScriptRoot\nuget.exe" -ArgumentList $ArgumentList -NoNewWindow -Wait
    }
    catch {
        throw $_.Exception.Message
    }

    #Cleanup
    Unregister-PSRepository -Name $BuildRepository
    Remove-Item -Path $TempPath -Recurse -Force
}
#PSGallery Publish
if ($Publish) {
    $Guid = New-Guid | Select-Object -ExpandProperty Guid
    $TempPath = New-Item -ItemType Directory -Path (Join-Path $env:TEMP "$Guid\cChocoEx") -Force -ErrorAction SilentlyContinue
    Copy-Item -Path "$SourceFolder\*" -Destination $TempPath.FullName -Force -Recurse
    Publish-Module -Path $TempPath -Repository $BuildRepository -NuGetApiKey $APIKey_PSGallery -Force -Verbose -WhatIf

    #Cleanup
    Remove-Item -Path $TempPath -Recurse -Force
}
