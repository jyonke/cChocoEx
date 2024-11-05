<#
.SYNOPSIS
Sets environmental variables for cChocoEx module.

.DESCRIPTION
This function sets various environmental variables used by the cChocoEx module.
It defines paths for the module base, data folder, configuration folders, log path,
media folder, and bootstrap script.

.EXAMPLE
Set-EnvironmentalVariables

.NOTES
This is a private function and is typically called internally by the cChocoEx module.

.LINK
https://github.com/jyonke/cChocoEx

#>
function Set-EnvironmentalVariables {
    [CmdletBinding()]
    param ()
    
    $env:cChocoModuleBase = Join-Path -Path ($PSScriptRoot | Split-Path -Parent) -ChildPath 'DSCResources'
    $env:cChocoExDataFolder = (Join-Path -Path $env:ProgramData -ChildPath 'cChocoEx')
    $env:cChocoExConfigurationFolder = (Join-Path -Path $env:cChocoExDataFolder -ChildPath 'config')
    $env:cChocoExTMPConfigurationFolder = (Join-Path -Path "$env:TEMP\cChocoEx" -ChildPath 'config')
    $env:cChocoExLogPath = (Join-Path -Path $env:cChocoExDataFolder -ChildPath "logs")
    $env:cChocoExMediaFolder = (Join-Path -Path $env:cChocoExDataFolder -ChildPath "media")
    $env:cChocoExBootstrap = (Join-Path -Path $env:cChocoExDataFolder -ChildPath "bootstrap.ps1")
}
