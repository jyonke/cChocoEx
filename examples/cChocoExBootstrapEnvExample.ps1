#Requires -Version 5.1
#Requires -RunAsAdministrator
#Requires -Modules PowerShellGet
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

#TranscriptLogging
$null = Start-Transcript -Path (Join-Path -Path $Env:TEMP -ChildPath 'cChocoExBootStrap.log') -Force

#Optional NuGet Package Provider URI
$NuGetPackageProviderURI = 'https://onegetcdn.azureedge.net/providers/Microsoft.PackageManagement.NuGetProvider-2.8.5.208.dll'

#Env Variables
$env:cChocoExBootstrapUri = 'https://raw.githubusercontent.com/jyonke/cChocoEx/master/examples/cChocoExBootstrapExample.ps1'
$env:cChocoExChocoConfig = 'https://raw.githubusercontent.com/jyonke/cChocoEx/master/examples/cChocoExConfigExample.psd1'
$env:cChocoExSourcesConfig = 'https://raw.githubusercontent.com/jyonke/cChocoEx/master/examples/cChocoExSourcesExample.psd1'
$env:cChocoExPackageConfig = 'https://raw.githubusercontent.com/jyonke/cChocoEx/master/examples/cChocoExPackagesExample.psd1'
$env:cChocoExFeatureConfig = 'https://raw.githubusercontent.com/jyonke/cChocoEx/master/examples/cChocoExFeatureExample.psd1'
$env:ChocoDownloadUrl = 'https://packages.chocolatey.org/chocolatey.2.2.2.nupkg'
$env:ChocoInstallScriptUrl = 'https://community.chocolatey.org/install.ps1'

#Start-cChocoEx Paramater Splat
$cChocoExParamters = @{
    Loop                   = $true
    LoopDelay              = 90
    EnableNotifications    = $true
    SetcChocoExEnvironment = $true
}

##########################################

#Check and Ensure NuGet Provider is Setup
Write-Host 'Checking NuGet Package Provider' -ForegroundColor Cyan
$NuGetPackageProvider = Get-PackageProvider -Name NuGet -ListAvailable -ErrorAction SilentlyContinue
if (-not($NugetPackageProvider)) {
    Write-Host 'Installing NuGet Package Provider' -ForegroundColor Cyan
    #Manual Deployment if URI defined
    if ($NuGetPackageProviderURI) {
        $Version = ($NuGetPackageProviderURI -Split '-' | Select-Object -Last 1) -replace '.dll', ''
        $OutputDirectory = (Join-Path -Path "$env:ProgramFiles\PackageManagement\ProviderAssemblies\nuget\" -ChildPath $Version)    
        $Null = New-Item -ItemType Directory -Path $OutputDirectory -ErrorAction SilentlyContinue
        Invoke-WebRequest -Uri $NuGetPackageProviderURI -UseBasicParsing -OutFile (Join-Path -Path $OutputDirectory -ChildPath 'Microsoft.PackageManagement.NuGetProvider.dll')
    }
    else {
        $null = Find-PackageProvider -Name 'Nuget' -ForceBootstrap -IncludeDependencies
    }
}

#Install/Update/Import cChocoEx
if (Get-Module -Name cChocoEx -ListAvailable -ErrorAction SilentlyContinue) {
    Update-cChocoEx
}
else {
    Install-Module -Name cChocoEx -Force
}

Write-Host 'Import cChocoEx Module' -ForegroundColor Cyan
Import-Module -Name 'cChocoEx' -Force

Write-Host "Check for updated bootstrap"
if ($env:cChocoExBootstrapUri) {
    $Updated = Update-cChocoExBootstrap -ErrorAction SilentlyContinue
}
if (($Updated).Updated -eq $true) {
    Write-Host "Restarting bootstrap.ps1"
    #Stop Logging
    $null = Stop-Transcript
    Start-Sleep -Seconds 3
    $Arguments = "-ExecutionPolicy ByPass -File `"" + $env:cChocoExBootstrap + "`""
    $Exe = (Join-Path $env:SystemRoot -ChildPath "\System32\WindowsPowerShell\v1.0\powershell.exe")
    Start-Process $Exe -ArgumentList $Arguments -Wait -NoNewWindow
}
else {
    #Start cChocoEx
    Write-Host "Start cChocoEx"
    Start-cChocoEx @cChocoExParamters
    #Stop Logging
    $null = Stop-Transcript
}
