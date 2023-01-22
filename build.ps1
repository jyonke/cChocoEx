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

Register-PSRepository -Name $BuildRepository -SourceLocation $LocalRepository -PublishLocation $LocalRepository -InstallationPolicy Trusted

#Test Builds
if (-Not($Publish)) {
    #Dependencies
    New-Item -ItemType Directory -Path $BuildDirectory -Force -ErrorAction SilentlyContinue | Out-Null
    if (-not(Test-Path "$PSScriptRoot\nuget.exe")) {
        Invoke-WebRequest -Uri 'https://dist.nuget.org/win-x86-commandline/latest/nuget.exe' -OutFile "$PSScriptRoot\nuget.exe"
    }
    
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
        #Gather function Names
        #https://www.codykonior.com/2018/02/20/populating-powershell-module-functionstoexport-automatically/
        $FunctionsToExport = Get-ChildItem -Path (Join-Path $PSScriptRoot 'src\Public\') -Recurse | Where-Object { $_.Name -match "^[^\.]+-[^\.]+\.ps1$" } -PipelineVariable file | ForEach-Object {
            $ast = [System.Management.Automation.Language.Parser]::ParseFile($file.FullName, [ref] $null, [ref] $null)
            if ($ast.EndBlock.Statements.Name) {
                $ast.EndBlock.Statements.Name
            }
        }
        $FormatsToProcess = Get-ChildItem -Path (Join-Path $PSScriptRoot 'src\Formats\') -Recurse -Filter *.ps1xml | Select-Object -ExpandProperty Name  | ForEach-Object { ".\Formats\$_" }

        #Update Module Manifest
        Update-ModuleManifest -Path $ModuleManifestFile -ModuleVersion $BuildVersion -FunctionsToExport $FunctionsToExport -FormatsToProcess $FormatsToProcess

        #Update Version in Nuspec
        [xml]$xml = Get-Content -Path $NuSpecFile -Raw
        $xml.package.metadata.version = $BuildVersion
        #$xml.SelectSingleNode('/nuspec:package/nuspec:metadata/nuspec:description', $ns).InnerText = Get-Content -Raw (Join-Path $Directory 'ReadMe.md')
        $xml.Save($NuSpecFile)
        Write-Host "$NuSpecFile -- Original Version: $CurrentVersion -- Updated to $BuildVersion"
    }
    catch {
        Unregister-PSRepository -Name $BuildRepository
        throw $_.Exception.Message
        return
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
    try {
        $Guid = New-Guid | Select-Object -ExpandProperty Guid
        $TempPath = New-Item -ItemType Directory -Path (Join-Path $env:TEMP "$Guid\cChocoEx") -Force -ErrorAction SilentlyContinue
        Copy-Item -Path "$SourceFolder\*" -Destination $TempPath.FullName -Force -Recurse
        Publish-Module -Path $TempPath -Repository 'PSGallery' -NuGetApiKey $APIKey_PSGallery -Force       
    }
    catch {
        Write-Error $_.Exception.Message
        Write-Error 'Module Failed to Publish!!!'
    }
    finally {
        #Cleanup
        Remove-Item -Path $TempPath -Recurse -Force
        Unregister-PSRepository -Name $BuildRepository
    }
}
