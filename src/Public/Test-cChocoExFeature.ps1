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
        $ModulePath = (Join-Path $Global:ModuleBase "cChocoFeature")
        Import-Module $ModulePath    

        if ($Path) {
            $cChocoExFeatureFile = $Path
        }
        else {
            $cChocoExFeatureFile = (Join-Path -Path $Global:cChocoExConfigurationFolder -ChildPath 'features.psd1')
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
                    PSTypeName  = 'cChocoExFeature'
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