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
        $Path,
        # Return True or False for all tests
        [Parameter()]
        [switch]
        $Quiet
    )
    
    begin {
        [array]$Status = @()
        $ChocolateyInstall = $env:ChocolateyInstall
        $cChocoExDataFolder = (Join-Path -Path $env:ProgramData -ChildPath 'cChocoEx')
        $cChocoExConfigurationFolder = (Join-Path -Path $cChocoExDataFolder -ChildPath 'config')
        $ModulePath = (Join-Path $ModuleBase "cChocoFeature")
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
        if ($Quiet) {
            if ($Status | Where-Object { $_.DSC -eq $False }) {
                return $False
            }
            else {
                return $True
            }
        }
        else {
            return $Status
        }
    }
    
}