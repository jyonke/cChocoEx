<#
.SYNOPSIS
Returns Chocolatey Feature DSC Configuration Status in cChocoEx
.DESCRIPTION
Returns Chocolatey Feature DSC Configuration Status in cChocoEx as a PowerShell Custom Object
#>
function Test-cChocoExFeature {
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
        $ModulePath = (Join-Path "$ModuleBase\DSCResources" "cChocoFeature")
        Import-Module $ModulePath    

        if ($Path) {
            $cChocoExFeatureFile = $Path
        }
        else {
            $cChocoExFeatureFile = (Get-ChildItem -Path $cChocoExConfigurationFolder -Filter 'features.psd1').FullName
        }
    }
    
    process {
        if ($cChocoExFeatureFile) {
            $ConfigImport = Import-PowerShellDataFile -Path $cChocoExFeatureFile
            $Configurations = $ConfigImport | ForEach-Object { $_.Values }

            $Configurations | ForEach-Object {
                $DSC = $null
                $Configuration = $_
                $Object = [PSCustomObject]@{
                    FeatureName = $Configuration.FeatureName
                    DSC         = $null
                    Ensure      = $Configuration.Ensure
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
        Remove-Module "cChocoFeature"

    }
    
    end {
        $Status
    }
    
}