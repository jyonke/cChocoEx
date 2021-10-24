<#
.SYNOPSIS
Returns Chocolatey Configuration DSC Configuration in cChocoEx
.DESCRIPTION
Returns Chocolatey Configuration DSC Configuration in cChocoEx as a PowerShell Custom Object
#>
function Get-cChocoExConfig {
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
            $Configurations = $ConfigImport | ForEach-Object { $_.Values | Where-Object { $_.ConfigName -ne 'MaintenanceWindow' -and $_.Name -ne 'MaintenanceWindow' } } 
                    
            $Configurations | ForEach-Object {
                $array += [PSCustomObject]@{
                    ConfigName = $_.ConfigName
                    Value      = $_.Value
                    Ensure     = $_.Ensure
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