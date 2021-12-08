<#
.SYNOPSIS
Returns Chocolatey Package DSC Configuration in cChocoEx
.DESCRIPTION
Returns Chocolatey Package DSC Configuration in cChocoEx as a PowerShell Custom Object
#>
function Get-cChocoExPackageInstall {
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
        [array]$Configurations = $null
        $cChocoExDataFolder = (Join-Path -Path $env:ProgramData -ChildPath 'cChocoEx')
        $cChocoExConfigurationFolder = (Join-Path -Path $cChocoExDataFolder -ChildPath 'config')

        if ($Path) {
            $cChocoExPackageFiles = Get-Item -Path $Path
        }
        else {
            $cChocoExPackageFiles = Get-ChildItem -Path $cChocoExConfigurationFolder -Filter *.psd1 | Where-Object { $_.Name -notmatch "sources.psd1|config.psd1|features.psd1" } 
        }
    }
    
    process {
        if ($cChocoExPackageFiles) {
            $cChocoExPackageFiles | ForEach-Object {
                $ConfigImport = $null
                $ConfigImport = Import-PowerShellDataFile $_.FullName 
                $Configurations += $ConfigImport | ForEach-Object { $_.Values }
            }        
                    
            $Configurations | ForEach-Object {
                $array += [PSCustomObject]@{
                    Name                      = $_.Name
                    Version                   = $_.Version
                    Source                    = $_.Source
                    MinimumVersion            = $_.MinimumVersion
                    Ensure                    = $_.Ensure
                    AutoUpgrade               = $_.AutoUpgrade
                    Params                    = $_.Params
                    ChocoParams               = $_.ChocoParams
                    OverrideMaintenanceWindow = $_.OverrideMaintenanceWindow
                    VPN                       = $_.VPN
                    Ring                      = $_.Ring
                    Priority                  = $_.Priority
                }
            }
        }
        else {
            Write-Warning 'No cChocoEx Package files found'
        }
    }
    
    end {
        $array
    }
}