#Requires -Version 5.1
#Requires -RunAsAdministrator
#Requires -Modules PowerShellGet
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

#TranscriptLogging
$null = Start-Transcript -Path (Join-Path -Path $Env:TEMP -ChildPath 'cChocoExBootStrap.log') -Force

#Start-cChocoEx Paramater Splat
$cChocoExParamters = @{
    Loop      = $true
    LoopDelay = 90
}
##########################################

#Check and Ensure NuGet Provider is Setup
Write-Host 'Checking NuGet Package Provider' -ForegroundColor Cyan
$NuGetPackageProvider = Get-PackageProvider -Name NuGet -ErrorAction SilentlyContinue
if (-not($NugetPackageProvider)) {
    Write-Host 'Installing NuGet Package Provider' -ForegroundColor Cyan
    $null = Find-PackageProvider -Name 'Nuget' -ForceBootstrap -IncludeDependencies
}
Get-PackageProvider -Name NuGet -ErrorAction SilentlyContinue | Select-Object Name, Version, ProviderPath | Format-List

#Install/Update/Import cChocoEx
if (-Not(Get-Module -Name 'cChocoEx' -ListAvailable)) {
    #Install Module
    Write-Host 'Installing/Updating cChocoEx' -ForegroundColor Cyan
    Find-Module -Name 'cChocoEx' | Sort-Object -Property 'Version' -Descending | Install-Module -Force
}

Write-Host 'Import cChocoEx Module' -ForegroundColor Cyan
Import-Module -Name 'cChocoEx' -Force

Write-Host "Check for bootstrap updates"
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