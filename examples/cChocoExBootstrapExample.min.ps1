#Requires -Version 5.1
#Requires -RunAsAdministrator
#Requires -Modules PowerShellGet
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

#TranscriptLogging
$null = Start-Transcript -Path (Join-Path -Path $Env:TEMP -ChildPath 'cChocoExBootStrap.log') -Force

#Required cChocoEx Version
$Name = 'cChocoEx'
$MinimumVersion = '22.1.16.5'
$LoopDelay = 90

#Optional URI to this script source to self update
$BootstrapUri = 'https://raw.githubusercontent.com/jyonke/cChocoEx/master/examples/cChocoExBootstrapExample.ps1'

##########################################

#Check and Ensure NuGet Provider is Setup
Write-Host 'Checking NuGet Package Provider' -ForegroundColor Cyan
$NuGetPackageProvider = Get-PackageProvider -Name NuGet -ListAvailable -ErrorAction SilentlyContinue
if (-not($NugetPackageProvider)) {
    Write-Host 'Installing NuGet Package Provider' -ForegroundColor Cyan
    $null = Find-PackageProvider -Name 'Nuget' -ForceBootstrap -IncludeDependencies
}
Get-PackageProvider -Name NuGet -ListAvailable -ErrorAction SilentlyContinue | Select-Object Name, Version, ProviderPath | Format-List

#Install/Update/Import cChocoEx
if (-Not(Get-Module -Name $Name -ListAvailable | Where-Object { [version]$_.Version -ge [version]$MinimumVersion })) {
    #Install Module
    Write-Host 'Installing/Updating cChocoEx' -ForegroundColor Cyan
    Find-Module -Name $Name -MinimumVersion $MinimumVersion | Sort-Object -Property 'Version' -Descending | Install-Module -Force
}

Write-Host 'Import cChocoEx Module' -ForegroundColor Cyan
Import-Module -Name 'cChocoEx' -Force -Verbose

#Update cChocoEx Bootstrap
if ($BootstrapUri) {
    Update-cChocoExBootstrap -Uri $BootstrapUri
}

#Register cChocoEx
Write-Host 'Register-cChocoExBootStrapTask' -ForegroundColor Cyan
Register-cChocoExBootStrapTask -LoopDelay $LoopDelay

#Stop Logging
$null = Stop-Transcript