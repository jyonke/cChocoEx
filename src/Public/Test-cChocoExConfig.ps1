<#
.SYNOPSIS
Returns Chocolatey Configuration DSC Configuration Status in cChocoEx
.DESCRIPTION
Returns Chocolatey Configuration DSC Configuration Status in cChocoEx as a PowerShell Custom Object
#>
function Test-cChocoExConfig {
    [CmdletBinding()]
    param (
        # Path
        [Parameter()]
        [string]
        $Path
    )
    
    begin {
        [array]$Status = @()
        $ChocolateyInstall = $env:ChocolateyInstall
        $cChocoExDataFolder = (Join-Path -Path $env:ProgramData -ChildPath 'cChocoEx')
        $cChocoExConfigurationFolder = (Join-Path -Path $cChocoExDataFolder -ChildPath 'config')
        $ModuleBase = (Get-Module -Name 'cChoco' -ListAvailable -ErrorAction Stop | Sort-Object -Property Version | Select-Object -Last 1).ModuleBase
        $ModulePath = (Join-Path "$ModuleBase\DSCResources" "cChocoConfig")
        Import-Module $ModulePath    

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
                $DSC = $null
                $Configuration = $_
                $Object = [PSCustomObject]@{
                    ConfigName = $Configuration.ConfigName
                    DSC        = $null
                    Ensure     = $Configuration.Ensure
                    Value      = $Configuration.Value
                }
                
                $DSC = Test-TargetResource @Configuration
                $Object.DSC = $DSC
                $Status += $Object
            }
        }
        else {
            Write-Warning 'No cChocoEx Configuration file found'
        }
        #Remove Module for Write-Host limitations
        Remove-Module "cChocoConfig"

    }
    
    end {
        $Status
    }
    
}