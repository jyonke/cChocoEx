<#
.SYNOPSIS
Returns Maintenance Window DSC Configuration in cChocoEx
.DESCRIPTION
Returns Maintenance Window DSC Configuration in cChocoEx as a PowerShell Custom Object
#>

function Get-cChocoExMaintenanceWindow {
    [CmdletBinding()]
    param (
        # Path
        [Parameter()]
        [string]
        $Path
    )
    
    begin {
        [array]$array = @()
        $ChocolateyInstall = $env:ChocolateyInstall
        $cChocoExDataFolder = (Join-Path -Path $env:ProgramData -ChildPath 'cChocoEx')
        $cChocoExConfigurationFolder = (Join-Path -Path $cChocoExDataFolder -ChildPath 'config')

        if ($Path) {
            $cChocoExConfigFile = $Path
        }
        else {
            $cChocoExConfigFile = (Get-ChildItem -Path $cChocoExConfigurationFolder -Filter 'config.psd1').FullName
        }
    }
    
    process {
        if ($cChocoExConfigFile) {
            $ConfigImport = Import-PowerShellDataFile -Path $cChocoExConfigFile
            $MaintenanceWindowConfig = $ConfigImport | ForEach-Object { $_.Values  | Where-Object { $_.ConfigName -eq 'MaintenanceWindow' -or $_.Name -eq 'MaintenanceWindow' } }
                    
            $MaintenanceWindowConfig | ForEach-Object {
                if ($_.Name) {
                    $ConfigName = $_.Name
                }
                else {
                    $ConfigName = $_.ConfigName
                }
                $array += [PSCustomObject]@{
                    ConfigName        = $ConfigName
                    UTC               = $_.UTC
                    EffectiveDateTime = $_.EffectiveDateTime
                    Start             = $_.Start
                    End               = $_.End
                }
            }
        }
        else {
            Write-Warning 'No cChocoEx Configuration file found'
        }
    }
    
    end {
        $array
    }
}