function Set-EnvironmentalVariables {
    param (
        
    )
    $env:cChocoModuleBase = Join-Path -Path ($PSScriptRoot | Split-Path -Parent) -ChildPath 'DSCResources'
    $env:cChocoExDataFolder = (Join-Path -Path $env:ProgramData -ChildPath 'cChocoEx')
    $env:cChocoExConfigurationFolder = (Join-Path -Path $env:cChocoExDataFolder -ChildPath 'config')
    $env:cChocoExTMPConfigurationFolder = (Join-Path -Path "$env:TEMP\cChocoEx" -ChildPath 'config')
    $env:cChocoExLogPath = (Join-Path -Path $env:cChocoExDataFolder -ChildPath "logs")
    $env:cChocoExMediaFolder = (Join-Path -Path $env:cChocoExDataFolder -ChildPath "media")
    $env:cChocoExBootstrap = (Join-Path -Path $env:cChocoExDataFolder -ChildPath "bootstrap.ps1")
}