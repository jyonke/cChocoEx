function Set-GlobalVariables {
    [CmdletBinding()]
    param ()
    $Global:ModuleBase = (Get-Module -Name 'cChoco' -ListAvailable -ErrorAction Stop | Sort-Object -Property Version | Select-Object -Last 1).ModuleBase
    $Global:cChocoExDataFolder = (Join-Path -Path $env:ProgramData -ChildPath 'cChocoEx')
    $Global:cChocoExConfigurationFolder = (Join-Path -Path $Global:cChocoExDataFolder -ChildPath 'config')
    $Global:cChocoExTMPConfigurationFolder = (Join-Path -Path "$env:TEMP\cChocoEx" -ChildPath 'config')
    $Global:LogPath = (Join-Path -Path $Global:cChocoExDataFolder -ChildPath "logs")
    $Global:cChocoExMediaFolder = (Join-Path -Path $Global:cChocoExDataFolder -ChildPath "media")
}