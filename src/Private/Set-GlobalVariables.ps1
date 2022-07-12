function Set-GlobalVariables {
    [CmdletBinding()]
    param ()
    $Global:ModuleBase = Join-Path -Path ($PSScriptRoot | Split-Path -Parent) -ChildPath 'DSCResources'
    $Global:cChocoExDataFolder = (Join-Path -Path $env:ProgramData -ChildPath 'cChocoEx')
    $Global:cChocoExConfigurationFolder = (Join-Path -Path $Global:cChocoExDataFolder -ChildPath 'config')
    $Global:cChocoExTMPConfigurationFolder = (Join-Path -Path "$env:TEMP\cChocoEx" -ChildPath 'config')
    $Global:LogPath = (Join-Path -Path $Global:cChocoExDataFolder -ChildPath "logs")
    $Global:cChocoExMediaFolder = (Join-Path -Path $Global:cChocoExDataFolder -ChildPath "media")
}